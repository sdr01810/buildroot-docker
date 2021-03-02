#!/usr/bin/env bash
##

. "$(dirname "$0")"/provision.prolog.sh

##
## from snippets:
##

function xx() { # ...

	echo 1>&2 "${PS4:-+}" "$@"

	"$@"
}

##
## core logic:
##

function setup_extra_configuration_pieces() { # 

	xx :
	xx addgroup --system wheel

	xx :
	xx adduser "${SUDO_USER:-$(id -un)}" wheel 

	xx :
	xx adduser "${SUDO_USER:-$(id -un)}" staff || :

	##

	local d1

	for d1 in "$(dirname "$0")"/etc ; do
	(
		xx :
		xx cd "$(realpath "${d1:?}")" || continue

		##

		local d1_manifest=$(find * ! -type d ! -name '*~' ! -name '*.rej' ! -name '.*' | sort)

		[[ -n ${d1_manifest} ]] || continue

		##

		xx :

		local d1_bn=$(basename "${d1:?}")

		local d2=${PROVISIONING_ROOT_PREFIX}/${d1_bn:?}
		
		echo "${d1_manifest:?}" | xx cpio -pdmuv "${d2:?}"

		##

		local d2_child

		echo "${d1_manifest:?}" | while read -r d2_child ; do

			xx :

			xx chown root:wheel "${d2:?}/${d2_child:?}"

			xx chmod a+rX,u+w,g+w,o-w "${d2:?}/${d2_child:?}"

			! [[ -d ${d2:?}/${d2_child:?} ]] ||

			xx chmod g+s "${d2:?}/${d2_child:?}"
		done

		##

		local d1_child

		for d1_child in * ; do

			[[ -d ${d1_child:?} ]] || continue

			provisioning_post_copy_handler="${FUNCNAME:?}"__${d1_bn:?}_${d1_child:?}__post_copy_handler

			if [[ $(type -t "${provisioning_post_copy_handler}") = function ]] ; then

				"${provisioning_post_copy_handler}" "${d1_bn:?}/${d1_child:?}"
			fi
		done
	)
	done
}

function setup_extra_configuration_pieces__etc_schroot__post_copy_handler() { # etc_schroot_rrpn

	local d1="${1:?missing value for etc_schroot_rrpn}" ; shift 1
	local f1 x1

	[[ -d "${PROVISIONING_ROOT_PREFIX}/${d1:?}" ]] || return 0

	for f1 in "${PROVISIONING_ROOT_PREFIX}/${d1:?}"/chroot.d/buildroot*.conf ; do

		for x1 in "${PROVISIONING_ROOT_PREFIX}/srv/chroot/$(basename "${f1%.conf}")/image"{.d,.ext4} ; do
		#^-- TODO: extract file/directory pathnames from .conf file; do not hardcode

			xx :

			if [[ ${x1:?} == *.d ]] ; then

				[[ -d ${x1:?} ]] || xx mkdir -p "${x1:?}"

				xx chown "${SUDO_USER:-$(id -un)}:wheel" "${x1:?}"

				#^-- the backing source for a directory chroot can be owned by non-root
			else
				[[ -f ${x1:?} ]] || xx touch "${x1:?}"

				xx chown "root:wheel" "${x1:?}"

				#^-- the backing source for a loopback chroot must be owned by root
			fi

			xx chmod u+rwX,g+rwX,o-rwX "${x1:?}"
		done
	done
}

function main() { #

	setup_extra_configuration_pieces "$@"
}

! [[ ${0} = ${BASH_SOURCE} ]] || main "$@"

