{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-gnome3
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
