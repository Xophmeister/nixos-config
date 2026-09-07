# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    ./unstable.nix # The `unstable` module argument

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

  # No per-interface useDHCP here: NetworkManager (pulled in by the GNOME
  # module) manages every interface. Declaring
  # networking.interfaces.<iface>.useDHCP would also switch on
  # networking.dhcpcd, leaving two DHCP clients contending for the same
  # lease and resolv.conf.

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

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Remote builders fetch substitutes themselves rather than having
      # this machine download results and push them out again.
      builders-use-substitutes = true;
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
  };

  nixpkgs.config = {
    allowUnfree = true;

    # packageOverrides = pkgs: {
    #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    #     inherit pkgs;
    #   };
    # };

    # Required by logseq, which pins an EOL Electron. Verified 2026-09-07:
    # removing this makes the whole system config refuse to evaluate. Drop
    # the entry once logseq moves to a supported Electron, or once logseq
    # itself is dropped -- nothing else here needs it.
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  # System packages
  #
  # Nothing here should duplicate what a module already provides. NixOS's
  # system-path.nix unconditionally installs a `corePackages` set -- bash,
  # coreutils-full, curl, gawk, gnugrep, gnused, gnutar, gzip, xz and
  # friends -- so listing those again just adds a second, identical entry
  # to the same buildEnv. Likewise `bolt`, which the GNOME module pulls in
  # via services.hardware.bolt.
  environment.systemPackages = with pkgs; [
    # Hardware support
    thunderbolt

    # Useful tools
    bc
    borgbackup
    git-filter-repo
    git-lfs
    gitFull
    jq
    s3fs
    tree
    unzip
    wget
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
  services.strongswan = {
    enable = true;
    secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
