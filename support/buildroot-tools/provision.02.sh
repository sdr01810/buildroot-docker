#!/bin/sh
##

set -e -x

##

pkg_buildroot_scripts_name=buildroot-scripts
pkg_buildroot_scripts_version=1.0.0-rc1
pkg_buildroot_scripts_artifact_stem=${pkg_buildroot_scripts_name}-${pkg_buildroot_scripts_version}
pkg_buildroot_scripts_artifact_depot_url=https://github.com/sdr01810/buildroot-scripts/releases/download
pkg_buildroot_scripts_artifact_url=${pkg_buildroot_scripts_artifact_depot_url}/v${pkg_buildroot_scripts_version}/${pkg_buildroot_scripts_artifact_stem}.tar.gz

pkg_qemu_scripts_name=qemu-scripts
pkg_qemu_scripts_version=1.0.0
pkg_qemu_scripts_artifact_stem=${pkg_qemu_scripts_name}-${pkg_qemu_scripts_version}
pkg_qemu_scripts_artifact_depot_url=https://github.com/sdr01810/qemu-scripts/releases/download
pkg_qemu_scripts_artifact_url=${pkg_qemu_scripts_artifact_depot_url}/v${pkg_qemu_scripts_version}/${pkg_qemu_scripts_artifact_stem}.tar.gz

mkdir -p artifacts.d

mkdir -p /opt

##

wget -O "artifacts.d/${pkg_buildroot_scripts_artifact_stem}.tar.gz" "${pkg_buildroot_scripts_artifact_url}"

tar xzf "artifacts.d/${pkg_buildroot_scripts_artifact_stem}.tar.gz" -C /opt

ln -snf "${pkg_buildroot_scripts_artifact_stem}" "/opt/${pkg_buildroot_scripts_name}"

##

wget -O "artifacts.d/${pkg_qemu_scripts_artifact_stem}.tar.gz" "${pkg_qemu_scripts_artifact_url}"

tar xzf "artifacts.d/${pkg_qemu_scripts_artifact_stem}.tar.gz" -C /opt

ln -snf "${pkg_qemu_scripts_artifact_stem}" "/opt/${pkg_qemu_scripts_name}"

##

"/opt/${pkg_buildroot_scripts_name}/bin/buildroot.sh" install --dependencies-only

##

ls -alh /opt

##

