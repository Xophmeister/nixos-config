{ config, pkgs, ... }:

{
  services = {
    # GNOME with GDM
    desktopManager.gnome.enable = true;

    displayManager = {
      gdm.enable = true;

      autoLogin = {
        enable = true;
        user = "chris";
      };
    };

    xserver = {
      enable = true;

      # TODO/FIXME Euro on 5 and pound on 4...
      xkb.options = "eurosign:5";
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

  # These are the GNOME tools we actually want.
  #
  # `dconf` and `seahorse` are omitted deliberately: the programs.* options
  # below already add them. `networkmanager` likewise comes from
  # networking.networkmanager, which the GNOME module enables.
  environment.systemPackages = with pkgs; [
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
    sushi
    gnomeExtensions.vitals
    wl-clipboard

    networkmanagerapplet
    networkmanager-l2tp
  ];

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };

  # Run Electron and Chromium apps natively on Wayland rather than through
  # XWayland. This is a nixpkgs convention rather than anything upstream:
  # the wrappers test it, and only append the Ozone flags when
  # WAYLAND_DISPLAY is also set, so it expands to nothing on an X11 session
  # and cannot break the fallback.
  #
  # It earns its place twice over here. The panel is 3840x2400, which GNOME
  # drives at 2x, and an XWayland client renders at 1x and is then upscaled
  # by the compositor -- so Slack and Logseq were soft rather than sharp.
  # Separately, slack's wrapper adds WebRTCPipeWireCapturer under this flag,
  # which is what routes screen capture through the PipeWire portal; without
  # it, sharing a screen in a huddle does not work on Wayland at all.
  #
  # It belongs at the system level, not in home-manager. NixOS sets these
  # through PAM early in login, so they reach applications GNOME launches
  # itself; home.sessionVariables only reaches shell startup files, which a
  # GDM-started session never sources.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
