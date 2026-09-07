{ ... }:

{
  programs.tmate = {
    enable = true;
    extraConfig = builtins.readFile ./.tmux.conf;
  };
}
