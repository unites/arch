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

## Partition
