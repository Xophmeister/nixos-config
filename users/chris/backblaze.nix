# Backblaze B2 buckets, mounted locally through s3fs.
#
# These exist so the buckets can be reached as ordinary directories. Nothing
# else in this configuration depends on them -- in particular they are not
# what ./backer-upper.nix backs up, which sends borg archives elsewhere and
# never touches these paths.
#
# A NixOS module because mounts, tmpfiles rules and fuse permissions are all
# system-level. Parameterised on `user` at the import site rather than through
# _module.args, which is global to the NixOS evaluation.
{ user }:

{ ... }:

let
  buckets = [
    "xoph-documents"
    "xoph-photos"
  ];
in
{
  # The mounts below pass allow_other, which fuse refuses from a non-root user
  # unless this is set.
  programs.fuse.userAllowOther = true;

  # s3fs will not create its own mount point, and /run/media is tmpfs, so the
  # directories have to be recreated on every boot.
  #
  # TODO Don't hardcode group
  systemd.tmpfiles.rules = map (
    bucket: "d /run/media/${user.id}/${bucket} 0700 ${user.id} users -"
  ) buckets;

  fileSystems = builtins.listToAttrs (
    map (bucket: {
      name = "/run/media/${user.id}/${bucket}";
      value = {
        device = bucket;
        fsType = "s3fs";
        options = [
          "_netdev"
          "allow_other"
          "use_path_request_style"
          "uid=1000" # TODO Don't hardcode this
          "gid=100" # TODO Don't hardcode this
          "passwd_file=/home/${user.id}/.config/s3fs/.backblaze"
          "url=https://s3.eu-central-003.backblazeb2.com"
          "ensure_diskfree=2048" # keep 2 GiB free, not 10% of the disk
        ];
      };
    }) buckets
  );
}
