{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    elixir-ls
    sublime4
  ];

  # This is "safe", see https://github.com/NixOS/nixpkgs/issues/239615
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
}
