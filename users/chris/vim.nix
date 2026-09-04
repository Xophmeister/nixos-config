{ pkgs }:

let
  vim-nextflow = pkgs.vimUtils.buildVimPlugin {
    name = "vim-nextflow";
    src = pkgs.fetchFromGitHub {
      owner = "raivivek";
      repo = "nextflow.vim";
      rev = "166c482f61d41caec5b6b0aebaba38564b0f77e2";
      sha256 = "0wm201b34iqq4x98r69xsfvw10hf2vr4pmf1w8fh1qhi9x5a3jsp";
    };
  };
in
{
  enable = true;
  defaultEditor = true;

  packageConfigurable = pkgs.vim-full;

  plugins = with pkgs.vimPlugins; [
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
}
