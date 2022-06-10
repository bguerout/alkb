#!/usr/bin/env bash
set -euo pipefail

readonly TASK=${1:?"Please provide a task [get_linux_package, configure_package, apply_patches]"}
shift
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PATCHES_DIR="${SCRIPT_DIR}/patches"
readonly BUILD_DIR="${SCRIPT_DIR}/build"
readonly LINUX_DIR="${BUILD_DIR}/linux"
readonly PACKAGE_DIR="${BUILD_DIR}/package"

function _apply_config() {
  echo "Applying custom config..."
  cd "${PACKAGE_DIR}"
  cat "${PATCHES_DIR}/config" >>config
  updpkgsums
  cd ..
}

function _set_version() {
  local package_name="${1}"
  local package_release_number="${2}"

  echo "Updating package name '${package_name}' and release number '${package_release_number}'..."
  cd "${PACKAGE_DIR}"
  sed -i "s/pkgbase=linux/pkgbase=${package_name}/g" PKGBUILD
  sed -i "s/pkgrel=1/pkgrel=${package_release_number}/g" PKGBUILD
  cd ..
}

function get_linux_package() {
  if [[ -d "${LINUX_DIR}" ]]; then
    echo "Fetching linux kernel repository..."
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
  cd ..
}

function configure_package() {
  apply_patches "remove-doc"
  _set_version "$@"
  _apply_config
}

function apply_patches() {
  local patches=("${@}")

  cd "${PACKAGE_DIR}"
  for patch in "${patches[@]}"; do
    patch PKGBUILD <"${PATCHES_DIR}/PKGBUILD-${patch}.patch"
  done
  cd ..
}

function build() {
  cd "${PACKAGE_DIR}"
  makepkg -s
  cd ..
}

#Call task
$TASK "${@}"
