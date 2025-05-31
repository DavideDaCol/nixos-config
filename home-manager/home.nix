{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # import other home-manager modules here
  imports = [
   
  ];

  nixpkgs = {
    # add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
    # Configure nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "davide";
    homeDirectory = "/home/davide";
  };

  home.packages = with pkgs; [
    firefox
    bat
    neofetch
    rofi
    vscode
  ];

  # fonts install
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];


  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      nrsf = "nixos-rebuild switch --flake .#nixos";
      nrtf = "nixos-rebuild test --flake .#nixos";
    };
  };
  
  programs.kitty = { 
    enable = true; # required for the default Hyprland config
    settings = {
      confirm_os_window_close = false;
    }
  }

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";
        bind =
          [
            "$mod, F, exec, firefox"
            ", Print, exec, grimblast copy area"
	          "$mod, Q, exec, kitty"
            "$mod, R, exec, rofi"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (i:
                let ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
      };
    };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion (tip: never)
  home.stateVersion = "24.11";
}
