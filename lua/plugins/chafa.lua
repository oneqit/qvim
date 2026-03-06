-- chafa.nvim: Image viewer using chafa (works over SSH)
return {
  dir = ".",
  name = "chafa.nvim",
  event = "VeryLazy",
  config = function()
    local image_formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "avif" }
    local pattern = "*." .. table.concat(image_formats, ",*.")

    local chafa_bufs = {} -- { [buf] = { file = string, chan = number, job = number? } }

    local function render_image(buf, file)
      local win = vim.fn.bufwinid(buf)
      if win == -1 then
        return
      end

      local entry = chafa_bufs[buf]
      local chan = entry and entry.chan

      -- Kill previous job if still running
      if entry and entry.job then
        pcall(vim.fn.jobstop, entry.job)
      end

      -- Close previous terminal channel, clear buffer, and open fresh one
      if chan then
        pcall(vim.fn.chanclose, chan)
        pcall(function()
          vim.bo[buf].modifiable = true
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
        end)
      end
      -- Save window options before nvim_open_term (TermOpen resets them)
      local saved_opts = {
        number = vim.wo[win].number,
        relativenumber = vim.wo[win].relativenumber,
        signcolumn = vim.wo[win].signcolumn,
        foldcolumn = vim.wo[win].foldcolumn,
        statuscolumn = vim.wo[win].statuscolumn,
      }
      chan = vim.api.nvim_open_term(buf, {})
      -- Restore window options
      for k, v in pairs(saved_opts) do
        vim.wo[win][k] = v
      end
      chafa_bufs[buf] = { file = file, chan = chan }

      -- Calculate size AFTER nvim_open_term + option restore
      local info = vim.fn.getwininfo(win)[1]
      local width = info.width - info.textoff
      local height = info.height

      local job = vim.fn.jobstart({ "chafa", "--animate", "off", "--size", width .. "x" .. height, file }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data then
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(buf) then
                return
              end
              vim.api.nvim_chan_send(chan, table.concat(data, "\r\n"))
            end)
          end
        end,
        on_exit = function()
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
              vim.bo[buf].modified = false
            end
          end)
        end,
      })
      chafa_bufs[buf].job = job
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
        vim.bo[ev.buf].filetype = "image"

        -- Close image window with q
        vim.keymap.set("n", "q", function()
          local win = vim.api.nvim_get_current_win()
          if #vim.api.nvim_list_wins() > 1 then
            vim.api.nvim_win_close(win, true)
          else
            vim.cmd("enew")
          end
        end, { buffer = ev.buf, silent = true })


        -- Render after window layout is settled
        vim.api.nvim_create_autocmd("BufWinEnter", {
          buffer = ev.buf,
          once = true,
          callback = function()
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(ev.buf) then
                render_image(ev.buf, file)
              end
            end)
          end,
        })
      end,
    })

    vim.api.nvim_create_autocmd("WinResized", {
      group = vim.api.nvim_create_augroup("chafa_image_resize", { clear = true }),
      callback = function()
        for _, win in ipairs(vim.v.event.windows) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local entry = chafa_bufs[buf]
            if entry then
              render_image(buf, entry.file)
            end
          end
        end
      end,
    })

    -- Auto-close image windows when entering a non-image buffer
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("chafa_image_autoclose", { clear = true }),
      callback = function(ev)
        if chafa_bufs[ev.buf] then
          return
        end
        vim.schedule(function()
          for buf, _ in pairs(chafa_bufs) do
            if vim.api.nvim_buf_is_valid(buf) then
              local img_win = vim.fn.bufwinid(buf)
              if img_win ~= -1 then
                local normal_wins = 0
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                  if vim.api.nvim_win_get_config(w).relative == "" then
                    normal_wins = normal_wins + 1
                  end
                end
                if normal_wins > 2 then
                  vim.api.nvim_win_close(img_win, true)
                end
              end
            end
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
      group = vim.api.nvim_create_augroup("chafa_image_cleanup", { clear = true }),
      callback = function(ev)
        chafa_bufs[ev.buf] = nil

      end,
    })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
      group = vim.api.nvim_create_augroup("chafa_image_write", { clear = true }),
      pattern = pattern,
      callback = function(ev)
        vim.bo[ev.buf].modified = false
      end,
    })
  end,
}
