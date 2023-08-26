{ config, pkgs, lib, ... }:

let 
  terminal = "${pkgs.kitty}/bin/kitty";
in {
  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
    rounded-window-corners
    dock-from-dash
  ];

  dconf.settings = let 
    wallpaper = "dune"; 
  in {
    # Overview
    "/org/gnome/shell" = {
      favorite-apps = [
        "librewolf.desktop"
        "md.obsidian.Obsidian.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
        "discord.desktop"
        "code.desktop"
        "kitty.desktop"
      ];
      # app-picker-layout = 
      #   "[{'ad420938-9793-43d4-9a98-9de8290215e7': <{'position': <0>}>, 'io.github.celluloid_player.Celluloid.desktop': <{'position': <1>}>, '8f6f1753-4a0a-4b8b-b46a-e6dad4856503': <{'position': <2>}>, 'Utilities': <{'position': <3>}>, 'chromium-browser.desktop': <{'position': <4>}>, 'org.gnome.Settings.desktop': <{'position': <5>}>, 'org.gnome.Extensions.desktop': <{'position': <6>}>, 'filezilla.desktop': <{'position': <7>}>, 'org.yuzu_emu.yuzu.desktop': <{'position': <8>}>, 'org.gnome.Software.desktop': <{'position': <9>}>, 'com.valvesoftware.Steam.desktop': <{'position': <10>}>, '04d85809-519b-4ace-81cf-14d177ef44c4': <{'position': <11>}>}]";
    };

    # Wallpaper
    "/org/gnome/desktop/background" = {
      picture-uri = "/run/current-system/sw/share/backgrounds/gnome/${wallpaper}-l.svg";
      picture-uri-dark = "/run/current-system/sw/share/backgrounds/gnome/${wallpaper}-d.svg";
    };

    # Input
    "/org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
    "/org/gnome/desktop/input-sources" = {
      sources = "[('xkb', 'us+euro')]";
      # sources = "[('xkb', 'us+intl')]";
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    # Keybindings
    "/org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      screenshot = [ "<Shift><Super>s" ];
      panel-run-dialog = [ "<Super>r" ];
      logout = [ "<Control><Alt>q" ];
    };
    "/org/gnome/settings-daemon/plugins/media-keys" = {
      play = [ "<Super>p" ];
      next = [ "<Shift><Super>period" ];
      prev = [ "<Shift><Super>comma" ];
    };

    # Custom keybindings
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open terminal";
      binding = "<Super>Return";
      command = terminal;
    };
  };
}
