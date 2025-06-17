#!/usr/bin/env bash

set -e
pushd /etc/nixos/
sudo vim .
alejandra . &>/dev/null
git diff -U0 *.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch &>nixos-switch.log || (
 cat nixos-switch.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
sudo git commit -am "$gen"
popd
73 current  2025-06-17 18:37:51  24.11.718195.f09dede81861  6.6.92                          *