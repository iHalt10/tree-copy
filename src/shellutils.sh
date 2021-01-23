#!/bin/bash
#
# shell utility
# by Takeaki Oura(@iHalt10)

if [ -L "$0" ]; then
  SRC_FILE="$(ls -l "$0" | awk '{print $11}')"
else
  SRC_FILE="$0"
fi

readonly PROGRAM_DIR="$(cd "$(dirname "${SRC_FILE}")" || exit 2; pwd -P)"
LOAD_SOURCE_LIST=( "${PROGRAM_DIR}/$(basename "$SRC_FILE")" )

function import() {
  local src="${PROGRAM_DIR}/${1#./}"
  if [[ -f ${src} ]]; then
    if [[ ! $(printf '%s\n' "${LOAD_SOURCE_LIST[@]}" | grep -qx "${src}"; echo -n $? ) -eq 0 ]]; then
      LOAD_SOURCE_LIST+=( "${src}" )

      source "${src}"
    fi
  else
    echo "${src}: No such file or directory" >&2
    exit 1
  fi
}
