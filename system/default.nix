{ config, pkg, ... }:

{
  imports = [
    ./desktop.nix
    ./docker.nix
    ./gnupg.nix
    ./printing.nix
    ./vim.nix
    ./zsh.nix
  ];
}
