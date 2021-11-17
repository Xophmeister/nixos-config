{ config, pkgs, ... }:

{
  # FIXME "brlaser" doesn't seem to work and "cups-brother-hl1210w" is
  # nowhere to be found...

  # services.printing = {
  #   enable = true;
  #   drivers = with pkgs; [ brlaser cups-brother-hl1210w ];
  # };
}
