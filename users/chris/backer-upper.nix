# Borg backup, run on the way to shutdown.
#
# The script this wraps lives outside the configuration, in
# ~/Projects/personal/backer-upper. It reads its settings from a .configrc
# there and sends archives over SSH to a Hetzner Storage Box, using a key and
# known-hosts file kept alongside it. What gets backed up is the single
# BACKUP_PATH named in that file; the Backblaze mounts in ./backblaze.nix are
# a separate concern and are not part of it.
#
# A NixOS module rather than a home-manager one, since it defines a system
# service. Its home-manager counterpart for user-level housekeeping is
# ./cleaner-upper.nix, which runs under systemd --user.
#
# Parameterised on `user` at the import site rather than through _module.args,
# which is global to the NixOS evaluation.
{ user }:

{ pkgs, lib, ... }:

let
  # borg and ssh are not otherwise on the system path, and a unit run during
  # shutdown cannot rely on a login shell having set one up, so the script is
  # handed the PATH it needs.
  wrapper = pkgs.writeShellScript "backer-upper-wrapper" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.bash
        pkgs.borgbackup
        pkgs.openssh
      ]
    }:$PATH

    exec /home/${user.id}/Projects/personal/backer-upper/backup.sh
  '';
in
{
  # The backup runs from ExecStop, so this is a shutdown hook wearing a
  # service's clothes: ExecStart is a no-op that leaves the unit active, and
  # the work happens when the unit is asked to stop. KillMode/KillSignal and
  # the absent SIGKILL keep systemd from cutting a long borg run short, and
  # the hour-long TimeoutStopSec bounds how long that patience lasts.
  systemd.services.backer-upper = {
    description = "Backup on shutdown";
    serviceConfig = {
      Type = "oneshot";
      User = user.id;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = wrapper;
      TimeoutStartSec = "1h";
      TimeoutStopSec = "1h";
      RemainAfterExit = true;
      KillMode = "process";
      KillSignal = "SIGTERM";
      SendSIGKILL = false;
      StandardOutput = "journal";
      StandardError = "journal";
    };

    after = [
      "network-online.target"
      "multi-user.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}
