-- Formatting and linting.
--
-- ALE treated these as one job with two option groups; Neovim splits them.
-- conform.nvim runs formatters, nvim-lint runs the checkers that are not
-- language servers. Anything a language server already reports is configured
-- in lsp.lua instead and deliberately absent here, so no finding is raised
-- twice from two directions.

local conform = require("conform")

conform.setup({
  formatters = {
    -- cljfmt leaves runs of spaces inside forms alone by default. Collapsing
    -- them is a deliberate house style rather than a cljfmt default, so the
    -- whole argument list is spelled out rather than appended: the flag has
    -- to precede the `-` that puts cljfmt in stdin mode.
    cljfmt = {
      args = { "fix", "--remove-multiple-non-indenting-spaces", "-" },
    },

    -- conform's stock definition shells out to `terraform`. OpenTofu's CLI is
    -- argument-compatible for `fmt`, so only the binary changes.
    terraform_fmt = {
      command = "tofu",
      args = { "fmt", "-" },
    },
  },

  formatters_by_ft = {
    clojure = { "cljfmt" },
    nix = { "nixfmt" },
    python = { "ruff_fix", "ruff_format" },
    rust = { "rustfmt" },
    terraform = { "terraform_fmt" },

    -- Applied to every buffer, on top of anything above. rustfmt is left to
    -- pick its own edition from Cargo.toml, defaulting to 2021, which is what
    -- the explicit `--edition 2021` was pinning by hand.
    ["*"] = { "trim_whitespace", "trim_newlines" },
  },

  format_on_save = {
    timeout_ms = 2000,
    -- Formatting is the formatters' job. Letting a language server format as
    -- well means rust-analyzer and rustfmt, or pylsp and ruff, each rewriting
    -- the other's output.
    lsp_format = "never",
  },
})

-- Bound to <leader>= rather than <leader>f, which is the prefix for the
-- fzf-lua group: a mapping that is also a prefix makes every use of it wait
-- out `timeoutlen` first. `=` is Vim's own operator for this.
vim.keymap.set({ "n", "v" }, "<leader>=", function()
  conform.format({ async = true, lsp_format = "never" })
end, { desc = "Format buffer or selection" })

local lint = require("lint")

-- Linting that no language server already covers.
--
-- Only Clojure needs anything: clj-kondo catches what clojure-lsp does not.
-- Python goes through pylsp's ruff and mypy plugins, Rust through
-- rust-analyzer's clippy check, and Terraform through tofu-ls.
--
-- tflint is deliberately absent. It parses Terraform and does not recognise
-- .tofu files, so it has nothing to say about this configuration's sources.
--
-- There is no executable-presence guard here either. clj-kondo is declared in
-- software.nix, so whether it is on PATH is settled when the system is built
-- rather than being something to discover on every save.
lint.linters_by_ft = {
  clojure = { "clj-kondo" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("chris.lint", { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})
