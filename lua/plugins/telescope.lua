local map = vim.keymap.set

return {
    {
        "nvim-telescope/telescope.nvim", tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            map("n", "<leader>ff", builtin.find_files)
            map("n", "<leader>fg", builtin.live_grep)
            map("n", "<leader>fo", builtin.oldfiles)
            map("n", "<leader>fb", builtin.buffers)
            map("n", "<leader>fh", builtin.help_tags)
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {}
                    }
                }
            })
            require("telescope").load_extension("ui-select")
        end
    }
}
