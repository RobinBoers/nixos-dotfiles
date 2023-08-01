# dotfiles

My NixOS configuration.

> Note:  
> If you came here via an link from Reddit, you're probably looking for my
> [old dotfiles](https://github.com/RobinBoers/dotfiles-legacy).

## Structure

[`configuration.nix`](configuration.nix) contains all system-level configuration.

That means it configures hardware, permissions, global settings and important multi-user packages.
It does NOT contain any application config, keybindings, or other things that are not essential for a
working system and/or for a working desktop.

All those settings are managed via [Home Manager](https://nix-community.github.io/home-manager/).
The only exception to this rule are fonts, since home-manager doesn't provide any way to install or
configure fonts, and the TTY setup, since has to always be configured system-wide.

## Theming

I use the default libadwaita theme + [`adw-gtk3`](https://github.com/lassekongo83/adw-gtk3)
for old apps. I have a program called `gtk3-darkmode-daemon` that listens for changes
in gsettings, and changes the GTK3 theme to `adw-gtk3-dark` if libadwaita dark-mode is activated.

## Desktop

I use the [Sway] window manager that I integrated with GNOME services, similar to my old
[`sway-gnome`](https://github.com/RobinBoers/sway-gnome) setup on Arch Linux.

The Sway + GNOME services is enabled system-wide, but the configuration for sway, and
its own services (`mako`, `kanshi` etc) is managed on user-level using Home Manager.

Xwayland is enabled by default. Because, let's be honest. Nothing is gonna work without it.
