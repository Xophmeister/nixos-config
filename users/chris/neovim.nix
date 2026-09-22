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

    # Not a language edited here, but Conjure's built-in tutorial,
    # :ConjureSchool, works through a Fennel buffer and extracts the forms it
    # evaluates with treesitter. Without the grammar the tutorial cannot run.
    g.fennel

    # Editing Neovim itself
    g.lua
    g.query
    g.vim
    g.vimdoc
  ]);
  # hover.nvim, with one upstream race patched out.
  #
  # open_floating_preview schedules `vim.wo[hover_winid].foldenable = false`
  # to run a tick after the popup opens, and the same function registers
  # autocommands -- CursorMoved, CursorMovedI, InsertCharPre, BufEnter -- that
  # close that window. When one of those fires inside the gap, the scheduled
  # write lands on a dead window id and throws "Invalid window id" through
  # __newindex. Nothing is broken by it, since the window is already gone, but
  # the message interrupts, and pointer hover hits it often because it opens
  # and closes popups continuously as the pointer moves.
  #
  # Reported as https://github.com/lewis6991/hover.nvim/issues/121; drop this
  # once a release carries the guard. --replace-fail means the build fails
  # loudly rather than silently doing nothing if that line moves upstream.
  hover = unstable.vimPlugins.hover-nvim.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace lua/hover/util.lua --replace-fail \
        "vim.wo[hover_winid].foldenable = false" \
        "if api.nvim_win_is_valid(hover_winid) then vim.wo[hover_winid].foldenable = false end"
    '';
  });
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

    # Remote-plugin hosts, for plugins written in Ruby or Python rather than
    # Lua. Nothing here is: the only rplugin/ directory in the plugin set is
    # Conjure's deoplete source, and deoplete is not installed, so that host
    # would sit unused. Both default to true while home.stateVersion is below
    # 26.05, which is what the eval warnings were about.
    withRuby = false;
    withPython3 = false;

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
      hover
      gitsigns-nvim

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

    # Tools the editor shells out to, put on the wrapper's PATH rather than
    # left to the profile, so that Neovim still works when started somewhere
    # a login shell never ran -- from a desktop entry, say.
    #
    # fzf is additionally in the profile, via ./fzf.nix, because the shell
    # wants it too; both name unstable.fzf, so that is one binary in two
    # places rather than two versions of one. The language servers and
    # formatters go the other way round entirely and live in software.nix,
    # being useful from a command line in their own right.
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
