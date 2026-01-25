
HOST=
FQDN=$(HOST).joukamachi.net
DEPLOYUSER=deploy
DEPLOYKEY=~/keys/id_deploy

.PHONY: build copy switch boot deploy clean

build:
	nix build -L .#nixosConfigurations.$(HOST).config.system.build.toplevel

copy: build
	nix copy --no-check-sigs --to ssh://$(DEPLOYUSER)@$(FQDN)?ssh-key=$(DEPLOYKEY) ./result

switch:
	ssh -i $(DEPLOYKEY) $(DEPLOYUSER)@$(FQDN) sudo nix-env -p /nix/var/nix/profiles/system --set $(shell readlink ./result)
	ssh -i $(DEPLOYKEY) $(DEPLOYUSER)@$(FQDN) sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch

boot:
	DERIVATION=$(shell readlink ./result)
	ssh -i $(DEPLOYKEY) $(DEPLOYUSER)@$(FQDN) sudo nix-env -p /nix/var/nix/profiles/system --set $(shell readlink ./result)
	ssh -i $(DEPLOYKEY) $(DEPLOYUSER)@$(FQDN) sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot

deploy:
	make HOST=$(HOST) build
	make HOST=$(HOST) copy
	make HOST=$(HOST) switch

clean:
	rm -f ./result
