{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # CLI tools
    yt-dlp
    lazygit
    git-remote-gcrypt
    imagemagick

    # Languages
    erlang_26
    elixir_1_15
    bun
    nixfmt

    # Graphical applications
    gnome.nautilus
    libreoffice-fresh
    feh
    librewolf
    ungoogled-chromium
    celluloid
    filezilla
    thunderbird
    spotify
    discord
    cinny-desktop
  ];

  home.sessionVariables.DEFAULT_BROWSER = "${pkgs.librewolf}/bin/librewolf"; # Needed for Electron apps
  home.sessionVariables.GTK_OVERLAY_SCROLLING = 1;

  ## XDG directories & default applications

  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    documents = "${config.home.homeDirectory}/docs";
    desktop = "${config.home.homeDirectory}/docs";
    templates = "${config.home.homeDirectory}/docs";
    pictures = "${config.home.homeDirectory}/pictures";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/music";
    videos = "${config.home.homeDirectory}/videoarchive";
  };

  gtk.gtk3.bookmarks = [
    "file://${config.home.homeDirectory}/projects"
    "file://${config.home.homeDirectory}/projects/qdentity"
    "file://${config.home.homeDirectory}/pictures/screenshots"
    "file://${config.home.homeDirectory}/games"
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "application/pdf" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };

  # Passwords & secrets

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland;

    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.passwords";
    };
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "librewolf" "chromium" ];
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentryFlavor = "gnome3";
  };

  # This spits out an SSH_AUTH_SOCK variable, 
  # which you have to put in the env.
  services.gnome-keyring = {
    enable = true;
    components = [ "ssh" "secrets" "pkcs11" ];
  };

  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

  # "dotfiles" repo for secrets, encrypted using GPG
  home.shellAliases = {
    # Secrets management
    secrets =
      "git --git-dir=${config.home.homeDirectory}/.secrets/ --work-tree=${config.home.homeDirectory}";
    lsecrets =
      "lazygit --git-dir=${config.home.homeDirectory}/.secrets/ --work-tree=${config.home.homeDirectory}";
  };

  ## Graphical programs

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableFishIntegration = true;
    };

    font = {
      name = "monospace";
      size = 15;
    }; 
    settings = {
      enable_audio_bell = "no";
      remember_window_size = "no";
      initial_window_width = 1200;
      initial_window_height = 700;
      #window_padding_width = 30;
      confirm_os_window_close = 0;
      repaint_delay = 0;
      cursor_shape = "beam";
      linux_display_server = "x11";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dynamic_title = false;
        title = "Alacritty";
        live_config_reload = true;
        decorations_theme_variant = "Dark";
      };
      font = { size = 19; };
      scrolling = {
        history = 10000;
        auto_scroll = true;
        tabspaces = 4;
      };
      env = { WINIT_X11_SCALE_FACTOR = "1"; };
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;

    extensions = [
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "gdbofhhdmcladcmmfjolgndfkpobecpg"; } # dont track me google
      { id = "bkdgflcldnnnapblkhphbgpggdiikppg"; } # DDG Privacy Essentials
      { id = "anlikcnbgdeidpacdbdljnabclhahhmd"; } # Enhanced GitHub
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "hkligngkgcpcolhcnkgccglchdafcnao"; } # Web Archives
      { id = "edibdbjcniadpccecjdfdjjppcpchdlm"; } # I still don't care about cookies
      { id = "mdifmgkofhcnndinbbdbaplplnmdalnc"; } # Classis Blue theme
      { id = "naepdomgkenhinolocfifgehidddafch"; } # Browserpass
    ];
  };

  # Make Netflix work
  nixpkgs.config.chromium.enableWideVine = true;

  # Shortcuts for my app menu

  home.file.".local/share/applications/element.desktop".text = ''
    [Desktop Entry]
    Name=Element
    Description=Matrix messenger
    Icon=librewolf
    Exec=librewolf https://app.element.io
    Terminal=false
    Type=Application
    StartupNotify=true
  '';
}
