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

  initExtra = ''
    setopt extendedglob

    # I don't like the right prompt
    unset RPS1

    # Toggle commented command line on double Escape
    comment-command-line() {
      [[ -z $BUFFER ]] && zle up-history
      if [[ $BUFFER =~ ^#+ ]]; then
        LBUFFER="$(sed -E 's/^#+ *//' <<< "$LBUFFER")"
      else
        LBUFFER="# $BUFFER"
      fi
    }

    zle -N comment-command-line
    bindkey "\e\e" comment-command-line
  '';

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
