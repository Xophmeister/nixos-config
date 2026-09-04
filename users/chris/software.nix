{
  config,
  pkgs,
  unstable,
  ...
}:

let
  stable = pkgs;

  # Copilot has a bug that expects bash to exist at /bin/bash, so we
  # need to build a FHS environment for it (see github/copilot-cli#3392)
  copilotFHS = pkgs.buildFHSEnv {
    name = "copilot";
    targetPkgs = p: [ unstable.github-copilot-cli ];
    runScript = "copilot";
  };
in
[
  ## Everyday tools
  stable.gimp
  stable.inkscape
  stable.libreoffice
  unstable.firefox
  unstable.ghostty
  stable.logseq
  unstable.slack
  unstable.thunderbird

  ## Software Development
  # Utilities
  unstable.shellcheck
  stable.gh
  unstable.git-fame
  unstable.cloc
  unstable.pre-commit
  unstable.reuse

  (pkgs.callPackage ./wean.nix {
    package = unstable.claude-code;
    binary = "claude";
  })

  (pkgs.callPackage ./wean.nix {
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

  # Chicken
  stable.chicken
  stable.chickenPackages_5.chickenEggs.lsp-server

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
]
