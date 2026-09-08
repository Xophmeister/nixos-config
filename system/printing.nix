{ config, pkgs, ... }:

{
  # Both drivers exist in nixpkgs now (brlaser-6.2.8 and
  # cups-brother-hl1210W-3.0.1-1), which they did not when this was first
  # written -- hence the FIXME that used to sit here.
  #
  # brlaser is the generic Brother laser driver and covers the HL-1210W;
  # the vendor package is kept alongside it because CUPS picks whichever
  # PPD matches the detected model.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser
      cups-brother-hl1210w
    ];
  };

  # Without this, printing gets as far as "Processing" and stops dead:
  #
  #   [Job 2] Owl-Maintain/brlaser: Could not write print data.
  #   [Job 2] printer-state-message="Unable to locate printer
  #           "BRN30C9ABE842B6.local"."
  #
  # The two halves of mDNS are separate. Avahi is already enabled (GNOME
  # pulls it in) and CUPS *discovers* the printer through it over D-Bus,
  # which is why it shows up in Settings and the queue can be created. But
  # the dnssd:// backend then resolves the device to a .local hostname and
  # hands that to the ordinary resolver -- and nsswitch had no mDNS module,
  # so the name went nowhere and the job hung.
  #
  # This adds mdns4_minimal to the hosts line, which is what lets glibc
  # resolve .local at all. nssmdns6 is left off: this printer answers on
  # IPv4, and enabling both makes every failed .local lookup wait for two
  # timeouts rather than one.
  services.avahi.nssmdns4 = true;
}
