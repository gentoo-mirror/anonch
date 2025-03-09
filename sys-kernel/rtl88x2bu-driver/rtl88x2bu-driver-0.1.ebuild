# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT_DRIVER="bd8baa17dc0c07510a7a56c52410a81c363b85ae"
COMMIT_SCRIPTS="2ccfce04436b5849d109d841c829d6eb43b2521b"

DESCRIPTION="RTL8822BU driver and script to install in kernel without firmware."
HOMEPAGE="https://github.com/morrownr/88x2bu-20210702"
SRC_URI="https://github.com/morrownr/88x2bu-20210702/archive/${COMMIT_DRIVER}.tar.gz -> 88x2bu-20210702.tar.gz
https://github.com/Anoncheg1/linux-drivers-install-scripts/archive/${COMMIT_SCRIPTS}.tar.gz -> ${P}.tar.gz"

# S="${WORKDIR}/linux-drivers-install-scripts-${COMMIT_SCRIPTS}"
S="${WORKDIR}/88x2bu-20210702-${COMMIT_DRIVER}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc x86"

RESTRICT="mirror bindist"

PATCHES=(
    # rename aes_encrypt that conflict to something postfixed
    "${FILESDIR}"/${PV}-fix-multiple-definition-of-aes_encrypt.patch
    "${FILESDIR}"/${PV}-Kconfig-depends-on.patch
)

RTL=rtl8822b # rtl8812au
CONF_MOD=CONFIG_RTL8822BU
OLD_DRIVER=rtw88
parentMakefile="/usr/src/linux/drivers/net/wireless/realtek/Makefile"
parentKconfig="/usr/src/linux/drivers/net/wireless/realtek/Kconfig"

backup_or_restore() {
    local file="$1"
    local backup="${file}.back"

    if [ -e "$backup" ]; then
        cp "$backup" "$file"
    else
        cp "$file" "$backup"
    fi
}

restore() {
    local file="$1"
    local backup="${file}.back"
    cp "$backup" "$file"
}

src_configure() {
   : # skip
}

src_compile() {
   : # skip
}

src_test() {
   : # skip
}



src_install() {
    cd "${WORKDIR}/linux-drivers-install-scripts-${COMMIT_SCRIPTS}"

    dobin rtl8822bu-install.sh
    dobin rtl8822bu-remove.sh
    dosym rtl8822bu-install.sh /usr/bin/rtl8822bu-install
    dosym rtl8822bu-remove.sh /usr/bin/rtl8822bu-remove

    dodir /usr/share/${PN}
    tar -C "${WORKDIR}/88x2bu-20210702-${COMMIT_DRIVER}" -czf "${ED}/usr/share/${PN}/${PN}.tar.gz" .

}
