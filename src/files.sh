#!/bin/bash
#
# files
# by Takeaki Oura(@iHalt10)
import log.sh
import name.sh

_files__is_filter_include=false
_files__is_filter_exclude=false
_files__filter_include_list_str=""
_files__filter_exclude_list_str=""
_files__is_dry_run=false
files__list=()
files__global_ignore_list=()

function files::disable_dry_run() {
  _files__is_dry_run=false
}

function files::enable_dry_run() {
  _files__is_dry_run=true
}

function files::set_filter_include() {
  _files__is_filter_include=true
  _files__filter_include_list_str="$1"
}

function files::reset_filter_include() {
  _files__is_filter_include=false
  _files__filter_include_list_str=""
}

function files::set_filter_exclude() {
 _files__is_filter_exclude=true
 _files__filter_exclude_list_str="$1"
}

function files::reset_filter_exclude() {
  _files__is_filter_exclude=false
  _files__filter_exclude_list_str=""
}

function files::load_global_ignore_list() {
  files__global_ignore_list+=(".DS_Store")
  readonly files__global_ignore_list
}

function files::_create_dist_dir() {
  local dist_dir="$1"
  ${_files__is_dry_run} || mkdir -p "${dist_dir}"
  log::info "Created dist dir: ${dist_dir}"
}

function files::check_dist_dir() {
  local dist_dir="$1"
  local is_create_dist_dir=${2:-false}
  if [[ ! -d "${dist_dir}" ]]; then
    if ${is_create_dist_dir}; then
      files::_create_dist_dir "${dist_dir}"
    else
      log::err "Not found ${dist_dir}."
      exit 1
    fi
  fi
}

function files::is_ignore() {
  local value="$1"
  for ignore in "${files__global_ignore_list[@]}"; do
    if [[ "${value}" == *"${ignore}"* ]]; then
      return 0
    fi
  done
  return 1
}

function files::is_filter() {
  local old_IFS="${IFS}"
  IFS=$','
  local filter_list=( $1 )
  IFS="${old_IFS}"

  local value="$2"

  for filter in "${filter_list[@]}"; do
    if [[ "${value}" == *"${filter}"* ]]; then
      return 0
    fi
  done

  return 1
}

function files::create_list() {
  local src_dir="$1"
  local maxdepth=$(( $2 ))

  while read -r file; do
    local is_add=false

    files::is_ignore "${file}" && {
      log::info "Ignore ${file}"
      continue
    }

    ${_files__is_filter_include} && files::is_filter "${_files__filter_include_list_str}" "${file}" && is_add=true
    ${_files__is_filter_exclude} && ( ${is_add} || ! ${_files__is_filter_include} ) && {
      if ! files::is_filter "${_files__filter_exclude_list_str}" "${file}"; then
        is_add=true
      else
        is_add=false
      fi
    }
    ${_files__is_filter_include} || ${_files__is_filter_exclude} || is_add=true

    if ${is_add}; then
      log::debug "Target ${file}"
      files__list+=("${file}")
    else
      log::debug "Not Target ${file}"
    fi
  done < <(find "${src_dir}" -maxdepth ${maxdepth} -type f 2>/dev/null)
}

function files::sort() {
  local sort_type="$1"
  local old_IFS="${IFS}"

  [[ ${#files__list[@]} -eq 0 ]] && return
  IFS=$'\n'
  if [ "${sort_type}" == "asc" ]; then
    files__list=( $( printf "%s\n" "${files__list[@]}" | sort) )
  elif [ "${sort_type}" == "desc" ]; then
    files__list=( $( printf "%s\n" "${files__list[@]}" | sort -r) )
  else
    true
  fi
  IFS="${old_IFS}"
}

function files::copy() {
  local src_file="$1"
  local dist_file="$2"

  ${_files__is_dry_run} || cp "${src_file}" "${dist_file}"
  log::info "Copyed: ${src_file} => ${dist_file}"
}

function files::delete() {
  local src_file="$1"
  local username_of_file=$(ls -l "${src_file}" | awk '{print $3}')
  if [[ "${username_of_file}" == "${USER}" ]]; then
    ${_files__is_dry_run} || rm -f "${src_file}"
    log::info "Deleted src file: ${src_file}"
  else
    log::err "Delete src file: Permission denied: ${src_file}"
  fi
}

function files::copies() {
  local naming_type="$1"
  local dist_dir="$2"
  local is_delete_src_file=${3:-false}

  [[ ${#files__list[@]} -eq 0 ]] && return
  for file in "${files__list[@]}"; do
    if [ -r "${file}" ]; then
      local username_of_file=$(ls -l "${file}" | awk '{print $3}')
      if [[ "${username_of_file}" != "${USER}" ]]; then
        log::warn "${file}: It is copied, but the file user and the exec user are different."
      fi
      name::determine_name "${naming_type}" "${file}" "${dist_dir}"
      files::copy "${file}" "${dist_dir}/${name__named_file}"
      ${is_delete_src_file} && files::delete "${file}"
    else
      log::warn "Not read: ${file}"
    fi
  done
}
