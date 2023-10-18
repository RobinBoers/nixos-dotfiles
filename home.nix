{ config, pkgs, lib, ... }:

{
  imports = [ 
    ./identity.nix 
    ./sway.nix 
    ./gnome.nix 
    ./neovim.nix 
    ./sublime.nix 
    ./shell.nix 
    ./theming.nix 
  ];

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

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
