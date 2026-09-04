function! ChickenLspProjectRoot(buffer) abort
  " Try to find Chicken-specific markers first
  let l:chicken_root = ale#path#FindNearestFile(a:buffer, '*.egg')

  if !empty(l:chicken_root)
    return fnamemodify(l:chicken_root, ':h')
  endif

  " Fall back to .setup files (Chicken 4 style)
  let l:setup_root = ale#path#FindNearestFile(a:buffer, '*.setup')

  if !empty(l:setup_root)
    return fnamemodify(l:setup_root, ':h')
  endif

  " Fall back to VCS root
  let l:git_root = ale#path#FindNearestDirectory(a:buffer, '.git')

  if !empty(l:git_root)
    return fnamemodify(l:git_root, ':h:h')
  endif

  " Last resort: use the buffer's directory
  return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

call ale#linter#Define('scheme', {
\   'name': 'chicken-lsp-server',
\   'lsp': 'stdio',
\   'executable': 'chicken-lsp-server',
\   'command': '%e --stdio',
\   'project_root': function('ChickenLspProjectRoot'),
\})
