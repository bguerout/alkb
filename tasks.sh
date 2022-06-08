#!/usr/bin/env bash
set -euo pipefail

readonly TASK=${1:?"Please provide a task"}
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PACKAGE_DIR="${SCRIPT_DIR}/linux"
readonly PATCHES_DIR="${SCRIPT_DIR}/patches"

function clone_kernel() {
  cd "$SCRIPT_DIR"
  asp update linux
  [[ -d "${PACKAGE_DIR}" ]] || asp export linux
  cd ..
}

function configure() {
  #https://github.com/archlinux/svntogit-packages/blob/packages/linux/trunk/PKGBUILD
  cp "${PATCHES_DIR}/PKGBUILD" "${PACKAGE_DIR}/PKGBUILD"

  patch "${PACKAGE_DIR}/config" <"${PATCHES_DIR}/config.patch"

  cd "$PACKAGE_DIR"
  local SHA256SUMS
  SHA256SUMS=$(makepkg -g -f -p PKGBUILD)

  SHA256SUMS="${SHA256SUMS}" envsubst '$SHA256SUMS' <PKGBUILD | tee PKGBUILD
  updpkgsums
  cd ..
}

function build_kernel() {
  cd "$PACKAGE_DIR"
  makepkg -s
  cd ..
}

function install_packages() {
  cd "$PACKAGE_DIR"
  pacman -U *.tar.zst
  cd ..
}

#Call task
$TASK
