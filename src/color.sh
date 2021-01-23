#!/bin/bash
#
# 8 common color constants.
# by Takeaki Oura(@iHalt10)
if type tput > /dev/null 2>&1; then
  readonly BLACK="$(tput setaf 0)"
  readonly RED="$(tput setaf 1)"
  readonly GREEN="$(tput setaf 2)"
  readonly YELLOW="$(tput setaf 3)"
  readonly BLUE="$(tput setaf 4)"
  readonly MAGENTA="$(tput setaf 5)"
  readonly CYAN="$(tput setaf 6)"
  readonly WHITE="$(tput setaf 7)"
  readonly RESET="$(tput sgr0)"
else
  readonly ESC=$(printf '\033')
  readonly BLACK="${ESC}[30m"
  readonly RED="${ESC}[31m"
  readonly GREEN="${ESC}[32m"
  readonly YELLOW="${ESC}[33m"
  readonly BLUE="${ESC}[34m"
  readonly MAGENTA="${ESC}[35m"
  readonly CYAN="${ESC}[36m"
  readonly WHITE="${ESC}[37m"
  readonly RESET="${ESC}[0m"
fi
