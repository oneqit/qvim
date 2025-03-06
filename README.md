# qvim
## Installation
### Install Neovim
<https://github.com/neovim/neovim>
### Install dependencies
- ripgrep
    - <https://github.com/BurntSushi/ripgrep>
- fd (only macOS)
    ```zsh
    brew install fd
    ```
### Pull
```shell
git clone https://github.com/oneqit/qvim.git ~/.config/nvim
```
## Shortcuts
### Basic
| keymap | description |
|--------|------|
| `<leader>e` | toggle [e]xplorer |
| `<leader>ff` | [f]ind [f]iles |
| `<leader>fg` | [f]ind with [g]rep |
| `<leader>fb` | [f]ind in [b]uffers  |
| `<leader>fh` | [f]inder [h]elps |
| `<leader>qq` | [q]uit |
| `Ctrl + hjkl` | navigate pane |
| `Ctrl + s` | [s]ave |

### Explorer
| keymap | description |
|--------|------|
| `hjkl` | navigate |
| `i` | [i]nsert filename to find |
| `Ctrl + v` | open a file by splitting it [v]ertically |
| `Ctrl + h` | open a file by splitting it [h]orizontally |

### Buffer
| keymap | description |
|--------|------|
| `<leader>b` | (Group) related to [b]uffer |
| `<leader>bd` | [b]uffer: [d]elete  |
| `<leader>bo` | [b]uffer: delete [o]thers |

### Terminal
| keymap | description |
|--------|------|
| `<leader>t` | (Group) related to [t]erminal |
| `<leader>tb` | open a [t]erminal at the bottom |
| `<leader>tf` | open a [t]erminal with floating window |
| `<esc><esc>` | turn terminal mode to normal mode (double tab quickly) |

### Code
| keymap | description |
|--------|------|
| `<leader>c` | (Group) related to [c]ode |
| `<leader>cf` | [c]ode [f]ormatting |
| `<leader>ca` | [c]ode [a]ction |
| `<leader>K` | cursor hover for diagnostics |
| `K` | cursor hover for hint |
| `q` | [q]uit floating window by cursoe hover |
| `gcc` | comment out |
| `gc` | comment out (visual mode) |
