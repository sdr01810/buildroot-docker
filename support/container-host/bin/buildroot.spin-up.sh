#!/bin/bash
## Spin up an environment for buildroot-based builds as a Docker container.
## By Stephen D. Rogers <inbox.c7r@steve-rogers.com>, 2020
##
## Usage:
##
##     buildroot.spin-up [--interactive|-i] [--restart policy] [--tty|-t] [listening_port [cli_listening_port]]
##

umask 0002

set -e -o pipefail

function no_worries() {

	echo 1>&2 "No worries; continuing."
}

function xx() {

	echo 1>&2 "${PS4:-+}" "$@"
	"$@"
}

##

run_options=()

run_detached_p=t

seal_off_access_to_container_workspaces_p=

while [ $# -gt 0 ] ; do
case "${1}" in 
--interactive|-i)
	run_detached_p=

	run_options+=( "${1}" )

	shift 1 ; continue
	;;

--restart)
	run_options+=( "${1}" "${2:?}" )

	shift 2 ; continue
	;;

--tty|-t)
	run_detached_p=

	run_options+=( "${1}" )

	shift 1 ; continue
	;;

--)
	shift 1 ; break
	;;

-*)
	echo 1>&2 "unrecognized option: ${1}"
	exit 2
	;;

*)
	break;
	;;
esac
done

! [ -n "${run_detached_p}" ] ||
run_options+=( --detach )

container_name=buildroot
container_image=sdr01810/${container_name}

for d1c in /v/sandbox ;  do # buildroot data directory in the container
for d2c in /v/home.ref ; do # buildroot initial reference data directory in the container

for d1h in /var/local/workspaces/buildroot/sandbox ;  do # buildroot data directory on the host
for d2h in /var/local/workspaces/buildroot/home.ref ; do # buildroot initial reference data directory on the host

	for dxh in "${d1h}" "${d2h}" ; do
	for dxh_parent in "$(dirname "$(dirname "${dxh}")")" ; do

		[ -n "${seal_off_access_to_container_workspaces_p}" ] || continue

		# The container determines owner uid/gid for "$dxh" and below;
		# seal off access to that subtree to just the superuser (root).

		xx sudo mkdir -p "${dxh_parent}"
		xx sudo chown root:root "${dxh_parent}"
		xx sudo chmod 0770 "${dxh_parent}"
		xx sudo chmod g+s "${dxh_parent}"
	done;done

	if [ ! -n "$(docker image list -q "${container_image}")" ] ; then

		xx :
		xx docker pull "${container_image}"
	fi

	xx :
	xx docker stop "${container_name}" || no_worries

	xx :
	xx docker rm --force "${container_name}" || no_worries

	xx :
	xx docker run \
		-v "${d1h}:${d1c}:z" \
		-v "${d2h}:${d2c}:z" \
		--name "${container_name}" \
		"${run_options[@]}" "${container_image}"

done;done
done;done
