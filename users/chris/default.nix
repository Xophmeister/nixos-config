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

  # Passwordless sudo for the two commands used often enough to be worth it.
  #
  # git and vim used to be here too, from when the configuration lived in
  # /etc/nixos and had to be edited as root. It is a symlink to a checkout
  # owned by chris now, so neither is needed -- which is just as well: both
  # spawn a root shell (`:!sh`, `git -c core.pager=...`), so granting them
  # NOPASSWD was equivalent to granting it for everything.
  #
  # SETENV is kept deliberately. chris is in wheel, which already carries
  # `SETENV: ALL`, but sudo applies the *last* matching rule rather than the
  # most permissive one -- so without it here, the `sudo -E` alias in
  # zsh.nix would be refused for exactly these two commands.
  #
  # nixos-rebuild still amounts to root by another route, since it activates
  # whatever the configuration says. That is the point of it, not an oversight.
  security.sudo.extraRules = [
    {
      users = [ user.id ];
      commands = [
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
    # These are home-manager modules, not functions returning option values,
    # so they merge like any other module: each may use mkIf/mkDefault, split
    # a definition across files, or read `config`. `unstable` reaches them
    # through home-manager.extraSpecialArgs in ../default.nix.
    imports = [
      ./software.nix
      ./chicken.nix
      ./zsh.nix
      ./tmux.nix
      ./tmate.nix
      ./neovim.nix
      ./git.nix
      ./prune.nix
    ];

    # `user` is this user's identity, so it is injected per-user rather than
    # through extraSpecialArgs, which would also hand chris's details to
    # every other home-manager user.
    _module.args.user = user;

    home.stateVersion = "21.05";
  };
}
