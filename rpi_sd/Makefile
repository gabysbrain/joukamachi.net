
.PHONY: sd vm variants

FLAKE = .\#newpi

sd:
	nixos-rebuild build-image --flake "$(FLAKE)" --image-variant sd-card

vm:
	nixos-rebuild build-vm --flake "$(FLAKE)"
