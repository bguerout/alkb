# Arch Linux Kernel Builder (alkb)

Tiny bash script to build Arch Linux kernel

## Configure the Linux kernel

`PKGBUILD` is patched to create a custom kernel config file based on modules provided by [modprobed](https://wiki.archlinux.org/title/Modprobed-db)

```sh
bash tasks.sk prepare
```

## Build the kernel
```sh
bash tasks.sk build
```

## Install the packages
```sh
bash tasks.sk install
```
