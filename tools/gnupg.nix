{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-gnome
  ];
  
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };
}
