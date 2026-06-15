return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = "VeryLazy",
  config = function()
    require("ufo").setup({
      -- markdown은 들여쓰기 기준(bullet 하위 접기), 그 외는 LSP → indent 폴백
      provider_selector = function(_, filetype, _)
        if filetype == "markdown" then
          return { "indent" }
        end
        return { "lsp", "indent" }
      end,
    })
  end,
  keys = {
    { "zR", function() require("ufo").openAllFolds() end, desc = "Open All Folds" },
    { "zM", function() require("ufo").closeAllFolds() end, desc = "Close All Folds" },
    { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek Folded Lines" },
  },
}
