#!/usr/bin/bash

set -ouex pipefail

# Disable all COPRs and RPM Fusion Repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
dnf5 -y remove PackageKit subscription-manager
dnf5 -y copr disable secureblue/run0edit

rm -f /usr/bin/chsh
rm -f /usr/bin/chfn
rm -f /usr/bin/pkexec
rm -f /usr/bin/sudo
rm -f /usr/bin/su