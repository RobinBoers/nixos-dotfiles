{ config, pkgs, lib, ... }:

let 
  ## Global
  
  # Colorscheme
  # (Used in TTY and kitty)
  color-scheme = {
    bg = "0d1117";
    fg = "c9d1d9";
    color0 = "0d1117";
    color1 = "ff7b72";
    color2 = "3fb950";
    color3 = "ffc300";
    color4 = "58a6ff";
    color5 = "bc8cff";
    color6 = "39c5cf";
    color7 = "c9d1d9";
    color8 = "484f58";
    color9 = "ff7b72";
    color10 = "3fb950";
    color11 = "ffc300";
    color12 = "58a6ff";
    color13 = "bc8cff";
    color14 = "39c5cf";
    color15 = "ffffff";
  };

in {
  imports = [
    ./desktop.nix
    ./neovim.nix
  ];

  home.username = "robin";
  home.homeDirectory = "/home/robin";


  ## Packages
  
  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  home.packages = with pkgs; [
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')    

    # CLI tools
    yt-dlp
    lazygit
    thefuck

    # Graphical applications
    gnome.nautilus
    libreoffice
    xarchiver
    feh
    librewolf
    ungoogled-chromium
    baobab
    celluloid
    filezilla
    vscode
    spotify
    discord
    minecraft
  ];

  # Append .local/bin to the path
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];


  ## Shell

  home.sessionVariables = {
    SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket";
    GTK_OVERLAY_SCROLLING = "1";
    ERL_AFLAGS = "-kernel shell_history enabled";
    ELIXIR_ERL_OPTIONS = "-kernel start_pg true shell_history enabled";
  };

  home.shellAliases = {
    sudo = "doas";
    sudoedit = "doas $EDITOR";
    cat = "bat";
    ls = "exa";
    tree = "exa -T";
    feh = "feh -Z --scale-down";
    ":q" = "exit";
    ":Q" = "exit";

    # Secrets management
    secrets = "git --git-dir=${config.home.homeDirectory}/.secrets/ --work-tree=${config.home.homeDirectory}";
    secrets-manage = "lazygit --git-dir=${config.home.homeDirectory}/.secrets/ --work-tree=${config.home.homeDirectory}";

    # Shortcuts
    rm = "rm -ri";
    cp = "cp -i";
    mv = "mv -i";
    ".." = "cd ..";
    less = "less -QFr";
  };

  programs.fish = {
    enable = true;
    
    shellAliases = config.home.shellAliases;
    shellInit = ''
      # Disable welcome message when logging in
      set fish_greeting

      # Enable amazing 'fuck' command
      thefuck --alias | source

      # Fancy TTY color scheme.
      echo -e "
        \e]P0${color-scheme.color0}
        \e]P1${color-scheme.color1}
        \e]P2${color-scheme.color2}
        \e]P3${color-scheme.color3}
        \e]P4${color-scheme.color4}
        \e]P5${color-scheme.color5}
        \e]P6${color-scheme.color6}
        \e]P7${color-scheme.color7}
        \e]P8${color-scheme.color8}
        \e]P9${color-scheme.color9}
        \e]PA${color-scheme.color10}
        \e]PB${color-scheme.color11}
        \e]PC${color-scheme.color12}
        \e]PD${color-scheme.color13}
        \e]PE${color-scheme.color14}
        \e]PF${color-scheme.color15}
        "
      clear
    '';
  };


  ## XDG directories

  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    documents = "${config.home.homeDirectory}/docs";
    pictures = "${config.home.homeDirectory}/pictures";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/music";
    videos = "${config.home.homeDirectory}/videoarchive";
  };


  ## Git

  programs.git = {
    enable = true;

    userName = "Robin Boers";
    userEmail = "robindev2019@outlook.com";
    signing = {
      key = "7EBA7FEA236B1DB0";
      signByDefault = true;
    };

    extraConfig = {
      core = {
        hooksPath = "${config.home.homeDirectory}/.githooks";
      };
      init = {
        defaultBranch = "master";
      };
      pull = {
        rebase = false;
        ff = "only";
      };
      aliases = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        cp = "cherry-pick";
        h = "log --graph --date=default-local --pretty=format:'%C(yellow)%h%C(reset) %C(green)%cd%C(reset) %C(blue)%an%C(reset)%C(red)%d%C(reset) %s'";
        ha = "h --all";
        prune-br = "! git fetch --all --prune && git branch -vv | grep '\\(origin\\|fork\\|src\\)/.*: gone]' | awk '{print $1}' | xargs git branch -D";
        git = "!git";
      };
    };

    # Use delta for 'git diff'
    delta = {
      enable = true;
      options = {
        decorations = {
          commit-decoration-style = "blue ol";
          commit-style = "raw";
          file-style = "omit";
          hunk-header-decoration-style = "blue box";
          hunk-header-file-style = "red";
          hunk-header-style = "file line-number syntax";
        };
        features = "decorations";
        nagivate = "true"; #Use n and N to jump between sections
        interactive = {
          keep-plus-minus-markers = false;
          side-by-side = true;
          line-numbers = true;
        };
      };
    };
  };

  programs.gh = {
    enable = true;

    enableGitCredentialHelper = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };


  ## Coding

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
      "*.py" = {
        indent_size = "4";
      };
    };
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false; # Don't let VSCode manage extensions.
    extensions = with pkgs.vscode-extensions; [
      elixir-lsp.vscode-elixir-ls
      github.github-vscode-theme
      eamodio.gitlens
      ms-vsliveshare.vsliveshare
      davidanson.vscode-markdownlint
      christian-kohler.path-intellisense
      phoenixframework.phoenix
      esbenp.prettier-vscode
      bradlc.vscode-tailwindcss
      vscode-icons-team.vscode-icons
      redhat.vscode-xml
      redhat.vscode-yaml
      tamasfe.even-better-toml
      formulahendry.auto-rename-tag
      formulahendry.auto-close-tag
      kamikillerto.vscode-colorize
      piousdeer.adwaita-theme
      dbaeumer.vscode-eslint
      rust-lang.rust-analyzer
    ];
  };


  ## Passwords

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland;
    
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.passwords";
    };
  };


  ## SSH

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


  ## Terminal

  programs.kitty = {
    enable = true;

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
      background = "#${color-scheme.bg}";
      foreground = "#${color-scheme.fg}";
      selection_foreground = "#${color-scheme.bg}";
      selection_background = "#${color-scheme.fg}";
      cursor = "#${color-scheme.fg}";
      color0 = "#${color-scheme.color0}";
      color1 = "#${color-scheme.color1}";
      color2 = "#${color-scheme.color2}";
      color3 = "#${color-scheme.color3}";
      color4 = "#${color-scheme.color4}";
      color5 = "#${color-scheme.color5}";
      color6 = "#${color-scheme.color6}";
      color7 = "#${color-scheme.color7}";
      color8 = "#${color-scheme.color8}";
      color9 = "#${color-scheme.color9}";
      color10 = "#${color-scheme.color10}";
      color11 = "#${color-scheme.color11}";
      color12 = "#${color-scheme.color12}";
      color13 = "#${color-scheme.color13}";
      color14 = "#${color-scheme.color14}";
      color15 = "#${color-scheme.color15}";
    };
    shellIntegration.enableFishIntegration = true;
  };

  programs.bat = {
    enable = true; 

    config = {
      theme = "base16";
      italic-text = "always";
      paging = "never";
      style = "plain";
      color = "always";
    };
  };

  programs.exa = {
    enable = true;

    enableAliases = true;
    extraOptions = [ "--group-directories-first" ];
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;

    enableFishIntegration = true;
    settings = {
      add_newline = false;
      line_break = {
      	disabled = true;
      };
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
        vimcmd_symbol = "[<](bold green)";
      };
      git_commit = {
        tag_symbol = " tag ";
      };
      git_status = {
        ahead = ">";
        behind = "<";
        diverged = "<>";
        renamed = "r";
        deleted = "x";
      };
      directory = {
        read_only = " ro";
      };
      git_branch = {
        symbol = "git ";
      };
      memory_usage = {
        symbol = "mem ";
      };
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$directory"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$cmake"
        "$meson"
        "$memory_usage"
        "$battery"
        "$env_var"
        "$cmd_duration"
        "$status"
        "$character"
      ];
    };
  };


  ## Misc

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;

    extensions = []; # TODO: add later!
  };

  gtk = {
    enable = true;

    gtk3 = {
      bookmarks = [
        "file://${config.home.homeDirectory}/projects"
        "file://${config.home.homeDirectory}/projects/qdentity"
        "file://${config.home.homeDirectory}/pictures/screenshots"
        "file://${config.home.homeDirectory}/games"
      ];
      extraConfig = {
        gtk-button-images = "1";
        gtk-menu-images = "1";
        gtk-enable-event-sounds = "1";
        gtk-enable-input-feedback-sounds = "1";
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-cursor-theme-size = "0";
        gtk-xft-antialias = "1";
        gtk-xft-hinting = "1";
        gtk-xft-hintstyle = "hintful";
      };
    };
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".githooks/pre-push".text = ''
      #!/bin/sh
      bix pre-push
    '';
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