local opt = vim.opt

-- tab/indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- visual
opt.number = true
opt.signcolumn = "yes"
-- opt.termguicolors = true

-- etc
opt.encoding = "UTF-8"
opt.scrolloff = 4
opt.mouse:append("a")

