{ config, pkgs, lib, ... }:

let 
  terminal = "${pkgs.kitty}/bin/kitty";
  extensions = with pkgs.gnomeExtensions; [
    blur-my-shell
    rounded-window-corners
    dock-from-dash
    unite
    impatience
  ]; 

  apps = with pkgs; [
    shortwave
    baobab
  ];
in {
  home.packages = extensions ++ apps; 

  home.file.".local/share/applications/gnome-control-center.desktop".text = ''
    [Desktop Entry]
    Name=Settings
    Icon=preferences-system
    Exec=gnome-control-center
    Terminal=false
    Type=Application
    StartupNotify=true
    Categories=GNOME;GTK;Settings;
    Keywords=Preferences;Settings;
    NotShowIn=GNOME;
  '';

  dconf.settings = {
    # Overview
    "org/gnome/shell" = {
      favorite-apps = [
        "librewolf.desktop"
        "md.obsidian.Obsidian.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
        "discord.desktop"
        "de.haeckerfelix.Shortwave.desktop"
        "code.desktop"
        "kitty.desktop"
      ];

      command-history = ["shutdown now"];

      app-picker-layout = 
        "[{'f2d32015-8b1b-4c33-8695-413a8a950e78': <{'position': <0>}>, '8f6f1753-4a0a-4b8b-b46a-e6dad4856503': <{'position': <1>}>, '04d85809-519b-4ace-81cf-14d177ef44c4': <{'position': <2>}>, 'Utilities': <{'position': <3>}>, 'f1c923d7-5dd0-4c2e-a221-d316c11fb6a2': <{'position': <4>}>, 'org.gnome.Settings.desktop': <{'position': <5>}>, 'org.gnome.Extensions.desktop': <{'position': <6>}>, 'filezilla.desktop': <{'position': <7>}>, 'element.desktop': <{'position': <8>}>, 'thunderbird.desktop': <{'position': <9>}>, 'cinny.desktop': <{'position': <10>}>, 'io.github.celluloid_player.Celluloid.desktop': <{'position': <11>}>, 'org.nickvision.cavalier.desktop': <{'position': <12>}>, 'Alacritty.desktop': <{'position': <13>}>, 'chromium-browser.desktop': <{'position': <14>}>}]";
    };

    # WM
    "org/gnome/shell/extensions/unite" = {
      autofocus-windows = true;
      enable-titlebar-actions = false;
      extend-left-box = false;
      grayscale-tray-icons = true;
      hide-activities-button = "never";
      hide-app-menu-icon = false;
      hide-dropdown-arrows = true;
      notifications-position = "center";
      reduce-panel-spacing = false;
      show-desktop-name = false;
      show-legacy-tray = true;
      show-window-buttons = "never";
    };

    # Input
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
    "org/gnome/desktop/input-sources" = {
      # sources = "[('xkb', 'us+euro')]";
      # sources = "[('xkb', 'us+intl')]";
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    # Keybindings
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      screenshot = [ "<Shift><Super>s" ];
      panel-run-dialog = [ "<Super>r" ];
      logout = [ "<Control><Alt>q" ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-6 = [ "<Shift><Super>6" ];
      move-to-workspace-7 = [ "<Shift><Super>7" ];
      move-to-workspace-8 = [ "<Shift><Super>8" ];
      move-to-workspace-9 = [ "<Shift><Super>9" ];
      move-to-workspace-10 = [ "<Shift><Super>0" ];
      switch-to-application-1 = [ "<Super>1" ];
      switch-to-application-2 = [ "<Super>2" ];
      switch-to-application-3 = [ "<Super>3" ];
      switch-to-application-4 = [ "<Super>4" ];
      switch-to-application-5 = [ "<Super>5" ];
      switch-to-application-6 = [ "<Super>6" ];
      switch-to-application-7 = [ "<Super>7" ];
      switch-to-application-8 = [ "<Super>8" ];
      switch-to-application-9 = [ "<Super>9" ];
      switch-to-application-10 = [ "<Super>0" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      play = [ "<Super>p" ];
      next = [ "<Shift><Super>period" ];
      prev = [ "<Shift><Super>comma" ];
    };

    # Custom keybindings
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open terminal";
      binding = "<Super>Return";
      command = terminal;
    };
  };
}
