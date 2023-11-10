
.PHONY: sd vm

IMG_NAME = .\#images.rpi

sd:
	nix build $(IMG_NAME)

vm:
	nixos-rebuild build-vm --flake "$(IMG_NAME)"
