return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  opts = {
    timeout = 3000,
    render = "default",
    stages = "static",
    top_down = true,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
    end,
  },
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify
  end,
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<leader>fn",
      function()
        require("telescope").extensions.notify.notify()
      end,
      desc = "Notification History",
    },
  },
}
