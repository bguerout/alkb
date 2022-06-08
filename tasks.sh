#!/usr/bin/env bash
set -euo pipefail

readonly TASK=${1:?"Please provide a task [clean, prepare, build, install]"}
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PATCHES_DIR="${SCRIPT_DIR}/patches"
readonly BUILD_DIR="${SCRIPT_DIR}/build"
readonly LINUX_DIR="${BUILD_DIR}/linux"
readonly PACKAGE_DIR="${BUILD_DIR}/package"

function clean() {
  [[ -d "${BUILD_DIR}" ]] && rm -r "${BUILD_DIR}"
}

function prepare() {
  mkdir -p "${BUILD_DIR}"

  if [[ -d "${LINUX_DIR}" ]]; then
    echo "Updating linux kernel repository..."
    cd "${LINUX_DIR}"
    git pull
    cd ..

  else
    echo "Cloning linux kernel repository..."
    git clone https://github.com/archlinux/svntogit-packages --branch packages/linux --single-branch "${LINUX_DIR}"
  fi

  mkdir -p "${PACKAGE_DIR}"
  cd "${PACKAGE_DIR}"
  echo "Copying package build instructions from trunk..."
  cp "${LINUX_DIR}"/trunk/{config,PKGBUILD} .

  echo "Patching files..."
  echo "CONFIG_I8K=y" >> config
  patch PKGBUILD <"${PATCHES_DIR}/PKGBUILD.patch"

  echo "Updating checksums..."
  updpkgsums
  cd ..
}

function build() {
  cd "${PACKAGE_DIR}"
  makepkg -s
  cd ..
}

function install() {
  cd "${PACKAGE_DIR}"
  pacman -U *.tar.zst
  cd ..
}

#Call task
$TASK
