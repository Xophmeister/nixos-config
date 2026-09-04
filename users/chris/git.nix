{ pkgs, user }: {
  enable = true;
  lfs.enable = true;

  ignores = import ./.gitignore.nix;

  settings = {
    user = {
      name = user.name;
      email = user.mail.work;
    };

    push.autoSetupRemote = true;

    credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
  };
}
