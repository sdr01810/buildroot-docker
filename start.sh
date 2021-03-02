#!/usr/bin/env bash
## Entry point for the buildroot container.
##

set -e

umask 0022

echo
echo "STATE: STARTING"

##

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

function xx_sleep_forever() {

	while true ; do

		xx sleep 3600
	done
}

##

buildroot_ssh_key_type="${buildroot_ssh_key_type:-rsa}"

##
## ensure buildroot user's sandbox is primed and ready
## 

(
	cd "${buildroot_user_sandbox_root}"

	for f1 in "/opt/${pkg_buildroot_scripts_name}"/bin/buildroot ; do

		[[ -e ${f1} ]] || continue

		"${f1:?}" install || [[ -n ${buildroot_install_might_fail_p} ]]
	done

	for f1 in "/opt/${pkg_buildroot_scripts_name}"/share/samples/buildroot.env ; do
	for f2 in buildroot.env.sample ; do

		[[ -e ${f1} && ! -e ${f2} ]] || continue

		xx :
		xx cp "${f1}" "${f2}"
	done;done
)

##
## update buildroot user's home directory against home.ref
##

xx :
xx rsync -i --stats -a -u "${buildroot_user_home_ref}"/ "${buildroot_user_home}"/

##
## ensure symbolic links to buildroot user's work trees are correct
##

xx :
xx ln -snf "${buildroot_user_home_ref}" "${buildroot_user_home}".ref

xx :
xx ln -snf "${buildroot_user_sandbox_root}" "${buildroot_user_home}"/sandbox

##
## ensure bash startup files for buildroot user are correct
##

for f1 in \
	"${buildroot_user_home}"/.bash_env \
	"${buildroot_user_home}"/.bash_login \
	"${buildroot_user_home}"/.bash_logout \
	"${buildroot_user_home}"/.bash_profile \
; do
	[ -e "${f1}" ] || continue

	xx :
	xx rm "${f1}"
done

for f1 in \
	"${buildroot_user_home}"/.bashrc \
	"${buildroot_user_home}"/.profile \
; do
	[ -e "${f1}".overall ] # required

	if [ ! -e "${f1}".00.base ] ; then

		if [ -e "${f1}" ] ; then

			xx :
			xx mv "${f1}"{,.00.base}
		else
			xx :
			xx cp /dev/null "${f1}".00.base
		fi
	fi

	xx :
	xx ln -snf "$(basename "${f1}".overall)" "${f1}"
done

## ensure buildroot user owns its home directory, home.ref, and sandbox:
## 

for d1 in "${buildroot_user_home}" "${buildroot_user_home_ref}" "${buildroot_user_sandbox_root}" ; do

	xx :
	xx mkdir -p "${d1}" ; xx chmod ug+w,o-w "${d1}"
	xx chown -R "${buildroot_user_name}:${buildroot_group_name}" "${d1}"
	xx ls -alh "${d1}"
done

##
## ensure buildroot user has an ssh key:
##

for k1 in "${buildroot_user_home:?}/.ssh/id_${buildroot_ssh_key_type:?}" ; do

	! [ -s "${k1:?}" -a -s "${k1:?}".pub ] || continue

	su -c "
		set -x && : && 

		ssh-keygen -t $(printf %q "${buildroot_ssh_key_type:?}") -f $(printf %q "${k1:?}") -N ''

	" "${buildroot_user_name:?}" ;
done

xx :
xx ls -al "${buildroot_user_home:?}"/.ssh

##
## update buildroot user's home.ref against home directory (note: exports ssh key)
##

xx :
xx rsync -i --stats -a -u "${buildroot_user_home}"/ "${buildroot_user_home_ref}"/

##
## configure git on demand for root:
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
xx cd "${buildroot_user_home:?}"

if [ $# -gt 0 ] ; then

	echo
	echo "STATE: RUNNING COMMAND; USER = root; COMMAND = ${@}"
	xx :
	xx exec "$@"
else
if [ -t 0 ] ; then

	echo
	echo "STATE: RUNNING LOGIN SHELL; USER = ${buildroot_user_name:?}"
	xx :
	xx exec su -c 'bash -l' "${buildroot_user_name:?}"
else
	echo
	echo "STATE: READY"
	xx :
	xx_sleep_forever
fi;fi

##

