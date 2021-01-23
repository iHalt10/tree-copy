#!/bin/bash
#
# install
# by Takeaki Oura(@iHalt10)
set -u

if [[ ! -d "${INSTALL_BIN_PATH}" ]]; then
  echo "err: Not found. INSTALL_BIN_PATH='${INSTALL_BIN_PATH}'" >&2
  exit 1
fi

if [[ ! -d "${APP_DIR}" ]]; then
  echo "err: Not found. APP_DIR='${APP_DIR}'" >&2
  exit 1
fi

if [[ -L "${INSTALL_BIN_PATH}/tcp" ]]; then
  echo "err: Already installed ${INSTALL_BIN_PATH}/tcp"
  exit 1
fi

chmod +x "${APP_DIR}/src/tcp"
ln -s "${APP_DIR}/src/tcp" "${INSTALL_BIN_PATH}/tcp"
echo "Create symlink: ${APP_DIR}/src/tcp to ${INSTALL_BIN_PATH}/tcp"
