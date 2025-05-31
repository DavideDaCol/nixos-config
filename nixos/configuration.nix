{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # other NixOS modules here
  imports = [
    # import home-manager module
    inputs.home-manager.nixosModules.home-manager

    # Import generated hardware configuration
    ./hardware-configuration.nix
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

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # FIXME: move this to modules

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #turn on nvidia's stupid drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs;
    [nvidia-vaapi-driver];
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia= {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  # Turn on bluetooth
  hardware.bluetooth.enable = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/Rome";

  # Set the locale
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users = {
    davide = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = ["wheel"];
    };
  };

  security.sudo.enable = true;

  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    pkgs.wget
    pkgs.kitty
  ];

  # fonts install
  fonts.packages = with pkgs; [
    jetbrains-mono
    fira-code-nerdfont
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # home-manager configuration
      davide = import ../home-manager/home.nix;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
