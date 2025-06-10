# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Daemon and command that allow to get most heavy process name for reccent several minutes."
HOMEPAGE="https://github.com/Anoncheg1/anonch-overlay"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
RESTRICT="fetch"


src_unpack() {
    mkdir -p $S
}

src_install() {
    newbin "${FILESDIR}"/heaviest-get.py heaviest-get
    newbin "${FILESDIR}"/heaviest-cpu-daemon.sh heaviest-cpu-daemon
    newinitd "${FILESDIR}/heaviest.initd" "heaviest"
}
