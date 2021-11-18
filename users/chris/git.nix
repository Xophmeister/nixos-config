{ pkgs, user }: {
  enable = true;

  userName = user.name;
  userEmail = "git@acc.xoph.co";

  # FIXME Blindly copy-and-pasting from the NixOS wiki is probably not
  # a good idea! Awaiting more help on how this all works...or maybe I
  # should just use SSH keys like a normal person ;)

  # extraConfig = {
  #   credential.helper = "${
  #       pkgs.git.override { withLibsecret = true; }
  #     }/bin/git-credential-libsecret";
  # };
}
