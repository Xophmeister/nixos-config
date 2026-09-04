let b:ale_linters = ['analyzer']
let b:ale_fixers = ['rustfmt']

let b:ale_rust_analyzer_config = {
\  'cargo': {
\    'allTargets': 'true',
\    'extraArgs': [
\      '--profile',
\      'lsp'
\    ]
\  },
\  'check': {
\    'command': 'clippy'
\  }
\}

" let b:ale_rust_cargo_use_clippy = executable('cargo-clippy')
" let b:ale_rust_cargo_use_check = 1
" let b:ale_rust_cargo_check_all_targets = 1
" let b:ale_rust_cargo_check_tests = 1
" let b:ale_rust_cargo_check_examples = 1

let b:ale_rust_rustfmt_options = '--edition 2021'
