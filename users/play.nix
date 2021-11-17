{ config, pkgs, ...}:

{
  programs.steam.enable = true;

  users.users.play = {
    description = "All Work And No Play";
    isNormalUser = true;
    packages = with pkgs; [ steam ];
  };
}
