{ config, pkgs, ... }:

{
  home.username = "wellerbp";
  home.homeDirectory = "/Users/wellerbp";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
      neovim
      ripgrep
      zsh-autosuggestions
      zsh-autocomplete
      zsh-fast-syntax-highlighting
      fzf
      zoxide
      thefuck
      eza
      bat
      fd
      fastfetch
      wget
      tealdeer
      trash-cli
      zenity

      #LSP Servers
      nil
      nixpkgs-fmt
      nixd
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/zed/settings.json".text = ''
    {
      "base_keymap": "VSCode",
      "ui_font_size": 16,
      "buffer_font_size": 15,
      "theme": {
        "mode": "system",
        "light": "macOS Classic Light",
        "dark": "macOS Classic Dark"
      },
      "hover_popover_enabled": false,
      "confirm_quit": true,
      "cursor_blink": false,
      "current_line_highlight": "line",
      "show_completion_documentation": false,
      "toolbar": {
        "selections_menu": false
      },
      "message_editor": {
        "auto_replace_emoji_shortcode": false
      },
      "show_call_status_icon": false,
      "tab_bar": {
        "show_nav_history_buttons": false
      },
      "line_indicator_format": "short",
      "workspace": {
        "open_files": ["/Users/wellerbp/Documents/"]
      },

      "autosave": "on_window_change",
      "preferred_line_length": 80,
      "tab_size": 2,
      "vim_mode": false,
      "enable_language_server": true,

      "languages": {
        "C": {
          "format_on_save": "language_server",
          "preferred_line_length": 80,
          "tab_size": 4
        },
        "Rust": {
          "format_on_save": "language_server",
          "preferred_line_length": 80,
          "tab_size": 4
        },
        "Python": {
          "format_on_save": "language_server",
          "preferred_line_length": 80,
          "tab_size": 4
        },
        "Nix": {
          "format_on_save": "language_server",
          "preferred_line_length": 80,
          "tab_size": 2
        },
        "JSON": {
          "tab_size": 2
        }
      },

      "git": {
        "git_gutter": "tracked_files",
        "inline_blame": {
          "enabled": true,
          "delay_ms": 500
        }
      },

      "terminal": {
        "font_family": "JetBrainsMono Nerd Font",
        "font_size": 15,
        "blinking": "off",
        "line_height": "comfortable",
        "option_as_meta": true,
        "working_directory": "current_project_directory"
      },

      "scrollbar": {
        "show": "auto",
        "git_diff": true,
        "search_results": true,
        "diagnostics": true
      },

      "editor": {
        "wrap_guides": [80]
      },

      "indent_guides": {
        "enabled": true,
        "coloring": "indent_aware"
      },

      "projects_online_by_default": false,
      "show_inline_completions": true,
      "show_whitespaces": "boundary",
      "remove_trailing_whitespace_on_save": true
    }
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wellerbp/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    ZSH = "$HOME/.oh-my-zsh";
    PATH = "${pkgs.nix}/bin:$(brew --prefix llvm)/bin:$PATH";

  };

  programs.home-manager = { 
    enable = true;
  };

  programs.zsh = {
    enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "eza"
          "macos"
        ];
      };
    shellAliases = {
      darwin-switch = "darwin-rebuild switch --flake ~/.config/nix-darwin#air";
      darwin-config = "code /Users/wellerbp/.config/nix-darwin/flake.nix";
      darwin-search = "sh -c 'nix search nixpkgs \"\$1\" | grep \"legacyPackages.aarch64-darwin\" | grep -v \"evaluating\" | sed \"s/^.*legacyPackages\\.aarch64-darwin\\.//\"' sh";
      darwin-home = "code /Users/wellerbp/.config/nix-darwin/home.nix";
      eza= "eza --header --long --no-filesize --no-user --icons=always --color=always";
      cat= "bat";
      fd="fd --no-ignore --hidden";
      };
    initExtra = ''
      eval "$(fzf --zsh)"
      eval "$(conda shell.zsh hook)"
      eval $(thefuck --alias)
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          size = 12.0; 
        };
        window = {
          padding = {
            x = 8;
            y = 8;
          };
          decorations = "full";  # Can be set to "full", "none", etc.
          opacity = 0.95;        
        };
      };
  };

  programs.helix = {
    enable = true;
    languages.language = [
    {
      name = "nix";
      scope = "source.nix";
      injection-regex = "nix";
      file-types = [ "nix" ];
      comment-token = "#";
      auto-format = true;
      formatter = {
        command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
      };
      language-servers = [
        "nil"
        "nixd"
      ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      grammar = "nix";
    }
    ];
    settings = {
      theme = "onedarker";
      editor = {
        line-number = "relative";
        mouse = false;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker = {
          hidden = false;
        };
      };
    };
  };
}
