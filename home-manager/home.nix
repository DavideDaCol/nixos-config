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

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      nrsf = "nixos-rebuild switch --flake .#davide";
      nrtf = "nixos-rebuild test --flake .#davide";
    };
  };

  programs.hyprland.enable = true;
  wayland.windowManager.hyprland.enable = true;

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion (tip: never)
  home.stateVersion = "23.05";
}
