{
  config,
  pkgs,
  options,
  ...
}: let
  hostname = "oatman-pc";
in {
  networking.hostName = hostname;

  imports = [
    /etc/nixos/hardware-configuration.nix
    (/home/oatman/dotfiles/nixos + "/${hostname}.nix")
  ];
}
