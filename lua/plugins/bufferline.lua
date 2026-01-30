return {
  "akinsho/bufferline.nvim",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>bd", "<cmd>bp|bd #<cr>", desc = "Delete Buffer" },
    {
      "<leader>bo",
      function()
        local current = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
            local buftype = vim.bo[buf].buftype
            if buftype == "" then
              vim.api.nvim_buf_delete(buf, { force = false })
            end
          end
        end
      end,
      desc = "Delete Other Buffers",
    },
  },
  config = function()
    require("bufferline").setup({
      options = {
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
