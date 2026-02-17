#!/usr/bin/env bash
set -euo pipefail

readonly _SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly _SOURCE_FILE="${_SCRIPT_DIR}/init.lua"
readonly _TARGET_DIR="${HOME}/.config/nvim"
readonly _TARGET_FILE="${_TARGET_DIR}/init.lua"
_FORCE=0

usage() {
    printf 'Usage: %s [--force|-f]\n' "$(basename "$0")" >&2
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

if [[ ! -f "${_SOURCE_FILE}" ]]; then
    printf 'Error: config file not found: %s\n' "${_SOURCE_FILE}" >&2
    exit 1
fi

mkdir -p -- "${_TARGET_DIR}"

if [[ -e "${_TARGET_FILE}" && ${_FORCE} -ne 1 ]]; then
    printf 'Error: config file already exists in destination: %s\n' "${_TARGET_FILE}" >&2
    printf 'Run again and use --force (or -f) to overwrite it.\n' >&2
    exit 1
fi

cp -- "${_SOURCE_FILE}" "${_TARGET_FILE}"

printf 'Applied Neovim config to %s\n' "${_TARGET_FILE}"

