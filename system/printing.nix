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
}
