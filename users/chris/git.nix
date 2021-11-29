{ pkgs, user }: {
  enable = true;
  lfs.enable = true;

  userName = user.name;
  userEmail = user.mail.work;

  extraConfig = {
    credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
  };
}
