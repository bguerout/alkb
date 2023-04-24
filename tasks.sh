#!/usr/bin/env bash
set -euo pipefail


readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2046
[ -f "${BASE_DIR}/.env" ] && export $(grep -vE "^(#.*|\s*)$" "${BASE_DIR}/.env" | xargs)
readonly KERNEL_NAME="${KERNEL_NAME:?"You must provide a kernel name (linux or linux-lts)"}"
readonly PATCHES_DIR="${BASE_DIR}/patches/${KERNEL_NAME}"
readonly BUILD_DIR="${BASE_DIR}/build"
readonly LINUX_DIR="${BUILD_DIR}/${KERNEL_NAME}/repo"
readonly PACKAGE_DIR="${BUILD_DIR}/${KERNEL_NAME}/package"
readonly DIST_DIR="${BASE_DIR}/dist"

function checkout_linux_repo() {
  if [[ -d "${LINUX_DIR}" ]]; then
    echo "Fetching linux kernel repository..."
    cd "${LINUX_DIR}"
    git pull
    cd ..
  else
    echo "Cloning linux kernel repository ${KERNEL_NAME}..."
    git clone https://github.com/archlinux/svntogit-packages --branch "packages/${KERNEL_NAME}" --single-branch "${LINUX_DIR}"
  fi

  mkdir -p "${PACKAGE_DIR}"
  cd "${PACKAGE_DIR}"
  echo "Copying package build instructions from trunk..."
  cp "${LINUX_DIR}"/trunk/{config,PKGBUILD} .
  cp "${LINUX_DIR}"/trunk/*.patch . || true
  cd ..
}

function configure_package() {
  local pkg_base="${PKG_BASE_NAME}"
  apply_patches "remove-doc"

  echo "Set pkgbase='${pkg_base}' into PKGBUILD..."
  cd "${PACKAGE_DIR}"
  sed -i "s/pkgbase=${KERNEL_NAME}/pkgbase=${pkg_base}/g" PKGBUILD
  cd ..

  echo "Prepare custom config"
  cd "${PACKAGE_DIR}"
  cat "${PATCHES_DIR}/config" >>config
  updpkgsums
  cd ..
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

  mkdir -p "${DIST_DIR}"
  mv "${PACKAGE_DIR}"/*.tar.zst "${DIST_DIR}"
}

function default {
  help
}

function help {
  echo "$0 <task> <args>"
  echo "Tasks:"
  compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time "${@:-default}"
