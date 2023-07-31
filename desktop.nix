{ config, pkgs, lib, ... }:

let 
  ## Custom binaries

  wayland-dbus-environment = pkgs.writeTextFile {
    name = "wayland-dbus-environment";
    destination = "/bin/wayland-dbus-environment";
    executable = true;

    text = ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd SWAYSOCK \
        I3SOCK \
        WAYLAND_DISPLAY \
        DISPLAY \
        XCURSOR_SIZE \
        XCURSOR_THEME \
        DBUS_SESSION_BUS_ADDRESS \
        DBUS_SESSION_BUS_PID \
        DBUS_SESSION_BUS_WINDOWID \
        XAUTHORITY \
        DG_CURRENT_DESKTOP=sway

      ${pkgs.systemd}/bin/systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      ${pkgs.systemd}/bin/systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  wayland-gsettings = pkgs.writeTextFile {
    name = "wayland-gsettings";
    destination = "/bin/wayland-gsettings";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
    '';
  };

  wayland-screenshot = pkgs.writeTextFile {
    name = "wayland-screenshot";
    destination = "/bin/wayland-screenshot";
    executable = true;

    text = ''
      ${pkgs.slurp}/bin/slurp \
      | ${pkgs.grim}/bin/grim -g - - \
      | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.wl-clipboard}/bin/wl-paste \
      > ~/pictures/screenshots/$(date +'%Y-%m-%d-%H%M%S.png')
    '';
  };

  wayland-get-wallpaper = pkgs.writeTextFile {
    name = "wayland-get-wallpaper";
    destination = "/bin/wayland-get-wallpaper";
    executable = true;

    # Since gnome-control-center and GNOME wallpapers in general
    # don't work yet, I hard-code the wallpaper path here for now.

    # text = ''
    #   ${pkgs.glib}/bin/gsettings get org.gnome.desktop.background picture-uri \
    #   | ${pkgs.coreutils}/bin/cut -c 9- \
    #   | ${pkgs.util-linux}/bin/rev \
    #   | ${pkgs.coreutils}/bin/cut -c 2- \
    #   | ${pkgs.util-linux}/bin/rev
    # '';

    text = ''
    echo /home/robin/pictures/wallpaper.jpg
    '';
  };  

  gtk3-darkmode-daemon = pkgs.writeTextFile {
      name = "gtk3-darkmode-daemon";
      destination = "/bin/gtk3-darkmode-daemon";
      executable = true;

      # TODO(robin): refactor this.
      # This is currently duplicated from `wayland-gsettings`.

      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in  ''
        #!/bin/sh

        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS

        sync_darkmode() {
          GNOME_SCHEMA="org.gnome.desktop.interface"
          SCHEME=$(${pkgs.glib}/bin/gsettings get $GNOME_SCHEMA color-scheme)
          THEME=$(${pkgs.glib}/bin/gsettings get $GNOME_SCHEMA gtk-theme)

          if [ "$SCHEME" == "'default'" ]; then
            ${pkgs.glib}/bin/gsettings set $GNOME_SCHEMA gtk-theme "${gtk3-theme}"
          else
            ${pkgs.glib}/bin/gsettings set $GNOME_SCHEMA gtk-theme "${gtk3-theme}-dark";
          fi
        }

        # Initial sync
        sync_darkmode

        # Monitor gsettings to resync when the color scheme changes
        ${pkgs.glib}/bin/gsettings monitor org.gnome.desktop.interface gtk-theme |
        while read -r line; do
            sync_darkmode
        done
      '';
  };

  ## Global

  gtk3-theme = "adw-gtk3";
  terminal = "${pkgs.kitty}/bin/kitty";
  color-scheme.dark = "14141d";
  sway-systemd-target = "sway-session.target";

in {
  ## Packages

  home.packages = with pkgs; [
      wayland-dbus-environment
      wayland-gsettings
      wayland-screenshot
      wayland-get-wallpaper
      
      # Utilities
      grim
      slurp
      clipman
      playerctl
      wl-clipboard
      
      # Sway services
      swaybg
      gtk3-darkmode-daemon
      autotiling
      swayest-workstyle
      wob

      # Misc
      gsettings-desktop-schemas # Used in `wayland-gsettings`.
      sound-theme-freedesktop # Used in mako config.
  ];

  programs.foot.enable = false;  # Don't install foot!!


  ## Launcher

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    cycle = true;
    terminal = terminal;
    extraConfig = {
      modes = [ "combi" ];
      combi-modes =  [ "drun" "run" ];
      show-icons = false;
      display-drun = "";
      drun-display-format = "{name}";
      disable-history = false;
      fullscreen = false;
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        background-color = mkLiteral "#285577";
      };
      "window" = {
        anchor = "center";
        location = "north";
        border = 2;
        border-color = mkLiteral "#4C7899";
        padding = 5;
        y-offset = mkLiteral "46px";
      };
      "mainbox" = {
        border = 0;
	      padding = 0;
      };
      "textbox" = {
        text-color = mkLiteral "#FFFFFF";
      };
      "listview" = {
        fixed-height = 0;
        spacing = mkLiteral "2px";
        scrollbar = true;
      };
      "element" = {
        border = 0;
	      padding = mkLiteral "1px";
      };
      "element-text" = {
        background-color = mkLiteral "inherit";
	      text-color = mkLiteral "inherit";
      };
      "element.normal" = {
        background-color = mkLiteral "#285577";
	      text-color = mkLiteral "#FFFFFF";
      };
      "element.selected" = {
        background-color = mkLiteral "#4C7899";
	      text-color = mkLiteral "#FFFFFF";
      };
      "scrollbar" = {
        width = mkLiteral "4px";
	      border = 0;
	      handle-width = mkLiteral "8px";
	      padding = 0;
      };
      "button.selected" = {
        background-color = mkLiteral "#4C7899";
	      text-color = mkLiteral "#FFFFFF";
      };
      "inputbar" = {
        spacing = 0;
        text-color = mkLiteral "#FFFFFF";
        background-color = mkLiteral "#285577";
        padding = mkLiteral "1px";
        children = [ 
          (mkLiteral "entry")
          (mkLiteral "case-indicator")
        ];
      };
      "case-indicator" = {
        spacing = 0;
	      text-color = mkLiteral "#FFFFFF";
      };
      "entry" = {
        spacing = 0;
	      text-color = mkLiteral "#FFFFFF";
      };
      "prompt" = {
        scaling = 0;
	      text-color = mkLiteral "#FFFFFF";
      };
    };
  };


  ## Services

  # Setup monitor managment
  # (binds to systemd)
  services.kanshi = {
    enable = true;
    systemdTarget = sway-systemd-target;
    profiles = {
      vm = {
        outputs = [
          {
            criteria = "Virtual-1";
            mode = "1920x1090";
            position = "0,0";
          }
        ];
      };
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1090";
            position = "0,0";
          }          
        ];
      };
      home-two-displays = {
        outputs = [
          {
            criteria = "Arnos Insturments & Computer Systems LE-22 00112";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            mode = "1920x1090";
            position = "0,1080";
          }
        ];
      };
      work-three-displays = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1090";
            position = "5120,0";
          }
          {
            criteria = "DP-1";
            mode = "2560x1440";
            position = "2560,0";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "0,0";
          }
        ];
      };
      work-singe-display = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            mode = "2560x1440";
            position = "2560,0";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "0,0";
          }
        ];
      };
    };
  };
  
  # Idle management with swaylock integration
  # (binds to systemd)
  services.swayidle = {
    enable = true;
    systemdTarget = sway-systemd-target;
    extraArgs = [ "-w" ];
    events = [
      {
        event = "before-sleep";
        command = "swaylock --image $(wayland-get-wallpaper)";
      }
    ];
  };

  # Notification daemon
  # (doesn't bind to systemd, see below)
  services.mako = {
    enable = true;
    anchor = "top-right";
    defaultTimeout = 10000;
    # extraConfig = [
    #   "on-notify=exec mpv /usr/share/sounds/freedesktop/stereo/message.oga"
    # ]
  };

  # Create systemd service files for services
  # that don't bind to systemd themselves.

  systemd.user.services.mako = {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      Documentation = [ "man:mako(1)" ];
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecCondition = "/bin/sh -c '[ -n \"$WAYLAND_DISPLAY\" ]'";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
    };
    Install = {
      WantedBy = [ sway-systemd-target ];
    };
  };

  systemd.user.services.autotiling = {
    Unit = {
      Description = "Script for sway and i3 to automatically switch the horizontal / vertical window split orientation ";
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart= "${pkgs.autotiling}/bin/autotiling";
    };
    Install = {
      WantedBy = [ sway-systemd-target ];
    };
  };

  systemd.user.services.sworkstyle = {
    Unit = {
      Description = "Dynamic workspace names based on open windows";
      Documentation = [ "man:sworkstyle(1)" ];
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart= "${pkgs.swayest-workstyle}/bin/sworkstyle";
    };
    Install = {
      WantedBy = [ sway-systemd-target ];
    };
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wallpaper setter for sway";
      Documentation = [ "man:swaybg(1)" ];
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c '${pkgs.sway}/bin/swaymsg output \\* bg $(${wayland-get-wallpaper}/bin/wayland-get-wallpaper) fill'";
    };
    Install = {
      WantedBy = [ sway-systemd-target ];
    };
  };

  systemd.user.services.gtk3-darkmode-daemon = {
    Unit = {
      Description = "Simple daemon set the GTK theme based on the dark mode preference in GNOME";
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart= "${gtk3-darkmode-daemon}/bin/gtk3-darkmode-daemon";
    };
    Install = {
      WantedBy = [ sway-systemd-target ];
    };
  };
  
  systemd.user.services.playerctld = {
    Unit = {
      Description = "Control media players via MPRIS";
      Documentation = [ "man:playerctl(1)" ];
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart= "${pkgs.playerctl}/bin/playerctld";
    };
    Install = {
      WantedBy = [ sway-systemd-target ];
    };
  };


  ## Window manager

  wayland.windowManager.sway = 
    let mod = "Mod4"; in {
    enable = true;
    package = null; # Managed in configuration.nix

    xwayland = true;
    config = {
      modifier = mod;
      terminal = terminal;
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
          dwt = "disabled";
        };
        "*" = {
          scroll_factor = "0.2"; # Only for VMs
          xkb_layout = "us";
          xkb_variant = "intl";
        };
      };
      focus = {
        followMouse = true;
        wrapping = "workspace";
        newWindow = "urgent"; # Mark new windows as urgent (red in workspace bar), but don't let them steal focus.
      };
      bars = [
        {
          colors = {
            # iceberg
            background = "#${color-scheme.dark}";
            
            # windows
            # background = "#d1e5ef";
            # focusedWorkspace "#eef3f8 #eef3f8 #282A36";
            # inactiveWorkspace = "#d1e5ef #d1e5ef #282A36";
          };
          
          extraConfig = ''
            height 40
            workspace_min_width 40
            font pango:FontAwesome 13
          '';

          position = "bottom";
          
          # bumblebee-status hasn't been packaged for NixOS yet :(
          # See https://github.com/tobi-wan-kenobi/bumblebee-status/issues/821

          # When it will be packaged, I'd need to add a little script or something,
          # that copies my iceberg-contrast-padding theme to /usr/share/bumblebee-status/themes/

          # statusCommand = "/usr/bin/bumblebee-status --theme iceberg-contrast-padding";
        }
      ];
      gaps = {
        # inner = 10;
        # outer = 5;
        smartBorders = "no_gaps";
        smartGaps = true;
      };
      window = {
        hideEdgeBorders = "smart";
        titlebar = false;
      };
      keybindings =
        lib.mkOptionDefault {
          # Alt-Tab to switch between workspaces
          "Mod1+Tab" = "workspace back_and_forth";
          "${mod}+Tab" = "workspace back_and_forth";

          # Ctrl+Tab to cycle windows in tabbed mode
          # "Control+Tab" = "focus next"; 

          # Start terminal
          "Mod1+Return" = "exec ${terminal}";
          "${mod}+Return" = "exec ${terminal}";

          # Super+q to close window
          "${mod}+q" = "kill";

          # Screenshotting
          "${mod}+Shift+s" = "exec wayland-screenshot";

          # Screen locking
          "${mod}+l" = "exec swaylock --grace 0 --image $(gsettings get org.gnome.desktop.background picture-uri | cut -c 9- | rev | cut -c 2- | rev)";

          # Reload & exit
          "Control+Mod1+r" = "reload";
          "Control+Mod1+q" = "exec swaymsg exit";

          # Workspace management
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "Mod1+Control+Right" = "workspace next";
          "Mod1+Control+Left" = "workspace prev";

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          "${mod}+Control+Left" = "resize grow width 10 px or 10 ppt";
          "${mod}+Control+Down" = "resize shrink height 10 px or 10 ppt";
          "${mod}+Control+Up" = "resize grow height 10 px or 10 ppt";
          "${mod}+Control+Right" = "resize shrink width 10 px or 10 ppt";

          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          # Window state management
          "${mod}+t" = "layout toggle tabbed splitv"; # Toggle tabbed mode        
          "${mod}+f" = "floating toggle"; # Toggle floating
          "${mod}+j" = "minimize toggle"; # Minimize applications        
          "F11" = "fullscreen toggle"; # Toggle fullscreen

          # Scratchpad
          "${mod}+Shift+BackSpace" = "move scratchpad";
          "${mod}+BackSpace" = "scratchpad show";
      };
      startup = 
        let gnome-schema = "org.gnome.desktop.interface"; 
        in [
        # Setup wayland session
        { command = "wayland-dbus-environment"; }
        { command = "wayland-gsettings"; }

        # Font settings
        { command = "gsettings set ${gnome-schema} font-name 'Inter'"; }
        { command = "gsettings set ${gnome-schema} document-font-name 'Inter'"; }
        { command = "gsettings set ${gnome-schema} font-antialiasing 'grayscale'"; }
        { command = "gsettings set ${gnome-schema} font-hinting 'slight'"; }

        # Disable audible bell
        { 
          command = "gsettings set org.gnome.desktop.wm.preferences audible-bell false"; 
          # (Determines whether applications or the system can generate audible “beeps”; may be used in conjunction with “visual bell” to allow silent “beeps”.)
        }
        
        # Prepare overlay image for swaylock
        # (See swaylock config for more info)
        { 
          command = "convert -size 1920x60 xc:transparent -font Liberation-Sans -pointsize 26 -fill white -gravity center -annotate +0+0 'Type password to unlock' /tmp/locktext.png"; 
        }

        # Clipboard
        { command = "wl-paste -t text --watch clipman store"; }

        # Wallpaper
        # ('always = true' is here to make wallpaper refresh
        # when sway is reloaded)
        { command = "systemctl --user start swaybg"; always = true; }

        # Set GTK theming
        # TODO(robin): replace this with a time-based daemon later.
        { command = "gsettings set org.gnome.desktop.interface.gtk-theme '${gtk3-theme}'"; }
        { command = "gsettings set org.gnome.desktop.interface.color-scheme 'default'"; }

        # Cool windows logo for first workspace
        # { command = "swaymsg rename workspace number 0 to "; }

        # (The sway systemd target is automagically started,
        # we don't have to start it manually here)
      ];
    };

    # Options that couldn't be configured using Home Manager.
    extraConfigEarly = ''
        # Start Rofi when pressing the Super key, because that is how it 
        # works on Windows and that is how my workflow works :)
        bindcode --release 133 exec rofi -show drun

        # Autostart Spotify & configure scatchpad
        exec --no-startup-id spotify
        for_window [class="Spotify"] move scratchpad, resize set 1880 1010;
        bindsym ${mod}+equal [class="Spotify"] scratchpad show

        # Setup wob
        set $WOBSOCK $XDG_RUNTIME_DIR/wob.sock
        exec rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | wob

        # Media control (--locked is not available in Home Manager)
        bindsym --locked ${mod}+p                exec playerctl play-pause
        bindsym --locked ${mod}+less             exec playerctl previous
        bindsym --locked ${mod}+greater          exec playerctl next

        bindsym --locked XF86AudioPlay           exec playerctl play-pause
        bindsym --locked XF86AudioPause          exec playerctl pause
        bindsym --locked XF86AudioNext           exec playerctl next
        bindsym --locked XF86AudioPrev           exec playerctl previous
    '';
  };


  ## Lock screen

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;

    settings = {
      ignore-empty-password = true;
      clock = true;
      font = "Liberation-Sans";
      timestr = "%H:%M";
      datestr = "%d/%m/%Y";
      scaling = "fill";
      indicator = true;
      grace = 2;

      # This imsage is generated when sway is started.
      # It is a little overlay that says "Type password to unlock", that I kinda like because pwetty.
      effect-compose = "50%,70%;center;/tmp/locktext.png";
      effect-blur = "7x7";

      color = color-scheme.dark;
      text-color = "FFFFFF";
      key-hl-color = "009193";
      separator-color = "00000000";
      inside-color = "00000099";
      inside-clear-color = "FFD20400";
      inside-caps-color = "009DDC00";
      inside-ver-color = "D9D8d800";
      inside-wrong-color = "EE2E2400";
      ring-color = "231F20D9";
      ring-clear-color = "231F20D9";
      ring-caps-lock-color = "231F20D9";
      ring-ver-color = "231F20D9";
      ring-wrong-color = "231F20D9";
      line-color = "00000000";
      line-clear-color = "FFD204FF";
      line-caps-lock-color = "009DDCFF";
      line-ver-color = "D9D8D8FF";
      line-wrong-color = "EE2E24FF";
      text-clear-color = "FFD20400";
      text-ver-color = "D9D8D800";
      text-wrong-color = "EE2E400";
      bs-hl-color = "EE2E24FF";
      caps-lock-key-hl-color = "FFD204FF";
      caps-lock-key-bs-color = "EE2E24FF";
      disable-caps-lock-text = true;
      text-caps-lock-color = "009ddc";
    };
  };
}