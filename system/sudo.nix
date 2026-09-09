{ ... }:

{
  # Give root-run commands root's home directory.
  #
  # Without this, sudo leaves HOME pointing at the invoking user's home while
  # the process runs as root. Nix notices the owner mismatch on every
  # nixos-rebuild and falls back to the passwd entry itself:
  #
  #   warning: $HOME ('/home/chris') is not owned by you, falling back to the
  #   one defined in the 'passwd' file ('/root')
  #
  # This was previously masked as being about the `sudo -E` alias in
  # users/chris/zsh.nix. It was not: the warning appears with a plain sudo
  # too, because preserving HOME is what sudo does unless -H is passed or
  # this option makes -H implicit.
  #
  # The cost is that a command run under sudo now reads root's dotfiles
  # rather than chris's -- which is the intended behaviour here, that alias
  # having existed precisely to get the other one.
  security.sudo.extraConfig = "Defaults always_set_home";
}
