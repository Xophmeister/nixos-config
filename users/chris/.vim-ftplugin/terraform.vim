" ftplugin/terraform.vim
" OpenTofu / Terraform integration via ALE:
"   - LSP:        tofu-ls   (custom linter; ALE ships no tofu-ls linter)
"   - Linting:    tflint    (ALE built-in)
"   - Formatting: tofu fmt  (small stdin/stdout fixer)
"
" tofu-ls accepts `terraform` as a language ID (see tofu-ls USAGE.md), which is
" the filetype Vim already uses for *.tf / *.tfvars, so no ID remapping is
" needed. Note: *.tofu files are not detected by Vim out of the box -- see the
" ftdetect snippet at the bottom of this file.

" --- buffer-local editing defaults (run on every terraform buffer) ----------
" tofu fmt enforces two-space indentation; match it so the buffer and the
" fixer agree.
setlocal expandtab shiftwidth=2 softtabstop=2
setlocal commentstring=#\ %s

" --- register linters and fixers once per session ---------------------------
if get(g:, 'loaded_ale_opentofu', 0)
  finish
endif
let g:loaded_ale_opentofu = 1

" Point tofu-ls at the workspace root it should index. Prefer an initialised
" `.terraform` directory, then a VCS root -- the two root markers listed in
" tofu-ls USAGE.md. Falling back to the repo root means `module` references
" still resolve before `tofu init` has created `.terraform`.
function! ALEOpenTofuProjectRoot(buffer) abort
  for l:dir in ['.terraform', '.git']
    let l:match = ale#path#FindNearestDirectory(a:buffer, l:dir)
    if !empty(l:match)
      " FindNearestDirectory returns '.../<marker>/' (trailing slash), so two
      " head-removals give the directory that contains the marker.
      return fnamemodify(l:match, ':h:h')
    endif
  endfor

  " `.git` is a file, not a directory, inside submodules and worktrees.
  let l:gitfile = ale#path#FindNearestFile(a:buffer, '.git')
  if !empty(l:gitfile)
    return fnamemodify(l:gitfile, ':h')
  endif

  return ''
endfunction

" tofu-ls speaks LSP over stdio and is launched with `tofu-ls serve`.
" If tofu-ls is not on $PATH, replace 'tofu-ls' with its absolute path.
call ale#linter#Define('terraform', {
\   'name': 'tofu_ls',
\   'lsp': 'stdio',
\   'executable': 'tofu-ls',
\   'command': '%e serve',
\   'language': 'terraform',
\   'project_root': function('ALEOpenTofuProjectRoot'),
\})

" `tofu fmt` mirrors Terraform's CLI: `-` reads the buffer on stdin and writes
" the formatted result to stdout, which is exactly what an ALE fixer consumes.
" Defined as a function reference so it applies only to this filetype, rather
" than globally repointing ALE's built-in `terraform` fixer at the tofu binary.
function! ALEOpenTofuFmt(buffer) abort
  return {'command': ale#Escape('tofu') . ' fmt -'}
endfunction

let g:ale_linters = extend(get(g:, 'ale_linters', {}),
\   {'terraform': ['tflint', 'tofu_ls']})
let g:ale_fixers = extend(get(g:, 'ale_fixers', {}),
\   {'terraform': [function('ALEOpenTofuFmt')]})

" Optional: format on save for terraform buffers only.
let g:ale_fix_on_save = 1
