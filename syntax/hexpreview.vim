let s:hilink = 'hi def link '
if version < 508
	let s:hilink = 'hi link '
endif

syn include @xxd syntax/xxd.vim
syn match hexpreviewNonPrintable /\V./ contained
syn match hexpreviewDocument /^.*$/ contains=hexpreviewNonPrintable

exe s:hilink 'hexpreviewDocument xxdAscii'
exe s:hilink 'hexpreviewNonPrintable xxdDot'

let b:current_syntax = "hexpreview"
