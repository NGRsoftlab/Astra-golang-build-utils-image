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
## Log the given message at the given level.
#############################################
# Log template for all received.
# All logs are written to stdout with a timestamp.
# ARGUMENTS:
#   $1, the level with specific color style
# OUTPUTS:
#   Write to stdout
#############################################
logger_template() {
  local TIMESTAMP LEVELNAME COLOR TABS
  TIMESTAMP=$(logger_time)
  LEVELNAME="${1}"

  ## Prepare actions
  case "${LEVELNAME}" in
    "INFO")
      COLOR="${logger_tty_green}"
      TABS=0
      ;;
    "WARNING")
      COLOR="${logger_tty_yellow}"
      TABS=0
      ;;
    "ERROR")
      COLOR="${logger_tty_red}"
      TABS=0
      ;;
    *)
      echo "[timestamp: $(date +%F' '%T)] [level: ERROR] undefinded log name"
      exit 1
      ;;
  esac

  ## Translation to the left side of the received log name argument
  shift 1

  ## STDOUT
  printf "[timestamp ${logger_tty_blue}${TIMESTAMP}${logger_tty_reset}] [levelname ${COLOR}${LEVELNAME}${logger_tty_reset}] %${TABS}s %s\n" "$*"
}

#############################################
# Log the given message at level, INFO
# ARGUMENTS:
#   $*, the info text to be printed
# OUTPUTS:
#   Write to stdout
#############################################
logger_info_message() {
  local MESSAGE="$*"
  logger_template "INFO" "${MESSAGE}"
}

#############################################
# Log the given message at level, WARNING
# ARGUMENTS:
#   $*, the warning text to be printed
# OUTPUTS:
#   Write to stdout
#############################################
logger_warning_message() {
  local MESSAGE="$*"
  logger_template "WARNING" "${MESSAGE}"
}

#############################################
# Log the given message at level, ERROR
# ARGUMENTS:
#   $*, the error text to be printed
# OUTPUTS:
#   Write to stdout
#############################################
logger_error_message() {
  local MESSAGE="$*"
  logger_template "ERROR" "${MESSAGE}"
}

#############################################
# Log the given message at level, ERROR
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
# Repeats a separator a specified number of times
# ARGUMENTS:
#   $1, it is separator (string)
#   $2, it is how much repeat ${PATTERN} (integer)
# OUTPUTS:
#   Write to stdout
#############################################
__decor() {
  local PATTERN REPEAT
  PATTERN="${1}"
  REPEAT="${2}"
  seq -s"${PATTERN}" "${REPEAT}" | tr -d '[:digit:]'
}

#############################################
# Logo sprite start message
# OUTPUTS:
#   Write to stdout
#############################################
__logo_start() {
  ## Doom font
  #+ https://patorjk.com/software/taag/#p=display&f=Doom&t=Let's%20build%20some%20GO
  #+ or install 'figlet'
  #+ download font: sudo curl 'http://www.figlet.org/fonts/doom.flf' -o /usr/share/figlet/doom.flf
  #+ figlet -f doom 'Let's build some GO'
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
# ARGUMENTS:
#   $1, string with version pattern: minor.major.patch
# RETURN:
#   parsed version or error with exit code 1
#############################################
__extract_version() {
  local STRING_VER VERSION
  STRING_VER="${1}"

  ## Take version
  VERSION=$(printf "%s" "${STRING_VER}" | grep -E -o 'go[0-9]+(\.[0-9]+){1,2}(rc[0-9]+)?$' | grep -E -o 'go[0-9]+(\.[0-9]+){1,2}' | sed 's/go//')

  ## Check version
  [[ -n ${VERSION} ]] || {
    logger_fail "can not extract version, VERSION variable is empty"
  }

  ## Pass value
  printf "%s" "${VERSION}"
}

#############################################
# Extract release candidate from string
# ARGUMENTS:
#   $1, string with version pattern: minor.major.patchrc1
# RETURN:
#   parsed release candidate or return 0
#############################################
__extract_rc() {
  local STRING_VER RC
  STRING_VER="${1}"

  ## Take RC if exists
  RC=$(printf "%s" "${STRING_VER}" | grep -E -o 'go[0-9]+(\.[0-9]+){1,2}rc[0-9]+' | sed -E 's#go[0-9]+(\.[0-9]+){1,2}##; s#^\.##')

  ## Check RC
  [[ -n ${RC} ]] || return 0

  ## Pass value
  printf "%s" "${RC}"
}

#############################################
# Check version for correct pattern
# ARGUMENTS:
#   $1, string with version pattern: minor.major.patch
# RETURN:
#   0 if variable correct or 1 if not correct
#############################################
__check_version() {
  local VERSION="${1}"

  ## Check version format: major.minor OR major.minor.patch
  if [[ ${VERSION} =~ ^[0-9]+(\.[0-9]+){1,2}$ ]]; then
    return 0
  fi

  return 1
}

#############################################
# Determine golang compiler
# ARGUMENTS:
#   $1, string with go version pattern: minor.major.patch
# RETURN:
#   golang compiler version or error with exit code 1
#############################################
__determine_compiler() {
  local VERSION MAJOR_STR MINOR_STR PATCH_STR MAJOR MINOR PATCH REQUIRED_MINOR
  VERSION="${1}"

  ## Parse version
  IFS='.' read -r MAJOR_STR MINOR_STR PATCH_STR <<<"${VERSION}"

  [[ -n ${PATCH_STR} ]] || PATCH_STR=0

  ## Transform string to integer
  MAJOR=$((10#$MAJOR_STR))
  MINOR=$((10#$MINOR_STR))
  PATCH=$((10#$PATCH_STR))

  if [[ ${MAJOR} -eq 1 ]]; then
    if [[ ${MINOR} -le 4 ]]; then
      printf "%s" "C toolchain"
    elif [[ ${MINOR} -ge 5 ]] && [[ ${MINOR} -le 19 ]]; then
      printf "%s" "1.4"
    elif [[ ${MINOR} -ge 20 ]] && [[ ${MINOR} -le 21 ]]; then
      printf "%s" "1.17"
    elif [[ ${MINOR} -ge 22 ]] && [[ ${MINOR} -le 23 ]]; then
      printf "%s" "1.20"
    else
      ## Check compile version with prompt:
      ## Go version 1.N will require a Go 1.M compiler, where M is N-2 rounded down to an even number
      ## Example: Go 1.24 and 1.25 require Go 1.22.
      REQUIRED_MINOR=$((MINOR - 2))
      if [[ $((REQUIRED_MINOR % 2)) -ne 0 ]]; then
        REQUIRED_MINOR=$((REQUIRED_MINOR - 1))
      fi
      printf "%s" "1.${REQUIRED_MINOR}"
    fi
  else
    logger_fail "unsupported Go version ${MAJOR}.${MINOR}.${PATCH}"
  fi
}

#############################################
# Patch project source
# ARGUMENTS:
#   $1, string with go version pattern: minor.major.patch
# OUTPUTS:
#   Write to stdout
#############################################
__patching_sources() {
  local VERSION MAJOR_STR MINOR_STR PATCH_STR MAJOR MINOR PATCH REQUIRED_MINOR
  VERSION="${1}"

  ## Parse version
  IFS='.' read -r MAJOR_STR MINOR_STR PATCH_STR <<<"${VERSION}"
  [[ -n ${PATCH_STR} ]] || PATCH_STR=0

  ## Transform string to integer
  MAJOR=$((10#$MAJOR_STR))
  MINOR=$((10#$MINOR_STR))
  PATCH=$((10#$PATCH_STR))

  ## Patching project depending on the product version
  if [[ ${MINOR} -gt 4 ]]; then
    ## Apply a patch to bypass the error that is indicated here: https://github.com/golang/go/issues/71077
    logger_info_message "patching sources to prevent a critical error with handshake client"
    patch -p1 </opt/patches/0001-Skip-failing-TLS-test-client.patch
  fi
  if [[ ${MINOR} -gt 20 ]]; then
    ## Apply a patch to bypass the error that is indicated here: https://patches.guix-patches.cbaines.net/project/guix-patches/patch/eb839a04fa9261a480af34520c6e89578877f293.1737417773.git.ryan@arctype.co/
    ## https://issues.guix.gnu.org/75716
    logger_info_message "patching sources to prevent a critical error with handshake server"
    patch -p1 </opt/patches/0002-Skip-failing-TLS-test-server.patch
  fi
}

#############################################
# Views the system architecture
# RETURN:
#   system architecture
#############################################
__arch_define() {
  local ARCH ARCHITECTURE
  ARCH="$(uname -m)"

  case "${ARCH}" in
    armv5*) ARCHITECTURE="armv5" ;;
    armv6*) ARCHITECTURE="armv6" ;;
    armv7*) ARCHITECTURE="arm" ;;
    aarch64) ARCHITECTURE="arm64" ;;
    x86) ARCHITECTURE="386" ;;
    x86_64) ARCHITECTURE="amd64" ;;
    i686) ARCHITECTURE="386" ;;
    i386) ARCHITECTURE="386" ;;
  esac

  printf "%s" "${ARCHITECTURE}"
}

#############################################
# Designate variables for assembly
# ARGUMENTS:
#   $1, string with go compile version
# OUTPUTS:
#   Write to stdout
#############################################
__source_compile_variable() {
  local COMPILER_VERSION DOWNLOAD_URI
  COMPILER_VERSION="${1}"

  ## Undefine go-root path
  unset GOROOT

  ## Set build os and arch type
  [[ -n ${GOOS} ]] || GOOS=$(uname | tr '[:upper:]' '[:lower:]')
  [[ -n ${GOARCH} ]] || GOARCH=$(__arch_define)
  export GOOS GOARCH

  ## Set the compiler setting
  if [[ ${COMPILER_VERSION} == 'C toolchain' ]]; then
    export CGO_ENABLED=0
  else
    export GOROOT_BOOTSTRAP="/opt/go${COMPILER_VERSION}"
    [[ -d ${GOROOT_BOOTSTRAP} ]] || {
      logger_warning_message "not found bootstrap into '${GOROOT_BOOTSTRAP}'"
      logger_warning_message "trying download bootstrap tools from artifact registry '${PUBLISH_REGISTRY_UPLOAD_URL}'"
      ## Create bootstrap field
      mkdir -p "${GOROOT_BOOTSTRAP}"
      ## Download bootstrap from registry
      DOWNLOAD_URI="${PUBLISH_REGISTRY_UPLOAD_URL}/repository/${PUBLISH_REGISTRY_UPLOAD_REPOSITORY_NAME}/${PUBLISH_REGISTRY_UPLOAD_DESTINATION_DIRECTORY_NAME}"
      curl --silent "${DOWNLOAD_URI}/go${COMPILER_VERSION}-${GOOS}-${GOARCH}-bootstrap.tgz" | tar --strip-component=1 -C "${GOROOT_BOOTSTRAP}" -zx || {
        logger_error_message "cannot download 'go${COMPILER_VERSION}-${GOOS}-${GOARCH}-bootstrap.tgz' from '${DOWNLOAD_URI}'"
        logger_fail "may be this bootstrap version is not uploaded into '${DOWNLOAD_URI}'?"
      }
    }
  fi

  logger_info_message "build golang for '${GOOS}' system, with '${GOARCH}' architecture"
}

#############################################
# Cleanup project build
# ARGUMENTS:
#   $1, string with project path
# OUTPUTS:
#   Write to stdout
#############################################
__clean_up_build() {
  local CURRENT_PATH="${1}"

  logger_info_message "cleaning residual files"
  rm -rf "${CURRENT_PATH}/pkg/linux_amd64_race" \
    "${CURRENT_PATH}/blog" \
    "${CURRENT_PATH}/.git"*
  find "${CURRENT_PATH}" -type d -name testdata -print0 | xargs -0 rm -rf
}

#############################################
# Package and print end message
# ARGUMENTS:
#   $1, name of archive package
#   $2, string to regex top level directory
#   $3, package directory name
#   $4, project path
# OUTPUTS:
#   Write to stdout
#############################################
__end_step() {
  local PACKAGE_NAME CONVERT_NAME CURRENT_DIRECTORY CURRENT_PATH
  PACKAGE_NAME="${1}"
  CONVERT_NAME="${2}"
  CURRENT_DIRECTORY="${3}"
  CURRENT_PATH="${4}"

  logger_info_message "package golang build"
  pushd .. >/dev/null
  tar czvf "${PACKAGE_NAME}" --transform "s;^${CURRENT_DIRECTORY};${CONVERT_NAME};" "${CURRENT_DIRECTORY}" --show-transformed-names
  mv "${PACKAGE_NAME}" "${CURRENT_PATH}/"
  popd >/dev/null

  ## End logo
  __logo_end

  ## End message
  __decor "*" "200"
  logger_info_message "'${PACKAGE_NAME}' is prepared to upload"
  __decor "*" "200"

  exit 0
}

#############################################
# Init, build and package bootstrap
# ARGUMENTS:
#   $1, string with go current version
#   $2, project path
# OUTPUTS:
#   Write to stdout
#############################################
__init_bootstrap() {
  local VERSION CURRENT_PATH CURRENT_DIRECTORY MAJOR_STR MINOR_STR PATCH_STR MAJOR MINOR
  VERSION="${1}"
  CURRENT_PATH="${2}"
  CURRENT_DIRECTORY="${CURRENT_PATH##*/}"

  logger_info_message "prepare bootstrap to build"

  ## Set write permission for files
  chmod -R +w "${CURRENT_PATH}/"

  ## Remove .gitignore file for comprehensive cleaning of unnecessary data
  rm -f "${CURRENT_PATH}/.gitignore"

  ## Check on exists .git directory for comprehensive cleaning of unnecessary data
  if [[ -e ${CURRENT_PATH}/.git ]]; then
    git clean -f -d || {
      logger_fail "cannot use 'git clean'"
    }
  fi

  ## Switch to build directory
  pushd "${CURRENT_PATH}/src" >/dev/null || {
    logger_fail "cannot switch to '${CURRENT_PATH}/src', is this path exists?"
  }

  logger_info_message "build bootstrap"

  ## Build project
  ./make.bash --no-banner || {
    logger_fail "an unknown error occurred during the collector and compilation of objects, which caused the program to terminate abnormally"
  }

  ## Switch back to project root directory
  popd >/dev/null

  logger_info_message "cleanup bootstrap"

  ## Remove residual and unnecessary data
  __clean_up_build "${CURRENT_PATH}"
  rm -rf "${CURRENT_PATH}/api" \
    "${CURRENT_PATH}/doc" \
    "${CURRENT_PATH}/misc" \
    "${CURRENT_PATH}/test" \
    "${CURRENT_PATH}/pkg/bootstrap" \
    "${CURRENT_PATH}/pkg/obj"

  ## Parse version
  IFS='.' read -r MAJOR_STR MINOR_STR PATCH_STR <<<"${VERSION}"

  ## Transform string to integer
  MAJOR=$((10#$MAJOR_STR))
  MINOR=$((10#$MINOR_STR))

  ## Package and final build message
  __end_step "go${MAJOR}.${MINOR}-${GOOS}-${GOARCH}-bootstrap.tgz" "go${VERSION}" "${CURRENT_DIRECTORY}" "${CURRENT_PATH}"
}

#############################################
# Main entrypoint for init action
# OUTPUTS:
#   Write to stdout
#############################################
main() {
  local CURRENT_VERSION CURRENT_RC GO_COMPILER_VERSION CURRENT_PATH CURRENT_DIRECTORY
  CURRENT_PATH="$(pwd)"
  CURRENT_DIRECTORY="${CURRENT_PATH##*/}"

  ## Definite branch/tag for build
  [[ -n ${GOLANG_BUILD_ENTITY} ]] || GOLANG_BUILD_ENTITY="${CI_COMMIT_REF_NAME}"
  [[ -n ${GOLANG_BUILD_ENTITY} ]] || {
    logger_error_message "branch/tag is not set"
    logger_fail "try to set 'GOLANG_BUILD_ENTITY' variable and launch '${0}' again"
  }

  ## Logo start
  __logo_start

  ## Try to grab version from variable
  CURRENT_VERSION=$(__extract_version "${GOLANG_BUILD_ENTITY}")

  ## Check variable for version
  __check_version "${CURRENT_VERSION}" || {
    logger_error_message "expected to receive the following pattern: 'major.minor.patch' or 'major.minor'"
    logger_fail "'${CURRENT_VERSION}' is not a semantic version"
  }

  ## Analyze the version and take the corresponding version of the compiler
  GO_COMPILER_VERSION=$(__determine_compiler "${CURRENT_VERSION}")
  logger_info_message "founding determine golang compiler for this build: '${GO_COMPILER_VERSION}'"

  ## Export build source variable
  __source_compile_variable "${GO_COMPILER_VERSION}"

  ## Check if this build bootstrap or not
  [[ ${GOLANG_IS_BOOTSTRAP,,} != 'true' ]] || {
    logger_info_message "this build is a bootstrap, the environment will be prepared for building other versions of the product"
    __init_bootstrap "${CURRENT_VERSION}" "${CURRENT_PATH}"
  }

  ## Patch sources
  __patching_sources "${CURRENT_VERSION}"

  ## Switch to build directory
  pushd "${CURRENT_PATH}/src" >/dev/null

  logger_info_message "build golang v${CURRENT_VERSION}"

  ## Build project
  ./all.bash || {
    logger_fail "an unknown error occurred during the collector and compilation of objects, which caused the program to terminate abnormally"
  }

  ## Switch back to project root directory
  popd >/dev/null

  ## Check golang version
  logger_info_message "$("${CURRENT_PATH}"/bin/go version) is built successfully"

  ## Test built application
  cat >"${CURRENT_PATH}/hello.go" <<EOF
package main

import "fmt"

func main() {
	fmt.Printf("hello, world\n")
}
EOF
  "${CURRENT_PATH}/bin/go" run hello.go || {
    logger_fail "go application test failed"
  }

  ## Remove test data
  rm -f "${CURRENT_PATH}/hello.go"

  ## Remove residual and unnecessary data
  __clean_up_build "${CURRENT_PATH}"

  ## Try to grab release candidate
  CURRENT_RC=$(__extract_rc "${GOLANG_BUILD_ENTITY}")
  [[ -z ${CURRENT_RC} ]] || {
    logger_info_message "founding release candidate for this build: '${CURRENT_RC}'"
    CURRENT_VERSION="${CURRENT_VERSION}${CURRENT_RC}"
  }

  ## Package and final build message
  __end_step "go${CURRENT_VERSION}-${GOOS}-${GOARCH}.tgz" "go" "${CURRENT_DIRECTORY}" "${CURRENT_PATH}"
}

## Call entrypoint
main
