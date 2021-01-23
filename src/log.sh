#!/bin/bash
#
# log format
# by Takeaki Oura(@iHalt10)
import color.sh

_log__IS_DEBUG=true
_log__IS_INFO=true
_log__IS_ERR=true
_log__IS_FATAL=true
_log__IS_WARN=true

_log__DATE_CMD=""
_log__DATE_FORMAT=""
if type gdate > /dev/null 2>&1; then
  _log__DATE_CMD="gdate"
  _log__DATE_FORMAT="%Y-%m-%dT%H:%M:%S.%N%z"
else
  _log__DATE_CMD="date"
  _log__DATE_FORMAT="%Y-%m-%dT%H:%M:%S%z"
fi
readonly _log__DATE_CMD
readonly _log__DATE_FORMAT

function log::disable_debug() {
  _log__IS_DEBUG=false
}

function log::enable_debug() {
  _log__IS_DEBUG=true
}

function log::disable_info() {
  _log__IS_INFO=false
}

function log::enable_info() {
  _log__IS_INFO=true
}

function log::disable_err() {
  _log__IS_ERR=false
}

function log::enable_err() {
  _log__IS_ERR=true
}

function log::disable_fatal() {
  _log__IS_FATAL=false
}

function log::enable_fatal() {
  _log__IS_FATAL=true
}

function log::disable_warn() {
  _log__IS_WARN=false
}

function log::enable_warn() {
  _log__IS_WARN=true
}

function log::info() {
  ${_log__IS_INFO} || return
  if [[ -t 1 ]]; then
    echo "[  ${CYAN}INFO${RESET} ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&1
  else
    echo "[  INFO ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&1
  fi
}

function log::debug() {
  ${_log__IS_DEBUG} || return
  if [[ -t 1 ]]; then
    echo "[ ${GREEN}DEBUG${RESET} ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&1
  else
    echo "[ DEBUG ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&1
  fi
}

function log::err() {
  ${_log__IS_ERR} || return
  if [[ -t 2 ]]; then
    echo "[ ${RED}ERROR${RESET} ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&2
  else
    echo "[ ERROR ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&2
  fi
}

function log::fatal() {
  ${_log__IS_FATAL} || return
  if [[ -t 2 ]]; then
    echo "[ ${MAGENTA}FATAL${RESET} ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&2
  else
    echo "[ FATAL ] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&2
  fi
}

function log::warn() {
  ${_log__IS_WARN} || return
  if [[ -t 2 ]]; then
    echo "[${YELLOW}WARNING${RESET}] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&2
  else
    echo "[WARNING] - Date: $(${_log__DATE_CMD} +"${_log__DATE_FORMAT}") - Message: $*" >&2
  fi
}
