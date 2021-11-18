{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
  user = import ./me.nix;
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  users.users."${user.id}" = {
    description = user.name;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  security.sudo.extraRules = [
    # Let me use Git, Vim and rebuild NixOS without any fuss
    {
      users = [ user.id ];
      commands = [
        # FIXME These are the system-wide paths for git and Vim, but we
        # are using the Home Manager versions...
        {
          command = "/run/current-system/sw/bin/git";
          options = [ "SETENV" "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/vim";
          options = [ "SETENV" "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
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
