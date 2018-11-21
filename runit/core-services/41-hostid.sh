#
# Copyright (c) 2007 Pawel Jakub Dawidek <pjd@FreeBSD.org>
# Copyright (c) 2015 Xin LI <delphij@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD$
#
[ -n "${JAILED}" ] && return 0
hostid_file=/etc/hostid

hostid_set() {
	uuid=$1
	# Generate hostid based on hostuuid - take first four bytes from md5(uuid).
	# shellcheck disable=SC2039
	id=$(echo -n "$uuid" | /sbin/md5)
	id="0x${id%????????????????????????}"

	# Set both kern.hostuuid and kern.hostid.
	#
	msg "Setting hostuuid to ${uuid}"
	sysctl kern.hostuuid="${uuid}" >/dev/null
	msg "Setting hostid to ${id}"
	sysctl kern.hostid="${id}" >/dev/null
}

valid_hostid() {
	uuid=$1

	x="[0-9a-f]"
	y=$x$x$x$x

	# Check against a blacklist before
	# accepting the UUID.
	case "${uuid}" in
	00000000-0000-0000-0000-000000000000) ;;
	00020003-0004-0005-0006-000700080009) ;;
	03000200-0400-0500-0006-000700080009) ;;
	07090201-0103-0301-0807-060504030201) ;;
	11111111-1111-1111-1111-111111111111) ;;
	11111111-2222-3333-4444-555555555555) ;;
	4c4c4544-0000-2010-8020-80c04f202020) ;;
	58585858-5858-5858-5858-585858585858) ;;
	890e2d14-cacd-45d1-ae66-bc80e8bfeb0f) ;;
	8e275844-178f-44a8-aceb-a7d7e5178c63) ;;
	dc698397-fa54-4cf2-82c8-b1b5307a6a7f) ;;
	fefefefe-fefe-fefe-fefe-fefefefefefe) ;;
	*-ffff-ffff-ffff-ffffffffffff) ;;
	$y$y-$y-$y-$y-$y$y$y) return 0 ;;
	esac

	return 1
}

hostid_hardware() {
	uuid=$(kenv -q smbios.system.uuid)

	if valid_hostid "$uuid"; then
		echo "${uuid}"
	fi
}

hostid_generate() {
	# First look for UUID in hardware.
	uuid=$(hostid_hardware)
	if [ -z "${uuid}" ]; then
		msg_warn "hostid: unable to figure out a UUID from DMI data, generating a new one"
		sleep 2
		# If not found, fall back to software-generated UUID.
		uuid=$(uuidgen)
	fi
	hostid_set "$uuid"
}

# If ${hostid_file} already exists, we take UUID from there.
if [ -r ${hostid_file} ]; then
	# shellcheck disable=SC2162
	read saved_hostid <${hostid_file}
	if valid_hostid "${saved_hostid}"; then
		hostid_set "$(cat ${hostid_file})"
	fi
else
	# No hostid file, generate UUID.
	hostid_generate
fi
