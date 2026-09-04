{ config, pkgs, ... }:

{
  services = {
    displayManager.autoLogin = {
      enable = true;
      user = "chris";
    };

    xserver = {
      enable = true;

      # TODO/FIXME Euro on 5 and pound on 4...
      xkb.options = "eurosign:5";

      # GNOME with GDM
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };

    # Be selective about what GNOME tools we want
    gnome.core-apps.enable = false;
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
    dconf-editor
    eog
    gnome-calculator
    gnome-disk-utility
    gnome-keyring
    gnome-screenshot
    gnome-sound-recorder
    gnome-system-monitor
    gnome-terminal
    gnome-tweaks
    nautilus
    seahorse
    sushi
    gnomeExtensions.vitals
    wl-clipboard

    networkmanagerapplet
    networkmanager
    networkmanager-l2tp
  ];

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };
}
