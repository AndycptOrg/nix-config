{
  config,
  pkgs,
  options,
  ...
}: let
  hostname = "oatman-pc"; # to alllow per-machine config
in {
  networking.hostName = hostname;

  imports = [
    /etc/nixos/hardware-configuration.nix
    (/home/oatman/dotfiles/nixos + "/${hostname}.nix")
  ];
}
