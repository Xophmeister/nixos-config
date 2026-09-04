" ALE: clj-kondo for linting, clojure-lsp for LSP
function! ALEClojureProjectRoot(buffer) abort
  for l:name in ['deps.edn', 'project.clj', 'build.boot']
    let l:path = ale#path#FindNearestFile(a:buffer, l:name)
    if !empty(l:path)
      return fnamemodify(l:path, ':h')
    endif
  endfor
  return ""
endfunction

call ale#linter#Define('clojure', {
\   'name': 'clojure_lsp',
\   'lsp': 'stdio',
\   'executable': 'clojure-lsp',
\   'command': '%e',
\   'project_root': function('ALEClojureProjectRoot'),
\})

let g:ale_linters = extend(get(g:, 'ale_linters', {}), {'clojure': ['clj-kondo', 'clojure_lsp']})
let g:ale_fixers = extend(get(g:, 'ale_fixers', {}), {'clojure': ['cljfmt']})
let g:ale_clojure_cljfmt_options = '--remove-multiple-non-indenting-spaces'
