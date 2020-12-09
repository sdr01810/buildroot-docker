#!/bin/sh
## Provision buildroot tools on the invoking host.
##
## Typical uses:
##
##     support/buildroot-tools/provision.sh
##

set -e -x

##

this_script_fpn="$(realpath "${0:?}")"

this_script_dpn="$(dirname "${this_script_fpn:?}")"
this_script_fbn="$(basename "${this_script_fpn:?}")"

##

for x1 in "${this_script_dpn:?}"/provision.*.sh ; do

	(. "${x1:?}")
done
