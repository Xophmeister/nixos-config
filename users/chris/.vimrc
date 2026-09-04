set nocompatible

syntax enable
filetype plugin on

" Terminal tweaks
set term=xterm-ghostty
set t_ut=

set termguicolors
set background=dark
colorscheme solarized8
highlight clear SignColumn

set wildmenu
set showcmd
set laststatus=2

set nowrap
set textwidth=72
set colorcolumn=+1
set cursorline
set scrolloff=2
set modelines=5
set splitright

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

set mouse=a
set ttymouse=sgr

set undolevels=1000
set undoreload=10000

set clipboard^=unnamed,unnamedplus

augroup scheme_filetype
  autocmd!
  autocmd BufNewFile,BufRead *.scm,*.ss,*.sld,*.egg setfiletype scheme
augroup END

let g:airline_powerline_fonts = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_min_count = 2

let g:ale_completion_enabled = 1
let g:ale_set_balloons = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}
let g:ale_sign_error = "🔥"
let g:ale_sign_warning = "⚠️"
nmap gd :ALEGoToDefinition -vsplit<CR>
nmap gr :ALERename<CR>

set completeopt=menuone,popup

" Rainbow parentheses
let g:rainbow_active = 1
