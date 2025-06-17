# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, options, ... }:
let
  unstable = import (builtins.fetchTarball
    "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable")
  # reuse the current configuration
    { config = config.nixpkgs.config; };
in {
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.overlays = import ./custom/overlays.nix;

  nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/custom/overlays/" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = "nix-command flakes";

  networking.hostName = "tau2c-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.networkmanager.dns = "none";

  # Hotspot
  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "enp8s0";
      WIFI_IFACE = "wlp0s20f3";
      SSID = "tau2c's hotspot";
      PASSPHRASE = "gdrs2049";
    };
  };

  # Secure DNS
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key =
          "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  boot.kernelPatches = lib.singleton {
    name = "hidbattery";
    patch = null;
    extraConfig = ''
      HID_BATTERY_STRENGTH y
    '';
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan pkgs.hplipWithPlugin ];
  };
  services = {
    udev.packages = [ pkgs.sane-airscan pkgs.platformio-core pkgs.openocd ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad = {
    sendEventsMode = "disabled-on-external-mouse";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.tau2c = {
    isNormalUser = true;
    description = "Tau2C";
    hashedPassword =
      "$y$j9T$Ls83iHfOPMeauHYlREdlh0$uJDVGSFZgWSjcowOCq4p.ByLRJ9NoAi4XFBfJQQe..8";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "dialout" ];
    packages = with pkgs; [
      thunderbird
      vesktop
      libreoffice-qt-still
      hunspell
      hunspellDicts.pl_PL
      hunspellDicts.en_US
      mangohud
      simple-scan
      dupeguru
      qgis
      gimp
      unstable.signal-desktop-bin
      inkscape-with-extensions
      joplin-desktop
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    arion
    vim
    wget
    git
    rustdesk
    unstable.vscode
    nixfmt-classic
    gparted
    ntfsprogs
    direnv
    cheese
    file
    cifs-utils
    unzip
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ ];
  };

  programs.localsend.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.ssh.startAgent = true;

  # Virtual machines manager
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  users.groups.libvirtd.members = [ "tau2c" ];

  # Docker
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
  users.groups.docker.members = [ "tau2c" ];

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "tau2c" ];
  # virtualisation.virtualbox.guest.dragAndDrop = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  fileSystems = let
    # this line prevents hanging on network split
    automount_opts =
      "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  in {
    "/home/tau2c/share/damian" = {
      device = "//nixos.local/damian";
      fsType = "cifs";
      options = [
        "${automount_opts},credentials=/etc/nixos/services/smb/smb.secrets,uid=1000,gid=1000"
      ];
    };
    "/home/tau2c/share/magazyn" = {
      device = "//nixos.local/magazyn";
      fsType = "cifs";
      options = [
        "${automount_opts},credentials=/etc/nixos/services/smb/smb.secrets,uid=1000,gid=1000"
      ];
    };
    "/home/tau2c/share/straż" = {
      device = "//nixos.local/straz";
      fsType = "cifs";
      options = [
        "${automount_opts},credentials=/etc/nixos/services/smb/smb.secrets,uid=1000,gid=1000"
      ];
    };
  };

  systemd.tmpfiles.settings = {
    "share" = {
      "/home/tau2c/share/".d = {
        mode = "0700";
        user = "tau2c";
        group = "tau2c";
      };
    };
    "tabby" = { "/var/lib/tabby" = { d.mode = "0777"; }; };
    "synthing" = {
      "/backup/data" = { d.mode = "0777"; };
      "/backup/config" = { d.mode = "0777"; };
    };
    "joplin" = { "/backup/data/joplin" = { d.mode = "0777"; }; };
  };

  services.openssh.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
  services.syncthing = {
    enable = true;
    user = "tau2c";
    openDefaultPorts = true;
    configDir = "/backup/config/config";
    settings = {
      options = {
        localAnnounceEnabled = true;
        urAccepted = 3;
      };
      folders = {
        "/backup/data/joplin" = {
          label = "Joplin";
          id = "ml2r2-7fxzi";
          devices = [ "Galaxy S22" "Tablet" "Acer" ];
        };
        "/home/tau2c/Downloads" = {
          label = "Downloads";
          id = "iuqq5-y5fxy";
          type = "sendonly";
          devices = [ "Acer" ];
        };
      };
      devices = {
        "Tablet" = {
          id =
            "4UNUYDG-YXNUTNX-PAWPHTP-TNHZVQK-VO75R2V-WI5DTJX-2TLYAZB-EIVGCAK";
        };
        "Galaxy S22" = {
          id =
            "LS2H4NR-UA5ELWN-5PPJWRA-N3QAV6M-KU5KEQX-WVRIWH7-O3TC7AK-JFS4LQ5";
        };
        "Acer" = {
          id =
            "NU4XDYL-HFGXIYC-WBIPSDK-NM2EIMF-NLQLSAS-U7CAM2V-OLPM57L-4RFRBAH";
        };
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
