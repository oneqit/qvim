local g = vim.g

-- leader key
g.mapleader = " "
g.maplocalleader = " "

local opt = vim.opt

-- tab/indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- visual
opt.wrap = false
opt.number = true
opt.signcolumn = "yes"
opt.scrolloff = 4
opt.termguicolors = true

-- folding
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.lsp.foldexpr()"

-- etc
opt.encoding = "UTF-8"
opt.mouse = "a"
opt.updatetime = 300
opt.clipboard = "unnamedplus"

-- copilot
opt.completeopt = { "noinsert" }

