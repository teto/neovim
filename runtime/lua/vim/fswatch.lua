local a = vim.api
local log = require 'vim.lsp.log'

-- 4. Try editing the file from another text editor.
-- 5. Observe that the file reloads in Nvim (because on_change() calls
--    |:checktime|). >
-- if for a folderm then we need sthg else
-- local nvim_err_writeln, nvim_buf_get_lines, nvim_command, nvim_buf_get_option
--   = vim.api.nvim_err_writeln, vim.api.nvim_buf_get_lines, vim.api.nvim_command, vim.api.nvim_buf_get_option
-- local uv = vim.loop


-- local w = vim.loop.new_fs_event()

-- vim.api.nvim_command(
-- 	"command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")

local M = {
  -- on=vim._ts_add_language,
}

local Watcher = {}
Watcher.__index = Watcher

-- local function file_id_new()
--   local info = ffi.new('FileID[1]')
--   info[0].inode = 0
--   info[0].device_id = 0
--   return info
-- end

function M.create_watcher(bufnr, id)
  if bufnr == 0 then
    bufnr = a.nvim_get_current_buf()
  end
  local self = setmetatable({bufnr=bufnr, valid=false}, Watcher)
  -- TODO move some of it to C ?
  self.change_cbs = {}
  return self
end

function M.on_change(err, fname, status)
    -- Do work...
    a.nvim_command('checktime')
    -- Debounce: stop/start.
    w:stop()
    watch_file(fname)
end


function M.watch_buffer(bufnr)
  -- print("WATCH BUFFER")
  -- log.debug('Watch buffer')
  if bufnr == 0 then
    bufnr = a.nvim_get_current_buf()
  end
  -- TODO use expand("#"..bufnr..":p")
  -- M.watch_file()

  print("FILENAME")
  local filename = a.nvim_eval('expand("#'..bufnr..':p")')
  -- local filename = a.call('expand("#"'..bufnr..'":p")')
  print("FILENAME")
  print(filename)
end

function M.watch_file(fname)
  -- print("WATCH FILE CALLED")
  local fullpath = a.nvim_call_function('fnamemodify', {fname, ':p'})

  local w = vim.loop.new_fs_event()
  if not w then
    error("Could not create loop")
  end

  w:start(fullpath, {}, vim.schedule_wrap(function(...)
    M.on_change(...) end))
end

return M
