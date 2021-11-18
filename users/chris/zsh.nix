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

  initExtra = builtins.readFile ./.zshrc;

  oh-my-zsh = {
    enable = true;
    theme = "minimal";
    plugins = [
      "docker"
      "git"
      "pip"
      "python"
      "vim-interaction"
    ];
  };
}
