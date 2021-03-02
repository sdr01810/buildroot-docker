#!/bin/sh
##

. "$(dirname "$0")"/provision.prolog.sh

set -x

##

:

pkg_buildroot_scripts_name=buildroot-scripts
pkg_buildroot_scripts_version=1.0.0-rc7
pkg_buildroot_scripts_artifact_stem=${pkg_buildroot_scripts_name}-${pkg_buildroot_scripts_version}
pkg_buildroot_scripts_artifact_depot_url=https://github.com/sdr01810/buildroot-scripts/releases/download
pkg_buildroot_scripts_artifact_url=${pkg_buildroot_scripts_artifact_depot_url}/v${pkg_buildroot_scripts_version}/${pkg_buildroot_scripts_artifact_stem}.tar.gz

:

pkg_qemu_scripts_name=qemu-scripts
pkg_qemu_scripts_version=1.0.0
pkg_qemu_scripts_artifact_stem=${pkg_qemu_scripts_name}-${pkg_qemu_scripts_version}
pkg_qemu_scripts_artifact_depot_url=https://github.com/sdr01810/qemu-scripts/releases/download
pkg_qemu_scripts_artifact_url=${pkg_qemu_scripts_artifact_depot_url}/v${pkg_qemu_scripts_version}/${pkg_qemu_scripts_artifact_stem}.tar.gz

:

mkdir -p artifacts

mkdir -p /opt

##

for this_pkg_id in buildroot_scripts qemu_scripts ; do
(
	:
	
	eval this_pkg_artifact_stem=\${pkg_${this_pkg_id}_artifact_stem}

	eval this_pkg_artifact_url=\${pkg_${this_pkg_id}_artifact_url}

	eval this_pkg_name=\${pkg_${this_pkg_id}_name}

	##

	:
	
	[ -e "artifacts/${this_pkg_artifact_stem:?}.tar.gz" ] ||

	wget -O "artifacts/${this_pkg_artifact_stem:?}.tar.gz" "${this_pkg_artifact_url:?}"

	:
	
	tar xzf "artifacts/${this_pkg_artifact_stem:?}.tar.gz" -C /opt

	:
	
	ln -snf "${this_pkg_artifact_stem:?}" "/opt/${this_pkg_name:?}"
)
done

##

:

(set +x

	"/opt/${pkg_buildroot_scripts_name}/bin/buildroot.sh" install --dependencies-only ||

	[ -n "${buildroot_install_might_fail_p}" ]
)

##

:

ls -alh /opt

##

