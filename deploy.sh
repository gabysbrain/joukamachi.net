#!/usr/bin/env sh

sshUser=deploy
sshOpts="-i ~/keys/id_deploy"
remotehost="$1"

nix build -L ".#nixosConfigurations.${remotehost}.config.system.build.toplevel"
nix copy --to ssh-ng://${sshUser}@${remotehost} ./result
ssh ${sshOpts} ${sshUser}@${remotehost} sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink ./result)
ssh ${sshOpts} ${sshUser}@${remotehost} sudo /nix/var/nix/profiles/system/bin/switch-to-configuration dry-activate

