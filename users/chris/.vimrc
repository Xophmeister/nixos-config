set nocompatible

syntax enable
filetype plugin on

set term=screen-256color
colorscheme solarized

set wildmenu
set showcmd
set laststatus=2

set nowrap
set textwidth=72
set colorcolumn=+1
set cursorline
set scrolloff=2
set modelines=5

set hlsearch
set incsearch

set spell spelllang=en_gb
set formatoptions=croqlj

set softtabstop=2
set autoindent
set smartindent

set autoread
set encoding=utf-8

set backspace=indent,eol,start
set listchars=tab:→\ ,trail:·
set list

set ttymouse=xterm2

set undolevels=1000
set undoreload=10000

set clipboard=unnamed

let g:airline_powerline_fonts = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_min_count = 2
