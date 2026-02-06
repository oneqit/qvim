return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]h", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "gitsigns: next hunk" })

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[h", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "gitsigns: prev hunk" })

        -- Actions
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "gitsigns: [h]unk [s]tage" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "gitsigns: [h]unk [r]eset" })

        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "gitsigns: [h]unk [s]tage" })

        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "gitsigns: [h]unk [r]eset" })

        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "gitsigns: [h]unk buffer" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "gitsigns: [h]unk [R]eset buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "gitsigns: [h]unk [p]review hunk" })
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "gitsigns: [h]unk preview hunk [i]nline" })

        map("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, { desc = "gitsigns: [h]unk stage" })

        map("n", "<leader>hd", gitsigns.diffthis, { desc = "gitsigns: [h]unk [d]iff this" })

        -- map("n", "<leader>hD", function()
        --   gitsigns.diffthis("~")
        -- end)
        --
        -- map("n", "<leader>hQ", function()
        --   gitsigns.setqflist("all")
        -- end)
        -- map("n", "<leader>hq", gitsigns.setqflist)
        --
        -- Toggles
        map("n", "<leader>gB", gitsigns.blame, { desc = "gitsigns: [g]it full [B]lame" })
        -- map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
        -- map("n", "<leader>td", gitsigns.toggle_deleted)
        -- map("n", "<leader>tw", gitsigns.toggle_word_diff)
        --
        -- -- Text object
        -- map({ "o", "x" }, "ih", gitsigns.select_hunk)
      end,
    })
  end,
}
