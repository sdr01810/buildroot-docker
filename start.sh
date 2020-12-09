#!/usr/bin/env bash
## Entry point for the buildroot container.
##

set -e

umask 0022

function xx() {

	echo 1>&2 "+" "$@"
	"$@"
}

function xx_eval() {

	eval "xx" "$@"
}

function xx_printenv_sorted() {

	xx printenv | xx env LC_ALL=C sort
}

##

buildroot_ssh_key_type="${buildroot_ssh_key_type:-rsa}"

##
## ensure the buildroot user is provisioned:
##

addgroup "${buildroot_group_name}"

adduser \
	--shell    "/bin/bash" \
	--ingroup  "${buildroot_group_name}" \
	--home     "${buildroot_home_root}" \
	--gecos    "Used for buildroot-based builds" \
	--disabled-password \
	"${buildroot_user_name}"

adduser "${buildroot_user_name}" root
adduser "${buildroot_user_name}" sudo

##
## ensure the buildroot user owns its home directory and sandbox (volumes):
## 

xx :
xx ln -snf "${buildroot_sandboxes_root}" "${buildroot_home_root}"/sandboxes

for d1 in "${buildroot_home_root}" "${buildroot_sandboxes_root}" ; do

	xx :
	xx mkdir -p "${d1}" ; xx chmod ug+w,o-w "${d1}"
	xx chown -R "${buildroot_user_name}:${buildroot_group_name}" "${d1}"
	xx ls -alh "${d1}"
done

##
## generate an ssh key for the buildroot user on demand:
##

for k1 in "${buildroot_home_root:?}/.ssh/id_${buildroot_ssh_key_type:?}" ; do

	! [ -s "${k1:?}" -a -s "${k1:?}".pub ] || continue

	su -c "set -x ; : ; ssh-keygen -t '${buildroot_ssh_key_type:?}' -f '${k1:?}' -N ''" "${buildroot_user_name:?}"
done

xx :
xx ls -al "${buildroot_home_root:?}"/.ssh

##
## configure git on demand:
##

if command -v git >/dev/null ; then

	xx :
	xx git config --global user.email root@localhost
	xx git config --global user.name "Administrator"
fi

##
## print environment variables:
##

echo
echo "Environment variables:"
xx :
xx_printenv_sorted

##
## launch:
##

xx :
xx cd "${buildroot_docker_image_setup_root:?}"

if [ $# -gt 0 ] ; then

	echo
	echo "Running command as root..."
	xx :
	xx exec "$@"
else
if [ -t 0 ] ; then

	echo
	echo "Launching shell as ${buildroot_user_name:?}..."
	xx :
	xx exec su -c 'bash -l' "${buildroot_user_name:?}"
fi;fi

##

