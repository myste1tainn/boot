
"autocmd InsertLeave <buffer> silent :GoImport

"au BufWinEnter * let w:m1=matchadd('struct', 'type $name$ struct {\n\n}', -1)
"au BufWinEnter * let w:m1=matchadd('interface', 'type $name$ interface {\n\n}', -1)
"inoremap <buffer> struct 'type $name$ struct {\n\n}'
"inoremap <buffer> interface 'type $name$ interface {\n\n}'


