#!/bin/sh
##

. "$(dirname "$0")/provision.prolog.sh"

##

egrep -h -v '^\s*#' "${this_script_dpn:?}"/packages.needed.0?.txt > "${this_script_dpn:?}"/packages.needed.all.filtered.txt

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils

DEBIAN_FRONTEND=noninteractive apt-get install -y apt-file debconf

DEBIAN_FRONTEND=noninteractive apt-get install -y $(cat "${this_script_dpn:?}"/packages.needed.all.filtered.txt)

: DISABLED: rm -rf /var/lib/apt/lists/*

