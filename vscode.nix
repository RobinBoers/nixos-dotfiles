{ config, pkgs, lib, ... }:

let
  system = builtins.currentSystem;
  extensions = (import (builtins.fetchGit {
    url = "https://github.com/nix-community/nix-vscode-extensions";
    ref = "refs/heads/master";
    rev = "1c6da5a92510184f159dc8e73eb340331166134d";
  })).extensions.${system};
in {
  home.packages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with extensions.vscode-marketplace; [
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
        brettm12345.nixfmt-vscode
        bbenoist.nix
      ];
    })
  ];
}