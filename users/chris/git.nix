{ pkgs, user }: {
  enable = true;
  lfs.enable = true;

  userName = user.name;
  userEmail = user.mail.work;

  ignores = import ./.gitignore.nix;

  extraConfig = {
    push.autoSetupRemote = true;

    credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
  };
}
