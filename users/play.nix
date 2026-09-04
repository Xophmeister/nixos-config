{ config, pkgs, ... }:

let
  user = "play";
in
{
  users.users."${user}" = {
    description = "All Work And No Play";
    isNormalUser = true;
  };

  home-manager.users."${user}".home = {
    stateVersion = "21.05";

    packages = with pkgs; [
      gnome-mines
      gnome-chess
    ];
  };
}
