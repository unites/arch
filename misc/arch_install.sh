#!/bin/sh

echo "------------------"
echo "Ensure you are using UEFI mode!"
echo "------------------"

# Make sure sudo or root
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

# Input Checks
if [ -z $1 ]; then
    echo "User Name was not given, please give a user name or pass \$USER"
    echo "Example: ./arch_install.sh user pass sda hostname"
    exit
fi
if [ -z $2 ]; then
    echo "Password not given, please give a user password for account"
    echo "Example: ./arch_install.sh user pass sda hostname"
    exit
fi
if [ -z $3 ]; then
    echo "Drive name was not given, please give a drive name (sda, sdb, dbc, etc.)"
    echo "Example: ./arch_install.sh user pass sda hostname"
    exit
fi
if [ -z $4 ]; then
    echo "Hostname was not given, please give a hostname"
    echo "Example: ./arch_install.sh user pass sda hostname"
    exit
fi

# Variables
uname="$1"
upass="$2"
droot="$3"
hname="$4"
hdir="/home/${uname}"
label_name=alpha

timedatectl set-ntp true

# May need to use LV tools to remove lv/vgs from disk before running below
echo "------------------"
echo "Setup Disks and Filesystems..."
echo "------------------"
wipefs -fa /dev/${droot}

parted -s /dev/${droot} mklabel gpt

parted /dev/${droot} mkpart ESP fat32 1MiB 512MiB
mkfs.fat -F32 /dev/${droot}1

#parted -sa opt /dev/${droot} mkpart primary ext4 0% 100%
parted -sa opt /dev/${droot} mkpart primary ext4 512MiB 100%
mkfs.ext4 -L ${label_name} /dev/${droot}2

mount /dev/${droot}2 /mnt
mkdir /mnt/boot
mount /dev/${droot}1 /mnt/boot

echo "------------------"
echo "Pacstrap and install base, setup fstab..."
echo "------------------"
pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

echo "------------------"
echo "Chroot and setup OS..."
echo "------------------"
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

hwclock --systohc

sed -i 's/^#en_US.UTF/en_US.UTF/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "${hname}" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ${hname}.localdomain ${hname}" >> /etc/hosts

# cat /etc/hostname
# cat /etc/hosts

mkinitcpio -P

pacman -Sy grub os-prober efibootmgr --noconfirm

grub-install --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg

pacman -Sy git base-devel --noconfirm

echo "------------------"
echo "Pacman Install of the OS packages..."
echo "------------------"
pacman -Sy base-devel \
git \
xorg \
xorg-xinit \
openssh \
fontconfig \
powerline-fonts \
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
pulseaudio \
pavucontrol \
mpc \
mpd \
ncmpcpp \
mpv \
ffmpeg \
freerdp \
nm-connection-editor \
syncthing \
blueman \
id3v2 \
pciutils \
i3 \
i3status \
dmenu \
i3lock \
conky \
kbd \
rofi \
xss-lock \
xautolock \
compton \
maim \
xclip \
dunst \
gnome-icon-theme \
xorg \
xorg-xinit \
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
peek --noconfirm

useradd -m ${uname}
usermod -aG wheel ${uname}
echo ${uname}:${upass} | chpasswd

echo "------------------"
echo "Setting up Sudoers wheel group..."
echo "------------------"
sed -i -e 's/^#.*%wheel/%wheel/g' -e 's/^%wheel.*NOPASSWD.*$//g' /etc/sudoers

echo "------------------"
echo "Hardening Security..."
echo "------------------"
# Prevent against Fork bomb and limit user active process 
echo "* soft nproc 100" > /etc/security/limits.conf
echo "* hard nproc 200" >> /etc/security/limits.conf

# Increase timeout on login attempts
echo "auth optional pam_faildelay.so delay=4000000" >> /etc/pam.d/system-login

echo "------------------"
echo "Enable Networking and SSH..."
echo "------------------"
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable sshd.service
systemctl preset-all

echo "[Match]" > /etc/systemd/network/20-wired.network
echo "Name=*" >> /etc/systemd/network/20-wired.network
echo "[Network]" >> /etc/systemd/network/20-wired.network
echo "DHCP=yes" >> /etc/systemd/network/20-wired.network

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
unzip Terminus.zip
unzip Hack.zip
unzip DejaVuSansMono.zip
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

cp $hdir/.config/.p10k_root.zsh /root/.p10k.zsh
cp $hdir/.config/.zshrc /root

# Dir and OS changes
mkdir -p $hdir/Music
mkdir -p $hdir/Images/screenshots

chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-autosuggestions
chmod -R 755 $hdir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

chown -R $uname:$uname $hdir

# Notification won't work without having dbus set NEED TO INSTALL EVERYTHING FIRST
sed -i 's/unset\ DBUS_SESSION_BUS_ADDRESS/#unset\ DBUS_SESSION_BUS_ADDRESS/g' /usr/bin/startx

echo "------------------"
echo "Flatpak Install..."
echo "------------------"
pacman -Sy flatpak --noconfirm
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

EOF


#Not working ---
# cd /opt  
# sudo git clone https://aur.archlinux.org/yay.git
# sudo chown -R ${uname}:${uname} /opt/yay

# cd yay/  
# runuser -l ${uname} -c "cd /opt/yays;makepkg -sri"


# su - ${uname}

# cd /opt  
# sudo git clone https://aur.archlinux.org/yay.git
# sudo chown -R ${uname}:${uname} /opt/yay

# cd yay/  
# makepkg -sri

# yay -S microsoft-edge-dev \
# brave-bin \
# brave-beta-bin \
# brave-nightly-bin \

# passwd

# probably want to copy .config out now

# Also need to create script that does the following...

# systemctl enable NetworkManager
# systemctl enable sshd.service
# systemctl start NetworkManager
# systemctl start sshd.service

# or just 
# systemctl enable systemd-networkd
# systemctl enable systemd-resolved
# systemctl enable sshd.service
# systemctl start systemd-networkd
# systemctl start systemd-resolved
# systemctl start sshd.service


# ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# ln -fs ~/.config/.zshrc ~/.zshrc
# ln -fs ~/.config/.vimrc ~/.vimrc
# ln -fs ~/.config/.xinitrc ~/.xinitrc

# pacman -Sy 

# yay -S microsoft-edge-dev \
# brave-bin \
# brave-beta-bin \
# brave-nightly-bin \
# google-chrome 

# ==> WARNING: Possibly missing firmware for module: aic94xx
# ==> WARNING: Possibly missing firmware for module: wd719x
# ==> WARNING: Possibly missing firmware for module: xhci_pci