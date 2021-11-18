{ pkgs }:

{
  enable = true;

  keyMode = "vi";
  prefix = "C-a";  # screen muscle memory :P
  escapeTime = 1;
  terminal = "screen-256color";

  plugins = with pkgs.tmuxPlugins; [
    tmux-colors-solarized
  ];

  extraConfig = builtins.readFile ./.tmux.conf;
}
