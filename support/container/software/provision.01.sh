#!/bin/sh
##
## For environment variable settings:
## 
## <https://wiki.debian.org/Multistrap/Environment>
##

. "$(dirname "$0")"/provision.prolog.sh

export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_FRONTEND=noninteractive

export LC_ALL=C LANGUAGE=C LANG=C

set -x

##

:

egrep -h -v '^\s*#' "${this_script_dpn:?}"/packages.needed.0?.txt > "${this_script_dpn:?}"/packages.needed.all.filtered.txt

:

apt-get update

:

apt-get install -y apt-utils

apt-get install -y apt-file debconf

apt-get install -y $(cat "${this_script_dpn:?}"/packages.needed.all.filtered.txt)

:

: DISABLED: rm -rf /var/lib/apt/lists/*

