{ pkgs }: with pkgs; [

    # Vim Plugins
    vimPlugins.ale
    vimPlugins.rust-vim
    vimPlugins.supertab
    vimPlugins.tabular
    vimPlugins.tagbar
    vimPlugins.vim-airline
    vimPlugins.vim-airline-themes
    vimPlugins.vim-colors-solarized
    vimPlugins.vim-fugitive
    vimPlugins.vim-gnupg
    vimPlugins.vim-markdown
    vimPlugins.vim-nix
    vimPlugins.vim-pathogen
    vimPlugins.vim-racket
    vimPlugins.vim-terraform

    # Useful tools
    anki
    bitwarden bitwarden-cli
    signal-desktop
    slack

    # Software Development
    # TODO Haskell
    cloc
    gcc
    git-fame
    python39
    python39Packages.pip # python39Packages.pylint python39Packages.mypy
    racket
    rustup

]
