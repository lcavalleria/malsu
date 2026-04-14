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
  blueman # Bluetooth management gui and tray applet
	cliphist # clipboard
	ripgrep # for neovim
  unzip # for neovim (also general utility)
	neovim
	zen-browser-bin # Web browser
	man-db # manual pages
	p7zip # 7z
	ttf-firacode-nerd # nice monofont
	ttf-roboto # nice propo font
	noto-fonts-emoji # emojis
	ttf-nerd-fonts-symbols # Fallback symbols
	brightnessctl # for screen and keyboard lights
	openssh
	git
	zsh
  iwgtk # gtk network manager gui
  gomplate-bin
)
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

			
################ Installations from other sources ###############
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" > /dev/null


###################### Copy config dotfile ######################
echo "Copy emptty conf with autologin for default user: $user"
sed "s/{user}/$user/g" "$SCRIPT_DIR/dotfiles/etc/emptty/conf" | sudo tee /etc/emptty/conf > /dev/null

echo "Copy default fonts conf.d (FiraCode for mono, Roboto for sans)"
sudo cp "$SCRIPT_DIR/dotfiles/etc/fonts/conf.d/68-malsu.conf" /etc/fonts/conf.d/

echo "Copy config dotfiles"
cp -rf "$SCRIPT_DIR/dotfiles/.config" $HOME

echo "Copy .zshrc and powerlevel10k configs (.p10k.zsh)"
cp "$SCRIPT_DIR/dotfiles/.zshrc" $HOME
cp "$SCRIPT_DIR/dotfiles/.p10k.zsh" $HOME

echo "Clone nvim-config git repo"
git clone https://github.com/lcavalleria/nvim-config $HOME/.config/nvim

echo "Run theme config script"
bash $HOME/.config/malsu/apply_theme.sh


##################### User Configurations ###################
echo "Set $user default shell to zsh"
sudo chsh -s /bin/zsh "$user" > /dev/null

echo "Add $user to new nopasswdlogin group"
sudo groupadd -r nopasswdlogin > /dev/null
sudo gpasswd -a $user nopasswdlogin > /dev/null

echo "Add user to input group, needed for waybar"
sudo usermod -a -G input $user > /dev/null


################### Setup necessary services ################### 
echo "Enable emptty systemd..."
sudo systemctl enable emptty > /dev/null
echo "Enable hyprpolkitagent..."
systemctl --user enable hyprpolkitagent.service > /dev/null
echo "Disable iwctl tray..."
sudo systemctl mask app-iwgtk\\x2dindicator@autostart.service
