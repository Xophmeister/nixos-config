{ config, pkgs, ... }:

let
  unstable = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/archive/master.tar.gz) { config = config.nixpkgs.config; };
in
{
  virtualisation.docker = {
    enable = true;
    package = unstable.docker;
    autoPrune.dates = "monthly";
  };

  programs.singularity.enable = true;

  environment.systemPackages = [
    unstable.docker-compose
  ];
}
