{ pkgs }: with pkgs; [

    # Useful tools
    anki
    bitwarden bitwarden-cli
    signal-desktop slack

    # Software Development
    # TODO Haskell
    cloc
    gcc
    git-fame
    python39
    python39Packages.pip # python39Packages.pylint python39Packages.mypy
    racket
    rustup
    shellcheck

]
