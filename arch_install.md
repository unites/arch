arch_install.md

# Desktop First Steps

## Checks

### UEFI
If the directory does not exist, the system is booted in BIOS.
```
ls /sys/firmware/efi/efivars
```

### Check
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
```