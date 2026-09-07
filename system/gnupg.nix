{ config, pkgs, ... }:

{
  # programs.gnupg.agent installs gnupg itself, so listing it here only added
  # a second, identical entry. pinentry is a different case: the agent refers
  # to it by store path via pinentryPackage below and does not put it on PATH,
  # so this entry is the only thing installing it. Dropping it would be a
  # behaviour change, not a de-duplication.
  environment.systemPackages = [ pkgs.pinentry-gnome3 ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
