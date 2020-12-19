##/bin/bash
## Source'd at the beginning of all scripts in this installation set.
## 

set -e

##

this_script_fpn="$(realpath "${0:?}")"

this_script_dpn="$(dirname "${this_script_fpn:?}")"
this_script_fbn="$(basename "${this_script_fpn:?}")"

##

