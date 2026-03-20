return {
  "akinsho/bufferline.nvim",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {},
  config = function()
    -- Snacks.bufdelete 사용 (마지막 버퍼일 때 빈 버퍼 생성)
    local function close_buffer(bufnum)
      local buf = bufnum or vim.api.nvim_get_current_buf()
      local listed = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
      if #listed > 1 then
        Snacks.bufdelete({ buf = buf })
      else
        local new_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(0, new_buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, {})
        end
      end
    end

    require("bufferline").setup({
      options = {
        close_command = close_buffer,
        right_mouse_command = close_buffer,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })
  end,
}
