#!/bin/sh

# Make sure sudo or root
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

usage() { echo "Usage: $0 [-u Username]" 1>&2; exit 1; }

while getopts ":u:" o; do
    case "${o}" in
        u)
            uname=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${uname}" ]; then
    usage
fi

# Var
hdir="/home/${uname}"

echo "------------------"
echo "Pacman Install of the OS packages..."
echo "------------------"

sudo pacman -Sy git \
xorg \
xorg-xinit \
xorg-server \
xorg-apps \
openssh \
libnotify \
fontconfig \
powerline-fonts \
ttf-dejavu \
feh \
fzf \
zsh \
curl \
wget \
tar \
rsync \
cifs-utils \
ranger \
vim \
python3 \
ruby \
nodejs \
pavucontrol \
mpc \
mpd \
ncmpcpp \
mpv \
vlc \
ffmpeg \
freerdp \
nm-connection-editor \
syncthing \
blueman \
id3v2 \
pciutils \
i3-gaps \
i3status \
dmenu \
i3lock \
conky \
kbd \
rofi \
xss-lock \
xautolock \
maim \
xclip \
dunst \
alacritty \
unzip \
picom \
bluez \
bluez-tools \
blueman \
id3v2 \
kbd \
neofetch \
cifs-utils \
xorg-xset \
lm_sensors \
htop \
ntfs-3g \
xdotool \
dos2unix \
copyq \
ddcutil \
atool \
highlight \
elinks \
mediainfo \
w3m \
ffmpegthumbnailer \
mupdf \
rxvt-unicode \
gpaste --noconfirm

# Replace Pulse with pipewire
pacman -Sy pipewire-pulse \
pipewire-alsa \
pipewire-jack \
alsa-card-profiles \
easyeffects 

# Nvidia Drivers
# pacman -Sy nvidia nvidia-utils nvidia-settings --noconfirm

echo "------------------"
echo "Adding Repos..."
echo "------------------"

# Add Sublime Repo
# curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
# echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
# pacman -Syu

pacman -Sy code \
firefox \
chromium \
profile-sync-daemon --noconfirm

echo "------------------"
echo "Pulling Config for Workstation..."
echo "------------------"
cd $hdir
git clone https://github.com/unites/.config.git
git remote set-url origin git@github.com:unites/.config.git

echo "------------------"
echo "Installing Nerd Fonts..."
echo "------------------"
mkdir -p  $hdir/.local/share/fonts/NerdFonts
cd  $hdir/.local/share/fonts/NerdFonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Terminus.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/DejaVuSansMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip Terminus.zip
unzip Hack.zip
unzip DejaVuSansMono.zip
unzip JetBrainsMono.zip
rm *.zip
rm *Windows*.ttf
fc-cache -fv  $hdir/.local/share/fonts/NerdFonts

echo "------------------"
echo "Installing Nerd Fonts..."
echo "------------------"
# Install Oh My ZSH
cd  $hdir
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo usermod --shell /usr/bin/zsh $uname
sudo usermod --shell /usr/bin/zsh root

echo "------------------"
echo "Setup Desktop..."
echo "------------------"
# Plugins for OhMyZSH
cd $hdir
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# P10k for ohmyzsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/themes/powerlevel10k

cp -r /root/.oh-my-zsh $hdir

# Link setup scripts to home dir from config
ln -fs $hdir/.config/.zshrc $hdir/.zshrc
ln -fs $hdir/.config/.p10k.zsh $hdir/.p10k.zsh
ln -fs $hdir/.config/.vimrc $hdir/.vimrc
ln -fs $hdir/.config/.xinitrc $hdir/.xinitrc
ln -fs $hdir/.config/.Xresources $hdir/.Xresources
ln -fs $hdir/.config/.Xresources $hdir/.Xsession

cp $hdir/.config/.p10k_root.zsh /root/.p10k.zsh
cp $hdir/.config/.zshrc /root

# Dir and OS changes
mkdir -p $hdir/Music
mkdir -p $hdir/Images
mkdir -p $hdir/.app/iPlex
mkdir -p $hdir/.app/iNetflix
mkdir -p $hdir/.app/iGeforce
mkdir -p $hdir/.app/iYoutube
mkdir -p $hdir/.app/iOutlook

chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-autosuggestions
chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

chown -R $uname:$uname $hdir

# Notification won't work without having dbus set NEED TO INSTALL EVERYTHING FIRST
sed -i 's/unset\ DBUS_SESSION_BUS_ADDRESS/#unset\ DBUS_SESSION_BUS_ADDRESS/g' /usr/bin/startx

# echo "------------------"
# echo "Flatpak Install..."
# echo "------------------"
pacman -Sy flatpak --noconfirm
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LANGUAGE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_ADDRESS=en_US.UTF-8" >> /etc/locale.conf
echo "LC_COLLATE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_CTYPE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_IDENTIFICATION=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MEASUREMENT=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=en_US.UTF-8" >> /etc/locale.conf
echo "LC_NAME=en_US.UTF-8" >> /etc/locale.conf
echo "LC_NUMERIC=en_US.UTF-8" >> /etc/locale.conf
echo "LC_PAPER=en_US.UTF-8" >> /etc/locale.conf
echo "LC_TELEPHONE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_TIME=en_US.UTF-8" >> /etc/locale.conf

# Screen blank on idle in CLI
# sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3\ quiet\ consoleblank=120\"/g' /etc/default/grub
# grub-mkconfig -o /boot/grub/grub.cfg

# cd /opt  
# sudo git clone https://aur.archlinux.org/yay.git
# sudo chown -R ${uname}:${uname} /opt/yay

# cd yay/  
# runuser -l ${uname} -c "cd /opt/yays;makepkg -sri"
