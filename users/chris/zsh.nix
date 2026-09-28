{ lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;

    shellAliases = {
      ":e" = "vim";
      ":q" = "exit";
      "exti" = "exit";
    };

    initContent =
      let
        # Temporary fix for minimal theme
        # https://github.com/ohmyzsh/ohmyzsh/issues/12328#issuecomment-2043492331
        before = lib.mkBefore "zstyle ':omz:alpha:lib:git' async-prompt no";

        # Ordered explicitly rather than left at the default 1000, which is
        # also what home-manager's own VTE integration uses: with both at the
        # same priority their relative order came down to which module was
        # evaluated first, and moving this definition into a file of its own
        # silently flipped it. 1050 keeps .zshrc after the VTE hook (1000)
        # and before the generated aliases (1100), which is where it landed
        # by accident before.
        extra = lib.mkOrder 1050 (builtins.readFile ./.zshrc);
      in
      lib.mkMerge [ before extra ];

    oh-my-zsh = {
      enable = true;
      theme = "minimal";
      plugins = [
        "docker"
        "git"
        "pip"
        "python"
        "rust"
        "terraform"
        "vim-interaction"
      ];
    };
  };

  # nix-shell and nix develop build their environment in Bash, then drop you
  # into it; this wraps them (as interactive zsh functions only) to exec zsh
  # instead. `command nix ...` bypasses the wrapper for the stock Bash shell.
  programs.nix-your-shell.enable = true;
}
