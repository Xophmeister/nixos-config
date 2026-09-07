{ pkgs, user, ... }:

let
  # One git, used for everything.
  #
  # There used to be three in the closure: gitFull in
  # environment.systemPackages, home-manager's plain git, and a third from
  # this same override built only to provide the credential helper binary.
  # None of that was visible in use, because ~/.nix-profile/bin precedes
  # /run/current-system/sw/bin, so the profile's git shadowed the system's
  # gitFull and the SVN support it was carrying was never reachable.
  #
  # Naming the derivation once here means the binary on PATH and the helper
  # the config points at cannot drift apart.
  git = pkgs.git.override { withLibsecret = true; };
in
{
  programs.git = {
    enable = true;
    package = git;
    lfs.enable = true;

    ignores = import ./.gitignore.nix;

    settings = {
      user = {
        name = user.name;
        email = user.mail.work;
      };

      push.autoSetupRemote = true;

      credential.helper = "${git}/bin/git-credential-libsecret";
    };
  };
}
