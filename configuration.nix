# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  lib,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball {
    url = https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;
    sha256 = "sha256:0qqlidc85b1km0dp2f03wdx9k37fyisnjm6cn685ab66m723c2s6";
  };
in {
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    (import "${home-manager}/nixos")
  ];

  users.users = {
    dev = {
      isNormalUser = true;
    };
    andy = {
      isNormalUser = true;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeWjj2ot1o/k0AlOv3cjH6VOIMyhLaeT7IYmUyMFoGZ"
      ];
    };
    nixos = {
      isNormalUser = true;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWZCMf5SnKq4nYrP5bOb64jUIGxw/R/GbsL+Kbkg6so"
      ];
    };
  };

  home-manager.users = {
    dev = {pkgs, ...}: {
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "26.05";
    };
    andy = {pkgs, ...}: {
      home.packages = with pkgs; [
        fastfetch
      ];

      programs.bash = {
        enable = true;
        initExtra = ''
          if [ -n "$SSH_CONNECTION" ]; then
            fastfetch
          fi
        '';
      };

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "26.05";
    };
    nixos = {pkgs, ...}: {
      home.packages = with pkgs; [
        tree
        git
        alejandra
        (pkgs.writeShellApplication
          {
            name = "rebuild";
            runtimeInputs = with pkgs; [
              git
              alejandra
            ];
            text = builtins.readFile /home/nixos/.dotfiles/nixos/rebuild.sh;
          })
      ];

      programs.vim = {
        enable = true;

        defaultEditor = true;

        settings = {
          number = true;
          relativenumber = true;
        };
        extraConfig = ''
          set linebreak
        '';
      };

      programs.git = {
        enable = true;

        ignores = [
          "*.swp"
        ];
      };

      programs.ssh.settings = {
        enable = true;

        # config file
        matchBlocks = {
        };
      };

      programs.bash.enable = true;

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "26.05";
    };
  };

  environment.systemPackages = [
    pkgs.vim
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "NixOSBtw";
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;

      PermitRootLogin = "no";
    };
  };

  services.pihole-ftl = {
    enable = true;

    useDnsmasqConfig = true;
    openFirewallDNS = true;
    openFirewallDHCP = true;
    queryLogDeleter.enable = true;

    settings = {
      # See <https://docs.pi-hole.net/ftldns/configfile/>

      # External DNS Servers quad9 and cloudflare
      dns.upstreams = [
        "9.9.9.9"
        "1.1.1.1"
        # "192.168.0.1"
      ];

      # Allows all traffic
      dns.listeningMode = "all";

      # Optionally resolve local hosts (domain is optional)
      # dns.hosts = [ "192.168.1.188 hostname.domain" ];
    };

    lists = [
      # Lists can be added via URL
      {
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
        type = "block";
        enabled = true;
        description = "hagezi blocklist";
      }
      {
        # url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        type = "block";
        enabled = true;
        # Alternatively, use the file from nixpkgs. Note its contents won't be
        # automatically updated by Pi-hole, as it would with an online URL.
        url = "file://${pkgs.stevenblack-blocklist}/hosts";
        description = "Steven Black's unified adlist";
      }
    ];
  };

  services.pihole-web = {
    enable = true;
    ports = ["443s"];
  };
}
