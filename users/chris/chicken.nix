# CHICKEN Scheme: the REPL's init file, and the two pieces of state that
# neither CHICKEN nor its eggs can find for themselves on this system.
{
  pkgs,
  lib,
  ...
}:

let
  eggs = pkgs.chickenPackages_5.chickenEggs;

  # chicken-lsp-server takes hover text and signatures from chicken-doc rather
  # than from the buffer, and verifies that repository during the LSP
  # initialize handshake -- without one it exits 70 before answering anything.
  #
  # The documented way to install it unpacks the repository into
  # $(chicken-home), which here is an immutable store path. That is why this
  # has never worked on this machine, and would have worked anywhere else.
  # CHICKEN_DOC_REPOSITORY, set below, redirects the lookup; the repository is
  # only ever read -- lookups do not take its lock file -- so a store path
  # serves perfectly well.
  #
  # Note the host: the copy that used to be on code.call-cc.org now 404s, and
  # this is the personal site of chicken-doc's author. The hash pins the
  # content, so a build either gets exactly this repository or fails; if the
  # site disappears it will need a mirror rather than a new hash.
  #
  # Building one locally is not an option: chicken-doc-admin -H indexes the
  # documentation of installed eggs, and Nix does not keep egg sources after
  # building, so it finds nothing.
  chickenDocRepo = pkgs.fetchzip {
    url = "https://3e8.org/pub/chicken-doc/chicken-doc-repo.tgz";
    hash = "sha256-ly2B6SFyQxM1ULoMrwKd+iFgtcFVjMmrWTfCUjecRfM=";
  };

  # breadline gives the REPL readline: history, completion, paren blinking.
  #
  # Its transitive egg dependencies are computed rather than listed. An egg
  # derivation propagates what it needs, but propagation only puts those
  # derivations in scope -- CHICKEN still has to be told each directory to
  # look in, and a missing one surfaces as "cannot load extension" at REPL
  # start rather than at build time. closePropagation walks the graph so that
  # naming breadline is enough.
  replEggs = lib.closePropagation [ eggs.breadline ];

  # A Scheme list of the directories to add, spliced into the prelude below.
  replEggPaths = lib.concatMapStringsSep "\n                    " (
    egg: ''"${egg}/lib/chicken/11"''
  ) replEggs;
in
{
  home.packages = [
    pkgs.chicken
    eggs.lsp-server

    # Useful in its own right at a prompt -- `chicken-doc string-append`
    # prints the signature and prose -- and what the language server reads
    # through.
    eggs.chicken-doc
  ];

  # Read by chicken-doc, and so by chicken-lsp-server through it. Set here
  # rather than only in the editor's wrapper so the chicken-doc CLI finds the
  # repository too; neovim.nix reads this same value back rather than
  # fetching its own copy.
  home.sessionVariables.CHICKEN_DOC_REPOSITORY = "${chickenDocRepo}";

  # csi looks for its init file at $HOME/.csirc and offers no way to move it,
  # so this is one of the few things that has to be a real file in $HOME.
  #
  # The eggs are added to the repository path from inside the file rather than
  # by exporting CHICKEN_REPOSITORY_PATH. That keeps them to the REPL: csc
  # goes on building projects against whatever their own devshell provides, so
  # a project that forgets to declare srfi-1 still fails here the way it would
  # anywhere else, instead of quietly compiling against this list.
  home.file.".csirc".text = ''
    ;; Prelude generated from users/chris/chicken.nix -- edit csirc.scm, not
    ;; ~/.csirc, which home-manager overwrites.

    ;; Quieten the loads below. csi announces its own reading of this file
    ;; before any of it runs, so that first line cannot be suppressed from
    ;; here -- but everything after it can, which matters when csi is driven
    ;; by something reading its output.
    (import (chicken load))
    (load-verbose #f)

    (import (chicken platform))
    (repository-path
      (append (repository-path)
              (list ${replEggPaths})))

  ''
  + builtins.readFile ./csirc.scm;
}
