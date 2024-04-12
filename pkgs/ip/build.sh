#!/bin/bash

function usage() {
	cat <<EOF
usage: $0

environment:
	- ALLY_OUTPUT_PATH: output path of the binary (current: "$ALLY_OUTPUT_PATH")

Will output the binary at "\$ALLY_OUTPUT_DIR"
EOF
}

function main() {
	output_file="$ALLY_OUTPUT_PATH"

	CGO_ENABLED=0 \
		go build \
		-o "$output_file" \
		-trimpath \
		-ldflags '-extldflags=-static -w -s' \
		-tags osusergo,netgo,sqlite_omit_load_extension \
		./ip.go

	if command -v strip >/dev/null; then
		strip "$output_file"
	fi
}

ALLY_OUTPUT_PATH="${ALLY_OUTPUT_PATH:-"../../dist/ip"}"

#####################
# BOILERPLATE STUFF #
#####################
SCRIPT_DIR="$(dirname $(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null))"
cd "$SCRIPT_DIR"
_prelude_path="$SCRIPT_DIR/../../common/prelude.sh"
if [ -f "$_prelude_path" ]; then
	source "$_prelude_path"
fi
if declare -F "run_main" &>/dev/null; then
	run_main "$@"
else
	set -exo pipefail
	main "$@"
fi
