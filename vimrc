set number
set laststatus=2
syntax on
filetype plugin indent on
set expandtab
set encoding=utf-8
set tabstop=4
set cursorline
autocmd VimLeave * silent !echo -ne "\e[1 q"
