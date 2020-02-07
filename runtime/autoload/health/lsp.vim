function! Test()
	" lua print(vim.inspect(vim.lsp.get_active_clients()))
lua << EOF
	print("test")
	local clients = vim.lsp.get_all_clients()
	print("clients")
	print(clients)
        print(vim.inspect(clients))

	for _, client in pairs(clients) do
		print("client")
		print(vim.inspect(client))
	end
EOF
endfunction

function! health#lsp#check()
	call health#report_start('sanity checks')
	call Test()
	" perform arbitrary checks
	" ...
	" if looks_good

	" call health#report_ok('found required dependencies')
	" else
	" call health#report_error('cannot find foo', 
	" 	\ ['npm install --save foo'])
	" endif
endfunction
