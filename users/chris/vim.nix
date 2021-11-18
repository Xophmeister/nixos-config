{ pkgs }:

{
  enable = true;

  plugins = with pkgs.vimPlugins; [
    ale
    rust-vim
    supertab
    tabular
    tagbar
    vim-airline
    vim-airline-themes
    vim-colors-solarized
    vim-fugitive
    vim-gnupg
    vim-markdown
    vim-nix
    vim-racket
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
}
