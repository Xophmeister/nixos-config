{ config, pkg, ... }:

{
  imports = [
    ./desktop.nix
    ./pipewire.nix
    ./docker.nix
    ./gnupg.nix
    ./printing.nix
    ./vim.nix
    ./zsh.nix
  ];
}
