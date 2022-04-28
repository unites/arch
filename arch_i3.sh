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
echo "i3wm UI"
echo "------------------"

sudo pacman -Sy git \
xorg \
xorg-xinit \
xorg-server \
xorg-apps \
xorg-xset \
libnotify \
fontconfig \
powerline-fonts \
ttf-dejavu \
dos2unix \
ntfs-3g \
lm_sensors \
htop \
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
mpc \
mpd \
ncmpcpp \
mpv \
vlc \
ffmpeg \
freerdp \
nm-connection-editor \
pavucontrol \
pciutils \
i3-gaps \
i3status \
dmenu \
i3lock \
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
neofetch \
id3v2 \
copyq \
elinks \
w3m \
tmux \
mediainfo --noconfirm

# Remove, possibly not needed anymore...
# blueman \
# conky \
# bluez \
# bluez-tools \
# xdotool \
# copyq \
# ddcutil \
# atool \
# highlight \
# ffmpegthumbnailer \
# mupdf \
# rxvt-unicode \
# gpaste 

echo "------------------"
echo "Copying Stock Configs"
echo "------------------"

cp /etc/i3/config $hdir/.config/i3/config
cp /etc/X11/xinitrc $hdir/.xinitrc
cp /etc/xdg/picom.conf $hdir/.config/picom.conf

echo "------------------"
echo "Adding Repos..."
echo "------------------"

# Add Sublime Repo
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
pacman -Syu

# Browsers and IDE
pacman -Sy code \
firefox \
chromium --noconfirm

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
echo "Installing ZSH Tools"
echo "------------------"
# Install Oh My ZSH
cd  $hdir
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo usermod --shell /usr/bin/zsh $uname
sudo usermod --shell /usr/bin/zsh root

# Plugins for OhMyZSH
cd $hdir
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Copy all from root to user and chown/chmod
cp -r /root/.oh-my-zsh $hdir
chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-autosuggestions
chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
chown -R $uname:$uname $hdir

# Notification won't work without having dbus set NEED TO INSTALL EVERYTHING FIRST
# Maybe not longer needed, default config removed this
#sed -i 's/unset\ DBUS_SESSION_BUS_ADDRESS/#unset\ DBUS_SESSION_BUS_ADDRESS/g' /usr/bin/startx

# Lang stuff
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

