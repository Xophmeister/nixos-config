{
  pkgs,
  unstable,
  ...
}:

let
  # `pkgs` is the system's stable instance (home-manager.useGlobalPkgs
  # is on, so it is literally the same one the NixOS modules see).
  # Aliasing it makes each entry below say which channel it came from.
  stable = pkgs;

  # Methadone has its own repository (tweag:Xophmeister/methadone.git);
  # this config only wraps binaries with it. The copies that used to sit
  # beside this file were hardlinks into that checkout, so the two were
  # the same file until any `git checkout` in either repo broke the link
  # and let them drift apart silently.
  #
  # Unlike backer-upper, which is named as a runtime path inside a
  # script, this is read during evaluation: `nixos-rebuild` will fail
  # outright if the checkout is missing, and uncommitted edits to it are
  # picked up.
  #
  # It evaluates to a library rather than a derivation: `wrap` puts
  # Methadone in front of an agent under that agent's name, and `stats`
  # installs it under its own, where it reports on the log instead. One
  # script serves all three, and they share one log.
  methadone = pkgs.callPackage /home/chris/Projects/personal/methadone/main/methadone.nix { };

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

    (methadone.wrap {
      package = unstable.claude-code;
      binary = "claude";
    })

    (methadone.wrap {
      package = copilotFHS;
      binary = "copilot";
    })

    methadone.stats

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

    # Nix
    unstable.nixd
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
