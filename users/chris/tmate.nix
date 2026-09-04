{ pkgs }:

{
  enable = true;
  extraConfig = builtins.readFile ./.tmux.conf;
}
