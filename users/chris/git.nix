{ pkgs, user }: {
  enable = true;
  lfs.enable = true;

  userName = user.name;
  userEmail = "git@acc.xoph.co";

  extraConfig = {
    credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
  };
}
