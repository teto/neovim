-- 2. Execute it with ":luafile %".
-- 3. Use ":Watch %" to watch any file.
-- 4. Try editing the file from another text editor.
-- 5. Observe that the file reloads in Nvim (because on_change() calls
--    |:checktime|). >
-- if for a folderm then we need sthg else

local vim = vim


local w = vim.loop.new_fs_event()

local function on_change(err, fname, status)
	-- Do work...
	vim.api.nvim_command('checktime')
	-- Debounce: stop/start.
	w:stop()
	watch_file(fname)
end


function watch_file(fname)
	local fullpath = vim.api.nvim_call_function(
		'fnamemodify', {fname, ':p'}
	)
	w:start(fullpath, {}, vim.schedule_wrap(function(...)
	on_change(...) end))
end
vim.api.nvim_command(
	"command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")

