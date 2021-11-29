{ config, pkgs, ... }:

let
  user = {
    id = "chris";
    name = "Christopher Harrison";
  };
in
{
  users.users."${user.id}" = {
    description = user.name;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  security.sudo.extraRules = let
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
          options = [ "SETENV" "NOPASSWD" ];
        }
        {
          command = "${profileDirectory}/bin/vim";
          options = [ "SETENV" "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "SETENV" "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users."${user.id}" = {
    home.packages = import ./software.nix { pkgs = pkgs; };

    programs.zsh = import ./zsh.nix { pkgs = pkgs; };
    programs.tmux = import ./tmux.nix { pkgs = pkgs; };
    programs.vim = import ./vim.nix { pkgs = pkgs; };
    programs.git = import ./git.nix { pkgs = pkgs; user = user; };
  };
}
