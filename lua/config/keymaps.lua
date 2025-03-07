local map = vim.keymap.set

-- General
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map("i", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

map({ "n", "i", "s" }, "<esc>", function()
  vim.cmd("nohlsearch")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Pane
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Pane navigation for macOS
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Pane navigation for Linux/Windows
map("n", "<C-S-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Indent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal
map("n", "<leader>tb", function()
  Snacks.terminal(nil, { env = { NVIM_TERMINAL_BOTTOM = "true" }, win = { position = "bottom" } })
end, { desc = "Terminal (Bottom)" })
map("n", "<leader>tf", function()
  Snacks.terminal(nil, { env = { NVIM_TERMINAL_FLOAT = "true" }, win = { position = "float", border = "rounded" } })
end, { desc = "Terminal (Float)" })
map("n", "<leader>tB", function()
  Snacks.terminal(
    nil,
    { env = { NVIM_TERMINAL_BOTTOM = "true" }, win = { position = "bottom" }, cwd = vim.fn.getcwd() }
  )
end, { desc = "Terminal (Bottom, cwd)" })
map("n", "<leader>tF", function()
  Snacks.terminal(
    nil,
    { env = { NVIM_TERMINAL_FLOAT = "true" }, win = { position = "float", border = "rounded" }, cwd = vim.fn.getcwd() }
  )
end, { desc = "Terminal (Float, cwd)" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- Buffer
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- Diagnostics
map("n", "<leader>K", function()
  -- call twice for focusing the floating window
  vim.diagnostic.open_float({ border = "rounded" })
  vim.diagnostic.open_float({ border = "rounded" })
end, { desc = "Popup Diagnostics" })
