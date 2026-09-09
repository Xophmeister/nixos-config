{ ... }:

{
  # A rescue editor, not the everyday one.
  #
  # chris edits in Neovim, configured in ../users/chris/neovim.nix, which
  # claims $EDITOR and aliases `vi` and `vim` to itself within that profile.
  # This copy is what root gets, and what remains if that profile is
  # unavailable -- a broken home-manager generation, or single-user mode --
  # so it stays deliberately unconfigured.
  #
  # programs.vim.enable installs pkgs.vim already; defaultEditor is not set
  # here, because two modules claiming it is how it came to be set twice.
  programs.vim.enable = true;
}
