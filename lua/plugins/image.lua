return {
  "3rd/image.nvim",
  build = false,
  config = function(_, opts)
    require("image").setup(opts)
    -- Clear images on exit to prevent ghosting in terminal
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        require("image").clear()
      end,
    })
  end,
  opts = {
    processor = "magick_cli",
    backend = "kitty",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" },
      },
      neorg = {
        enabled = true,
        filetypes = { "norg" },
      },
    },
    max_width = nil,
    max_height = nil,
    max_height_window_percentage = 50,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.svg" },
  },
}
