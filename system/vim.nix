{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.vim ];
  programs.vim.defaultEditor = true;
}
