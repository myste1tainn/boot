set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

let g:coc_node_path = '/usr/local/bin/node'
let g:coc_npm_path = '/usr/local/bin/npm'

" Loads original vim config first
source ~/.vimrc

" Packer for nvim
lua <<EOF
require('plugins')
require('setup-plugins')
EOF

" Then loads nvim config
source ~/.config/nvim/.vimrc_settings_vim_go
source ~/.config/nvim/.vimrc_keymap_basic
source ~/.config/nvim/.vimrc_keymap_lsp
source ~/.config/nvim/.vimrc_keymap_telescope
source ~/.vimrc_settings_basic
set nohls

" Formatter plugin setup 'Format on Save'
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END
