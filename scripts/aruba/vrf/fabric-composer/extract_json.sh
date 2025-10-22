#!/bin/bash
# Deprecated shim. The extract_json() implementation now lives in lib/commons.sh
# This stub sources the shared library to provide extract_json to legacy callers.

# shellcheck disable=SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../../../lib" && pwd)"
if [[ -f "${LIB_DIR}/commons.sh" ]]; then
  # shellcheck source=/dev/null
  source "${LIB_DIR}/commons.sh"
else
  echo "ERROR: lib/commons.sh not found from ${LIB_DIR}" >&2
  exit 1
fi
