#!/bin/sh
# Ensure you are using UEFI mode!

# Make sure sudo or root
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

usage() { echo "Usage: $0 [-u Username] [-p Password] [-d disk (sda,sdc,etc)] [-h hostname]" 1>&2; exit 1; }

while getopts ":u:p:h:d:" o; do
    case "${o}" in
        u)
            uname=${OPTARG}
            ;;
        p)
            upass=${OPTARG}
            ;;
        d)
            droot=${OPTARG}
            ;;
        h)
            hname=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


if [ -z "${uname}" ] || [ -z "${upass}" ] || [ -z "${droot}" ] || [ -z "${hname}" ]; then
    usage
fi

# Vars
hdir="/home/${uname}"

# Allow nonfree and contrib
sed -i 's/main$/main\ contrib\ non\-free/g' /etc/apt/sources.list
apt-get update && apt-get upgrade -y

# Microcode Intel
# apt-get install intel-microcode
# Microcode AMD
# apt-get install amd64-microcode

echo "--- Install Core Packages ---"
apt-get install xorg \
i3 \
suckless-tools \
vim \
wget \
gpg \
apt-transport-https \
dos2unix \
ntfs-3g \
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
pavucontrol \
pciutils \
i3status \
i3lock \
kbd \
rofi \
xss-lock \
xautolock \
maim \
xclip \
dunst \
unzip \
picom \
neofetch \
elinks \
w3m \
tmux \
mediainfo \
freerdp2-x11 \
sudo \
git \
flatpak -y

echo "### Repo Additions ###"
cd $hdir
echo "--- Sublime Text ---"
wget -O- https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor > /usr/share/keyrings/sublimehq-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/dev/" | tee /etc/apt/sources.list.d/sublime-text.list
echo "------"
echo "--- VScode ---"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
echo "------"
echo "--- Brave ---"
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"| tee /etc/apt/sources.list.d/brave-browser-release.list
echo "------"

echo "### Install Additional Repo Packages ###"
apt-get update -y
apt-get install sublime-text \
code -y

echo "### Flatpak Installs ###"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub md.obsidian.Obsidian -y
flatpak install com.google.Chrome -y
flatpak install org.chromium.Chromium -y
flatpak install org.mozilla.firefox -y

echo "### Install Browsers ###"
apt-get install brave-browser -y

echo "### Copy Stock Config Files ###"
cp /etc/X11/xinit/xinitrc $hdir/.xinitrc
mkdir -p $hdir/.config/i3/config
cp /etc/i3/config $hdir/.config/i3/config

echo "------------------"
echo "Installing Nerd Fonts..."
echo "------------------"
mkdir -p  /root/.local/share/fonts/NerdFonts
mkdir -p  $hdir/.local/share/fonts/NerdFonts
cd  /root/.local/share/fonts/NerdFonts
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
fc-cache -fv  /root/.local/share/fonts/NerdFonts

cp /root/.local/share/fonts/NerdFonts/* $hdir/.local/share/fonts/NerdFonts/
chown -R $uname:$uname

echo "------------------"
echo "Installing ZSH Tools"
echo "------------------"
# Install Oh My ZSH
cd /root
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
usermod --shell /usr/bin/zsh $uname
usermod --shell /usr/bin/zsh root

# Plugins for OhMyZSH
cd /root
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Copy all from root to user and chown/chmod
cp -r /root/.oh-my-zsh $hdir
chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-autosuggestions
chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
chown -R $uname:$uname $hdir

# Make sure everything is owned by user in their home dir
chown -R $uname:$uname $hdir