#!/bin/sh
## Provision buildroot tools on the invoking host.
##
## Typical uses:
##
##     support/buildroot-tools/provision.sh
##

. "$(dirname "$0")"/provision.prolog.sh

##

for x1 in "${this_script_dpn:?}"/provision.[0-9]*.sh ; do

	"${x1:?}"
done
