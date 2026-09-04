{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = {
    id = "chris";
    name = "Christopher Harrison";
    mail = {
      # TODO Obfuscate this...
      work = "christopher.harrison@tweag.io";
    };
  };

  unstable =
    import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz")
      {
        config = pkgs.config;
      };

  buckets = [
    "xoph-documents"
    "xoph-photos"
  ];

  backerUpperWrapper = pkgs.writeShellScript "backer-upper-wrapper" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.bash
        pkgs.borgbackup
        pkgs.openssh
      ]
    }:$PATH

    exec /home/chris/Projects/personal/backer-upper/backup.sh
  '';
in
{
  users.users."${user.id}" = {
    description = user.name;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  programs.fuse.userAllowOther = true;

  # TODO Don't hardcode group
  systemd.tmpfiles.rules = map (
    bucket: "d /run/media/${user.id}/${bucket} 0700 ${user.id} users -"
  ) buckets;

  fileSystems = builtins.listToAttrs (
    map (bucket: {
      name = "/run/media/${user.id}/${bucket}";
      value = {
        device = bucket;
        fsType = "s3fs";
        options = [
          "_netdev"
          "allow_other"
          "use_path_request_style"
          "uid=1000" # TODO Don't hardcode this
          "gid=100" # TODO Don't hardcode this
          "passwd_file=/home/chris/.config/s3fs/.backblaze"
          "url=https://s3.eu-central-003.backblazeb2.com"
          "ensure_diskfree=2048" # keep 2 GiB free, not 10% of the disk
        ];
      };
    }) buckets
  );

  systemd.services.backer-upper = {
    description = "Backup on shutdown";
    serviceConfig = {
      Type = "oneshot";
      User = user.id;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = backerUpperWrapper;
      TimeoutStartSec = "1h";
      TimeoutStopSec = "1h";
      RemainAfterExit = true;
      KillMode = "process";
      KillSignal = "SIGTERM";
      SendSIGKILL = false;
      StandardOutput = "journal";
      StandardError = "journal";
    };

    after = [
      "network-online.target"
      "multi-user.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  security.sudo.extraRules =
    let
      # DRAGONS BE HERE
      # sudoer rules for user binaries is probably not a great idea...
      profileDirectory = config.home-manager.users."${user.id}".home.profileDirectory;
    in
    [
      # Let me use Git, Vim and rebuild/clean-up NixOS without any fuss
      {
        users = [ user.id ];
        commands = [
          {
            command = "${profileDirectory}/bin/git";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
          {
            command = "${profileDirectory}/bin/vim";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
          {
            command = "/run/current-system/sw/bin/nix-collect-garbage";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
        ];
      }
    ];

  home-manager.users."${user.id}" = {
    home.stateVersion = "21.05";

    home.packages = import ./software.nix { inherit config pkgs unstable; };

    programs.zsh = import ./zsh.nix { inherit pkgs; };
    programs.tmux = import ./tmux.nix { inherit pkgs; };
    programs.tmate = import ./tmate.nix { inherit pkgs; };
    programs.vim = import ./vim.nix { pkgs = unstable; };
    programs.git = import ./git.nix { inherit pkgs user; };

    # Custom Vim ftplugins
    home.file.".vim/ftplugin".source = ./.vim-ftplugin;
  };
}
