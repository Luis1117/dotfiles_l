local function open_with_sioyek(file, lnum)
  local abs = vim.fn.fnamemodify(file, ":p")
  local page = math.max(1, math.floor((tonumber(lnum) or 1) / 50))
  vim.fn.jobstart({ "sioyek", abs, "--page", tostring(page) }, { detach = true })
end

local function rga_search(query)
  query = query or vim.fn.input("RGA busca: ")
  if not query or query == "" then return end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local cmd = {
    "rga", "--vimgrep", "--hidden", "--follow",
    "--glob", "!*.git/*", query, vim.fn.getcwd(),
  }

  pickers.new({}, {
    prompt_title = "RGA: " .. query,
    finder = finders.new_oneshot_job(cmd, {
      entry_maker = function(line)
        local filename, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
        if not filename then return nil end
        return {
          value = line,
          display = filename .. ":" .. lnum .. " " .. text,
          ordinal = line,
          filename = filename,
          lnum = tonumber(lnum),
          col = tonumber(col),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then return end
        if entry.filename:match("%.pdf$") then
          open_with_sioyek(entry.filename, entry.lnum)
        else
          vim.cmd("edit " .. vim.fn.fnameescape(entry.filename))
          vim.api.nvim_win_set_cursor(0, { entry.lnum or 1, math.max((entry.col or 1) - 1, 0) })
        end
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", "<leader>fp", rga_search, { desc = "RGA buscar em PDFs/docs" })
vim.api.nvim_create_user_command("Rga", function(opts) rga_search(opts.args ~= "" and opts.args or nil) end, { nargs = "*" })

