{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vimHugeX
  ];

  programs.vim.defaultEditor = true;
}
