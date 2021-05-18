let s:hilink = 'hi def link '
if version < 508
	let s:hilink = 'hi link '
endif

syn match hexbytesByte0 /[0-9a-fA-F]\{2}/ nextgroup=hexbytesByte0Post
syn match hexbytesByte0Post /\s*/ contained conceal cchar=  nextgroup=hexbytesByte1
for i in range(1, 15)
	exe 'syn match hexbytesByte' . printf('%X', i) . ' /[0-9a-fA-F]\{2}/ contained nextgroup=hexbytesByte' . printf('%X', i) . 'Post'
	exe 'syn match hexbytesByte' . printf('%X', i) . 'Post conceal cchar=  /\s*/ contained nextgroup=hexbytesByte' . printf('%X', (i + 1) % 16)
endfor

for i in range(8)
	exe s:hilink . 'hexbytesByte' . printf('%X', i + 8) . ' hexbytesByte' . printf('%X', i)
endfor

for i in range(4)
	exe s:hilink . 'hexbytesByte' . printf('%X', i + 4) . ' hexbytesByte' . printf('%X', i)
endfor

for i in range(2)
	exe s:hilink . 'hexbytesByte' . printf('%X', i + 2) . ' hexbytesByte' . printf('%X', i)
endfor

exe s:hilink 'hexbytesByte0 Constant'
exe s:hilink 'hexbytesByte1 Statement'

let b:current_syntax = "hexbytes"
