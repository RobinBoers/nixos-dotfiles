{ config, pkgs, lib, ... }:

let
  system = builtins.currentSystem;
  extensions = (import (builtins.fetchGit {
    url = "https://github.com/nix-community/nix-vscode-extensions";
    ref = "refs/heads/master";
    rev = "d11ffab0c514009179dbcdfee1c397bfaec2f2d4";
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
        tombonnike.vscode-status-bar-format-toggle
        elixir-tools.elixir-tools
        #jakebecker.elixir-ls
        brettm12345.nixfmt-vscode
        bbenoist.nix
        joaopalmeiro.icons-octicons
        miguelsolorio.fluent-icons
      ];
    })
  ];
}
