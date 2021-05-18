setlocal syntax=hexbytes
call setbufvar(bufname(), '&equalprg', 'xxd -ps -r | xxd -g 1 | sed -E ''s/^([^:]+):\s*((\s?[a-f0-9]{2})+)\s*(.*)$/\2/''')

aug hexbytesInsertSkipws
	au!
	au InsertEnter,TextChangedI <buffer> if match((getline('.') . (line('$') == line('.') ? '0' : ''))[getcurpos()[2] - 1], '^[0-9a-fA-F]') == -1
	au InsertEnter,TextChangedI <buffer> 	normal! w
	au InsertEnter              <buffer> 	let v:char=' '
	au InsertEnter,TextChangedI <buffer> endif
aug END
