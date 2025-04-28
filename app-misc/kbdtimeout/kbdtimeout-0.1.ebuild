# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A keyboard daemon that execute command if there was no event for timegap."
HOMEPAGE="https://github.com/Anoncheg1/anonch-overlay"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
RESTRICT="fetch"


src_unpack() {
    mkdir -p $S
}

src_install() {
    newbin "${FILESDIR}"/kbdtimeout.sh kbdtimeout
    newinitd "${FILESDIR}/kbdtimeout.initd" "kbdtimeout"
    insinto /etc/kbdtimeout
    doins "${FILESDIR}"/default.conf
}
