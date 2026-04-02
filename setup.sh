#/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

user=$(whoami)

# ask for password, and keep it alive
echo "Enter password for all required sudo commands in script"
sudo -v
while true; do sudo -v; sleep 60; done 2>/dev/null & SUDO_PID=$!
# make sure we stop refreshing password
trap 'kill $SUDO_PID 2>/dev/null' EXIT



####### First of all, set font to a readable size #######
sudo pacman -S --noconfirm --needed --quiet terminus-font
setfont /usr/share/kbd/consolefonts/ter-c28b.psf.gz



################# Install paru for AUR ##################
if command -v paru > /dev/null 2>&1; then
	echo "paru is already installed, skipping"
else
	echo "paru not found, installing..."
	sudo pacman -S --noconfirm --needed base-devel git
	git clone https://aur.archlinux.org/paru.git /tmp/paru && \
		(cd /tmp/paru && makepkg -s) && \
		sudo pacman -U --noconfirm /tmp/paru/*.pkg.tar.zst && \
		rm -rf /tmp/paru
	echo "Paru installed"
fi


################ Install packages ################ 
packages=(
	emptty # greeter
	uwsm # Universal Wayland Session manager
	hyprland # WM
	hyprpolkitagent # Required for hyprland authentication privileges
	kitty # Terminal
	awww # Dynamic wallpapers
	mako # Notifications
	wofi # App launcher
	dolphin # File explorer
	xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5-wayland qt6-wayland # Hyprland themes integration
	waybar # Status bar
	cliphist # clipboard
	neovim # Pr0 text editor
	zen-browser-bin # Web browser
	man-db # manual pages
	p7zip # 7z
	ttf-firacode-nerd # nice monofont
	brightnessctl # for screen and keyboard lights
	openssh
	git
)
echo "Packages to install:"
printf ' - %s\n' "${packages[@]}"
for pkg in "${packages[@]}"; do
	if pacman -Qi "$pkg" >/dev/null 2>&1; then
		echo -e "[SKIP]\t\t$pkg"
	else
		echo -e "[INSTALL]\t$pkg"
		if paru -S --noconfirm --needed "$pkg" >/dev/null 2>&1; then
			echo -e "[OK]\t\t$pkg"
		else
			echo -e "[FAIL]\t\t$pkg"
		fi
	fi
done
			
#paru -S --noconfirm --needed --quiet "${packages[@]}"

################### Enable necessary services ################### 
echo "Enable emptty systemd..."
sudo systemctl enable emptty
echo "Enable hyprpolkitagent..."
systemctl --user enable hyprpolkitagent.service


###################### Copy config dotfile ######################
echo "Setup auto login (will add user $user to new nopasswdlogin group)"
sudo groupadd -r nopasswdlogin > /dev/null
sudo gpasswd -a $user nopasswdlogin > /dev/null
sed "s/{user}/$user/g" "$SCRIPT_DIR/dotfiles/etc/emptty/conf" | sudo tee /etc/emptty/conf > /dev/null
echo "Copy config dotfiles"
cp -rf "$SCRIPT_DIR/dotfiles/.config" $HOME


############################# Other #############################
cp -r "$SCRIPT_DIR/wallpapers" $HOME/.config/awww/wallpapers
