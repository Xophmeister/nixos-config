# A second nixpkgs instance tracking the nixos-unstable channel, for the
# handful of packages we want ahead of the release channel.
#
# This requires the channel to exist:
#
#   sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
#   sudo nix-channel --update nixos-unstable
#
# It is exposed as a module argument rather than being imported ad hoc, so
# that any module can take `unstable` in its argument list. Importing it
# per-module instead means several instances, each evaluated separately and
# free to drift apart if their arguments disagree.
{ pkgs, ... }:

{
  # Inherit the stable instance's platform and nixpkgs config (allowUnfree
  # and permittedInsecurePackages) so the two agree on everything but the
  # channel they came from. Passing the system explicitly also keeps the
  # import off builtins.currentSystem, which would make evaluation depend
  # on the machine doing it.
  _module.args.unstable = import <nixos-unstable> {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (pkgs) config;
  };
}
