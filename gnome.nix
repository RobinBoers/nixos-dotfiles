{ config, pkgs, lib, ... }:

let 
  terminal = "${pkgs.kitty}/bin/kitty";
in {
  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
    rounded-window-corners
    dock-from-dash
    unite
    impatience
  ];

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
        "code.desktop"
        "kitty.desktop"
      ];
    };

    # Wallpaper
    "org/gnome/desktop/background" = {
      picture-uri = "file:///nix/store/b52s9srq3g9i16rfhiws682kr2yf89h1-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      picture-uri-dark = "file:///nix/store/nps9j555vjl968gxj5sczvc9b6f8vibx-simple-dark-gray-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-dark-gray.png";
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
