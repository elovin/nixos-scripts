# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

 fileSystems."/" =
    { device = "/dev/disk/by-uuid/cccca387-18a3-4459-8293-9650108c21b7";
      fsType = "ext4"; 
      options = [ "nodelalloc" ];
    };

  fileSystems."/var" =
    { device = "/dev/disk/by-uuid/2f1b0aee-6a5b-4420-97f8-a67fa0c4a5a5";
      fsType = "ext4";
      options = [ "nodelalloc" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/aecf6582-15ae-43d2-9ec7-81efa71b2eb7";
      fsType = "ext4";
      options = [ "nodelalloc" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/654b1ef2-34d4-44c4-9367-e9a46b011df0";
      fsType = "ext4";
      options = [ "nodelalloc" ];
    };

  boot.initrd.luks.devices = { 
   	luks2_root = {
      		device = "/dev/disk/by-uuid/21e984c4-85a1-4123-abc8-8774ebeb2201";
      		preLVM = true;
      		allowDiscards = true;
    	};
  };
 
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.loader.grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = false;
  };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/B74A-0DAC";
      fsType = "vfat";
    };
  

  boot.kernelParams = [ "drm.edid_firmware=DP-2:edid/freeSyncBenQ.bin" ];

  fileSystems."/home/elovin/storage" =
    { device = "/dev/disk/by-uuid/4eb5d2d6-2375-4593-b49f-0fc119e464d1";
      fsType = "ext4";
    };

  boot.kernelPackages = pkgs.linuxPackages_latest;  

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  #

  networking.hostName = "nixos_elovin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";


  nixpkgs.config.allowUnfree = true;

  powerManagement.cpuFreqGovernor = "powersave";
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  # Enable periodic trim support
  #
  services.fstrim.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";



  services.xserver.videoDrivers = ["amdgpu"];

  services.xserver.deviceSection = ''
# DO NOT add the out commented lines they are injected by the main xserver conf script from nixos
#	Section "Device"
#    		Identifier "AMD"
#  		Driver "amdgpu"
 		Option "TearFree" "true"
   		Option "DRI" "3"
   		Option "VariableRefresh" "true"
#	EndSection
  '';


  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.autoLogin.enable = true;
  services.xserver.displayManager.sddm.autoLogin.user = "elovin"; 

  services.xserver.desktopManager.plasma5.enable = true;

  hardware.opengl.driSupport32Bit = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  hardware.opengl.extraPackages = with pkgs; [
	libva
  ];

  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.elovin = {
     initialPassword = "asdf";
     home = "/home/elovin";
     createHome = true;
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "vboxusers" "docker" ]; # Enable ‘sudo’ for the user.
   };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [ 9000 ];

  environment = {
    systemPackages = let
    delta-chat = pkgs.callPackage /home/elovin/Documents/backup/linuxFiles/nixos/nixpkgs/delta-chat/delta-chat.nix {};
    unstable = import
    (
       fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz
      #fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    )
    {
	config.permittedInsecurePackages = [
    		"p7zip-16.02"
  	];
	config.allowUnfree = true;
    };
    in
    with pkgs; [
	wget
	vim 
	thunderbird
	firefox 
	yakuake 
	sddm 
	sddm-kcm
	plasma-desktop 
	plasma-nm 
	redshift-plasma-applet 
	plasma-workspace 
	plasma-workspace-wallpapers
	konsole
	kwalletcli
	kwallet-pam
	kate
	dolphin
	kdeplasma-addons
	plasma-pa
	plasma-browser-integration
	ksysguard
	vagrant
	chromium
	unzip
	curl
	php
	partition-manager
	docker-compose
	nodejs
	python3
	libreoffice
	okular
	kdeApplications.print-manager
	simple-scan
	kdeApplications.spectacle
	kdeApplications.dolphin-plugins
	kdeFrameworks.kconfigwidgets
	gwenview
	ark
	kdeFrameworks.kwallet
	kdeApplications.kwalletmanager
	git
	electron_6

	#custom packages
	delta-chat
	
	# deb extraction tools
	binutils-unwrapped
	dpkg
	
	# jetbrains dev tools
	unstable.jetbrains.phpstorm
	unstable.jetbrains.pycharm-community


	# privacy 
	tor-browser-bundle-bin

	# gaming related tools
	libva

	unstable.vulkan-loader
	unstable.vulkan-tools

	unstable.steam
	unstable.mesa.drivers
	unstable.pkgsi686Linux.mesa.drivers

	unstable.lutris
	unstable.wine-staging

	xorg.xf86videoamdgpu
   
     ];
 };
}


