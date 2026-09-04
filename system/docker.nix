{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.dates = "monthly";
  };

  programs.singularity.enable = true;

  environment.systemPackages = [
    pkgs.docker-compose
  ];
}
