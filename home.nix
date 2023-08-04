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

  newt-color-scheme = ''
    root=lightgray,default
    border=blue,default
    window=lightgray,default
    shadow=default,default
    title=lightgray,default
    button=black,blue
    actbutton=blue,black
    compactbutton=black,lightgray
    checkbox=lightgray,black
    actcheckbox=lightgray,cyan
    entry=lightgray,default
    disentry=gray,default
    label=lightgray,default
    listbox=lightgray,default
    actlistbox=blue,default
    sellistbox=lightgray,default
    actsellistbox=black,blue
    textbox=black,lightgray
    acttextbox=black,blue
    emptyscale=,gray
    fullscale=,cyan
    helpline=white,default
    roottext=lightgrey,default
  '';

  dialog-color-scheme = ''
    aspect = 0
    separate_widget = ""
    tab_len = 0
    visit_items = OFF
    use_scrollbar = OFF
    use_shadow = OFF
    use_colors = ON
    screen_color = (BLUE,BLACK,ON)
    shadow_color = (WHITE,BLACK,OFF)
    dialog_color = (WHITE,BLACK,OFF)
    title_color = (WHITE,BLACK,ON)
    border_color = (BLUE,BLACK,ON)
    button_active_color = (BLACK,BLUE,ON)
    button_inactive_color = (BLACK,WHITE,ON)
    button_key_active_color = button_active_color
    button_key_inactive_color = (RED,WHITE,OFF)
    button_label_active_color = (WHITE,BLUE,ON)
    button_label_inactive_color = (BLACK,WHITE,ON)
    inputbox_color = (WHITE,BLACK,OFF)
    inputbox_border_color = (WHITE,BLACK,OFF)
    searchbox_color = border_color
    searchbox_title_color = title_color
    searchbox_border_color = border_color
    position_indicator_color = title_color
    menubox_color = (WHITE,BLACK,OFF)
    menubox_border_color = border_color
    item_color = (WHITE,BLACK,OFF)
    item_selected_color = button_active_color
    tag_color = title_color
    tag_selected_color = button_label_active_color
    tag_key_color = button_key_inactive_color
    tag_key_selected_color = (RED,BLUE,ON)
    check_color = (WHITE,BLACK,OFF)
    check_selected_color = button_active_color
    uarrow_color = (GREEN,WHITE,ON)
    darrow_color = uarrow_color
    itemhelp_color = (WHITE,BLACK,OFF)
    form_active_text_color = button_active_color
    form_text_color = (WHITE,CYAN,ON)
    form_item_readonly_color = (CYAN,WHITE,ON)
    gauge_color = title_color
    border2_color = border_color
    inputbox_border2_color = border_color
    searchbox_border2_color = border_color
    menubox_border2_color = border_color
  '';

  home-directory = "/home/robin";
  script-directory = "${home-directory}/sd";

in {
  imports = [ ./desktop.nix ./neovim.nix ];

  home.username = "robin";
  home.homeDirectory = home-directory;

  ## Packages

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  home.packages = with pkgs; [
    # CLI tools
    yt-dlp
    lazygit
    thefuck
    git-remote-gcrypt

    # Languages
    elixir_1_15
    nixfmt

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
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  ## Shell

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

  programs.fish = {
    enable = true;

    shellAliases = config.home.shellAliases;
    shellInit = ''
      # Disable welcome message
      set fish_greeting

      # Enable amazing 'fuck' command
      thefuck --alias | source

      # Environment/session variables
      export NEWT_COLORS="${newt-color-scheme}"
      export DEFAULT_BROWSER="${pkgs.librewolf}/bin/qutebrowser"    # Needed for Electron apps
      export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh    # See gnome-keyring section
      
      export GTK_OVERLAY_SCROLLING=1;
      export ERL_AFLAGS="-kernel shell_history enabled"
      export ELIXIR_ERL_OPTIONS="-kernel start_pg true shell_history enabled"
      export DIRENV_LOG_FORMAT=""   # Disable annoying direnv output

      # Fancy TTY color scheme.
      if test $TERM = "linux"
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
      end
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

  ## Git

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
        nagivate = "true"; # Use n and N to jump between sections
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

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = { co = "pr checkout"; };
    };

    # This is only for HTTPS, and I only use SSH anyways
    enableGitCredentialHelper = false;   
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
      "*.py" = { indent_size = "4"; };
    };
  };

  programs.vscode = let
    system = builtins.currentSystem;
    extensions = (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "c43d9089df96cf8aca157762ed0e2ddca9fcd71e";
    })).extensions.${system};
  in {
    enable = true;
    enableUpdateCheck = false;
    mutableExtensionsDir =
      false; # Don't let VSCode itself manage extensions, but instead force extensions to be installed via this file.
    extensions = with extensions.vscode-marketplace; [
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
      miguelsolorio.fluent-icons
      tombonnike.vscode-status-bar-format-toggle
      jakebecker.elixir-ls
    ];
    userSettings = {
      # Global
      "window"."restoreWindows" = "folders";
      "editor"."wordWrap" = "on";
      "editor"."formatOnSave" = true;
      "editor"."formatOnPaste" = true;
      "editor"."formatOnType" = true;
      "editor"."tabSize" = 2;

      # Theming / setup
      "workbench"."colorTheme" = "Adwaita Dark";
      "window"."autoDetectColorScheme" = true;
      "workbench"."preferredDarkColorTheme" = "Adwaita Dark";
      "workbench"."preferredLightColorTheme" = "Adwaita Dark";
      "editor"."fontFamily" = "monospace";
      "editor"."fontLigatures" = true;
      "editor"."fontSize" = 23;
      "editor"."bracketPairColorization"."enabled" = false;
      "terminal"."integrated"."fontSize" = 23;
      "workbench"."iconTheme" = "vscode-icons";
      "workbench"."productIconTheme" = "fluent-icons";
      "window"."nativeTabs" = true;
      "window"."title" =
        "\${dirty}\${activeEditorLong}\${separator}\${appName}\${separator}\${remoteName}";
      "window"."titleSeparator" = " — ";
      "window"."menuBarVisibility" = "compact";
      "window"."titleBarStyle" = "custom";
      "editor"."cursorBlinking" = "phase";
      "editor"."cursorSmoothCaretAnimation" = "on";
      "window"."zoomLevel" = -1;

      # Base configuration / sensible defaults
      "workbench"."editor"."untitled"."experimentalLanguageDetection" = true;
      "workbench"."tips"."enabled" = false;
      "redhat"."telemetry"."enabled" = false;
      "security"."workspace"."trust"."untrustedFiles" = "open";
      "terminal"."integrated"."enableMultiLinePasteWarning" = false;
      "terminal"."integrated"."persistentSessionReviveProcess" = "never";
      "git"."enableCommitSigning" = true;
      "editor"."unicodeHighlight"."allowedCharacters" = {
        "❯" = true;
        "❮" = true;
      };
      "markdownlint"."config" = {
        "MD030" = false;
        "MD045" = false;
        "MD036" = false;
        "MD026" = false;
        "MD041" = false;
        "MD033" = false;
        "MD024" = false;
      };
      "editor"."selectionClipboard" = false;
      "editor"."defaultFormatter" = "esbenp.prettier-vscode";
      "rust-analyzer"."checkOnSave"."command" = "clippy";
      "colorize"."include" = [ "*" ];
      "css"."lint"."zeroUnits" = "warning";
      "css"."lint"."ieHack" = "warning";
      "css"."lint"."unknownAtRules" = "ignore";
      "remoteHub"."commitDirectlyWarning" = "off";
      "explorer"."confirmDelete" = false;
      "git"."autofetch" = true;
      "git"."enableSmartCommit" = true;
      "diffEditor"."ignoreTrimWhitespace" = false;
      "explorer"."confirmDragAndDrop" = false;
      "workbench"."startupEditor" = "none";
      "git"."confirmSync" = false;
      "git"."openRepositoryInParentFolders" = "always";
      "editor"."inlayHints"."enabled" = "off";

      # Extensions
      "gitlens"."hovers"."currentLine"."over" = "line";
      "gitlens"."currentLine"."enabled" = false;
      "gitlens"."defaultDateShortFormat" = "D MMMM YYYY";
      "gitlens"."defaultTimeFormat" = "H:MM";
      "gitlens"."defaultDateFormat" = "D MMMM YYYY; H:MM";
      "gitlens"."codeLens"."enabled" = false;
      #"python"."defaultInterpreterPath" = "/bin/python3";
      "cSpell"."enabled" = false;
      "elixirLS"."suggestSpecs" = false;
      "elixirLS"."dialyzerEnabled" = false;
      "elixirLS"."fetchDeps" = false;
      "vsicons"."dontShowNewVersionMessage" = true;
      "[json]" = {
        "editor"."defaultFormatter" = "vscode.json-language-features";
      };
      "[xml]" = { "editor"."defaultFormatter" = "redhat.vscode-xml"; };
      "[elixir]" = { "editor"."defaultFormatter" = "JakeBecker.elixir-ls"; };
      "[phoenix-heex]" = {
        "editor"."defaultFormatter" = "JakeBecker.elixir-ls";
      };
      "[eex]" = { "editor"."defaultFormatter" = "JakeBecker.elixir-ls"; };
      "[css]" = { "editor"."defaultFormatter" = "esbenp.prettier-vscode"; };
      "[xsl]" = { "editor"."defaultFormatter" = "redhat.vscode-xml"; };
      "[python]" = { "editor"."formatOnType" = true; };
      "[toml]" = { "editor"."defaultFormatter" = "tamasfe.even-better-toml"; };
      "emmet"."includeLanguages" = { "phoenix-heex" = "html"; };
      "tailwindCSS"."includeLanguages" = {
        "elixir" = "html";
        "phoenix-heex" = "html";
      };
      "yaml"."validate" = false;
      "files"."associations" = {
        "**/"."i3/config" = "i3";
        "**/i3/config" = "i3";
        "**/"."sway/config" = "i3";
        "**/sway/config" = "i3";
        "**/"."i3status/config" = "i3";
        "**/i3status/config" = "i3";
        "**/"."i3lock/config" = "i3";
        "**/i3lock/config" = "i3";
        "**/"."swaylock/config" = "i3";
        "**/swaylock/config" = "i3";
        "*"."heex" = "phoenix-heex";
        "*"."grape" = "dart";
      };
    };
  };

  programs.script-directory = {
    enable = true;
    settings = {
      SD_ROOT = script-directory;
    };
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
      line_break = { disabled = true; };
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
        vimcmd_symbol = "[<](bold green)";
      };
      git_commit = { tag_symbol = " tag "; };
      git_status = {
        ahead = ">";
        behind = "<";
        diverged = "<>";
        renamed = "r";
        deleted = "x";
      };
      directory = { read_only = " ro"; };
      git_branch = { symbol = "git "; };
      memory_usage = { symbol = "mem "; };
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$directory"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_status"
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

    extensions = [ ]; # TODO: add later!
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

    ".dialogrc".text = dialog-color-scheme;

    ".githooks/pre-push".text = ''
      #!/bin/sh
      bix pre-push
    '';

    ".config/fish/completions/sd.fish".text = ''
     # Completions for the custom Script Directory (sd) script

     # These are based on the contents of the Script Directory, so we're reading info from the files.
     # The description is taken either from the first line of the file $cmd.help,
     # or the first non-shebang comment in the $cmd file.

     # Disable file completions
     complete -c sd -f

     # Create command completions for a subcommand
     # Takes a list of all the subcommands seen so far
     function __list_subcommand
         # Handles fully nested subcommands
         set basepath (string join '/' ${script-directory} $argv)
          # Total subcommands
         # Used so that we can ignore duplicate commands
         set -l commands
         for file in (ls -d $basepath/*)
             set cmd (basename $file .help)
             set helpfile $cmd.help
             if [ (basename $file) != "$helpfile" ]
                 set commands $commands $cmd
             end
         end
          # Setup the check for when to show these commands
         # Basically you need to have seen everything in the path up to this point but not any commands in the current irectory.
         # This will cause problems if you have a command with the same name as a directory parent.
         set check
         for arg in $argv
             set check (string join ' and ' $check "__fish_seen_subcommand_from $arg;")
         end
         set check (string join ' ' $check "and not __fish_seen_subcommand_from $commands")
          # Loop through the files using their full path names.
         for file in (ls -d $basepath/*)
             set cmd (basename $file .help)
             set helpfile $cmd.help
             if [ (basename $file) = "$helpfile" ]
                 # This is the helpfile, use it for the help statement
                 set help (head -n1 "$file")
                 complete -c sd -a "$cmd" -d "$help" \
                     -n $check
             else if test -d "$file"
                 set help "$cmd commands"
                 __list_subcommand $argv $cmd
                 complete -c sd -a "$cmd" -d "$help" \
                     -n "$check"
             else
                 set help (sed -nE -e '/^#!/d' -e '/^#/{s/^# *//; p; q;}' "$file")
                 if not test -e "$helpfile"
                     complete -c sd -a "$cmd" -d "$help" \
                         -n "$check"
                 end
             end
         end
     end

     function __list_commands
         # commands is used in the completions to know if we've seen the base commands
         set -l commands
         # Create a list of commands for this directory.
         # The list is used to know when to not show more commands from this directory.
         for file in $argv
             set cmd (basename $file .help)
             set helpfile $cmd.help
             if [ (basename $file) != "$helpfile" ]
                 # Ignore the special commands that take the paths as input.
                 if not contains $cmd cat edit help new which
                     set commands $commands $cmd
                 end
             end
         end
         for file in $argv
             set cmd (basename $file .help)
             set helpfile $cmd.help
             if [ (basename $file) = "$helpfile" ]
                 # This is the helpfile, use it for the help statement
                 set help (head -n1 "$file")
                 complete -c sd -a "$cmd" -d "$help" \
                     -n "not __fish_seen_subcommand_from $commands"
             else if test -d "$file"
                 # Directory, start recursing into subcommands
                 set help "$cmd commands"
                 __list_subcommand $cmd
                complete -c sd -a "$cmd" -d "$help" \
                     -n "not __fish_seen_subcommand_from $commands"
             else
                  # Script
                # Pull the help text from the first non-shebang commented line.
                 set help (sed -nE -e '/^#!/d' -e '/^#/{s/^# *//; p; q;}' "$file")
                  if not test -e "$helpfile"
                     complete -c sd -a "$cmd" -d "$help" \
                         -n "not __fish_seen_subcommand_from $commands"
                 end
             end
         end
     end

      # Hardcode the starting directory
     __list_commands ${script-directory}/*
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
