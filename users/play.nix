{ config, pkgs, ... }:

let
  user = "play";
in
{
  programs.steam.enable = true;

  users.users."${user}" = {
    description = "All Work And No Play";
    isNormalUser = true;
  };

  home-manager.users."${user}".home.packages = with pkgs; [
    steam
    gnome.gnome-mines
    gnome.gnome-chess
    gnome.gnome-sudoku
  ];
}
