-- local a = vim.api
local log = require 'vim.lsp.log'

do
  local function path_join(...)
    return table.concat(vim.tbl_flatten{...}, path_sep)
  end

  local logfilename = path_join(vim.fn.stdpath('data'), 'vim-fswatch.log')
  log.get_filename = function ()
      return logfilename
  end

  log.create_log_file('vim-fswatch.log', vim.fn.stdpath('data'))
end
-- 4. Try editing the file from another text editor.
-- 5. Observe that the file reloads in Nvim (because on_change() calls
--    |:checktime|). >
-- if for a folderm then we need sthg else
-- local nvim_err_writeln, nvim_buf_get_lines, nvim_command, nvim_buf_get_option
--   = vim.api.nvim_err_writeln, vim.api.nvim_buf_get_lines, vim.api.nvim_command, vim.api.nvim_buf_get_option
-- local uv = vim.loop


local w = vim.loop.new_fs_event()

-- vim.api.nvim_command(
-- 	"command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")

local M = {
  -- on=vim._ts_add_language,
}

local Watcher = {}
Watcher.__index = Watcher

-- Watcher:watch()
-- end

-- local function file_id_new()
--   local info = ffi.new('FileID[1]')
--   info[0].inode = 0
--   info[0].device_id = 0
--   return info
-- end
function M.get_log_path()
  return log.get_filename()
end

function M.set_log_level(level)
  if type(level) == 'string' or type(level) == 'number' then
    log.set_level(level)
  else
    error(string.format("Invalid log level: %q", level))
  end
end

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
    M.watch_file(fname)
end


function M.watch_buffer(bufnr)
  -- print("WATCH BUFFER")
  -- log.debug('Watch buffer')
  if bufnr == 0 then
    bufnr = a.nvim_get_current_buf()
  end
  -- TODO use expand("#"..bufnr..":p")

  print("FILENAME")
  local filename = a.nvim_eval('expand("#'..bufnr..':p")')
  -- local filename = a.call('expand("#"'..bufnr..'":p")')
  print("FILENAME")
  print(filename)
  M.watch_file(filename)
end

function M.watch_file(fname)
  print("WATCH FILE CALLED")
  log.info("Start Watching")
  local fullpath = a.nvim_call_function('fnamemodify', {fname, ':p'})

  log.info("Watching file fullname "..fname)
  local w = vim.loop.new_fs_event()
  if not w then
    error("Could not create loop")
  end

  w:start(fullpath, {}, vim.schedule_wrap(function(...)
    M.on_change(...) end))
end

return M
