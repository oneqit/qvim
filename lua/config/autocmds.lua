-- Indent
vim.api.nvim_create_augroup("FileTypeTabStop", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = { "lua", "javascript", "typescript" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = "go",
  callback = function()
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.noexpandtab = true
  end,
})

vim.api.nvim_create_autocmd("WinEnter", {
    pattern = "*",
    callback = function()
        local win = vim.api.nvim_get_current_win() -- 현재 창 가져오기
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            -- 현재 창이 floating window라면 ESC로 닫기
            vim.keymap.set("n", "<Esc>", function()
                vim.api.nvim_win_close(win, true)
            end, { noremap = true, silent = true })
        end
    end,
})
