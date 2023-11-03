{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # CLI tools
    yt-dlp
    lazygit
    git-remote-gcrypt
    imagemagick
    acpi
    bsd-finger

    # Languages
    erlang_26
    elixir_1_15
    bun
    nixfmt

    # Graphical applications
    gnome.nautilus
    libreoffice-fresh
    feh
    celluloid
    filezilla
    thunderbird
    spotify
    discord
    cinny-desktop
  ];

  home.shellAliases = {
    sudo = "doas";
    sudoedit = "doas $EDITOR";
  };

  home.sessionVariables.DEFAULT_BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser"; # Needed for Electron apps
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
      "text/html" = "qutebrowser.desktop";
      "application/pdf" = "qutebrowser.desktop";
      "x-scheme-handler/http" = "qutebrowser.desktop";
      "x-scheme-handler/https" = "qutebrowser.desktop";
      "x-scheme-handler/about" = "qutebrowser.desktop";
      "x-scheme-handler/unknown" = "qutebrowser.desktop";
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

  # Browsers
  # I used to use Firefox. However, I noticed to many quirks while using
  # it. Webapps not working, styling issues, slowness bc sites were only
  # optimized for Chrome. So I decided to ditch the Web altogether and use
  # a minimal qutebrowser setup, with a fallback to Chrome for when I 
  # REALLY need webapps.

  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true; # Load settings made via GUI

    keyBindings = let keybindings = {
      "<Ctrl-l>" = "cmd-set-text -s :open";
      "<Ctrl-f>" = "cmd-set-text /";
      "<Ctrl-r>" = "reload";
      "<Alt-Left>" = "back";
      "<Alt-Right>" = "forward";
      "<Ctrl-Tab>" = "tab-next";
      "<Ctrl-t>" = "cmd-set-text -s :open -t ";
      "<Ctrl-Shift-i>" = "devtools";
      "<Ctrl-u>" = "view-source";
      "<Ctrl-Shift-l>" = "yank pretty-url";
      "<Ctrl-=>" = "zoom-in";
      "<Ctrl-->" = "zoom-out";
    }; in {
      normal = keybindings;
      insert = keybindings;
    };
        
    # Search engines
    searchEngines = let qwant = "https://lite.qwant.com/?q={}"; in {
      DEFAULT = qwant;
      w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
      m = "https://search.marginalia.nu/search?query={}";
      q = qwant;
      g = "https://www.google.com/search?hl=en&q={}";
    };

    settings = {
      # Preferences
      content = { 
        default_encoding = "UTF-8";
        pdfjs = true; # Render PDFs
        
        # Don't let sites randomly play sounds
        autoplay = false;
        mute = true;
      };
      confirm_quit = [ "downloads" ];
      scrolling.bar = "always";
      url = let homepage = "about:blank"; in {
        default_page = homepage;
        start_pages = [ homepage ];
      };

      # Extreme privacy, breaks most things 
      content.cookies.accept = "never"; # Disallow all cookies
      content.cookies.store = false;
      content.canvas_reading = false; # Disallow sites to read canvas
      content.desktop_capture = false; # Disallow screen capture
      content.geolocation = false; # Disallow location
      content.headers.do_not_track = true; # Send Do-Not-Track header
      content.headers.referer = "never"; # Don't send referer header
      content.javascript.enabled = false; # Disable JavaScript
      content.local_storage = false; # Disable localStorage & WebSQL
      content.notifications.enabled = false; # Disable notifications
      content.site_specific_quirks.enabled = false; # Don't try to make sites work. Fuck em!
      content.webgl = false; # Disable WebGL
     
      # Disallow capturing video/sound
      content.media = {
        audio_video_capture = false;
        video_capture = false;
      };

      # Adblocking
      content.blocking = {
        method = "adblock"; # Only use ABP, because hosts is already blocked system-wide.
        adblock.lists = [
          "https://easylist.to/easylist/easylist.txt"
          "https://easylist.to/easylist/easyprivacy.txt"
          "https://easylist-downloads.adblockplus.org/easylistdutch.txt"
          "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt"
          "https://www.i-dont-care-about-cookies.eu/abp/"
          "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
        ];
      };
      
      # Content appearance
      fonts = {
        default_family = "monospace";
        default_size = "14pt";

        # UI
        completion.entry = "default_size default_family";
        contextmenu = "default_size sans-serif";

        # Content
        web = {
          family.standard = "sans-serif";
          family.fixed = "monospace";
          family.serif = "serif";
          size.default = 17;
          size.default_fixed = 21;
        };
      };

      # Browser behavoir
      tabs = {
        last_close = "close";
        show = "multiple";
        tabs_are_windows = false; # Set to true to use window manager tabs instead.
        mousewheel_switching = false;
      };
      input.insert_mode = {
        auto_load = true;
        leave_on_load = true;
        auto_enter = true;
        auto_leave = true;
      };
    };
  };

  programs.chromium = {
    enable = true;

    extensions = [
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "gdbofhhdmcladcmmfjolgndfkpobecpg"; } # dont track me google
      { id = "bkdgflcldnnnapblkhphbgpggdiikppg"; } # DDG Privacy Essentials
      { id = "anlikcnbgdeidpacdbdljnabclhahhmd"; } # Enhanced GitHub
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "edibdbjcniadpccecjdfdjjppcpchdlm"; } # I still don't care about cookies
      { id = "naepdomgkenhinolocfifgehidddafch"; } # Browserpass
    ];
  };

  # Make Netflix work
  nixpkgs.config.chromium.enableWideVine = true;
}
