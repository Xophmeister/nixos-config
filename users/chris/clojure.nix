# Clojure: the toolchain, and the formatter's house style.
{ pkgs, ... }:

let
  # As in ./software.nix: `pkgs` is the system's stable instance, aliased so
  # that each entry says which channel it came from.
  stable = pkgs;
in
{
  home.packages = [
    stable.clojure
    stable.babashka
    stable.clojure-lsp
    stable.clj-kondo
    stable.cljfmt
  ];

  # ~/.cljfmt.edn rather than a project file or a --config flag.
  #
  # cljfmt locates its configuration by walking up from its working directory,
  # taking the first .cljfmt.edn it finds and merging that one file over the
  # defaults. Putting this at the top of $HOME therefore makes it the fallback
  # for every checkout that does not carry its own, while a project that does
  # carry one still wins outright. Passing --config instead would defeat that,
  # since an explicit path skips the search entirely.
  home.file.".cljfmt.edn".source = ./cljfmt.edn;
}
