{ config, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;

      # TODO/FIXME Euro on 5 and pound on 4...
      xkbOptions = "eurosign:5";

      # GNOME with GDM
      desktopManager.gnome.enable = true;
      displayManager = {
        gdm.enable = true;
        autoLogin = {
          enable = true;
          user = "chris";
        };
      };
    };

    # Be selective about what GNOME tools we want
    gnome.core-utilities.enable = false;
  };

  # Fix for Gnome/GDM crash at login
  # https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  # These are the GNOME tools we actually want
  environment.systemPackages = with pkgs; [
    dconf
    evince
    gnome.dconf-editor
    gnome.eog
    gnome.gnome-calculator
    gnome.gnome-disk-utility
    gnome.gnome-keyring
    gnome.gnome-screenshot
    gnome.gnome-system-monitor
    gnome.gnome-terminal
    gnome.gnome-tweaks
    gnome.nautilus
    gnome.seahorse
    gnome.sushi
  ];

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };
}
