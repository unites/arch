# Desktop First Steps

## Checks

### UEFI
If the directory does not exist, the system is booted in BIOS.
```
ls /sys/firmware/efi/efivars
```

### Check Networking
Check DHCP and DNS as well as general connectivity.
```
ping archlinux.org
```

Note you can use:
```
systemctl stop dhcpcd@
systemctl start dhcpcd@
```

Also useful:
```
ip link
ip link set eth0 up
ip link set eth0 down
ip link show dev eth0
```

### Time and Date
Set system Clock
```
timedatectl set-ntp true
timedatectl status
```

## Partitions
Use `cgdisk` or `cfdisk`.  `fdisk -l` will give you quick info about the disks available.

Note, the "Linux LVM" filesystem Type won't work, you need to use "Linux Filesystems".

### efi
100M 

### boot
UEFI requires 512M or greater or 200M for BIOS.  This should also be a partition and not a LV.

### LVM
The rest of the disk should be assigned as a LVM, if you intend to use LVM.

## Filesystems and LV's
`lsblk -f` checks for mounted filesystems

### /swap
8G, or the size of your RAM

### /boot
UEFI requires 512M or greater or 200M for BIOS.  This should also be a partition and not a LV.

### /home
10G for a start, if using LVM it can be expanded later. This stores all user data.

### /var
8G is ideal.  Store ABS tree and pacman cache.

### /
Root partition, at least 15G

### /data
Not needed but can be used for shared data.


## Format Partitions
```
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap
```

## Create Partitions

