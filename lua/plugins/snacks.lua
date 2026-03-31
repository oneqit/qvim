return {
  "folke/snacks.nvim",
  enabled = true,
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    image = {
      enabled = true,
      cache = "/tmp/neovim-snacks-image",
      formats = {
        "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif",
        "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns", "svg",
      },
    },
    words = { enabled = true },
    styles = {
      notification_history = {
        wo = { wrap = true },
      },
    },
  },
	-- stylua: ignore
  keys = {
    -- Other
    { "<leader>td", function() Snacks.dashboard() end, desc = "Snacks: Open dashboard" },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Snacks: Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Snacks: Select Scratch Buffer" },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Snacks: Notification History" },
    { "<leader>bd", function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].modified then
        vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
        return
      end
      local listed = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
      if #listed > 1 then
        Snacks.bufdelete()
      else
        local new_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(0, new_buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, {})
        end
      end
    end, desc = "Snacks: Delete Buffer" },
    { "<leader>bD", function()
      local buf = vim.api.nvim_get_current_buf()
      local listed = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
      if #listed > 1 then
        vim.cmd("bp|bd! #")
      else
        local new_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(0, new_buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end, desc = "Snacks: Force Delete Buffer" },
    { "<leader>bn", "<cmd>enew<cr>", desc = "New Buffer" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
    -- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Snacks: Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Snacks: Git Browse", mode = { "n", "v" } },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Snacks: Lazygit" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Snacks: Dismiss All Notifications" },
    { "<leader>tf", function()
      Snacks.terminal(
        nil, {
          env = { NVIM_TERMINAL_FLOAT = "true" },
          win = { position = "float", border = "rounded" }
        }
      )
      end, desc = "Terminal (Float)" },
    { "<C-t>", function()
      Snacks.terminal(
        nil, {
          env = { NVIM_TERMINAL_FLOAT = "true" },
          win = { position = "float", border = "rounded" }
        }
      )
      end, desc = "Terminal (Float)" },
    { "<leader>tF", function()
      Snacks.terminal(
        nil, {
          env = { NVIM_TERMINAL_FLOAT = "true" },
          win = { position = "float", border = "rounded" }, cwd = vim.fn.getcwd()
        }
      )
      end, desc = "Terminal (Float, cwd)" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Snacks: Next Reference", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Snacks: Prev Reference", mode = { "n", "t" } },
    {
      "<leader>N",
      desc = "Snacks: Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
    { "<leader>iC", function()
      local cache = "/tmp/neovim-snacks-image"
      vim.fn.delete(cache, "rf")
      vim.notify("Image cache cleared", vim.log.levels.INFO)
    end, desc = "Clear [i]mage [C]ache" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
