return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local kulala_cond = function()
      return (vim.bo.filetype == "http" or vim.bo.filetype == "rest")
        and package.loaded["kulala"] ~= nil
    end

    local kulala_env_file = {
      function()
        local ok, kulala = pcall(require, "kulala")
        if not ok then return nil end
        local fs = require("kulala.utils.fs")
        local env_file = fs.find_file_in_parent_dirs("http-client.env.json")
        return " " .. (env_file and vim.fn.fnamemodify(env_file, ":~:.") or "no env file")
      end,
      cond = kulala_cond,
    }

    local kulala_env = {
      function()
        local ok, kulala = pcall(require, "kulala")
        if not ok then return nil end
        return "« " .. kulala.get_selected_env() .. " »"
      end,
      cond = kulala_cond,
    }

    require("lualine").setup({
      options = {
        theme = "auto",
      },
      winbar = {
        lualine_a = { kulala_env },
        lualine_b = { kulala_env_file },
      },
      inactive_winbar = {
        lualine_a = { kulala_env },
        lualine_b = { kulala_env_file },
      },
    })
  end,
}
