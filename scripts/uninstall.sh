#!/bin/bash
#
# uninstall
# by Takeaki Oura(@iHalt10)
set -eu

if [[ ! -d "${INSTALL_BIN_PATH}" ]]; then
  echo "err: Not found. INSTALL_BIN_PATH='${INSTALL_BIN_PATH}'" >&2
  exit 1
fi

if [[ ! -d "${APP_DIR}" ]]; then
  echo "err: Not found. APP_DIR='${APP_DIR}'" >&2
  exit 1
fi

if [[ ! -L "${INSTALL_BIN_PATH}/tcp" ]]; then
  echo "err: Already uninstalled ${INSTALL_BIN_PATH}/tcp"
  exit 1
fi

rm -f "${INSTALL_BIN_PATH}/tcp"
echo "Delete symlink: ${INSTALL_BIN_PATH}/tcp"
