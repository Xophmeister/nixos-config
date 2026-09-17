{ lib, pkgs, user, ... }:

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

  # `git clone-tree`, as a script rather than an alias string: at this length
  # a gitconfig one-liner buys nothing but escaping. Kept in its own file so
  # neither git's config escapes nor Nix's antiquotation stand between the
  # shell and the reader; writeShellApplication supplies errexit and nounset
  # and runs shellcheck over it at build time.
  git-clone-tree = pkgs.writeShellApplication {
    name = "git-clone-tree";
    runtimeInputs = [
      git
      pkgs.coreutils
    ];
    text = builtins.readFile ./git-clone-tree.sh;
  };
in
{
  programs.git = {
    enable = true;
    package = git;
    lfs.enable = true;

    ignores = import ./.gitignore.nix;

    settings = {
      alias.clone-tree = "!${lib.getExe git-clone-tree}";

      user = {
        name = user.name;
        email = user.mail.work;
      };

      push.autoSetupRemote = true;

      credential.helper = "${git}/bin/git-credential-libsecret";
    };
  };
}
