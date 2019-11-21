echo "=> Updating /var/run/os-release"
version=$(freebsd-version -u)
version_id=${version%%[^0-9.]*}
cat <<EOF >/var/run/os-release && chmod 444 /var/run/os-release
NAME=FreeBSD
VERSION=${version}
VERSION_ID=${version_id}
ID=freebsd
ANSI_COLOR="0;31"
PRETTY_NAME="FreeBSD ${version}"
CPE_NAME=cpe:/o:freebsd:freebsd:${version_id}
HOME_URL=https://FreeBSD.org/
BUG_REPORT_URL=https://bugs.FreeBSD.org/
EOF
