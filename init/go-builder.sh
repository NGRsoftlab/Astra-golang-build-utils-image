#!/usr/bin/env bash

## Check bash interpreter is installed
if [ -z "${BASH_VERSION:-}" ]; then
  echo "[timestamp: $(date +%F' '%T)] [level: ERROR] [file: $(basename "${0}")] bash is required to interpret this script"
  exit 33
fi

set -Eeo pipefail

[[ ${DEBUG} != 'ON' ]] || set -x

#############################################
# Style format
# ARGUMENTS:
#   $1, it is receive style format (int)
# OUTPUTS:
#   Return to ANSI style with format \033[FORMAT;COLORm
#############################################
tty_escape() { printf "\033[%sm" "${1}"; }

#############################################
# Bold style colors
# ARGUMENTS:
#   $1, it is receive color (int)
# OUTPUTS:
#   Return to ANSI color with format \033[BOLD;COLORm
#############################################
tty_mkbold() { tty_escape "1;${1}"; }

#############################################
# Date format
# OUTPUTS:
#   Return to dynamic actual date format YYYY-MM-DD HH:MM:SS
#############################################
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this file
logger_time() { date +%F' '%T; }

## Definite color variables
logger_tty_reset="$(tty_escape 0)"
logger_tty_red="$(tty_mkbold 31)"
logger_tty_green="$(tty_mkbold 32)"
logger_tty_yellow="$(tty_mkbold 33)"
logger_tty_blue="$(tty_mkbold 34)"
logger_tty_purple="$(tty_mkbold 35)"
logger_tty_cyan="$(tty_mkbold 36)"

#############################################
## Log the given message at the given level
#############################################
# Log template for all received.
# All logs are written to stdout with a timestamp
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, the level with specific color style
#   $*, the message text
# RETURNS:
#   0 if 'levelname' is defined, 1 if not defined
# OUTPUTS:
#   Write to stderr if error
#############################################
logger_template() {
  local timestamp color tabs
  timestamp=$(logger_time)
  local levelname="${1}"

  ## Translation to the left side of the received log name argument
  shift 1

  ## Define log level
  case "${levelname^^}" in
    "INFO")
      color="${logger_tty_green}"
      tabs=0
      ;;
    "WARNING")
      color="${logger_tty_yellow}"
      tabs=0
      ;;
    "ERROR")
      color="${logger_tty_red}"
      tabs=0
      ;;
    *)
      printf "[timestamp: %s] [level: %s] [file: %s] %s\n" \
        "$(date +%F' '%T)" 'ERROR' "$(basename "${0}")" \
        "undefined log name" >&2
      exit 1
      ;;
  esac

  ## STDOUT
  printf "%s %s %${tabs}s %s\n" \
    "[timestamp ${logger_tty_blue}${timestamp}${logger_tty_reset}]" \
    "[levelname ${color}${levelname}${logger_tty_reset}]" \
    "$*"

  ## For those who remain, we pass on 0 code
  return 0
}

#############################################
# Log the given message at level, INFO
# GLOBALS:
#   none
# ARGUMENTS:
#   $*, the info text to be printed
# OUTPUTS:
#   Write message to stdout
#############################################
logger_info_message() {
  local message="$*"
  logger_template "INFO" "${message}"
}

#############################################
# Log the given message at level, WARNING
# GLOBALS:
#   none
# ARGUMENTS:
#   $*, the warning text to be printed
# OUTPUTS:
#   Write message to stdout
#############################################
logger_warning_message() {
  local message="$*"
  logger_template "WARNING" "${message}"
}

#############################################
# Log the given message at level, ERROR
# GLOBALS:
#   none
# ARGUMENTS:
#   $*, the error text to be printed
# OUTPUTS:
#   Write message to stdout
#############################################
logger_error_message() {
  local message="$*"
  logger_template "ERROR" "${message}" >&2
}

#############################################
# Log the given message at level, ERROR
# GLOBALS:
#   none
# ARGUMENTS:
#   $*, the fail text to be printed
# OUTPUTS:
#   Write to stdout and exit with status 1
#############################################
logger_fail() {
  logger_error_message "$*"
  exit 1
}

#############################################
# Repeats a string a specified number of times
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string to repetitions (string)
#   $2, number of repetitions (integer)
# RETURNS:
#   0 if thing was printed, non-zero on error
# OUTPUTS:
#   Line with the number of specified repetitions
#############################################
__decor() {
  local pattern="${1}"
  local -i repeat="${2}"
  seq -s"${pattern}" "${repeat}" | tr -d '[:digit:]'
}

#############################################
# Logo sprite start message
# GLOBALS:
#   none
# ARGUMENTS:
#   none
# OUTPUTS:
#   Write to stdout
#############################################
__logo_start() {
  ## Doom font
  ## https://patorjk.com/software/taag/#p=display&f=Doom&t=Let's%20build%20some%20GO
  ## or install 'figlet'
  ## download font:
  ## sudo curl 'http://www.figlet.org/fonts/doom.flf' -o /usr/share/figlet/doom.flf
  ## figlet -f doom 'Let's build some GO'
  cat <<EOFLOGO
${logger_tty_cyan}
                                    ,_---~~~~~----._
                              _,,_,*^____      _____''*g*\"*,
                            / __/ /'     ^.  /      \ ^@q   f
                            [  @f | @))    |  | @))   l  0 _/
                            \'/   \~____ / __ \_____/    \
                              |           _l__l_           I
                              }          [______]           I
                              ]            | | |            |
                              ]             ~ ~             |
                              |                            |
                              |                           |
${logger_tty_reset}
$(__decor "─" "100")
${logger_tty_purple}
      _          _   _       _           _ _     _                              _____ _____
      | |        | | ( )     | |         (_) |   | |                            |  __ \  _  |
      | |     ___| |_|/ ___  | |__  _   _ _| | __| |  ___  ___  _ __ ___   ___  | |  \/ | | |
      | |    / _ \ __| / __| | '_ \| | | | | |/ _' | / __|/ _ \| '_ ' _ \ / _ \ | | __| | | |
      | |___|  __/ |_  \__ \ | |_) | |_| | | | (_| | \__ \ (_) | | | | | |  __/ | |_\ \ \_/ /
      \_____/\___|\__| |___/ |_.__/ \__,_|_|_|\__,_| |___/\___/|_| |_| |_|\___|  \____/\___/
${logger_tty_reset}
$(__decor "─" "100")
EOFLOGO
}

#############################################
# Logo sprite end massage
# GLOBALS:
#   none
# ARGUMENTS:
#   none
# OUTPUTS:
#   Write to stdout
#############################################
__logo_end() {
  ## Generate ascii image by: https://www.asciiart.eu/image-to-ascii
  cat <<EOFLOGO
${logger_tty_cyan}
                                                ██████
                                              █▓░░░░▒██
                                              █▒▒░░▒░██
                                              ██▒▓█▒░▒█
                                        █████████▓▒▓░░██
                                █████▓▓▒░░░░░░░░░░▒▓████
                            ████▒░░░░░░░░░░░░░░░░░░░░░░░▒███
                        ██▓▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒███
            ███████   ███▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒░██
          ██▒░░░░░▓███▓▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒██
          █▒░░░▒▓▓░▓█▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒░██
          ██▓▒▒▒▒▒█▓▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒░▓█
            █████▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██▒░░░░▒▓██░░░░░░▓█
                █▓▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█▒░░░░░░░░░░░▒█▒░░░░██
              █▓▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░▒█▒░░░░░░░░░░░░░░░▓▓░░░░█
              ██▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░▒█▒▒░░░░░░░░░░░░░░░░▒█▓░░▒█
              ██▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░█▓▒░░░░░░░░░░░░░▒▒█░▒█▒░░░██
              █▓▓██▒▒░░░░░▓█▓░░░░░░░░░░░░░░▒█▒▒░░░░░░░░░░░▒█▒░▓█▒▒▒░░░▓█
              ██▒▒░░░░░░░░░░░▓█░░░░░░░░░░░░▒█▒▒▒▒░░░░░░░░░▒████  ▒▒░░░░█
            ██▓▒▒░░░░░░░░░░░░░░█▒░░░░░░░░░░▒███▓▓▓▓▓███▓▒░░███▒  █▒░░░░▓█
            █▒▒▒▒░░░░░░░░░░░░░░░▓▓░░░░▒▓▓▒░░▒█▒░░░░             ▓▓░░░░░▒█
          ██▒▒▒▒░░░░░░░░░▒▒▓░▒▓█▒░░░▓███▓▓█▓▒█▓░░            ░█▒░░░░░░░██
          █▓▒▒▒▒░░░░░░▒█▓▒░▒█▓░▒▓░░▓█░░░░░░█▒▒▒█▓░         ░█▓░░░░░░░░░▓█
          ██▒▒▒▒▒░░░░░░▒▓███▓   ▓▒░▒█▒▒██▒██▒░░░▒▒▒████████▓░░░░░░░░░░░░░█
          █████████▓▒░░▓███   ░█░░░▒▓▓█▓███░░░░░░░░░░░░░░░░░░░░░░░░░▒▓███▓▓▒▒▒▒▓███
            ██▒░░░░           ░█▒░░░░░░░▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░▒░░░░░░░░░░░░░▓█
              █▓▒░░         ░▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▓▒▒▒▒▓██
                ██▓▒░   ░░▒█▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▓▓█████    █
                ██▒▒▓▓▓▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓███        ██ ██
                ██▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒█         ██      █
                █▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██  ████▓██████   █   █
                █▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█  ███▓▓▓▒▒░▒██████████
              ██▓█▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓█   ████▓▓▓▓▓▓▓██▒▓▒█▒▓█
              ██▒▒█▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██     ██████▓██▓▒▒█▒▒▒█
            █▓▒▒▒█▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██      ██ █ ███▓▓█▒▒▒▓█
            █▒▒▒▒▒▓▓▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██         ██  ████▓▓██
          ██▓▒▒▒▒▒▓█▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██                 ██
          █▓▒▒▒▒▒███▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
          ██▒▒▓██ ██▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██
          ████    █▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒░▓█
                  █▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░█
                  ██▒▒▒█▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓░░██
                    █▓▒▓▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
                    ██▒▒▒▓▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██
                    ██▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██
                      ██▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒███
                        ██▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒█▒░░██
                      ██▒▒██▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒██▒▒░░░▒██
                      █▒▒▒▒▒▓██▒▒▒░░░░░░░░░░░░░░░░░░░░░░░▒▓█████▓▒▒░░░░▒█
                      █▓▒▒▒▒▒▒███████▓▓▒▒▒▒▒▒▒▒▒▒▒▓▓███████      ██▒▒░░░░██
                    ██▒▒▒▒▒▓█         █████████                  ██▓▒░░░▓█
                    ██▒▒▒▒██                                       ██▓▒██
                      ██████
${logger_tty_reset}
$(__decor "─" "100")
${logger_tty_purple}
      _   _                             _    _    _        _           _ _     _   _ _   _
      | | | |                           | |  | |  | |      | |         (_) |   | | (_) | | |
      | |_| | ___   ___  _ __ __ _ _   _| |  | |  | | ___  | |__  _   _ _| | __| |  _| |_| |
      |  _  |/ _ \ / _ \| '__/ _' | | | | |  | |/\| |/ _ \ | '_ \| | | | | |/ _' | | | __| |
      | | | | (_) | (_) | | | (_| | |_| |_|  \  /\  /  __/ | |_) | |_| | | | (_| | | | |_|_|
      \_| |_/\___/ \___/|_|  \__,_|\__, (_)   \/  \/ \___| |_.__/ \__,_|_|_|\__,_| |_|\__(_)
                                    __/ |
                                  |___/
${logger_tty_reset}
$(__decor "─" "100")
EOFLOGO
}

#############################################
# Extract version from string
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string with version pattern: minor.major.patch
# RETURN:
#   0 if thing was printed, non-zero on error
# OUTPUTS:
#   Parsed version
#############################################
__extract_version() {
  local version
  local string_ver="${1}"

  ## Take version
  version=$(
    printf "%s" "${string_ver}" \
      | grep -E -o 'go[0-9]+(\.[0-9]+){1,2}(rc[0-9]+)?$' \
      | grep -E -o 'go[0-9]+(\.[0-9]+){1,2}' \
      | sed 's/go//'
  )

  ## Check version
  [[ -n ${version} ]] || {
    logger_fail "can not extract version, variable is empty"
  }

  ## Pass value
  printf "%s" "${version}"
}

#############################################
# Extract release candidate from string
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string with version pattern: minor.major.patchrc1
# RETURN:
#   0 if thing was printed, non-zero on error
# OUTPUTS:
#   Parsed release
#############################################
__extract_rc() {
  local release_candidate
  local string_ver="${1}"

  ## Take RC if exists
  release_candidate=$(
    printf "%s" "${string_ver}" \
      | grep -E -o 'go[0-9]+(\.[0-9]+){1,2}rc[0-9]+' \
      | sed -E 's#go[0-9]+(\.[0-9]+){1,2}##; s#^\.##'
  )

  ## Check RC
  [[ -n ${release_candidate} ]] || return 0

  ## Pass value
  printf "%s" "${release_candidate}"
}

#############################################
# Check version for correct pattern
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string with version pattern: minor.major.patch
# RETURN:
#   0 if variable correct or 1 if not correct
#############################################
__check_version() {
  local version="${1}"

  ## Check version format: major.minor OR major.minor.patch
  if [[ ${version} =~ ^[0-9]+(\.[0-9]+){1,2}$ ]]; then
    return 0
  fi

  return 1
}

#############################################
# Determine golang compiler
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string with go version pattern: minor.major.patch
# RETURN:
#   0 if thing was printed, non-zero on error
# OUTPUTS:
#   Golang compiler version
#############################################
__determine_compiler() {
  local major_str minor_str patch_str
  local version="${1}"

  ## Parse version
  IFS='.' read -r major_str minor_str patch_str <<<"${version}"
  [[ -n ${patch_str} ]] || patch_str=0

  ## Transform string to integer
  local major minor patch
  major=$((10#$major_str))
  minor=$((10#$minor_str))
  patch=$((10#$patch_str))

  if [[ ${major} -eq 1 ]]; then
    if [[ ${minor} -le 4 ]]; then
      printf "%s" "C toolchain"
    elif [[ ${minor} -ge 5 ]] && [[ ${minor} -le 19 ]]; then
      printf "%s" "1.4"
    elif [[ ${minor} -ge 20 ]] && [[ ${minor} -le 21 ]]; then
      printf "%s" "1.17"
    elif [[ ${minor} -ge 22 ]] && [[ ${minor} -le 23 ]]; then
      printf "%s" "1.20"
    else
      ## Check compile version with prompt:
      ## Go version 1.N will require a Go 1.M compiler
      ## where M is N-2 rounded down to an even number
      ## Example: Go 1.24 and 1.25 require Go 1.22
      local required_minor
      required_minor=$((minor - 2))
      if [[ $((required_minor % 2)) -ne 0 ]]; then
        required_minor=$((required_minor - 1))
      fi
      printf "%s" "1.${required_minor}"
    fi
  else
    logger_fail "unsupported Go version ${major}.${minor}.${patch}"
  fi
}

#############################################
# Patch project source
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string with go version pattern: minor.major.patch
# RETURN:
#   0 if thing was printed, non-zero on error
# OUTPUTS:
#   Write to stdout
#############################################
__patching_sources() {
  local major_str minor_str patch_str
  local version="${1}"

  ## Parse version
  IFS='.' read -r major_str minor_str patch_str <<<"${version}"
  [[ -n ${patch_str} ]] || patch_str=0

  ## Transform string to integer
  local minor
  minor=$((10#$minor_str))

  ## Patching project depending on the product version ${minor}>4
  if [[ ${minor} -gt 4 ]]; then
    ## Apply a patch to bypass the error that is indicated here:
    ## https://github.com/golang/go/issues/71077
    logger_info_message \
      "patching sources to prevent a critical error with handshake client"
    patch -p1 </opt/patches/0001-Skip-failing-TLS-test-client.patch
  fi

  ## Patching project depending on the product version ${minor}>20
  if [[ ${minor} -gt 20 ]]; then
    ## Apply a patch to bypass the error that is indicated here:
    ## https://patches.guix-patches.cbaines.net/project/guix-patches/patch/eb839a04fa9261a480af34520c6e89578877f293.1737417773.git.ryan@arctype.co/
    ## https://issues.guix.gnu.org/75716
    logger_info_message \
      "patching sources to prevent a critical error with handshake server"
    patch -p1 </opt/patches/0002-Skip-failing-TLS-test-server.patch
  fi
}

#############################################
# Convert machine arch to standardized architecture
# GLOBALS:
#   none
# ARGUMENTS:
#   none
# RETURN:
#   0 if thing was printed, non-zero on error
# OUTPUTS:
#   System architecture
#############################################
__arch_define() {
  local machine_architecture architecture
  machine_architecture="$(uname -m)"

  case "${machine_architecture}" in
    armv5*) architecture="armv5" ;;
    armv6*) architecture="armv6" ;;
    armv7*) architecture="arm" ;;
    aarch64) architecture="arm64" ;;
    x86) architecture="386" ;;
    x86_64) architecture="amd64" ;;
    i686) architecture="386" ;;
    i386) architecture="386" ;;
  esac

  printf "%s" "${architecture}"
}

#############################################
# Designate variables for assembly
# GLOBALS:
#   GOROOT
#   GOOS
#   GOARCH
#   CGO_ENABLED
#   GOROOT_BOOTSTRAP
#   PUBLISH_REGISTRY_UPLOAD_URL
#   PUBLISH_REGISTRY_UPLOAD_REPOSITORY_NAME
#   PUBLISH_REGISTRY_UPLOAD_DESTINATION_DIRECTORY_NAME
# ARGUMENTS:
#   $1, string with go compile version
# OUTPUTS:
#   Write to stdout
#############################################
__source_compile_variable() {
  local compiler_version="${1}"

  ## Undefine go-root path
  unset GOROOT

  ## Set build os and arch type
  [[ -n ${GOOS} ]] || GOOS=$(uname | tr '[:upper:]' '[:lower:]')
  [[ -n ${GOARCH} ]] || GOARCH=$(__arch_define)
  export GOOS GOARCH

  ## Set the compiler setting
  if [[ ${compiler_version} == 'C toolchain' ]]; then
    export CGO_ENABLED=0
  else
    export GOROOT_BOOTSTRAP="/opt/go${compiler_version}"
    [[ -d ${GOROOT_BOOTSTRAP} ]] || {
      logger_warning_message "not found bootstrap into '${GOROOT_BOOTSTRAP}'"
      logger_warning_message \
        "trying download bootstrap tools from artifact registry" \
        "'${PUBLISH_REGISTRY_UPLOAD_URL}'"

      ## Create bootstrap field
      mkdir -p "${GOROOT_BOOTSTRAP}"

      ## Define download variable
      local download_uri="${PUBLISH_REGISTRY_UPLOAD_URL}/repository/${PUBLISH_REGISTRY_UPLOAD_REPOSITORY_NAME}/${PUBLISH_REGISTRY_UPLOAD_DESTINATION_DIRECTORY_NAME}"
      local golang_bootstrap_link="${download_uri}/go${compiler_version}-${GOOS}-${GOARCH}-bootstrap.tgz"

      ## Download bootstrap from registry
      curl \
        --silent \
        "${golang_bootstrap_link}" \
        | tar --strip-component=1 -C "${GOROOT_BOOTSTRAP}" -zx \
        || {
          logger_error_message "cannot download" \
            "'go${compiler_version}-${GOOS}-${GOARCH}-bootstrap.tgz'" \
            "from '${download_uri}'"
          logger_fail \
            "may be this bootstrap version is not uploaded into" \
            "'${download_uri}'?"
        }
    }
  fi

  logger_info_message \
    "build golang for '${GOOS}' system, with '${GOARCH}' architecture"
}

#############################################
# Cleanup project build
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, string with project path
# OUTPUTS:
#   Write to stdout
#############################################
__clean_up_build() {
  local current_path="${1}"

  logger_info_message "cleaning residual files"
  rm -rf "${current_path}/pkg/linux_amd64_race" \
    "${current_path}/blog" \
    "${current_path}/.git"*
  find "${current_path}" -type d -name testdata -print0 | xargs -0 rm -rf
}

#############################################
# Package and print end message
# GLOBALS:
#   none
# ARGUMENTS:
#   $1, name of archive package
#   $2, string to regex top level directory
#   $3, package directory name
#   $4, project path
# OUTPUTS:
#   Write to stdout
#############################################
__end_step() {
  local package_name="${1}"
  local convert_name="${2}"
  local current_directory="${3}"
  local current_path="${4}"

  logger_info_message "package golang build"
  pushd .. >/dev/null
  tar -czvf \
    "${package_name}" --transform "s;^${current_directory};${convert_name};" \
    "${current_directory}" \
    --show-transformed-names
  mv "${package_name}" "${current_path}/"
  popd >/dev/null

  ## End logo
  __logo_end

  ## End message
  __decor "*" "200"
  logger_info_message "'${package_name}' is prepared to upload"
  __decor "*" "200"

  exit 0
}

#############################################
# Init, build and package bootstrap
# GLOBALS:
#   GOOS
#   GOARCH
# ARGUMENTS:
#   $1, string with go current version
#   $2, project path
# OUTPUTS:
#   Write to stdout
#############################################
__init_bootstrap() {
  local version="${1}"
  local current_path="${2}"
  local current_directory="${current_path##*/}"

  logger_info_message "prepare bootstrap to build"

  ## Set write permission for files
  chmod -R +w "${current_path}/"

  ## Remove .gitignore file for comprehensive cleaning of unnecessary data
  rm -f "${current_path}/.gitignore"

  ## Check on exists .git directory
  ## for comprehensive cleaning of unnecessary data
  if [[ -e ${current_path}/.git ]]; then
    git clean -f -d || {
      logger_fail "cannot use 'git clean'"
    }
  fi

  ## Switch to build directory
  pushd "${current_path}/src" >/dev/null || {
    logger_fail "cannot switch to '${current_path}/src', is this path exists?"
  }

  logger_info_message "build bootstrap"

  ## Build project
  ./make.bash --no-banner || {
    logger_fail \
      "an unknown error occurred during the collector and compilation" \
      "of objects, which caused the program to terminate abnormally"
  }

  ## Switch back to project root directory
  popd >/dev/null

  logger_info_message "cleanup bootstrap"

  ## Remove residual and unnecessary data
  __clean_up_build "${current_path}"
  rm -rf "${current_path}/api" \
    "${current_path}/doc" \
    "${current_path}/misc" \
    "${current_path}/test" \
    "${current_path}/pkg/bootstrap" \
    "${current_path}/pkg/obj"

  ## Parse version
  local major_str minor_str patch_str
  IFS='.' read -r major_str minor_str patch_str <<<"${version}"

  ## Transform string to integer
  local major minor
  major=$((10#$major_str))
  minor=$((10#$minor_str))

  ## Package and final build message
  __end_step \
    "go${major}.${minor}-${GOOS}-${GOARCH}-bootstrap.tgz" \
    "go${version}" \
    "${current_directory}" \
    "${current_path}"
}

#############################################
# Entrypoint
# GLOBALS:
#   GOOS
#   GOARCH
#   GOLANG_BUILD_ENTITY
# ARGUMENTS:
#   $1, string with go current version
#   $2, project path
# OUTPUTS:
#   Write to stdout
#############################################
main() {
  local current_path="${PWD}"
  local current_directory="${current_path##*/}"

  ## Definite branch/tag for build
  [[ -n ${GOLANG_BUILD_ENTITY} ]] \
    || GOLANG_BUILD_ENTITY="${CI_COMMIT_REF_NAME}"
  [[ -n ${GOLANG_BUILD_ENTITY} ]] || {
    logger_error_message "branch/tag is not set"
    logger_fail \
      "try to set 'GOLANG_BUILD_ENTITY' variable and launch '${0}' again"
  }

  ## Logo start
  __logo_start

  ## Try to grab version from variable
  local current_version
  current_version=$(__extract_version "${GOLANG_BUILD_ENTITY}")

  ## Check variable for version
  __check_version "${current_version}" || {
    logger_error_message \
      "expected to receive the following pattern:" \
      "'major.minor.patch' or 'major.minor'"
    logger_fail "'${current_version}' is not a semantic version"
  }

  ## Analyze the version and take the corresponding version of the compiler
  local go_compiler_version
  go_compiler_version=$(__determine_compiler "${current_version}")
  logger_info_message \
    "founding determine golang compiler for this build:" \
    "'${go_compiler_version}'"

  ## Export build source variable
  __source_compile_variable "${go_compiler_version}"

  ## Check if this build bootstrap or not
  [[ ${GOLANG_IS_BOOTSTRAP,,} != 'true' ]] || {
    logger_info_message \
      "this build is a bootstrap, the environment will be prepared" \
      "for building other versions of the product"
    __init_bootstrap "${current_version}" "${current_path}"
  }

  ## Patch sources
  __patching_sources "${current_version}"

  ## Switch to build directory
  pushd "${current_path}/src" >/dev/null

  logger_info_message "build golang v${current_version}"

  ## Build project
  ./all.bash || {
    logger_fail \
      "an unknown error occurred during the collector and compilation" \
      "of objects, which caused the program to terminate abnormally"
  }

  ## Switch back to project root directory
  popd >/dev/null

  ## Check golang version
  logger_info_message \
    "$("${current_path}"/bin/go version) is built successfully"

  ## Test built application
  cat >"${current_path}/hello.go" <<EOF
package main

import "fmt"

func main() {
	fmt.Printf("hello, world\n")
}
EOF
  "${current_path}/bin/go" run hello.go || {
    logger_fail "go application test failed"
  }

  ## Remove test data
  rm -f "${current_path}/hello.go"

  ## Remove residual and unnecessary data
  __clean_up_build "${current_path}"

  ## Try to grab release candidate
  local current_rc
  current_rc=$(__extract_rc "${GOLANG_BUILD_ENTITY}")
  [[ -z ${current_rc} ]] || {
    logger_info_message \
      "founding release candidate for this build: '${current_rc}'"
    current_version="${current_version}${current_rc}"
  }

  ## Package and final build message
  __end_step \
    "go${current_version}-${GOOS}-${GOARCH}.tgz" \
    "go" \
    "${current_directory}" \
    "${current_path}"
}

## Call entrypoint
main
