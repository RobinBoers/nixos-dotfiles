{ config, pkgs, lib, ... }:

let
  script-directory = "${config.home.homeDirectory}/sd";
in {
  home.packages = with pkgs; [
    fishPlugins.z
  ];

  home.shellAliases = {
    cat = "bat";
    feh = "feh -Z --scale-down";
    tree = "exa -T";
    ":q" = "exit";
    ":Q" = "exit";
    clear = "printf '\\033[2J\\033[3J\\033[1;1H'";

    # Shortcuts
    rm = "rm -r";
    cp = "cp -i";
    mv = "mv -i";
    ".." = "cd ..";
    less = "less -QFr";
  };

  # Append .local/bin to the path
  home.sessionPath = [ 
    "${config.home.homeDirectory}/.local/bin" 
    "${config.home.homeDirectory}/.mix/escripts" 
  ];

  home.sessionVariables = {
    ERL_AFLAGS = "-kernel shell_history enabled";
    ELIXIR_ERL_OPTIONS = "-kernel start_pg true shell_history enabled";
    DIRENV_LOG_FORMAT = ""; # Disable annoying direnv output
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "UTF-8";
        end_of_line = "lf";
        trim_leading_whitespace = true;
        indent_style = "space";
        indent_size = "2";
      };
      "*.py" = { indent_size = "4"; };
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = config.home.shellAliases;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;

    gitCredentialHelper.enable = true;   
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = { co = "pr checkout"; };
    };
  };

  programs.script-directory = {
    enable = true;
    settings = {
      SD_ROOT = script-directory;
    };
  };

  home.file.".config/fish/functions/fish_greeting.fish".text = ''
    # Disables greeting when starting fish

    function fish_greeting
    end
  '';

  home.file.".config/fish/functions/fish_prompt.fish".text = ''
    function fish_prompt
      set -l prompt_symbol '$'
      fish_is_root_user; and set prompt_symbol '#'

      printf '%s%s@%s%s:%s%s%s%s ' (set_color green --bold) $USER \
	 $hostname (set_color normal) (set_color blue) (prompt_pwd) \
	 (set_color normal) $prompt_symbol
    end
  '';

  home.file.".config/fish/completions/sd.fish".text = ''
    # Completions for the custom Script Directory (sd) script

    # These are based on the contents of the Script Directory, so we're reading info from the files.
    # The description is taken either from the first line of the file $cmd.help,
    # or the first non-shebang comment in the $cmd file.

    # Disable file completions
    complete -c sd -f

    # Create command completions for a subcommand
    # Takes a list of all the subcommands seen so far
    function __list_subcommand
        # Handles fully nested subcommands
        set basepath (string join '/' ${script-directory} $argv)
        # Total subcommands
        # Used so that we can ignore duplicate commands
        set -l commands
        for file in (ls -d $basepath/*)
            set cmd (basename $file .help)
            set helpfile $cmd.help
            if [ (basename $file) != "$helpfile" ]
                set commands $commands $cmd
            end
        end
        # Setup the check for when to show these commands
        # Basically you need to have seen everything in the path up to this point but not any commands in the current irectory.
        # This will cause problems if you have a command with the same name as a directory parent.
        set check
        for arg in $argv
            set check (string join ' and ' $check "__fish_seen_subcommand_from $arg;")
        end
        set check (string join ' ' $check "and not __fish_seen_subcommand_from $commands")
        # Loop through the files using their full path names.
        for file in (ls -d $basepath/*)
            set cmd (basename $file .help)
            set helpfile $cmd.help
            if [ (basename $file) = "$helpfile" ]
                # This is the helpfile, use it for the help statement
                set help (head -n1 "$file")
                complete -c sd -a "$cmd" -d "$help" \
                    -n $check
            else if test -d "$file"
                set help "$cmd commands"
                __list_subcommand $argv $cmd
                complete -c sd -a "$cmd" -d "$help" \
                    -n "$check"
            else
                set help (sed -nE -e '/^#!/d' -e '/^#/{s/^# *//; p; q;}' "$file")
                if not test -e "$helpfile"
                    complete -c sd -a "$cmd" -d "$help" \
                        -n "$check"
                end
            end
        end
    end

    function __list_commands
        # commands is used in the completions to know if we've seen the base commands
        set -l commands
        # Create a list of commands for this directory.
        # The list is used to know when to not show more commands from this directory.
        for file in $argv
            set cmd (basename $file .help)
            set helpfile $cmd.help
            if [ (basename $file) != "$helpfile" ]
                # Ignore the special commands that take the paths as input.
                if not contains $cmd cat edit help new which
                    set commands $commands $cmd
                end
            end
        end
        for file in $argv
            set cmd (basename $file .help)
            set helpfile $cmd.help
            if [ (basename $file) = "$helpfile" ]
                # This is the helpfile, use it for the help statement
                set help (head -n1 "$file")
                complete -c sd -a "$cmd" -d "$help" \
                    -n "not __fish_seen_subcommand_from $commands"
            else if test -d "$file"
                # Directory, start recursing into subcommands
                set help "$cmd commands"
                __list_subcommand $cmd
              complete -c sd -a "$cmd" -d "$help" \
                    -n "not __fish_seen_subcommand_from $commands"
            else
                # Script
              # Pull the help text from the first non-shebang commented line.
                set help (sed -nE -e '/^#!/d' -e '/^#/{s/^# *//; p; q;}' "$file")
                if not test -e "$helpfile"
                    complete -c sd -a "$cmd" -d "$help" \
                        -n "not __fish_seen_subcommand_from $commands"
                end
            end
        end
    end

    # Hardcode the starting directory
    __list_commands ${script-directory}/*
  '';

  programs.bat = {
    enable = true;

    config = {
      theme = "base16";
      italic-text = "always";
      paging = "never";
      style = "plain";
      color = "always";
    };
  };

  programs.eza = {
    enable = true;

    enableAliases = true;
    extraOptions = [ "--group-directories-first" ];
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableFishIntegration = true;

    settings = {
      add_newline = false;
      line_break = { disabled = true; };
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
        vimcmd_symbol = "[<](bold green)";
      };
      git_commit = { tag_symbol = " tag "; };
      git_status = {
        ahead = ">";
        behind = "<";
        diverged = "<>";
        renamed = "r";
        deleted = "x";
      };
      directory = { read_only = " ro"; };
      git_branch = { symbol = "git "; };
      memory_usage = { symbol = "mem "; };
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$directory"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_status"
        "$git_metrics"
        "$cmake"
        "$meson"
        "$memory_usage"
        "$battery"
        "$env_var"
        "$cmd_duration"
        "$status"
        "$character"
      ];
    };
  };

  home.file.".githooks/pre-push" = {
    text = ''
      #!/bin/sh
      bix pre-push
    '';
    executable = true;
  };

  home.file.".local/bin/bix" = {
    text = builtins.readFile(builtins.fetchurl "https://git.dupunkto.org/~robin/libre0b11/bix/plain/bix.sh");
    executable = true;
  };

  programs.git.delta = {
    enable = true;

    options = {
      decorations = {
        commit-decoration-style = "blue ol";
        commit-style = "raw";
        file-style = "omit";
        hunk-header-decoration-style = "blue box";
        hunk-header-file-style = "red";
        hunk-header-style = "file line-number syntax";
      };
      features = "decorations";
      nagivate = "true"; # Use n and N to jump between sections
      interactive = {
        keep-plus-minus-markers = false;
        side-by-side = true;
        line-numbers = true;
      };
    };
  };
}
