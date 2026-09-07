{ config, pkgs, ... }:

{
  # programs.vim.enable installs pkgs.vim already.
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
}
