#!/usr/bin/env bash
set -euo pipefail

readonly _SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly _SOURCE_INIT_FILE="${_SCRIPT_DIR}/init.lua"
readonly _SOURCE_LUA_DIR="${_SCRIPT_DIR}/lua"
readonly _TARGET_DIR="${HOME}/.config/nvim"
readonly _TARGET_INIT_FILE="${_TARGET_DIR}/init.lua"
readonly _TARGET_LUA_DIR="${_TARGET_DIR}/lua"
_FORCE=0

usage() {
    printf 'Usage: %s [--force|-f]\n' "$(basename "$0")" >&2
}

version_at_least() {
    local major=$((10#$1)) minor=$((10#$2)) patch=$((10#$3))
    local required_major=$4 required_minor=$5 required_patch=$6

    ((major > required_major ||
        (major == required_major && minor > required_minor) ||
        (major == required_major && minor == required_minor && patch >= required_patch)))
}

while (($# > 0)); do
    case "$1" in
        -f|--force)
            _FORCE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Error: unknown option: %s\n' "$1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ ! -f "${_SOURCE_INIT_FILE}" ]]; then
    printf 'Error: config file not found: %s\n' "${_SOURCE_INIT_FILE}" >&2
    exit 1
fi

if [[ ! -d "${_SOURCE_LUA_DIR}" ]]; then
    printf 'Error: config directory not found: %s\n' "${_SOURCE_LUA_DIR}" >&2
    exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
    printf 'Error: Neovim 0.12.0 or newer is required; nvim was not found.\n' >&2
    exit 1
fi

if ! _NVIM_VERSION_OUTPUT="$(nvim --version)" ||
    [[ ! ${_NVIM_VERSION_OUTPUT} =~ ^NVIM\ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    printf 'Error: could not determine the Neovim version.\n' >&2
    exit 1
fi

if ! version_at_least "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" 0 12 0; then
    printf 'Error: Neovim 0.12.0 or newer is required (found %s).\n' "${BASH_REMATCH[0]}" >&2
    exit 1
fi

if
    [[ ${_FORCE} -ne 1 ]] &&
        { [[ -e "${_TARGET_INIT_FILE}" ]] || [[ -L "${_TARGET_INIT_FILE}" ]] ||
            [[ -e "${_TARGET_LUA_DIR}" ]] || [[ -L "${_TARGET_LUA_DIR}" ]]; }
then
    printf 'Error: Neovim config already exists in destination: %s\n' "${_TARGET_DIR}" >&2
    printf 'Run again and use --force (or -f) to overwrite it.\n' >&2
    exit 1
fi

mkdir -p -- "${_TARGET_DIR}"

if [[ ${_FORCE} -eq 1 ]]; then
    rm -rf -- "${_TARGET_INIT_FILE}" "${_TARGET_LUA_DIR}"
fi

cp -- "${_SOURCE_INIT_FILE}" "${_TARGET_INIT_FILE}"
cp -R -- "${_SOURCE_LUA_DIR}" "${_TARGET_LUA_DIR}"

printf 'Applied Neovim config to %s\n' "${_TARGET_DIR}"
