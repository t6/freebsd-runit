# Copyright (c) 2000  The FreeBSD Project
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
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
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
[ -n "$VIRTUALIZATION" ] && return 0

msg "Configuring system console..."

flags=
sysrc -c keymap=NO || flags="${flags} -l $(sysrc -qn keymap)"
sysrc -c keyrate=NO || flags="${flags} -r $(sysrc -qn keyrate)"
sysrc -c keybell=NO || flags="${flags} -b $(sysrc -qn keybell)"
kbdcontrol < /dev/ttyv0 ${flags}

allscreens_kbdflags=$(sysrc -qn allscreens_kbdflags)
if [ -n "${allscreens_kbdflags}" ]; then
	for ttyv in /dev/ttyv*; do
		kbdcontrol ${allscreens_kbdflags} < ${ttyv} > ${ttyv} 2>&1
	done
fi

allscreens_flags=$(sysrc -qn allscreens_flags)
if [ -n "${allscreens_flags}" ]; then
	for ttyv in /dev/ttyv*; do
		vidcontrol ${allscreens_flags} < ${ttyv} > ${ttyv} 2>&1
	done
fi
