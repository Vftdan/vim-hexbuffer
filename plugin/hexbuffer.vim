aug hexbufferScheme
	au!
	au BufReadCmd   hexbuffer://*	exe "sil doau BufReadPre ".fnameescape(expand("<amatch>"))|silent call hexbuffer#bufread_bytes(hexbuffer#extract_bufnr(expand("<amatch>")))|exe "sil doau BufReadPost ".fnameescape(expand("<amatch>"))
	au FileReadCmd  hexbuffer://*	exe "sil doau FileReadPre ".fnameescape(expand("<amatch>"))|silent call hexbuffer#bufread_bytes(hexbuffer#extract_bufnr(expand("<amatch>")))|exe "sil doau FileReadPost ".fnameescape(expand("<amatch>"))
	au BufWriteCmd  hexbuffer://*	exe "sil doau BufWritePre ".fnameescape(expand("<amatch>"))|silent call hexbuffer#bufwrite_bytes(hexbuffer#extract_bufnr(expand("<amatch>")))|exe "sil doau BufWritePost ".fnameescape(expand("<amatch>"))
	au FileWriteCmd hexbuffer://*	exe "sil doau FileWritePre ".fnameescape(expand("<amatch>"))|silent call hexbuffer#bufwrite_bytes(hexbuffer#extract_bufnr(expand("<amatch>")))|exe "sil doau FileWritePost ".fnameescape(expand("<amatch>"))

	au BufReadCmd   hexpreviewbuffer://*	exe "sil doau BufReadPre ".fnameescape(expand("<amatch>"))|silent call hexbuffer#bufread_preview(hexbuffer#extract_bufnr(expand("<amatch>")))|exe "sil doau BufReadPost ".fnameescape(expand("<amatch>"))
	au FileReadCmd  hexpreviewbuffer://*	exe "sil doau FileReadPre ".fnameescape(expand("<amatch>"))|silent call hexbuffer#bufread_preview(hexbuffer#extract_bufnr(expand("<amatch>")))|exe "sil doau FileReadPost ".fnameescape(expand("<amatch>"))

	au InsertLeave,TextChanged hexbuffer://*	call hexbuffer#bufread_preview(hexbuffer#extract_bufnr(expand("<amatch>")), line("'["), line("']"))
aug END

" pid is only used to avoid swapfile collisions
function! ToHexBuffer()
	let l:bnr = bufnr()
	exe 'e hexbuffer://' . l:bnr . '?pid=' . getpid()
	if l:bnr == bufnr()
		return
	endif
	try
		exe 'aug hexbufferCursorBind' . l:bnr
		au!
		exe 'au CursorMoved,WinLeave <buffer> noau call hexbuffer#_preview_sync_pos_import(' . l:bnr . ', ["."])'
		exe 'au WinEnter <buffer> noau call hexbuffer#_preview_sync_pos_export(' . l:bnr . ', ["''<"], 0)'
		exe 'au WinEnter <buffer> noau call hexbuffer#_preview_sync_pos_export(' . l:bnr . ', ["''>"], 1)'
		setlocal scrollbind
		exe 'belowright vsplit hexpreviewbuffer://' . l:bnr . '?pid=' . getpid()
		exe 'au CursorMoved,WinLeave <buffer> noau call hexbuffer#_preview_sync_pos_export(' . l:bnr . ', ["."], 0)'
		exe 'au WinEnter <buffer> noau call hexbuffer#_preview_sync_pos_import(' . l:bnr . ', ["''<", "''>"])'
		16wincmd |
		nmap <buffer> r <Plug>(hexbuffer-preview-r)
		nmap <buffer> u <Plug>(hexbuffer-preview-u)
		nmap <buffer> <c-r> <Plug>(hexbuffer-preview-c-r)
		setlocal scrollbind nonumber norelativenumber scl=no
		wincmd h
	finally
		aug END
	endtry
endfunction
command! ToHexBuffer call ToHexBuffer()

nnoremap <Plug>(hexbuffer-preview-r) <cmd>call hexbuffer#_preview_r()<cr>
nnoremap <Plug>(hexbuffer-preview-u) <cmd>call hexbuffer#preview_exe_atbytes('normal! u')<cr>
nnoremap <Plug>(hexbuffer-preview-c-r) <cmd>call hexbuffer#preview_exe_atbytes("normal! \<lt>c-r>")<cr>
