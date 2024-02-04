
.PHONY: sd vm

IMG_NAME = .\#packages.aarch64-linux.sdcard

sd:
	nix build $(IMG_NAME)

vm:
	nixos-rebuild build-vm --flake "$(IMG_NAME)"
