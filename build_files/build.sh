#!/bin/bash

set -ouex pipefail

# Environment variables
CONTEXT_PATH="$(realpath "$(dirname "$0")/..")" # should return /run/context
BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"
MAJOR_VERSION_NUMBER="$(sh -c '. /usr/lib/os-release ; echo ${VERSION_ID%.*}')"
SCRIPTS_PATH="$(realpath "$(dirname "$0")/scripts")"
export SCRIPTS_PATH
export PATH="${SCRIPTS_PATH}:${PATH}"
export MAJOR_VERSION_NUMBER

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf -y copr enable secureblue/run0edit
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/10/tailscale.repo
# this installs a package from fedora repos
dnf -y install tailscale distrobox podman cockpit samba run0edit git gcc NetworkManager libvirt qemu-kvm cmake llvm


dnf config-manager --add-repo "https://download.docker.com/linux/rhel/docker-ce.repo"
dnf config-manager --set-disabled docker-ce-stable
dnf -y install rsync rsnapshot
dnf -y --enablerepo docker-ce-stable install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
dnf -y remove PackageKit subscription-manager
dnf -y copr disable secureblue/run0edit
#### Example for enabling a System Unit File
systemctl enable brew-setup.service
systemctl enable tailscaled.service
systemctl enable podman.socket
systemctl enable docker.socket
systemctl enable sshd.service
systemctl enable brew-upgrade.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer
systemctl enable brew-update.service
systemctl --global enable podman-auto-update.timer
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable libvirtd
systemctl enable virtlogd



# /*
# docker sysctl.d
# */
mkdir -p /usr/lib/sysctl.d
echo "net.ipv4.ip_forward = 1" >/usr/lib/sysctl.d/docker-ce.conf

# /*
# sysusers.d for docker
# */
cat >/usr/lib/sysusers.d/docker.conf <<'EOF'
g docker -
EOF

rm -f /usr/bin/chsh
rm -f /usr/bin/chfn
rm -f /usr/bin/pkexec
rm -f /usr/bin/sudo
rm -f /usr/bin/su
