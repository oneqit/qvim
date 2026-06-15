#!/usr/bin/env bash
# Auto pull, commit, push for a git repo. Invoked by the qvim autosync plugin.
# Always pulls; commits if dirty; pushes if there are local commits to send.
#
# Usage: sync.sh <repo-dir>
set -uo pipefail

VERSION="2"
REPO="${1:-}"
LOG="${HOME}/Library/Logs/autosync.log"

if [ -z "$REPO" ]; then
  echo "usage: $0 <repo-dir>" >&2
  exit 2
fi

mkdir -p "$(dirname "$LOG")"
name="$(basename "$REPO")"
ts() { date "+%Y-%m-%d %H:%M:%S"; }
log() { echo "[$(ts)] [$name] $*" >> "$LOG"; }

cd "$REPO" 2>/dev/null || { log "cd failed: $REPO"; exit 1; }

# Skip if a rebase/merge is in progress.
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ]; then
  log "skip: rebase/merge in progress"
  exit 0
fi

# Require an upstream so the push target is unambiguous. Operates on whatever
# tracked branch is currently checked out.
if ! git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  log "skip: no upstream configured for current branch"
  exit 0
fi

# 1) Always pull first to pick up remote changes from other machines.
if ! git pull --rebase --autostash >>"$LOG" 2>&1; then
  log "pull --rebase failed (likely conflict); aborting rebase"
  git rebase --abort >>"$LOG" 2>&1 || true
  exit 1
fi

# 2) Commit local changes if any.
if [ -n "$(git status --porcelain)" ]; then
  git add -A >>"$LOG" 2>&1
  msg="auto: $(date '+%Y-%m-%d %H:%M:%S')

Auto-Sync: qvim autosync v${VERSION}"
  if ! git commit -m "$msg" >>"$LOG" 2>&1; then
    log "commit failed"
    exit 1
  fi
  log "committed"
fi

# 3) Push if there are local commits ahead of upstream.
if [ -n "$(git rev-list '@{u}..HEAD' 2>/dev/null)" ]; then
  if ! git push >>"$LOG" 2>&1; then
    log "push failed"
    exit 1
  fi
  log "pushed"
fi
