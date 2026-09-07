# Vim comes from the unstable channel, which is what the old
# `import ./vim.nix { pkgs = unstable; }` call did by substituting the
# argument. Now that this is a module and `pkgs` means the system's stable
# instance, the choice has to be spelled out: every derivation below is
# taken from `unstable` explicitly, so the plugin set and the editor they
# are built against cannot drift apart.
{ unstable, ... }:

{
  programs.vim = {
    enable = true;
    defaultEditor = true;

    packageConfigurable = unstable.vim-full;

    plugins = with unstable.vimPlugins; [
      ale
      copilot-vim
      parinfer-rust
      rainbow
      rust-vim
      supertab
      tabular
      tagbar
      vim-airline
      vim-airline-themes
      vim-fireplace
      vim-gnupg
      vim-markdown
      vim-nix
      vim-sexp
      vim-sexp-mappings-for-regular-people
      vim-solarized8
      vim-terraform
    ];

    settings = {
      background = "dark";
      expandtab = true;
      modeline = true;
      mouse = "a";
      number = true;
      shiftwidth = 2;
      tabstop = 2;
      undodir = [ "$HOME/.vim/undo" ];
      undofile = true;
    };

    extraConfig = builtins.readFile ./.vimrc;
  };
}
