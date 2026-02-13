# qvim
## Installation
### Install Neovim
<https://github.com/neovim/neovim>
### Install dependencies
- ripgrep (for live grep)
    - <https://github.com/BurntSushi/ripgrep>
- fd (for finding files on snacks picker)
    - <https://github.com/sharkdp/fd>
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
| `<leader>qq` | [q]uit |
| `Ctrl + hjkl` | navigate pane |
| `Ctrl + s` | [s]ave |

### Explorer
| keymap | description |
|--------|------|
| `hjkl` | navigate |
| `l` | open file/expand directory |
| `h` | close node |
| `Y` | cop[Y] file path |
| `z/Z` | expand/close all subnodes |

### Buffer
| keymap | description |
|--------|------|
| `Shift + h/l` | previous/next buffer |
| `<leader>bd` | [b]uffer: [d]elete  |
| `<leader>bo` | [b]uffer: delete [o]thers |

### Terminal
| keymap | description |
|--------|------|
| `<leader>tf` | open a [t]erminal with [f]loating window |
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
| `]h / [h` | next/previous hunk |
| `<leader>hs` | [h]unk [s]tage |
| `<leader>hr` | [h]unk [r]eset |
| `<leader>hp` | [h]unk [p]review |
| `<leader>hb` | [h]unk [b]lame line |
| `<leader>hd` | [h]unk [d]iff this |

### Code
| keymap | description |
|--------|------|
| `gd` | [g]oto [d]efinition |
| `gD` | [g]oto [d]eclaration |
| `Ctrl + t` | go back |
| `<leader>cf` | [c]ode [f]ormatting |
| `<leader>ca` | [c]ode [a]ction |
| `<leader>cd` | [c]ode [d]iagnostics on cursor |
| `K` | cursor hover for hint |
| `gcc` | comment out |
| `gc` | comment out (visual mode) |

### Theme
| keymap | description |
|--------|------|
| `<leader>tr` | [t]heme [r]otate |
| `<leader>uC` | pick [C]olorscheme |

### UI Toggles
| keymap | description |
|--------|------|
| `<leader>us` | toggle [s]pelling |
| `<leader>uw` | toggle [w]rap |
| `<leader>ul` | toggle [l]ine numbers |
| `<leader>uL` | toggle relative [L]ine numbers |
| `<leader>ud` | toggle [d]iagnostics |
| `<leader>uh` | toggle inlay [h]ints |
| `<leader>ub` | toggle dark/light [b]ackground |
