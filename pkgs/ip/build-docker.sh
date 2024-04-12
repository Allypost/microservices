#!/bin/bash

function usage() {
	cat <<EOF
usage: $0

environment:
	- ALLY_DOCKER_BASENAME: base image tag to use. (default: "$ALLY_DOCKER_BASENAME")
	- ALLY_DOCKER_PUSH: whether to push image to dockerhub. "yes", "1", "true", "y" for yes, otherwise false. (default: "$ALLY_DOCKER_PUSH")

Creates a new docker image labelled "$ALLY_DOCKER_BASENAME:latest"
EOF
}

function main() {
	image_name="$ALLY_DOCKER_BASENAME:latest"

	docker_image_build_with_tag "$image_name"
	docker_image_push_if "$ALLY_DOCKER_PUSH" "$image_name"
}

ALLY_DOCKER_BASENAME="${ALLY_DOCKER_BASENAME:-"allypost/m-ip"}"
ALLY_DOCKER_PUSH="$(echo "${ALLY_DOCKER_PUSH:-"yes"}" | tr "[:upper:]" "[:lower:]")"

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
