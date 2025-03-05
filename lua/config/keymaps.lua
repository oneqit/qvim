local map = vim.keymap.set

-- General
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

map({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	-- LazyVim.cmp.actions.snippet_stop()
	return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Pane
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

map("n", "<C-S-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Indent
map("v", "<", "<gv")
map("v", ">", ">gv")
