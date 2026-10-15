# shellcheck shell=bash disable=SC2154  # fragment appended to Fedora config.sh; kiwi_profiles comes from /.profile
#======================================
# tushar-os customisations (appended to Fedora's config.sh by build-iso.sh)
#--------------------------------------
if [[ "$kiwi_profiles" == *"TusharOS"* ]]; then
	echo 'livesys_session="hyprland"' > /etc/sysconfig/livesys
	systemctl set-default graphical.target
	systemctl enable sddm.service
	# Hostname / pretty name come from tushar-os-release
	# Plymouth: neutral spinner (Fedora's charge theme is Fedora-branded)
	plymouth-set-default-theme spinner || true
	# Flathub for the welcome app (system-wide remote, no apps preinstalled)
	flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
fi
