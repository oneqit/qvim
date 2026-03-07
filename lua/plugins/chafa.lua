-- chafa.nvim: Image viewer using chafa (works over SSH)
return {
  dir = ".",
  name = "chafa.nvim",
  event = "VeryLazy",
  config = function()
    local static_formats = { "png", "jpg", "jpeg", "bmp", "webp", "tiff", "avif" }
    local animated_formats = { "gif", "mp4", "mov", "avi", "mkv", "webm" }
    local all_formats = vim.list_extend(vim.list_extend({}, static_formats), animated_formats)
    local pattern = "*." .. table.concat(all_formats, ",*.")

    local animated_set = {}
    for _, fmt in ipairs(animated_formats) do
      animated_set[fmt] = true
    end

    local function open_image(file)
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)
      local ext = vim.fn.fnamemodify(file, ":e"):lower()

      local cmd = { "chafa", "--size", width .. "x" .. height }
      if not animated_set[ext] then
        table.insert(cmd, "--animate")
        table.insert(cmd, "off")
      end
      table.insert(cmd, file)

      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " " .. vim.fn.fnamemodify(file, ":t") .. " ",
        title_pos = "center",
      })

      vim.fn.termopen(cmd, {
        on_exit = function()
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
              vim.bo[buf].modified = false
            end
          end)
        end,
      })
      vim.cmd("startinsert")

      for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set({ "n", "t" }, key, function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end, { buffer = buf, silent = true })
      end
    end

    vim.api.nvim_create_autocmd("BufReadCmd", {
      group = vim.api.nvim_create_augroup("chafa_image_viewer", { clear = true }),
      pattern = pattern,
      callback = function(ev)
        local file = vim.fn.expand("<afile>:p")
        vim.bo[ev.buf].buftype = "nofile"
        vim.bo[ev.buf].swapfile = false
        vim.bo[ev.buf].buflisted = false
        vim.bo[ev.buf].bufhidden = "wipe"
        -- Restore the previous buffer in the current window
        local alt = vim.fn.bufnr("#")
        if alt ~= -1 and alt ~= ev.buf and vim.api.nvim_buf_is_valid(alt) then
          vim.api.nvim_win_set_buf(0, alt)
        end
        open_image(file)
      end,
    })

    vim.api.nvim_create_user_command("ChafaOpen", function(opts)
      open_image(vim.fn.fnamemodify(opts.args, ":p"))
    end, { nargs = 1, complete = "file" })
  end,
}
