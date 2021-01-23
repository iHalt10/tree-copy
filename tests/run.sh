#!/bin/bash
#
# Integration Tests
# by Takeaki Oura(@iHalt10)

EXEC_SRC="$1"
if [[ ! -f "${EXEC_SRC}" ]]; then
  echo "err: ${EXEC_SRC} not found." >&2
fi

TEST_SRC_DIR="$(dirname "$0")"
ASSET_DIR="${TEST_SRC_DIR}/assets"
TCP_SRC_DIR="${ASSET_DIR}/src"
TCP_DIST_DIR="${ASSET_DIR}/dist"

function create_assets() {
  mkdir -p "${TCP_SRC_DIR}"
  mkdir -p "${TCP_DIST_DIR}"

  touch "${TCP_SRC_DIR}/a.txt"
  mkdir -p "${TCP_SRC_DIR}/b"
  touch "${TCP_SRC_DIR}/b/c.md"
  touch "${TCP_SRC_DIR}/b/d"
  touch "${TCP_SRC_DIR}/b/e.txt"
  touch "${TCP_SRC_DIR}/e.txt"
}

function delete_assets() {
  rm -rf "${ASSET_DIR}"
}


## Test case 1 ##
echo "[ Test Case 1 ]"
create_assets

echo "TEST CMD: /bin/bash ${EXEC_SRC} -n kn -s "${TCP_SRC_DIR}" -d "${TCP_DIST_DIR}" --debug"
/bin/bash ${EXEC_SRC} -n kn -s "${TCP_SRC_DIR}" -d "${TCP_DIST_DIR}" --debug

echo
echo "TEST RESULT CMD: find ${ASSET_DIR} -type f"
find ${ASSET_DIR} -type f

delete_assets

echo
echo
## Test case 2 ##
echo "[ Test Case 2 ]"
create_assets

echo "TEST CMD: /bin/bash ${EXEC_SRC} -n uid-lower -s "${TCP_SRC_DIR}" -d "${TCP_DIST_DIR}" -f include .text,.md --debug"
/bin/bash ${EXEC_SRC} -n uid-lower -s "${TCP_SRC_DIR}" -d "${TCP_DIST_DIR}" -f include ".txt,.md" --debug

echo
echo "TEST RESULT CMD: find ${ASSET_DIR} -type f"
find ${ASSET_DIR} -type f

delete_assets
