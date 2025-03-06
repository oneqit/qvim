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
| `<leader>e` | Toggle Explorer |
| `<leader>t` | (Group) Terminal |
| `Ctrl + s` | Save |
| `<leader>ff` | [f]ind [f]iles |
| `<leader>fg` | [f]ind with [g]rep |
| `<leader>fb` | [f]ind in [b]uffers  |
| `<leader>fh` | [f]inder [h]elps |
| `<leader>qq` | [q]uit |

### Explorer
| keymap | description |
|--------|------|
| `Ctrl + v` | Open a file by splitting it vertically |
| `Ctrl + h` | Open a file by splitting it horizontally |

### Buffer
| keymap | description |
|--------|------|
| `<leader>b` | (Group) related to [b]uffer |
| `<leader>bd` | [b]uffer [d]eletion |

### Terminal
| keymap | description |
|--------|------|
| `<leader>t` | (Group) related to [t]erminal |

### Code
| keymap | description |
|--------|------|
| `<leader>c` | (Group) related to [c]ode |
