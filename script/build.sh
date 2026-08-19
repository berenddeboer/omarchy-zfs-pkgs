#!/bin/bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
omarchy_src="${OMARCHY_SRC:-$repo_root/omarchy}"
out_dir="${OUT_DIR:-$repo_root/x86_64}"

[[ -d $omarchy_src ]] || {
  printf 'Missing Omarchy source: %s\n' "$omarchy_src" >&2
  exit 1
}

pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm --needed base-devel git pacman-contrib imagemagick

if ! id builder >/dev/null 2>&1; then
  useradd -m builder
fi
echo 'builder ALL=(ALL) NOPASSWD: /usr/bin/pacman' >/etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder

git config --global --add safe.directory "$omarchy_src"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
chown -R builder:builder "$work_dir"

mkdir -p "$out_dir"
chown builder:builder "$out_dir"

for pkg in omarchy-settings-dev omarchy-dev; do
  pkg_work="$work_dir/$pkg"
  cp -a "$repo_root/pkgbuilds/$pkg" "$pkg_work"
  chown -R builder:builder "$pkg_work"
  su builder -c "
    set -euo pipefail
    cd '$pkg_work'
    PKGDEST='$out_dir' OMARCHY_SRC='$omarchy_src' \
      makepkg --noconfirm --skippgpcheck --skipchecksums --nodeps -f
  "
done

rm -f "$out_dir"/omarchy-zfs.db* "$out_dir"/omarchy-zfs.files*
repo-add "$out_dir/omarchy-zfs.db.tar.gz" "$out_dir"/*.pkg.tar.zst
chown -R "${HOST_UID:-1000}:${HOST_GID:-1000}" "$out_dir" 2>/dev/null || true
