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
mkfs.ext4 -F -L ${label_name} /dev/${droot}2

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
localectl set-x11-keymap us
# if the above doesn't work try: echo "KEYMAP=us" >> /etc/vconsole.conf

echo "${hname}" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ${hname}.localdomain ${hname}" >> /etc/hosts

# cat /etc/hostname
# cat /etc/hosts

mkinitcpio -P

pacman -Sy grub os-prober efibootmgr amd-ucode --noconfirm

grub-install --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg

pacman -Sy  base-devel linux-lts openssh vim vi wpa_supplicant git wget curl unzip zsh --noconfirm

useradd -m ${uname}
usermod -aG wheel ${uname}
echo ${uname}:${upass} | chpasswd

echo "------------------"
echo "Setting up Sudoers wheel group..."
echo "------------------"
#sed -i -e 's/^#.*%wheel/%wheel/g' -e 's/^%wheel.*NOPASSWD.*$//g' /etc/sudoers
sed -i 's/^#.*%wheel/%wheel/g' /etc/sudoers

echo "------------------"
echo "Hardening Security..."
echo "------------------"
# Prevent against Fork bomb and limit user active process THESE BROKE THINGS
# echo "* soft nproc 100" > /etc/security/limits.conf
# echo "* hard nproc 200" >> /etc/security/limits.conf
# Increase timeout on login attempts
# echo "auth optional pam_faildelay.so delay=4000000" >> /etc/pam.d/system-login
# Harden SSH
sed -i 's/^#PermitRootLogin.*$/PermitRootLogin\ no/g' /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries.*$/MaxAuthTries\ 3/g' /etc/ssh/sshd_config
sed -i 's/^#LoginGraceTime.*$/LoginGraceTime\ 20/g' /etc/ssh/sshd_config
sed -i 's/^#PermitEmptyPasswords.*$/PermitEmptyPasswords\ no/g' /etc/ssh/sshd_config

echo "------------------"
echo "Enable Networking and SSH..."
echo "------------------"
echo "enable sshd.service" > /lib/systemd/system-preset/20-sshd.preset
systemctl preset-all

echo "[Match]" > /etc/systemd/network/20-wired.network
echo "Name=*" >> /etc/systemd/network/20-wired.network
echo "[Network]" >> /etc/systemd/network/20-wired.network
echo "DHCP=yes" >> /etc/systemd/network/20-wired.network
EOF

# Umount
umount /mnt/boot
umount /mnt