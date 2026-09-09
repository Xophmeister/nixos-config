# Neovim comes from the unstable channel, as the Vim setup it replaces did:
# every derivation below is taken from `unstable` explicitly, so the editor,
# its plugins and its treesitter grammars cannot drift apart. `pkgs` here is
# the system's stable instance and is deliberately not used.
{ config, unstable, ... }:

let
  # Grammars are scoped to what is actually edited rather than pulled in
  # wholesale: withAllGrammars is several hundred megabytes of parsers for
  # languages this machine never opens.
  #
  # This is nvim-treesitter's `main` branch, which has no runtime installer.
  # A language missing from this list gets no treesitter highlighting at all,
  # so adding one here is the whole of the change.
  treesitter = unstable.vimPlugins.nvim-treesitter.withPlugins (g: [
    # Languages with a language server or formatter configured
    g.clojure
    g.hcl
    g.nix
    g.python
    g.rust
    g.scheme
    g.terraform

    # Everyday formats
    g.bash
    g.diff
    g.git_config
    g.git_rebase
    g.gitcommit
    g.json
    g.markdown
    g.markdown_inline
    g.toml
    g.yaml

    # Editing Neovim itself
    g.lua
    g.query
    g.vim
    g.vimdoc
  ]);
in
{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;

    # $EDITOR points here. The system Vim in ../../system/vim.nix deliberately
    # no longer claims it: that copy exists for root and for single-user mode,
    # where this profile is not on PATH.
    defaultEditor = true;

    # `vi` and `vim` both reach Neovim, so muscle memory does not have to
    # change along with the editor.
    viAlias = true;
    vimAlias = true;

    plugins = with unstable.vimPlugins; [
      # Diagnostics, completion and formatting -- between them these do what
      # ALE did alone. nvim-lspconfig contributes no runtime behaviour of its
      # own here; it is the collection of server defaults that core's
      # vim.lsp.config reads.
      nvim-lspconfig
      blink-cmp
      conform-nvim
      nvim-lint

      # Syntax and structure
      treesitter
      rainbow-delimiters-nvim

      # Appearance and navigation
      vim-solarized8
      lualine-nvim
      aerial-nvim
      fzf-lua
      which-key-nvim

      # Lisps: REPL, structural motions, and paren inference
      conjure
      vim-sexp
      vim-sexp-mappings-for-regular-people
      parinfer-rust

      # Carried over unchanged -- these have no Neovim-specific successor
      copilot-lua
      vim-gnupg
      tabular
    ];

    # Tools the editor shells out to, kept on the wrapper's PATH rather than
    # in home.packages: they are Neovim's dependencies, not ones wanted at a
    # shell prompt. The language servers and formatters are the other way
    # round and stay in software.nix, since they are useful from the command
    # line too.
    extraPackages = with unstable; [
      # fzf-lua
      fzf
      fd
      ripgrep

      # copilot.lua is configured to use the standalone server rather than the
      # Node one, and finds it by name on this PATH.
      copilot-language-server
    ];

    # home.sessionVariables reaches an interactive shell, and so reaches
    # Neovim when it is started from one. Setting it on the wrapper as well
    # means chicken-lsp-server still starts if Neovim is launched some other
    # way -- from a desktop entry, say -- where that shell never ran.
    # software.nix owns the value; this only passes it along.
    extraWrapperArgs = [
      "--set"
      "CHICKEN_DOC_REPOSITORY"
      config.home.sessionVariables.CHICKEN_DOC_REPOSITORY
    ];

    initLua = builtins.readFile ./nvim/init.lua;
  };

  # init.lua requires these; they have to be real files under the runtime
  # path rather than more text appended to initLua, so that Lua's own module
  # loader can find them -- and so they stay editable as Lua.
  xdg.configFile = {
    "nvim/lua/chris".source = ./nvim/lua/chris;
    "nvim/after/ftplugin".source = ./nvim/after/ftplugin;
  };
}
