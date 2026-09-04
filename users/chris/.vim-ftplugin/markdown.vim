setlocal nofoldenable

setlocal formatoptions-=tc
setlocal wrap
setlocal linebreak
setlocal breakindent
setlocal breakindentopt=list:-1
setlocal formatlistpat=^\\s*\\d\\+[.)]\\s\\+\\\|^\\s*[-*+]\\s\\+

for s:m in ['n', 'x']
  execute s:m . 'noremap <buffer> <expr> j      v:count ? "j" : "gj"'
  execute s:m . 'noremap <buffer> <expr> k      v:count ? "k" : "gk"'
  execute s:m . 'noremap <buffer> <expr> <Down> v:count ? "j" : "gj"'
  execute s:m . 'noremap <buffer> <expr> <Up>   v:count ? "k" : "gk"'
endfor

" Insert-mode arrows (no count applies here)
inoremap <buffer> <Down> <C-o>gj
inoremap <buffer> <Up>   <C-o>gk

" Line-extent motions by display line
nnoremap <buffer> <Home> g<Home>
nnoremap <buffer> <End>  g<End>
nnoremap <buffer> 0 g0
nnoremap <buffer> ^ g^
nnoremap <buffer> $ g$

" Teardown natural cursor mappings
let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ . (empty(get(b:, 'undo_ftplugin', '')) ? '' : ' | ')
      \ . 'silent! nunmap <buffer> j'
      \ . ' | silent! xunmap <buffer> j'
      \ . ' | silent! nunmap <buffer> k'
      \ . ' | silent! xunmap <buffer> k'
      \ . ' | silent! nunmap <buffer> <Up>'
      \ . ' | silent! iunmap <buffer> <Up>'
      \ . ' | silent! xunmap <buffer> <Up>'
      \ . ' | silent! nunmap <buffer> <Down>'
      \ . ' | silent! iunmap <buffer> <Down>'
      \ . ' | silent! xunmap <buffer> <Down>'
      \ . ' | silent! nunmap <buffer> <Home>'
      \ . ' | silent! nunmap <buffer> <End>'
      \ . ' | silent! nunmap <buffer> 0 '
      \ . ' | silent! nunmap <buffer> ^'
      \ . ' | silent! nunmap <buffer> $'
