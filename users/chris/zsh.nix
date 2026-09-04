{ pkgs }:

{
  enable = true;
  enableVteIntegration = true;

  shellAliases = {
    ":e" = "vim";
    ":q" = "exit";
    "exti" = "exit";
    "sudo" = "sudo -E";
  };

  initContent =
    let
      # Temporary fix for minimal theme
      # https://github.com/ohmyzsh/ohmyzsh/issues/12328#issuecomment-2043492331
      before = pkgs.lib.mkBefore "zstyle ':omz:alpha:lib:git' async-prompt no";
      extra = builtins.readFile ./.zshrc;
    in
    pkgs.lib.mkMerge [ before extra ];

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
}
