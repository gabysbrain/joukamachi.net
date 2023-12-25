#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
  nix run github:serokell/deploy-rs 
else
  nix run github:serokell/deploy-rs -- "${@:2}"
fi
