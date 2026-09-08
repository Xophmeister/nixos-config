{ ... }:

{
  # This machine shipped with BIOS N32ET66W 1.42, dated June 2021, and
  # Lenovo publishes X1 Carbon Gen 9 firmware to LVFS. Enabling this mostly
  # buys visibility -- the daemon and the LVFS remote -- rather than any
  # automatic action:
  #
  #   fwupdmgr refresh
  #   fwupdmgr get-updates
  #   fwupdmgr update        # only when asked
  #
  # Nothing is flashed without an explicit command.
  services.fwupd.enable = true;
}
