#!/bin/bash

# wrapper around running cwltool
# includes extra CLI args and sets up temporary directories to run in
# so that repeated runs do not collide

# adapted from https://github.com/mskcc/pluto/blob/master/run-cwltool.sh
# see also https://github.com/mskcc/pluto/blob/master/run-toil.sh

# example usage;
# $ make bash
# $ ./run-cwltool.sh cwl/some_workflow.cwl input.json

set -euo pipefail

TIMESTAMP="$(date +%s)"
RUN_DIR="${PWD}/cwltool_runs/${TIMESTAMP}"
OUTPUT_DIR="${RUN_DIR}/output"
TMP_DIR="${RUN_DIR}/tmp"
LOG_FILE="${RUN_DIR}/stdout.log"
[ -e "${RUN_DIR}" ] && echo "ERROR: already exists; $RUN_DIR" && exit 1 || echo ">>> Running in ${RUN_DIR}"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TMP_DIR"

{ set -x ;
cwltool \
--preserve-environment PATH \
--leave-tmpdir \
--debug \
--js-console \
--outdir "$OUTPUT_DIR" \
--tmpdir-prefix "$TMP_DIR" \
$@  ; } 2>&1 | tee "${LOG_FILE}"

echo ">>> done: ${RUN_DIR}"

# some extra args to try
# --parallel
# --js-console
# --cachedir
# --preserve-environment SINGULARITY_CACHEDIR \
# --singularity \
# NOTE: --parallel causes random failures too often so do not use it by default!
