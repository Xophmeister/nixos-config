{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    <home-manager/nixos>

    ./chris
    ./play.nix
  ];
}
