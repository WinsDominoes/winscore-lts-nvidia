#### Enabling System Unit Files
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