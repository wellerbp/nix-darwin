{
  description = "Nix-Darwin macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, mac-app-util, ... }:
  let
    configuration = { pkgs, config, ... }: {
      users.users.wellerbp = {
        name = "wellerbp";
        home = "/Users/wellerbp";
        shell = pkgs.zsh;
      };
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = [
        pkgs.mkalias
        pkgs.jellyfin
        pkgs.telegram-desktop
        pkgs.vlc-bin
        pkgs.zoom-us
        pkgs.vesktop
        pkgs.vscode
      ];
      homebrew = {
        enable = true;
        caskArgs.no_quarantine = true;
        brews = [
          "mas"
          "winetricks"
          "helix"
          "llvm"
        ];
        casks = [
          # "aerospace" # Commented out cask
          "anki"
          "chatgpt"
          "deluge"
          "deepl"
          "element"
          #"free-download-manager"
          "gstreamer-runtime"
          "librewolf"
          "miniconda"
          "moonlight"
          "obsidian"
          "platypus"
          # "playcover-nightly" # Commented out cask
          "rectangle"
          "steam"
          "tachidesk-sorayomi"
          "whisky"
          "wine@staging"
          "xiv-on-mac"
          "zed"
        ];
        masApps = {
          "AdGuard" = 1440147259;
          "DDG Safari" = 1482920575;
          "Copilot: Finance" = 1447330651;
          "WhatsApp" = 310633997;
          "LINE" = 539883307;
          "WireGuard" = 1451685025;
          "PiPifier" = 1160374471;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      security.pam.enableSudoTouchIdAuth = true;

      system.defaults = {
        NSGlobalDomain = {
          AppleICUForce24HourTime = true;
          AppleInterfaceStyle = "Dark";
          AppleSpacesSwitchOnActivate = false;
          KeyRepeat = 2;
        };
        dock = {
          autohide = true;
          largesize = 64;
          persistent-apps = [
        # "${pkgs.alacritty}/Applications/Alacritty.app"
        # "/Applications/Firefox.app"
        # "${pkgs.obsidian}/Applications/Obsidian.app"
        # "/System/Applications/Mail.app"
        # "/System/Applications/Calendar.app"
          ];
          static-only = true;
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          CreateDesktop = false;
          FXDefaultSearchScope = "SCcf";
          FXPreferredViewStyle = "clmv";
          QuitMenuItem = true;
          ShowPathbar = true;
          _FXSortFoldersFirst = true;
        };
        loginwindow = {
          GuestEnabled = false;
          #LoginwindowText = "おはようございます！";
        };
        screencapture.location = "~/Pictures/Screenshots";
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        #"com.apple.controlcenter" = {
        #  BatteryShowPercentage = true;
        #};
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh = {
        enable = true;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."air" = nix-darwin.lib.darwinSystem {
          modules = [
            configuration
            mac-app-util.darwinModules.default
            nix-homebrew.darwinModules.nix-homebrew {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = "wellerbp";
                autoMigrate = true;
              };
            }
            home-manager.darwinModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.wellerbp = {
                imports = [
                  ./home.nix
                  mac-app-util.homeManagerModules.default
                  ];
              };
              #home-manager.sharedModule = [
              #  mac-app-util.homeManagerModules.default
              #];
            }
          ];
        };
    darwinPackages = self.darwinConfigurations."air".pkgs;
  };
}
