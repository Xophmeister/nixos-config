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

  # chicken-lsp-server takes hover text and signatures from chicken-doc
  # rather than from the buffer, and verifies the doc repository exists
  # during the LSP initialize handshake -- so without one it does not start
  # at all, exiting 70 before serving a single request.
  #
  # The documented way to install that repository is to unpack it into
  # $(chicken-home), which here is an immutable store path. That is why this
  # has never worked on this machine, and would have worked anywhere else.
  # CHICKEN_DOC_REPOSITORY, set below, redirects the lookup. The repository
  # is only ever read -- lookups do not take its lock file -- so a store
  # path serves perfectly well.
  #
  # Upstream publishes it prebuilt, but note the host: the copy that used to
  # be on code.call-cc.org now 404s, and this is the personal site of
  # chicken-doc's author. The hash pins the content, so a build either gets
  # exactly this repository or fails; if the site disappears it will need a
  # mirror rather than a new hash.
  #
  # Building one locally instead is not an option here: chicken-doc-admin -H
  # indexes the docs of installed eggs, and Nix does not keep egg sources
  # after building, so it finds nothing.
  chickenDocRepo = pkgs.fetchzip {
    url = "https://3e8.org/pub/chicken-doc/chicken-doc-repo.tgz";
    hash = "sha256-ly2B6SFyQxM1ULoMrwKd+iFgtcFVjMmrWTfCUjecRfM=";
  };

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
    unstable.ghostty
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

    # Chicken
    stable.chicken
    stable.chickenPackages_5.chickenEggs.lsp-server

    # Useful in its own right at a prompt -- `chicken-doc string-append`
    # prints the signature and prose -- and it is what the language server
    # reads through.
    stable.chickenPackages_5.chickenEggs.chicken-doc

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

  # Read by chicken-doc, and so by chicken-lsp-server through it. Set here
  # rather than only in the editor's wrapper so the chicken-doc CLI finds the
  # repository too; neovim.nix reads this same value back rather than
  # fetching its own copy.
  home.sessionVariables.CHICKEN_DOC_REPOSITORY = "${chickenDocRepo}";
}
