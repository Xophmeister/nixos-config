{ lib, pkgs, user, ... }:

let
  # One git, used for everything. Naming the derivation once here means the
  # binary on PATH and the helper `credential.helper` points at cannot drift
  # apart; ~/.nix-profile/bin precedes /run/current-system/sw/bin, so a
  # second git installed system-wide would silently shadow this one.
  #
  # gitFull rather than `git.override { withLibsecret = true; }`, which is
  # the same thing only leaner: gitFull already sets withLibsecret on
  # non-Darwin, and it is the variant Hydra builds. The bare override is a
  # combination nobody else asks for, so it misses the binary cache and is
  # compiled from source -- test suite and all -- on every channel bump.
  #
  # withLibsecret is the point of all this: it builds
  # git-credential-libsecret, which keeps credentials in the GNOME keyring
  # rather than falling back to a prompt. The Tk askpass that guiSupport
  # drags in is not reachable from the command line -- git resolves
  # GIT_ASKPASS, then core.askPass, then SSH_ASKPASS, which the desktop
  # points at seahorse. gitFull's svn and gui support is therefore dead
  # weight: subversion-client, serf and tk, and nothing else, ride along in
  # the closure unused. That is the price of being a variant Hydra builds.
  git = pkgs.gitFull;

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

      # Named outright, rather than left to `vimdiff` happening to resolve
      # `vim` to Neovim via vimAlias in ./neovim.nix.
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";

      # Only the file being merged, rather than the default LOCAL, BASE and
      # REMOTE above it. Conflicts are resolved in that one buffer with
      # git-conflict.nvim (see ./nvim/lua/chris/git.lua), whose highlights
      # are the same Diff* groups that diff mode would paint over it.
      mergetool.nvimdiff.layout = "MERGED";

      # The conflicted file can be recovered with `git checkout -m` while the
      # merge is in progress, so the `.orig` backups are just litter.
      mergetool.keepBackup = false;

      credential.helper = "${git}/bin/git-credential-libsecret";
    };
  };
}
