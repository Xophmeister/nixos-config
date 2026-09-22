{ pkgs, ... }:

let
  user = {
    id = "chris";
    name = "Christopher Harrison";
    mail = {
      # TODO Obfuscate this...
      work = "christopher.harrison@tweag.io";
    };
  };
in
{
  # chris's system-level configuration: filesystems, tmpfiles rules and system
  # services, none of which home-manager can express. `user` is passed at each
  # import site, so it stays scoped to the modules that need it rather than
  # reaching every module in the system through _module.args.
  imports = [
    (import ./backblaze.nix { inherit user; })
    (import ./backer-upper.nix { inherit user; })
  ];

  users.users."${user.id}" = {
    description = user.name;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  # Passwordless sudo for the two commands used often enough to be worth it.
  #
  # git and vim used to be here too, from when the configuration lived in
  # /etc/nixos and had to be edited as root. It is a symlink to a checkout
  # owned by chris now, so neither is needed -- which is just as well: both
  # spawn a root shell (`:!sh`, `git -c core.pager=...`), so granting them
  # NOPASSWD was equivalent to granting it for everything.
  #
  # No SETENV either. It was here to let a `sudo -E` alias carry chris's
  # environment into root, so that root-run Vim picked up their config; that
  # alias is gone, and with it the reason to let arbitrary environment be
  # injected into a command that builds and activates the system.
  #
  # nixos-rebuild still amounts to root by another route, since it activates
  # whatever the configuration says. That is the point of it, not an oversight.
  security.sudo.extraRules = [
    {
      users = [ user.id ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = [ "NOPASSWD" ];
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
      ./ghostty.nix
      ./zsh.nix
      ./fzf.nix
      ./tmux.nix
      ./tmate.nix
      ./neovim.nix
      ./git.nix
      ./clojure.nix
      ./cleaner-upper.nix
    ];

    # `user` is this user's identity, so it is injected per-user rather than
    # through extraSpecialArgs, which would also hand chris's details to
    # every other home-manager user.
    _module.args.user = user;

    home.stateVersion = "21.05";
  };
}
