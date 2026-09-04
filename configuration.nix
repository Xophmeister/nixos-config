# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    ./users # User-level modules
    ./system # System-level modules
  ];

  # TODO Most of the following should be moved into appropriate system modules

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };

    efi.canTouchEfiVariables = true;
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus32";
  #   keyMap = "us";
  # };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    buildMachines = [
      # tweag remote builders
      {
        hostName = "build01.tweag.io";
        maxJobs = 24;
        sshUser = "nix";
        sshKey = "/root/.ssh/id-tweag-builder";
        protocol = "ssh-ng";
        system = "x86_64-linux";
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
      {
        hostName = "build02.tweag.io";
        maxJobs = 24;
        sshUser = "nix";
        sshKey = "/root/.ssh/id-tweag-builder";
        protocol = "ssh-ng";
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        supportedFeatures = [ "big-parallel" ];
      }
    ];

    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;

    # packageOverrides = pkgs: {
    #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    #     inherit pkgs;
    #   };
    # };

    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Hardware support
    bolt
    thunderbolt

    # Useful tools
    bash
    bc
    borgbackup
    coreutils-full
    curl
    fuse
    gawk
    git-filter-repo
    git-lfs
    gitFull
    gnugrep
    gnused
    gnutar
    gzip
    jq
    s3fs
    tree
    unzip
    wget
    xz
    yq-go
    zip
  ];

  fonts.packages = with pkgs; [
    source-code-pro
    powerline-fonts
    noto-fonts-cjk-sans
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.networkmanager.plugins = [ pkgs.networkmanager-strongswan ];
  services.xl2tpd.enable = false;
  services.strongswan = {
    enable = true;
    secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
