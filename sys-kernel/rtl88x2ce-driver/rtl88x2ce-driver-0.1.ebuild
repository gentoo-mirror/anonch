# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT_DRIVER="2ca4545cb12ece0f0a068c297e1543c30a8ff709"
COMMIT_SCRIPTS="bdea1200449f3701e536c9f658c932c01fa05bd5"

DESCRIPTION="RTL8822CE driver for PCIe and script to install in kernel without firmware."
HOMEPAGE="https://github.com/juanro49/rtl88x2ce-dkms/"
SRC_URI="https://github.com/juanro49/rtl88x2ce-dkms/archive/${COMMIT_DRIVER}.tar.gz -> rtl88x2ce-dkms.tar.gz
https://github.com/Anoncheg1/linux-drivers-install-scripts/archive/${COMMIT_SCRIPTS}.tar.gz -> ${P}.tar.gz"

# S="${WORKDIR}/linux-drivers-install-scripts-${COMMIT_SCRIPTS}"
S="${WORKDIR}/rtl88x2ce-dkms-${COMMIT_DRIVER}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc x86"

RESTRICT="mirror bindist"

PATCHES=(
        "${FILESDIR}"/${PV}-Kconfig-depends-on.patch
)

# - for info, not used:
# DRIVER_TAR="/usr/share/rtl88x2ce-driver/rtl88x2ce-driver.tar.gz"
# RTL=rtl88x2ce
# CONF_MOD=CONFIG_RTL8822CE
# OLD_DRIVER=rtw88
# parentMakefile="/usr/src/linux/drivers/net/wireless/realtek/Makefile"
# parentKconfig="/usr/src/linux/drivers/net/wireless/realtek/Kconfig"

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

    dobin rtl8822ce-install.sh
    dobin rtl8822ce-remove.sh
    dosym rtl8822ce-install.sh /usr/bin/rtl8822ce-install
    dosym rtl8822ce-remove.sh /usr/bin/rtl8822ce-remove

    dodir /usr/share/${PN}
    tar -C "${WORKDIR}/rtl88x2ce-dkms-${COMMIT_DRIVER}" -czf "${ED}/usr/share/${PN}/${PN}.tar.gz" .

}
