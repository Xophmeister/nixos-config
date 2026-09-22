# Fuzzy finding at the shell prompt.
#
# Taken from `unstable` rather than the default `pkgs.fzf`, so that this is
# literally the same derivation ./neovim.nix puts on the editor's PATH for
# fzf-lua. Matching then behaves identically whether the prompt came from
# <leader>ff or from Ctrl+T, which is most of the reason to have it in both
# places; the default would give the shell stable's fzf and leave the two to
# agree only approximately.
{ unstable, ... }:

{
  programs.fzf = {
    enable = true;
    package = unstable.fzf;

    # Binds Ctrl+R over history, Ctrl+T to insert a path at the cursor, and
    # Alt+C to cd. Ctrl+R displaces zsh's own
    # history-incremental-search-backward, which is the point.
    #
    # home-manager injects this at mkOrder 910, so it lands ahead of the VTE
    # hook at 1000, .zshrc at 1050 and the generated aliases at 1100. See
    # ./zsh.nix, which explains why that ordering is pinned rather than left
    # to evaluation order.
    enableZshIntegration = true;
  };
}
