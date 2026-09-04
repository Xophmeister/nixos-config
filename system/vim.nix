{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.vim ];
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
}
