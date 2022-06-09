#!/usr/bin/env bash
set -euo pipefail

readonly TASK=${1:?"Please provide a task [clean, prepare, build, install]"}
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

function get_kernel_package() {

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
  cd ..
}

function configure_package() {
  apply_patches "change-version"
  apply_patches "remove-doc"
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

#Call task
$TASK "${@}"
