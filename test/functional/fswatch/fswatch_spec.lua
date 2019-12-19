-- Test suite for libuv notifications (may depend on filesystem)
local helpers = require('test.functional.helpers')(after_each)

-- local lfs = require('lfs')
-- local bit = require('bit')

local uhelpers = require('test.unit.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
-- local fs = require('vim.fswatch')
local funcs = helpers.funcs
local meths = helpers.meths
local command = helpers.command
local clear = helpers.clear
local eq = helpers.eq
local eval = helpers.eval
local feed = helpers.feed
local pcall_err = helpers.pcall_err
local exec_lua = helpers.exec_lua
local matches = helpers.matches
local source = helpers.source
local NIL = helpers.NIL
local retry = helpers.retry

local cimport = uhelpers.cimport
local ffi = uhelpers.ffi

-- cimport('./src/nvim/os/shell.h')
-- cimport('./src/nvim/option_defs.h')
-- cimport('./src/nvim/main.h')
-- cimport('./src/nvim/fileio.h')
cimport('./src/nvim/os/os.h')
-- , './src/nvim/path.h')
-- cppimport('sys/stat.h')
-- cppimport('fcntl.h')
-- cimport('uv.h')

before_each(clear)

-- local function test_rpc_server_setup(test_name, timeout_ms)
--   exec_lua([=[
--     lsp = require('vim.lsp')
--     local test_name, fixture_filename, timeout = ...

-- local f = eval('fnamemodify(@%,":p")')
-- assert(string.len(f) > 3)
local function file_id_new()
  local info = ffi.new('FileID[1]')
  info[0].inode = 0
  info[0].device_id = 0
  return info
end

  -- itp('returns true if given an existing file and fills file_id', function()
  --   local file_id = file_id_new()
  --   local path = 'unit-test-directory/test.file'
  --   assert.is_true((fs.os_fileid(path, file_id)))
  --   assert.is_true(0 < file_id[0].inode)
  --   assert.is_true(0 < file_id[0].device_id)
  -- end)

-- -- reuse for instance
-- describe('os_fileinfo_inode', function()
--   itp('returns the inode from FileInfo', function()
--     local info = file_info_new()
--     local path = 'unit-test-directory/test.file'
--     assert.is_true((fs.os_fileinfo(path, info)))
--     local inode = fs.os_fileinfo_inode(info)
--     eq(info[0].stat.st_ino, inode)
--   end)
-- end)

-- some inspiration from test/unit/os/fs_spec.lua
describe('file watcher', function()
  it('file external modification', function()

    local file_id = file_id_new()
    local env = {XDG_DATA_HOME='Xtest-userdata', XDG_CONFIG_HOME='Xtest-userconfig'}
    clear{args={}, args_rm={'-i'}, env=env}

    local screen = Screen.new(3, 8)
    screen:attach()
    command('edit Xtest-foo')
    insert([[aa bb]])
    command('write')
    -- replace with command
    -- fs.watch_file()
    exec_lua([[
        fs = require('vim.fswatch')

    ]])
    command('Watch Xtest-foo')

    local file = io.open("Xtest-foo", 'w')
    local new_content = 'new_content'
    file:write(new_content)
    file:flush()
    file:close()
    screen:expect({any = new_content})

      -- if (os.execute('echo "appended" > Xtest-foo 2>&1') ~= 0) then
      --   pending('skipped (missing `cat` utility)', function() end)
      -- else
      --   check
      -- end
      --

    -- command('qall')
    -- clear{args={}, args_rm={'-i'}, env=env}
    -- os.remove('Xtest-foo')
    -- rmdir('Xtest-userdata')
  end)

  -- TODO check inodes etc
end)

