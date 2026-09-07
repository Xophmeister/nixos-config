# A daily sweep of build output and tool caches that have gone cold.
#
# This exists because 60 GiB of cargo target/ directories across 18
# projects quietly filled the disk, which only surfaced when a rebuild
# could not complete.
{ pkgs, lib, ... }:

let
  # Anything untouched for longer than this goes.
  maxAgeDays = 7;

  # Caches safe to thin out file-by-file: each entry is independently
  # redownloadable or regenerable, and none of them keeps a separate index
  # that could be left pointing at something no longer present.
  #
  # Deliberately absent, and why:
  #
  #   borg        borg's chunk index. Losing it costs no data, but forces a
  #               full re-index on the next backup -- and backer-upper runs
  #               at shutdown under TimeoutStopSec=1h, so that could turn a
  #               disk tidy-up into a failed backup.
  #   nix         holds fetcher-cache-v4.sqlite and its write-ahead log.
  #               Removing files underneath a live SQLite index is how you
  #               get a cache that lies about what it has. Nix expires its
  #               own entries via tarball-ttl anyway.
  #   mozilla     browser caches, in use whenever the browser is. They cost
  #   thunderbird browsing performance to rebuild and are not large enough
  #   chromium    to be worth the risk of deleting under a running process.
  #   tracker3    GNOME's search index; regenerates, but at a real CPU cost.
  #   mesa_*      GPU shader caches; small, and rebuilt during frames you
  #               would rather not drop.
  cacheDirs = [
    # Package manager caches
    "pip"
    "pypoetry"
    "uv"
    "yarn"
    "node-gyp"
    "puppeteer"

    # Tool binaries and indexes, fetched or built on demand
    "bazel"
    "clojure-lsp"
    "nixpkgs-review"
    "psalm"
    "pyright-python"
    "topiary"
    "zig"

    # Regenerated lazily on next view
    "thumbnails"
  ];

  # Caches that predate the XDG spec and sit directly in $HOME. Same
  # treatment, different root.
  #
  # npm's _cacache is content-addressed: index-v5 maps a key to an integrity
  # hash, and content-v2 holds the blob under a path derived from it. A blob
  # that has gone missing reads back as ENOENT, which npm treats as an
  # ordinary cache miss and refetches -- so removing whole blob files is
  # safe, and is roughly what `npm cache verify` does from the other side.
  #
  # index-v5 is left alone. It is small, and an entry pointing at a blob
  # that is no longer there costs nothing beyond one refetch. npm itself is
  # not in this closure to run its own garbage collection -- node lives in
  # per-project devshells -- so this is done structurally instead.
  homeDirs = [
    ".npm/_cacache/content-v2"
    ".npm/_cacache/tmp"
    ".npm/_logs"
    ".npm/_npx"
  ];

  prune = pkgs.writeShellApplication {
    name = "prune-stale-artefacts";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
    ];
    text = ''
      age=${toString maxAgeDays}
      projects="$HOME/Projects"
      cache="''${XDG_CACHE_HOME:-$HOME/.cache}"

      # --- cargo build output -------------------------------------------
      #
      # The test is the newest mtime anywhere under target/, which is when
      # cargo last wrote to it. mtime is used rather than atime on purpose:
      # atime records reads, and a single ripgrep or editor index across the
      # tree refreshes it on everything, after which nothing is ever stale.
      # mtime here means "not built for a week", which is the actual question.
      if [[ -d "$projects" ]]; then
        while IFS= read -r -d "" manifest; do
          target="$(dirname "$manifest")/target"
          [[ -d "$target" ]] || continue

          # -quit stops at the first recent file instead of walking a tree
          # that can hold hundreds of thousands of them.
          if [[ -n "$(find "$target" -newermt "-$age days" -print -quit)" ]]; then
            continue
          fi

          size="$(du -sh "$target" 2>/dev/null | cut -f1)"
          echo "cargo: removing $target ($size)"
          rm -rf "$target"
        done < <(
          find "$projects" \
            \( -name .git -o -name target -o -name node_modules \) -prune -o \
            -type f -name Cargo.toml -print0
        )
      fi

      # --- tool caches ---------------------------------------------------
      #
      # atime is right here, unlike above: what matters for a cache entry is
      # when it was last *read*. The root filesystem is mounted relatime, so
      # atime is only updated once a day at most -- coarse, but a threshold
      # measured in days does not care.
      # Whole files are deleted, never truncated: a missing blob is a cache
      # miss, whereas a half-written one is corruption.
      prune_dir() {
        local dir="$1" label="$2" before after
        [[ -d "$dir" ]] || return 0

        before="$(du -sh "$dir" 2>/dev/null | cut -f1)"
        find "$dir" -type f -atime "+$age" -delete 2>/dev/null || true
        find "$dir" -mindepth 1 -type d -empty -delete 2>/dev/null || true
        after="$(du -sh "$dir" 2>/dev/null | cut -f1)"

        [[ "$before" == "$after" ]] || echo "cache: $label $before -> $after"
      }

      for name in ${lib.escapeShellArgs cacheDirs}; do
        prune_dir "$cache/$name" "$name"
      done

      for rel in ${lib.escapeShellArgs homeDirs}; do
        prune_dir "$HOME/$rel" "$rel"
      done
    '';
  };
in
{
  systemd.user.services.prune-stale-artefacts = {
    Unit.Description = "Remove stale build output and tool caches";

    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe prune;

      # This is housekeeping; it should never compete with anything the
      # machine is actually being used for.
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.prune-stale-artefacts = {
    Unit.Description = "Daily sweep of stale build output and tool caches";

    Timer = {
      OnCalendar = "daily";

      # A laptop is usually asleep at whatever hour this lands on, so run
      # on the next resume rather than skipping the day entirely.
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    Install.WantedBy = [ "timers.target" ];
  };
}
