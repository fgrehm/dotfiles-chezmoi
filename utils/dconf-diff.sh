#!/bin/bash

set -eo pipefail

DUMP_DIR="tmp/dconf-dumps"
NEW="$(date --utc --iso-8601).ini"

mkdir -p "${DUMP_DIR}"
dconf dump / >"${DUMP_DIR}/${NEW}"

PREVIOUS="$(ls -t ${DUMP_DIR} | head -2 | tail -n 1)"
diff --color "${DUMP_DIR}/${PREVIOUS}" "${DUMP_DIR}/${NEW}"
