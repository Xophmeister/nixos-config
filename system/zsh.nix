{ config, pkgs, ... }:

{
  # programs.zsh installs zsh, and its syntaxHighlighting suboption installs
  # zsh-syntax-highlighting. autosuggestions is sourced straight from the
  # store by the module without going on PATH, so that one stays listed.
  environment.systemPackages = with pkgs; [
    zsh-autoenv
    zsh-autosuggestions
  ];

  programs.zsh = {
    enable = true;

    autosuggestions = {
      enable = true;
      strategy = ["match_prev_cmd"];
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
  };
}
