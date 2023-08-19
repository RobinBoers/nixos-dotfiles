# This file contains all system-level configuration.
# That means it configures hardware, permissions, global settings and important multi-user packages. It does NOT contain any application config, keybindings, or other things that are not essential for a working system and/or for a working desktop. All those settings are managed via home-manager. The only exception to this rule are fonts, since home-manager doesn't provide any way to install or configure fonts, and the TTY setup, since has to always be configured system-wide.

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  ## Bootloader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  ## Networking

  networking.hostName = "nexus";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  #networking.defaultGateway = "192.168.1.1";
  #networking.nameservers = [ "8.8.8.8" ];

  # Hosts file
  # (Optionally remove '-porn' from the url ;) ...)
  networking.extraHosts = let
    hostsPath =
      "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts";
    hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";

  ## Locale

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties.

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  ## Keymap

  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
  };

  console.keyMap = "us-acentos";

  ## Users

  users.mutableUsers =
    false; # Disable imperatively adding/modifying users using useradd, usermod etc.

  users.users.root.initialHashedPassword =
    "$y$j9T$bLPCHboiH0gwS3OFClO8c/$I64k3abGdocz4a8rGlB.YSSHquzMXHkfSPZSSAR7aY5";

  users.users.robin = {
    isNormalUser = true;
    description = "Robin Boers";
    hashedPassword =
      "$y$j9T$oXO6uosfLDvrfO6O.apcw1$kSheV9P3BqVlDZJdFfMQdBVeubp3KC/kLbVoLKdoMPB";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    packages = with pkgs; [ ];
  };

  programs.fish.enable = true; # Use fish as default shell
  users.defaultUserShell = pkgs.fish;

  # Packages

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  environment.systemPackages = with pkgs; [
    # Base utils
    git
    wget
    curl
    neovim
    htop
    openssh
    killall
    gnupg
    pinentry

    # CLI tools    
    fd
    ripgrep
    jq

    # Theming
    gnome.adwaita-icon-theme

    # Home manager
    home-manager

    # Needed to make VM work
    #libva
  ];

  # Enable flatpaks
  services.flatpak.enable = true;

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };

  system.autoUpgrade.enable = true; # Autoupdating
  system.autoUpgrade.allowReboot = false;

  ## Security

  networking.firewall.enable = false; # Disable firewall

  # Use doas instead of sudo
  security.doas.enable = true;
  security.sudo.enable = false;

  security.doas.extraRules = [{
    users = [ "robin" ];
    keepEnv = true;
    persist = true;
  }];

  security.rtkit.enable = true; # Needed for sound to work.
  security.polkit.enable =
    true; # Use polkit for access to shutdown, reboot etc.

  ## Hardware

  hardware.bluetooth.enable = true; # Disable bluetooth

  powerManagement.cpuFreqGovernor = "performance"; # Make laptop go vroom

  # Sound
  sound.enable = true;

  # Use pipewire instead of pulse
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Brightness
  # Replace with `programs.light.brightnessKeys = true;` 
  # once https://github.com/NixOS/nixpkgs/pull/60804 gets merged.
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = let
      light = "${pkgs.light}/bin/light";
      step = "10";
    in [
      {
        keys = [ 224 ];
        events = [ "key" ];
        # Use minimum brightness 0.1 so the display won't go totally black.
        command = "${light} -N 0.1 && ${light} -U ${step}";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "${light} -A ${step}";
      }
    ];
  };

  # OpenGL
  hardware.opengl = {
    enable = true;

    # Needed to make Sway work in VMs
    #package = (pkgs.mesa.override { galliumDrivers = [ "i915" "swrast" "virgl" ]; }).drivers;
  };

  ## Graphical session (Sway + GNOME services)

  programs.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
      base = true;
    };
    extraPackages = with pkgs; [
      xdg-utils # for opening programs using custom handlers (steam:// etc.)
      glib # gsettings support
      gnome.gnome-session
      gnome.gnome-control-center
      qt5.qtwayland
      polkit_gnome
    ];
    extraSessionCommands = ''
      export NIXOS_OZONE_WL=1
      export _JAVA_AWT_WM_NOREPARENTIN=1
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export MOX_ENABLE_WAYLAND=1
    '';
  };

  # Desktop integration
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gcr ]; # Needed to make gpg-agent pinentry work
  services.xserver.updateDbusEnvironment = true; # Make dbus work in Xwayland?
  services.udisks2.enable = true;
  services.avahi.enable = true;
  services.gvfs.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals =
    [ pkgs.xdg-desktop-portal-gtk ]; # GTK portal needed to make GTK apps happy

  # Settings
  programs.dconf.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;

  # Keyring & polkit
  programs.seahorse.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.passwd.enableGnomeKeyring = true;
  services.gnome.at-spi2-core.enable =
    true; # To prevent "The name org.a11y.Bus was not provided by any .service files." when starting gnome polkit.

  systemd.user.services.gnome-polkit = {
    description = "Legacy polkit authentication agent for GNOME";
    partOf = [ "graphical-session.target" ];

    path = with pkgs; [ polkit_gnome ];

    script = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";

    wantedBy = [ "gnome-services.target" ];

    serviceConfig = { Type = "simple"; };
  };

  systemd.user.targets.gnome-services = {
    description = "GNOME services";
    documentation = [ "man:systemd.special(7)" ];
    partOf = [ "graphical-session.target" ];

    unitConfig = {
      RefuseManualStart = false;
      StopWhenUnneeded = true;
      Requires = [ "basic.target" ];
    };

    # This should probably be refactored. The `sway-session.target` is a something configured and managed by home-manager. We shouldn't assume it is enabled and set to this value. Instead this config should be moved to home-manager (but that would break the setup, and the GNOME services are a system-level thing) or this should be started from the Sway config somehow (instead of the other way around, aka depending on the sway session here).

    # I tried to run `systemctl start --user gnome-services.target` in the sway autostart section, but that resulted in 'display not found' errors for GNOME polkit.

    wantedBy = [ "sway-session.target" ];

    # Starting GSD doesn't work unfortunately. NixOS masks the GSD systemd files for some reason, probably to prevent hacky setups like this. I tried unmasking using `systemd.user.targets.<name>.enable = true;`, but that didn't work out. I just got the message to run `systemctl --user daemon-reload`, and that didn't do anything (it didn't unmask the units and it also didn't make the message go away).

    # I'll let this be for the moment (which sucks because now I can't use gnome-control-center for Wifi or Bluetooth or appearance settings).

    wants = [
      "gsd-housekeeping.target"
      "gsd-xsettings.target"
      "gsd-datetime.target"
      "gsd-print-notifications.target"
      "gsd-rfkill.target"
      "gsd-usb-protection.target"
      "gsd-wacom.target"
      "gsd-wwan.target"
    ];
  };

  ## Fonts

  # I'd rather have these options in home-manager as well, but sadly they are only available system-wide.

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      inter
      libertinus
      whatsapp-emoji-font
      jetbrains-mono
      fira-code
      ibm-plex
      font-awesome
      noto-fonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Libertinus Serif" ];
        sansSerif = [ "Inter" ];
        emoji =
          [ "Apple Color Emoji" ]; # That's the name of the Whatsapp font :p
        monospace = [ "Jetbrains Mono" "Fira Code" "IMB Plex Mono" ];
      };
    };
  };

  # Use terminus in TTY
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-118n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05";
}

