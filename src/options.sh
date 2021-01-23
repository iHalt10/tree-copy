#!/bin/bash
#
# options
# by Takeaki Oura(@iHalt10)
import env.sh
import log.sh

readonly options__USAGE_TEXT=$(cat << EOS
Usage: ${PROGNAME} [--version] [--help] [-n <NamingType>] ...
EOS
)

readonly options__HELP_TEXT=$(cat << EOS
${options__USAGE_TEXT}

Description:
  Collect files nested by folders into one folder.

Options:
  -n, --nameing-type <NamingType>   : Determining the name of the file to be copied. (default: kn)
                                      If there is an extension, it remains in the determined file name.
                                      <NamingTypes>
                                      - 'numbering' (short: 'n')
                                        ./src/a.txt   => ./dist/0.txt
                                        ./src/b/a.txt => ./dist/1.txt
                                        ./src/b/c.txt => ./dist/2.txt
                                        ./src/d       => ./dist/3
                                      - 'keep-and-numbering' (short: 'kn')
                                        ./src/a.txt   => ./dist/a.txt
                                        ./src/b/a.txt => ./dist/a (1).txt
                                        ./src/b/c.txt => ./dist/c.txt
                                        ./src/d       => ./dist/d
                                      - 'uuid' (short: 'u')
                                        ./src/a.txt   => ./dist/D3E92237-B5D7-4647-99B1-637E45FC74A7.txt
                                        ./src/b/a.txt => ./dist/338DB1F8-E4DC-4030-BA39-64034243A458.txt
                                        ./src/b/c.txt => ./dist/79E1E60A-3D10-47FE-8767-281DEA52991F.txt
                                        ./src/d       => ./dist/d
                                      - 'uid-upper' (short: 'up')
                                        ./src/a.txt   => ./dist/15B2C356FD364E9ABFBACFA0CA5B9FC7.txt
                                        ./src/b/a.txt => ./dist/5D2420A1C54745E386203672A233EBA2.txt
                                        ./src/b/c.txt => ./dist/D92032E3888F4B5CA179D3786750752F.txt
                                        ./src/d       => ./dist/9CA57511ACD74BB99ED23504298CDC06
                                      - 'uid-lower' (short: 'lo')
                                        ./src/a.txt   => ./dist/9fe37ec5e7754689aef63c7813b70029.txt
                                        ./src/b/a.txt => ./dist/cbb52770b2064578a0f9995ac3959586.txt
                                        ./src/b/c.txt => ./dist/1542fe5aedbc41329167875a390550f4.txt
                                        ./src/d       => ./dist/63f39c358e184d71885f2de4c1548ee9
  -m, --maxdepth <Numeric>          : Depth of source directory to be copied. (default: 3)
  -s, --src-dir <Path>              : Specify the directory you want to collect.　(default './')
  -d, --dist-dir <Path>             : Specify the copy destination directory. (default './')
  --sort <SortType>                 : Copy in sort order. SortTypes are 'asc' or 'desc' or 'disable'. (default: 'asc')
                                      It strongly affects the 'numbering' of Naming Type.
  -f, --filter <FilterType> <List>  : File paths that contain certain characters are filtered.
                                      example: -f include "jpg,png"
                                      <FilterType>
                                      - include
                                        File paths that contain certain characters are included.
                                      - exclude
                                        File paths that contain certain characters are excluded.
                                      <List>
                                      Specify them separated by commas.
  --create                          : Create a copy destination directory. (default: false)
  --delete                          : After copying the file, delete it. (default: false)
  --dry-run                         : Not run copy and delete. (default: false)
  --debug                           : print debug. (default: false)
  --version                         : print version.
  -h, --help                        : print help.
EOS
)

options__NAMEING_TYPES=(
  "numbering" "n"
  "keep-and-numbering" "kn"
  "uuid" "u"
  "uid-upper" "up"
  "uid-lower" "lo"
)
options__SORT_TYPES=("asc" "desc" "disable")
options__FILTER_TYPES=("include" "exclude")
readonly options__NAMEING_TYPES
readonly options__SORT_TYPES
readonly options__FILTER_TYPES

options__NAMEING_TYPE="kn"
options__MAXDEPTH=3
options__SRC_DIR="."
options__DIST_DIR="."
options__SORT_TYPE="asc"
options__IS_FILTER_INCLUDE=false
options__IS_FILTER_EXCLUDE=false
options__FILTER_INCLUDE_LIST_STR=""
options__FILTER_EXCLUDE_LIST_STR=""
options__IS_CREATE_DIST_DIR=false
options__IS_DELETE_SRC_FILE=false
options__IS_DRY_RUN=false


function options::print_usage() {
  log::warn "${options__USAGE_TEXT}"
}

function options::print_help() {
  echo "${options__HELP_TEXT}" >&0
}

function options::print_version() {
  echo "${VERSION}" >&0
}

function options::parser() {
  local except_specified_opts=()
  while (($#)) ; do
    local opt="$1"
    case "${opt}" in
      '-n' | '--nameing-type' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          log::err "'${opt}' option requires an argument."
          options::print_usage
          exit 1
        fi

        options__NAMEING_TYPE="$2"
        if [[ ! $(printf '%s\n' "${options__NAMEING_TYPES[@]}" | grep -qx "${options__NAMEING_TYPE}"; echo -n $? ) -eq 0 ]]; then
          log::err "'${opt}' option arguments requires of the specified 'NamingType'."
          options::print_usage
          exit 1
        fi
        shift 2
        ;;
      '-m' | '--maxdepth' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          log::err "'${opt}' option requires an argument."
          options::print_usage
          exit 1
        fi

        if ! [[ $2 =~ ^[0-9]+$ ]] ; then
          log::err "'${opt}' option requires a numeric argument."
          options::print_usage
          exit 1
        fi
        options__MAXDEPTH=$(( 10#$2 ))
        shift 2
        ;;
      '-s' | '--src-dir' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          log::err "'${opt}' option requires an argument."
          options::print_usage
          exit 1
        fi

        options__SRC_DIR="${2%/}"
        if [ ! -d "${options__SRC_DIR}" ]; then
          log::err "'${options__SRC_DIR}' directory doesn't exist. -- (opt: $opt)"
          options::print_usage
          exit 1
        fi
        shift 2
        ;;
      '-d' | '--dist-dir' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          log::err "'${opt}' option requires an argument."
          options::print_usage
          exit 1
        fi

        options__DIST_DIR="${2%/}"
        shift 2
        ;;
      '--sort' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          log::err "'${opt}' option requires an argument."
          options::print_usage
          exit 1
        fi

        options__SORT_TYPE="$2"
        if [[ ! $(printf '%s\n' "${options__SORT_TYPES[@]}" | grep -qx "${options__SORT_TYPE}"; echo -n $? ) -eq 0 ]]; then
          log::err "'${opt}' option arguments requires of the specified 'SortType'."
          options::print_usage
          exit 1
        fi
        shift 2
        ;;
      '-f' | '--filter' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]] || [[ -z "$3" ]] || [[ "$3" =~ ^-+ ]]; then
          log::err "${opt}' option requires an argument."
          options::print_usage
          exit 1
        fi

        local filter_type="$2"
        if [[ ! $(printf '%s\n' "${options__FILTER_TYPES[@]}" | grep -qx "${filter_type}"; echo -n $? ) -eq 0 ]]; then
          log::err "${opt}' option arguments requires of the specified 'FilterType'."
          options::print_usage
          exit 1
        fi

        if [[ "${filter_type}" == "include" ]]; then
          options__IS_FILTER_INCLUDE=true
          options__FILTER_INCLUDE_LIST_STR="$3"
        elif [[ "${filter_type}" == "exclude" ]]; then
          options__IS_FILTER_EXCLUDE=true
          options__FILTER_EXCLUDE_LIST_STR="$3"
        else
          true
        fi
        shift 3
        ;;
      '--create' )
        options__IS_CREATE_DIST_DIR=true
        shift 1
        ;;
      '--delete' )
        options__IS_DELETE_SRC_FILE=true
        shift 1
        ;;
      '--dry-run' )
        options__IS_DRY_RUN=true
        shift 1
        ;;
      '--debug' )
        log::enable_debug
        shift 1
        ;;
      '--version' )
        options::print_version
        exit 0
        ;;
      '-h' | '--help' )
        options::print_help
        exit 0
        ;;
      '--' | '-' )
        shift 1
        except_specified_opts+=( "$@" )
        break
        ;;
      -* )
        log::err "illegal specified '$opt' option"
        options::print_usage
        exit 1
        ;;
      * )
        except_specified_opts+=( "$opt" )
        shift 1
        ;;
    esac
  done

  if [ ${#except_specified_opts[@]} -ne 0 ];then
    log::err "illegal -- '${except_specified_opts[*]}'"
    options::print_usage
    exit 1
  fi

  readonly options__NAMEING_TYPE
  readonly options__MAXDEPTH
  readonly options__SRC_DIR
  readonly options__DIST_DIR
  readonly options__SORT_TYPE
  readonly options__IS_FILTER_INCLUDE
  readonly options__IS_FILTER_EXCLUDE
  readonly options__FILTER_INCLUDE_LIST_STR
  readonly options__FILTER_EXCLUDE_LIST_STR
  readonly options__IS_CREATE_DIST_DIR
  readonly options__IS_DELETE_SRC_FILE
  readonly options__IS_DRY_RUN

  log::debug "options[NAMEING_TYPE]            = ${options__NAMEING_TYPE}"
  log::debug "options[MAXDEPTH]                = ${options__MAXDEPTH}"
  log::debug "options[SRC_DIR]                 = ${options__SRC_DIR}"
  log::debug "options[DIST_DIR]                = ${options__DIST_DIR}"
  log::debug "options[SORT_TYPE]               = ${options__SORT_TYPE}"
  log::debug "options[IS_FILTER_INCLUDE]       = ${options__IS_FILTER_INCLUDE}"
  log::debug "options[IS_FILTER_EXCLUDE]       = ${options__IS_FILTER_EXCLUDE}"
  log::debug "options[FILTER_INCLUDE_LIST_STR] = ${options__FILTER_INCLUDE_LIST_STR}"
  log::debug "options[FILTER_EXCLUDE_LIST_STR] = ${options__FILTER_EXCLUDE_LIST_STR}"
  log::debug "options[IS_CREATE_DIST_DIR]      = ${options__IS_CREATE_DIST_DIR}"
  log::debug "options[IS_DELETE_SRC_FILE]      = ${options__IS_DELETE_SRC_FILE}"
  log::debug "options[IS_DRY_RUN]              = ${options__IS_DRY_RUN}"
}
