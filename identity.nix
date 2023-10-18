{ config, pkgs, lib, ... }:

{
  ## Git

  programs.git = {
    enable = true;

    userName = "Robin Boers";
    userEmail = "robindev2019@outlook.com";
    signing = {
      key = "B1181BC2D8530F64";
      signByDefault = true;
    };

    extraConfig = {
      core = { hooksPath = "${config.home.homeDirectory}/.githooks"; };
      init = { defaultBranch = "master"; };
      pull = {
        rebase = true;

        # Enable this to prevent automatic rebase
        # when pulling.
        # rebase = false;
        # ff = "only";
      };
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        cp = "cherry-pick";
        h =
          "log --graph --date=default-local --pretty=format:'%C(yellow)%h%C(reset) %C(green)%cd%C(reset) %C(blue)%an%C(reset)%C(red)%d%C(reset) %s'";
        ha = "h --all";
        prune-br =
          "! git fetch --all --prune && git branch -vv | grep '\\(origin\\|fork\\|src\\)/.*: gone]' | awk '{print $1}' | xargs git branch -D";
        git = "!git";
      };
    };
  };

  # SSH

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/github";
      };
      "geheimesite.nl" = {
        hostname = "94.124.122.11";
        user = "robinb";
        identityFile = "${config.home.homeDirectory}/.ssh/sweet";
      };
      "dupunkto.org" = {
        hostname = "45.90.13.70";
        identityFile = "${config.home.homeDirectory}/.ssh/sweet";
      };
      "git.geheimesite.nl" = {
        hostname = "45.140.190.5";
        port = 222;
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/github";
      };
    };
  };
}