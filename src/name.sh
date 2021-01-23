#!/bin/bash
#
# file naming
# by Takeaki Oura(@iHalt10)

name__named_file=""

_name__numbering_cnt=0
function name::_get_numbering() {
  local file="$1"
  local filename="$(basename "${file}")"
  local base="${filename%.*}"
  local extension="${filename##*.}"

  if [[ "${base}" == "${extension}" ]]; then
    name__named_file="${_name__numbering_cnt}"
  else
    name__named_file="${_name__numbering_cnt}.${extension}"
  fi

  _name__numbering_cnt=$(( _name__numbering_cnt + 1 ))
}

function name::_get_keep_and_numbering() {
  local file="$1"
  local dist_dir="$2"
  local filename="$(basename "${file}")"
  local base="${filename%.*}"
  local extension="${filename##*.}"

  if [[ -f "${dist_dir}/${filename}" ]]; then
    if [[ "${base}" == "${extension}" ]]; then
      local cnt=$(find "${dist_dir}" -maxdepth 1 -name "${base} (*)" | wc -l | awk '{$1=$1};1')
      cnt=$(( cnt + 1 ))
      name__named_file="${base} (${cnt})"
    else
      local cnt=$(find "${dist_dir}" -maxdepth 1 -name "${base} (*).${extension}" | wc -l | awk '{$1=$1};1')
      cnt=$(( cnt + 1 ))
      name__named_file="${base} (${cnt}).${extension}"
    fi
  else
    name__named_file="${filename}"
  fi
}

function name::_get_uuid() {
  local file="$1"
  local filename="$(basename "${file}")"
  local base="${filename%.*}"
  local extension="${filename##*.}"
  local newbase="$(uuidgen)"

  if [[ "${base}" == "${extension}" ]]; then
    name__named_file="${newbase}"
  else
    name__named_file="${newbase}.${extension}"
  fi
}

function name::_get_uid_upper() {
  local file="$1"
  local filename="$(basename "${file}")"
  local base="${filename%.*}"
  local extension="${filename##*.}"
  local newbase="$(uuidgen | tr "[:lower:]" "[:upper:]" | sed "s/-//g")"

  if [[ "${base}" == "${extension}" ]]; then
    name__named_file="${newbase}"
  else
    name__named_file="${newbase}.${extension}"
  fi
}

function name::_get_uid_lower() {
  local file="$1"
  local filename="$(basename "${file}")"
  local base="${filename%.*}"
  local extension="${filename##*.}"
  local newbase="$(uuidgen | tr "[:upper:]" "[:lower:]" | sed "s/-//g")"

  if [[ "${base}" == "${extension}" ]]; then
    name__named_file="${newbase}"
  else
    name__named_file="${newbase}.${extension}"
  fi
}

function name::determine_name() {
  local naming_type="$1"
  local file="$2"
  local dist_dir="$3"

  case "${naming_type}" in
    'numbering' | 'n' )
      name::_get_numbering "${file}"
      ;;
    'keep-and-numbering' | 'kn' )
      name::_get_keep_and_numbering "${file}" "${dist_dir}"
      ;;
    'uuid' | 'u' )
      name::_get_uuid "${file}"
      ;;
    'uid-upper' | 'up' )
      name::_get_uid_upper "${file}"
      ;;
    'uid-lower' | 'lo' )
      name::_get_uid_lower "${file}"
      ;;
  esac
}
