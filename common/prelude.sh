#!/bin/bash

set -eo pipefail

function print_usage_if_needed() {
	for var in "$@"; do
		case "$var" in
		--help | -h)
			usage
			exit 0
			;;
		esac
	done
}

function require_function_defined() {
	if ! declare -F "$1" &>/dev/null; then
		echo "Function \`$1\` not defined!"
		exit 2
	fi
}

function run_main() {
	require_function_defined main
	require_function_defined usage

	print_usage_if_needed "$@"

	set -exo pipefail

	main "$@"
}

function docker_image_build_with_tag() {
	tag_name="$1"

	shift

	docker build \
		--pull \
		--compress \
		--label "org.opencontainers.image.created=$(date --utc --rfc-3339=seconds)" \
		--tag "$tag_name" "$@" \
		.
}

function docker_image_push_if() {
	should_push="$1"
	shift
	tag_name="$1"
	shift

	case "$should_push" in
	"true" | "1" | "yes" | "y")
		docker push "$tag_name" "$@"
		;;
	esac
}
