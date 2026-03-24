# qvim
## Installation
### Install Neovim
<https://github.com/neovim/neovim>
### Install dependencies
- ripgrep (required for snacks picker grep)
    - <https://github.com/BurntSushi/ripgrep>
- fd (required for snacks picker files/explorer)
    - <https://github.com/sharkdp/fd>
- tree-sitter-cli (for compiling treesitter parsers)
    - <https://github.com/nvim-treesitter/nvim-treesitter>
- imagemagick with librsvg support (for image.nvim with SVG)
    - <https://github.com/3rd/image.nvim?tab=readme-ov-file#imagemagick>
    - macOS: `brew install imagemagick-full && brew link imagemagick-full`
### Install qvim
```shell
git clone https://github.com/oneqit/qvim.git ~/.config/nvim
```
## Shortcuts
### Basic
| keymap | description |
|--------|------|
| `<leader><space>` | smart find files |
| `<leader>e` | toggle [e]xplorer |
| `<leader>E` | reveal current file in explorer |
| `<leader>ff` | [f]ind [f]iles |
| `<leader>fg` | [f]ind [g]it files |
| `<leader>/` | grep |
| `<leader>,` | find buffers |
| `<leader>fr` | [f]ind [r]ecent |
| `<leader>:` | command history |
| `<leader>qq` | [q]uit |
| `<leader>qQ` | [q]uit without saving |
| `<leader>?` | show keymaps (which-key) |
| `Ctrl + hjkl` | navigate pane |
| `Ctrl + s` | [s]ave |

### Explorer
| keymap | description |
|--------|------|
| `hjkl` | navigate |
| `l` | open file/expand directory |
| `h` | close node |
| `Y` | cop[Y] file path |
| `z/Z` | close/expand all subnodes |
| `<leader>z/<leader>Z` | close/expand all nodes |
| `<` / `>` / `=` | decrease/increase/reset width |
| `v` | toggle mark |
| `<esc>` | unmark all |
| `D` | delete marked files |
| `ga` | [g]it [a]dd file |
| `gu` | [g]it [u]nstage file |
| `gr` | [g]it [r]evert file |
| `gc` | [g]it [c]ommit |

### Buffer
| keymap | description |
|--------|------|
| `Shift + h/l` | previous/next buffer |
| `<leader>bd` | [b]uffer: [d]elete  |
| `<leader>bD` | [b]uffer: force [D]elete |
| `<leader>bo` | [b]uffer: delete [o]thers |
| `<leader>bn` | [b]uffer: [n]ew |

### Terminal
| keymap | description |
|--------|------|
| `<leader>tf` | open a [t]erminal with [f]loating window |
| `<leader>tF` | open a [t]erminal with [F]loating window (cwd) |
| `Ctrl + t` | open a [t]erminal with floating window |
| `<esc><esc>` | turn terminal mode to normal mode |

### Git
| keymap | description |
|--------|------|
| `<leader>gg` | lazy[g]it |
| `<leader>gs` | [g]it [s]tatus |
| `<leader>gb` | [g]it [b]ranches |
| `<leader>gl` | [g]it [l]og |
| `<leader>gd` | [g]it [d]iff (hunks) |
| `<leader>gS` | [g]it [S]tash |
| `<leader>gB` | [g]it [B]rowse |
| `]h / [h` | next/previous hunk |
| `<leader>hs` | [h]unk [s]tage |
| `<leader>hr` | [h]unk [r]eset |
| `<leader>hS` | [h]unk [S]tage buffer |
| `<leader>hR` | [h]unk [R]eset buffer |
| `<leader>hp` | [h]unk [p]review |
| `<leader>hi` | [h]unk preview [i]nline |
| `<leader>hb` | [h]unk [b]lame line |
| `<leader>hd` | [h]unk [d]iff this |

### Search
| keymap | description |
|--------|------|
| `<leader>sb` | [s]earch [b]uffer lines |
| `<leader>sB` | [s]earch grep open [B]uffers |
| `<leader>sg` | [s]earch [g]rep |
| `<leader>sw` | [s]earch [w]ord under cursor |
| `<leader>s"` | [s]earch registers |
| `<leader>s/` | [s]earch history |
| `<leader>sa` | [s]earch [a]utocmds |
| `<leader>sc` | [s]earch [c]ommand history |
| `<leader>sC` | [s]earch [C]ommands |
| `<leader>sk` | [s]earch [k]eymaps |
| `<leader>su` | [s]earch [u]ndo history |

### Code
| keymap | description |
|--------|------|
| `gd` | [g]oto [d]efinition |
| `gD` | [g]oto [d]eclaration |
| `Ctrl + t` | go back |
| `<leader>cf` | [c]ode [f]ormatting |
| `<leader>cF` | [c]ode [F]ormatting (all formatters) |
| `<leader>ca` | [c]ode [a]ction |
| `<leader>cd` | [c]ode [d]iagnostics on cursor |
| `K` | cursor hover for hint |
| `gcc` | comment out |
| `gc` | comment out (visual mode) |
| `]]` / `[[` | next/previous reference |

### REST/HTTP (Kulala)
| keymap | description |
|--------|------|
| `<leader>Rs` | [R]est: [s]end request |
| `<leader>Ra` | [R]est: send [a]ll requests |
| `<leader>Rb` | [R]est: open scratchpad ([b]uffer) |
| `<leader>Re` | [R]est: select [e]nvironment |

### Theme
| keymap | description |
|--------|------|
| `<leader>tr` | [t]heme [r]otate |
| `<leader>uC` | pick [C]olorscheme |

### UI Toggles
| keymap | description |
|--------|------|
| `<leader>ul` | toggle [l]ine numbers |
| `<leader>uL` | toggle relative [L]ine numbers |
| `<leader>uD` | toggle [D]im mode |
| `<leader>uh` | toggle inlay [h]ints |
| `<leader>uT` | toggle [T]reesitter |
| `<leader>ug` | toggle indent [g]uides |
| `<leader>uc` | toggle [c]sv view |
| `<leader>um` | toggle render [m]arkdown |

### Utilities
| keymap | description |
|--------|------|
| `<leader>.` | toggle scratch buffer |
| `<leader>S` | [S]elect scratch buffer |
| `<leader>n` | [n]otification history |
| `<leader>un` | dismiss all [n]otifications |
