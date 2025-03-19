local map = vim.keymap.set

-- General
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map("i", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
map("n", "<leader>qQ", "<cmd>q!<cr>", { desc = "Quit Without Saving" })

map({ "n", "i", "s" }, "<esc>", function()
  vim.cmd("nohlsearch")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Pane
map({ "n", "v" }, "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map({ "n", "v" }, "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map({ "n", "v" }, "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map({ "n", "v" }, "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Pane resize for macOS
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Pane resize for Linux/Windows
map("n", "<C-S-K>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-J>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-H>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-L>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Indent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Buffer
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Diagnostics
map("n", "<leader>cd", function()
  vim.diagnostic.open_float({ border = "rounded", scope = "cursor", focusable = false })
end, { desc = "[c]ode [d]iagnostics on cursor" })

