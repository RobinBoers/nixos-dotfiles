{ config, pkgs, lib, ... }:

let
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

  gtk3-theme = "adw-gtk3";
  cursor-theme = "Vanilla-DMZ";
  font = "Inter";
  gtk3-theme-package = pkgs.adw-gtk3;
  cursor-theme-package = pkgs.vanilla-dmz;

  gtk3-darkmode-daemon = let
    # TODO(robin): refactor this.
    # This is currently duplicated from `wayland-gsettings`.

    schema = pkgs.gsettings-desktop-schemas;
    datadir = "${schema}/share/gsettings-schemas/${schema.name}";
  in pkgs.writeShellScriptBin "gtk3-darkmode-daemon" ''
    export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS

    sync_darkmode() {
      GNOME_SCHEMA="org.gnome.desktop.interface"
      SCHEME=$(${pkgs.glib}/bin/gsettings get $GNOME_SCHEMA color-scheme)

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

in {
  home.packages = with pkgs; [
    gtk3-darkmode-daemon
    gtk3-theme-package
    cursor-theme-package
    gnome.adwaita-icon-theme
    sound-theme-freedesktop
  ];

  home.file.".local/share/fonts/AppleColorEmoji.ttf".source =
    builtins.fetchurl "https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji.ttf";

  programs.kitty.settings = {
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

  programs.fish.loginShellInit = ''
    # home-manager can't handle this if I put it in
    # `home.sessionVariables` for some reason.
    export NEWT_COLORS="${newt-color-scheme}"

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

  home.file.".dialogrc".text = dialog-color-scheme;

  gtk = {
    enable = true;

    gtk3 = {
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

    cursorTheme = {
      package = cursor-theme-package;
      name = cursor-theme;
    };
  };

  systemd.user.services.gtk3-darkmode-daemon = {
    Unit = {
      Description =
        "Simple daemon set the GTK theme based on the dark mode preference in GNOME";
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${gtk3-darkmode-daemon}/bin/gtk3-darkmode-daemon";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    font-name = font;
    document-font-name = font;
    font-antialiasing = "grayscale";
    font-hinting = "slight";
    cursor-theme = cursor-theme;
  };

  # For GTK2 apps
  home.file.".local/share/icons/default".source = 
    "${cursor-theme-package}/share/icons/${cursor-theme}"; 
}
