# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;

  networking.hostName = "nexus";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  #networking.defaultGateway = "192.168.1.1";
  #networking.nameservers = [ "8.8.8.8" ];
  
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  users.users.root.initialHashedPassword = "";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.robin = {
    isNormalUser = true;
    description = "Robin Boers";
    hashedPassword = "$y$j9T$oXO6uosfLDvrfO6O.apcw1$kSheV9P3BqVlDZJdFfMQdBVeubp3KC/kLbVoLKdoMPB";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    packages = with pkgs; [];
  };

  # Disable imperatively adding/modifying users
  # using useradd, usermod etc.
  users.mutableUsers = false;

  # Use fish as default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Base utils
    git
    wget
    curl
    neovim
    htop
    openssh

    # CLI tools    
    fd
    ripgrep
    jq
    yt-dlp
    lazygit
    thefuck
    
    # Graphical
    gnome.gnome-control-center
    gnome.seahorse
    gnome.nautilus
    libreoffice
    xarchiver
    feh

    # Theming
    adw-gtk3
    gnome.adwaita-icon-theme

    # Wayland
    wayland
    sway
    qt5.qtwayland
    clipman

    # Home manager
    home-manager

    # Needed to make VM work
    libva
  ];

  # Autoupdating
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Use doas instead of sudo
  security.doas.enable = true;
  security.sudo.enable = false;

  security.doas.extraRules = [{
    users = [ "robin" ];
    keepEnv = true;
    persist = true;
  }];

  # Disable firewall
  networking.firewall.enable = false;

  # Use polkit for access to shutdown, reboot etc.
  security.polkit.enable = true;

  # TTY environment
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-112n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };  

  # Sound
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # I'd rather have these options
  # in Home Manager as well, but sadly
  # they are only available system-wide.

  # Fonts
  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;

    fonts = with pkgs; [
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
        serif = [ "Libertinus" ];
        sansSerif = [ "Inter" ];
        monospace = [ "Jetbrains Mono" "Fira Code" "IMB Plex Mono" ];
      };
    };
  };

  # Wayland
  programs.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
      base  = true;
    };
    extraSessionCommands = ''
      export NIXOS_OZONE_WL=1
      export _JAVA_AWT_WM_NOREPARENTIN=1
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export MOX_ENABLE_WAYLAND=1
    '';
  };
  
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;

    # GTK portal needed to make GTK apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # OpenGL
  hardware.opengl = {
    enable = true;

    # Needed to make Sway work in VMs
    package = (pkgs.mesa.override { galliumDrivers = [ "i915" "swrast" "virgl" ]; }).drivers;
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

