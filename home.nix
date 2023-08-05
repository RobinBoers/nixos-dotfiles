{ config, pkgs, lib, ... }:

{
  home.username = "robin";
  home.homeDirectory = "/home/robin";

  imports = [ ./sway.nix ./neovim.nix ./vscode.nix ./shell.nix ./theming.nix ];

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  home.packages = with pkgs; [
    # CLI tools
    yt-dlp
    lazygit
    thefuck
    git-remote-gcrypt
    imagemagick

    # Languages
    elixir_1_15
    nixfmt

    # Graphical applications
    gnome.nautilus
    libreoffice
    gnome.file-roller
    feh
    librewolf
    ungoogled-chromium
    baobab
    celluloid
    filezilla
    spotify
    discord
    minecraft
  ];

  # Append .local/bin to the path
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.shellAliases = {
    sudo = "doas";
    sudoedit = "doas $EDITOR";
    feh = "feh -Z --scale-down";
    ":q" = "exit";
    ":Q" = "exit";

    # Secrets management
    secrets =
      "git --git-dir=${config.home.homeDirectory}/.secrets/ --work-tree=${config.home.homeDirectory}";
    lsecrets =
      "lazygit --git-dir=${config.home.homeDirectory}/.secrets/ --work-tree=${config.home.homeDirectory}";

    # Shortcuts
    rm = "rm -ri";
    cp = "cp -i";
    mv = "mv -i";
    ".." = "cd ..";
    less = "less -QFr";
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.librewolf}/bin/librewolf"; # Needed for Electron apps
    GTK_OVERLAY_SCROLLING = 1;
    ERL_AFLAGS = "-kernel shell_history enabled";
    ELIXIR_ERL_OPTIONS = "-kernel start_pg true shell_history enabled";
    DIRENV_LOG_FORMAT = ""; # Disable annoying direnv output
  };

  programs.fish = {
    enable = true;

    shellAliases = config.home.shellAliases;
    interactiveShellInit = ''
      # Disable welcome message
      set fish_greeting

      # Enable amazing 'fuck' command
      thefuck --alias | source
    '';
  };

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

  ## Coding

  programs.git = {
    enable = true;

    userName = "Robin Boers";
    userEmail = "robindev2019@outlook.com";
    signing = {
      key = "B1181BC2D8530F64";
      signByDefault = true;
    };

    extraConfig = {
      core = { hooksPath = "${config.home.homeDirectory}/.githooks"; };
      init = { defaultBranch = "master"; };
      pull = {
        rebase = false;
        ff = "only";
      };
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        cp = "cherry-pick";
        h =
          "log --graph --date=default-local --pretty=format:'%C(yellow)%h%C(reset) %C(green)%cd%C(reset) %C(blue)%an%C(reset)%C(red)%d%C(reset) %s'";
        ha = "h --all";
        prune-br =
          "! git fetch --all --prune && git branch -vv | grep '\\(origin\\|fork\\|src\\)/.*: gone]' | awk '{print $1}' | xargs git branch -D";
        git = "!git";
      };
    };
  };

  home.file.".githooks/pre-push".text = ''
      #!/bin/sh
      bix pre-push
  '';

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "UTF-8";
        end_of_line = "lf";
        trim_leading_whitespace = true;
        indent_style = "space";
        indent_size = "2";
      };
      "*.py" = { indent_size = "4"; };
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

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentryFlavor = "gnome3";
  };

  # This spits out an SSH_AUTH_SOCK variable, 
  # which you have to put in the shell init.
  services.gnome-keyring = {
    enable = true;
    components = [ "ssh" "secrets" "pkcs11" ];
  };

  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/github";
      };
      "geheimesite.nl" = {
        hostname = "94.124.122.11";
        user = "robin";
        identityFile = "${config.home.homeDirectory}/.ssh/sweet";
      };
      "vps.geheimesite.nl" = {
        hostname = "45.140.190.5";
        user = "robin";
        identityFile = "${config.home.homeDirectory}/.ssh/sweet";
      };
      "git.geheimesite.nl" = {
        hostname = "45.140.190.5";
        port = 222;
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/github";
      };
    };
  };

  ## Graphical programs

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;

    font = {
      name = "monospace";
      size = 15;
    };
    settings = {
      enable_audio_bell = "no";
      remember_window_size = "no";
      window_padding_width = 30;
      confirm_os_window_close = 0;
      repaint_delay = 0;
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;

    extensions = [ ]; # TODO(robin): add later!
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
  };

  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11";
}
