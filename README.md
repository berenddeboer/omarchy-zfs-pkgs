# omarchy-zfs-pkgs

Private pacman repo for Quattro-on-ZFS. Not a fork of `omacom-io/omarchy-pkgs`.

It publishes only:

- `omarchy-dev`
- `omarchy-settings-dev`

built from `berenddeboer/omarchy` branch `quattro-on-zfs`.

## Use

```
[omarchy-zfs]
SigLevel = Optional TrustAll
Server = https://github.com/berenddeboer/omarchy-zfs-pkgs/releases/download/zfs
```

Put `[omarchy-zfs]` above `[omarchy]` in `/etc/pacman.conf`. The packages use `epoch=1` so they win over official Omarchy builds of the same name.

## Build locally

```bash
git clone --branch quattro-on-zfs git@github.com:berenddeboer/omarchy.git omarchy
docker run --rm -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
  -v "$PWD:/work" -w /work archlinux:base-devel bash /work/script/build.sh
```
