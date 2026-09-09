{
  pkgs,
  unstable,
  ...
}:

let
  # `pkgs` is the system's stable instance (home-manager.useGlobalPkgs is on,
  # so it is literally the same one the NixOS modules see). Aliasing it makes
  # each entry below say which channel it came from.
  stable = pkgs;

  # wean has its own repository (tweag:Xophmeister/wean.git); this config
  # only wraps binaries with it. The copies that used to sit beside this
  # file were hardlinks into that checkout, so the two were the same file
  # until any `git checkout` in either repo broke the link and let them
  # drift apart silently.
  #
  # Unlike backer-upper, which is named as a runtime path inside a script,
  # this is read during evaluation: `nixos-rebuild` will fail outright if
  # the checkout is missing, and uncommitted edits to it are picked up.
  wean = /home/chris/Projects/personal/wean/wean.nix;

  # Copilot has a bug that expects bash to exist at /bin/bash, so we
  # need to build a FHS environment for it (see github/copilot-cli#3392)
  copilotFHS = pkgs.buildFHSEnv {
    name = "copilot";
    targetPkgs = p: [ unstable.github-copilot-cli ];
    runScript = "copilot";
  };
in
{
  home.packages = [
    ## Everyday tools
    stable.gimp
    stable.inkscape
    stable.libreoffice
    unstable.firefox
    stable.logseq
    unstable.slack
    unstable.thunderbird

    ## Software Development
    # Utilities
    unstable.shellcheck
    stable.gh
    unstable.git-fame
    stable.git-filter-repo
    unstable.cloc
    unstable.pre-commit
    unstable.reuse

    (pkgs.callPackage wean {
      package = unstable.claude-code;
      binary = "claude";
    })

    (pkgs.callPackage wean {
      package = copilotFHS;
      binary = "copilot";
    })

    # Python
    stable.python313
    stable.python313Packages.pip
    unstable.python313Packages.mypy
    stable.python313Packages.pylsp-mypy
    stable.python313Packages.python-lsp-ruff
    stable.python313Packages.python-lsp-server
    unstable.python313Packages.ruff
    unstable.python313Packages.uv

    # Rust
    unstable.rustc
    unstable.cargo
    unstable.rust-analyzer
    unstable.rustfmt
    unstable.clippy

    # Clojure
    stable.clojure
    stable.babashka
    stable.clojure-lsp
    stable.clj-kondo
    stable.cljfmt

    # Nix
    unstable.nixfmt

    # OpenTofu
    unstable.opentofu
    stable.tofu-ls

    # GCC
    #stable.bintools
    stable.gcc

    # Bullshit
    stable.zoom-us
    stable.ungoogled-chromium
  ];

}
