{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    oh-my-zsh
    zsh
    zsh-autoenv
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  programs.zsh = {
    enable = true;

    autosuggestions = {
      enable = true;
      strategy = "match_prev_cmd";
      highlightStyle = "fg=10";
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern"];
      patterns = {
        "\\#*" = "fg=10";
        "rm -rf*" = "fg=white,bold,bg=red";
      };
    };

    ohMyZsh = {
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
  };
}
