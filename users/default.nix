{ unstable, ... }:

{
  imports = [
    <home-manager/nixos>

    ./chris
  ];

  # Home-manager evaluates its own nixpkgs unless told otherwise. Ours would
  # be instantiated with the same arguments anyway, so this asks it to reuse
  # the system's instance instead of building a third one alongside the
  # stable and unstable pair set up in ../unstable.nix.
  #
  # It also makes `pkgs` mean the same thing inside a home-manager module as
  # it does inside a NixOS one -- notably carrying nixpkgs.config, so
  # allowUnfree and permittedInsecurePackages apply to user packages too.
  home-manager.useGlobalPkgs = true;

  # Arguments every home-manager module may take, alongside the usual
  # config/pkgs/lib. This is the home-manager counterpart of _module.args:
  # specialArgs are available while the module list is still being resolved,
  # so they can be used in `imports` and not just in module bodies.
  home-manager.extraSpecialArgs = {
    inherit unstable;
  };
}
