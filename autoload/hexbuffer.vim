let s:preserve_opts = ['eol', 'bin', 'ff', 'fenc']

function! hexbuffer#_temptab()
	let l:old = tabpagenr()
	noau tabnew
	setlocal noswapfile noundofile
	return [l:old, tabpagenr()]
endfunction

function! hexbuffer#_endtemptab(state)
	let [l:old, l:cur] = a:state
	noau exe l:cur . 'tabclose'
	noau exe l:old . 'tabnext'
endfunction

function! hexbuffer#_preview_bytes_temptab()
	let l:bnr = hexbuffer#extract_bufnr(bufname())
	let l:save = hexbuffer#_temptab()
	exe 'e hexbuffer://' . l:bnr . '?pid=' . getpid()
	return l:save
endfunction

function! hexbuffer#_get_opts(opts)
	return map(copy(a:opts), 'eval("&" . v:val)')
endfunction

function! hexbuffer#_set_opts(opts, values)
	for l:i in range(len(a:opts))
		exe 'let &' . a:opts[l:i] . ' = a:values[l:i]'
	endfor
endfunction

function! hexbuffer#extract_bufnr(url)
	let l:idx = match(a:url, '://\zs[0-9]\+\(?\|$\)')
	if l:idx < 0
		echoerr 'Not a valid url'
	endif
	let l:value = str2nr(a:url[(l:idx):])
	return l:value
endfunction

function! hexbuffer#bufread_bytes(bnr)
	let l:view = winsaveview()
	undojoin
	let l:save = hexbuffer#_temptab()
		exe 'buffer ' . a:bnr
		let l:data = getline(0, line('$'))
		let l:opts = hexbuffer#_get_opts(s:preserve_opts)
	call hexbuffer#_endtemptab(l:save)
	call hexbuffer#_set_opts(s:preserve_opts, l:opts)
	let l:pos = getpos('.')
	silent %delete _
	call setline(1, l:data)
	call setpos('.', l:pos)
	silent %!xxd -g 1
	silent %s/\v^[^:]+: (%( ?[a-f0-9]{2})+) +.*$/\1/e
	setlocal ft=hexbytes
	call winrestview(l:view)
endfunction

function! hexbuffer#bufwrite_bytes(bnr)
	let l:data = getline(0, line('$'))
	let l:opts = hexbuffer#_get_opts(s:preserve_opts)
	let l:save = hexbuffer#_temptab()
		call hexbuffer#_set_opts(s:preserve_opts, l:opts)
		call setline(1, l:data)
		%!xxd -ps -r
		let l:data = getline(0, line('$'))
		silent undo 0
		exe 'buffer ' . a:bnr
		silent %delete _
		call setline(1, l:data)
	call hexbuffer#_endtemptab(l:save)
	setlocal nomod
endfunction

function! hexbuffer#bufread_preview(bnr, ...)
	let l:win = winnr()
	let l:pwin = bufwinnr('hexpreviewbuffer://' . a:bnr . '?pid=' . getpid())
	if l:pwin >= 0
		noau exe l:pwin . 'wincmd w'
	endif
	let l:range = [get(a:000, 0, 1), get(a:000, 1, '$')]
	let l:save = hexbuffer#_temptab()
		exe 'e hexbuffer://' . a:bnr . '?pid=' . getpid()
		if type(l:range[1]) != 0
			let l:range[1] = line(l:range[1])
		endif
		let l:total = line('$')
		let l:data = getline(l:range[0], l:range[1])
		noswapfile enew
		call setline(1, l:data)
		silent %!xxd -ps -r | xxd -g 1
		silent %s/\v^[^:]+:%( ?[a-f0-9]{2})+ +(.*)$/\1/e
		let l:data = getline(0, line('$'))
		silent undo 0
		exe 'e hexpreviewbuffer://' . a:bnr . '?pid=' . getpid()
		setlocal ma hidden
		let l:last = line('$')
		if l:last > l:total
			silent exe (l:total + 1) . ',' . l:last . 'delete _'
		endif
		call setline(l:range[0], l:data)
		setlocal ft=hexpreview noma nomod
	call hexbuffer#_endtemptab(l:save)
	if l:pwin >= 0
		noau exe l:win . 'wincmd w'
	endif
endfunction

function! hexbuffer#convertpos_preview2bytes(row, col, rightnibble)
	return [a:row, a:col * 3 - 2 + a:rightnibble]
endfunction

function! hexbuffer#convertpos_bytes2preview(row, col)
	return [a:row, float2nr(a:col / 3) + 1]
endfunction

function! hexbuffer#_preview_r()
	let l:code = getchar()
	if type(l:code) != 0 || l:code > 255
		return
	endif
	call hexbuffer#preview_exe_atbytes('noau normal! R' . printf('%02x', l:code) . "\<Esc>")
endfunction

function! hexbuffer#_preview_sync_pos_export(bnr, marks, rightnibble)
	if mode() != 'n'
		return
	endif
	let l:win = winnr()
	noau exe bufwinnr('hexpreviewbuffer://' . a:bnr . '?pid=' . getpid()) . 'wincmd w'
	let l:poss = map(copy(a:marks), 'hexbuffer#convertpos_preview2bytes(line(v:val), col(v:val), a:rightnibble)')
	noau exe bufwinnr('hexbuffer://' . a:bnr . '?pid=' . getpid()) . 'wincmd w'
	let l:oldpos = [line('.'), col('.')]
	for l:i in range(len(a:marks))
		noau call setpos(a:marks[(l:i)], [0, l:poss[(l:i)][0], l:poss[(l:i)][1], 0])
	endfor
	if (&cursorline && l:oldpos[0] != line('.')) || (&cursorcolumn && l:oldpos[1] != col('.'))
		redraw
	endif
	noau exe l:win . 'wincmd w'
	redraw
endfunction

function! hexbuffer#_preview_sync_pos_import(bnr, marks)
	if mode() != 'n'
		return
	endif
	let l:win = winnr()
	noau exe bufwinnr('hexbuffer://' . a:bnr . '?pid=' . getpid()) . 'wincmd w'
	let l:poss = map(copy(a:marks), 'hexbuffer#convertpos_bytes2preview(line(v:val), col(v:val))')
	noau exe bufwinnr('hexpreviewbuffer://' . a:bnr . '?pid=' . getpid()) . 'wincmd w'
	let l:oldpos = [line('.'), col('.')]
	for l:i in range(len(a:marks))
		noau call setpos(a:marks[(l:i)], [0, l:poss[(l:i)][0], l:poss[(l:i)][1], 0])
	endfor
	if (&cursorline && l:oldpos[0] != line('.')) || (&cursorcolumn && l:oldpos[1] != col('.'))
		redraw
	endif
	noau exe l:win . 'wincmd w'
	redraw
endfunction

function! hexbuffer#preview_exe_atbytes(cmd)
	let l:view = winsaveview()
	let [l:row, l:col] = hexbuffer#convertpos_preview2bytes(line('.'), col('.'), 0)
	let l:save = hexbuffer#_preview_bytes_temptab()
		%!xxd -ps -r | xxd -g 1 | sed -E 's/^([^:]+):\s*((\s?[a-f0-9]{2})+)\s*(.*)$/\2/'
		call setpos('.', [0, l:row, l:col, 0])
		exe a:cmd
	call hexbuffer#_endtemptab(l:save)
	e!
	call winrestview(l:view)
endfunction
