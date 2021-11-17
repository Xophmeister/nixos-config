{ pkgs }:

{
  enable = true;

  oh-my-zsh = {
    enable = true;
    theme = "minimal";
    plugins = [
      "docker"
      "git"
      "pip"
      "python"
      "tmux"
      "vim-interaction"
    ];
  };
}
