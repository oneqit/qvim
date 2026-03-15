---
name: check-plugin-updates
description: lazy-lock.json의 git diff를 분석하여 업데이트된 플러그인들의 GitHub 커밋 내역을 조회합니다.
allowed-tools: Bash, Read
---

lazy-lock.json에서 변경된 플러그인의 업데이트 내역을 확인합니다.

## 절차

1. `git diff lazy-lock.json`으로 변경된 플러그인과 old/new 커밋 SHA를 추출한다.
2. 각 플러그인의 GitHub 저장소를 파악한다. lazy-lock.json의 플러그인 이름과 실제 GitHub 저장소 매핑은 lazy.nvim 플러그인 스펙 파일들에서 확인한다.
3. 각 플러그인에 대해 GitHub Compare API를 curl로 호출하여 커밋 목록을 가져온다:
   ```
   curl -s "https://api.github.com/repos/{owner}/{repo}/compare/{old_sha}...{new_sha}" | jq -r '.commits[] | "\(.sha[0:7]) \(.commit.message | split("\n")[0])"'
   ```
   - `gh` CLI는 사내 GitHub로 연결되므로 사용하지 않는다. 반드시 `curl`을 사용한다.
   - 여러 플러그인을 병렬로 조회하여 속도를 높인다.
4. 결과를 플러그인별로 테이블 형태로 정리하여 보여준다.
5. breaking change(`!` 표시 또는 `BREAKING` 키워드)가 있으면 경고를 표시한다.
