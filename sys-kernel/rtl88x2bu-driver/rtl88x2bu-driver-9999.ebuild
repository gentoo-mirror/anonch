# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT1="bd8baa17dc0c07510a7a56c52410a81c363b85ae"
COMMIT2="2ccfce04436b5849d109d841c829d6eb43b2521b"

DESCRIPTION="RTL8822BU driver and script to install in kernel without firmware."
HOMEPAGE="https://github.com/morrownr/88x2bu-20210702"
SRC_URI="https://github.com/morrownr/88x2bu-20210702/archive/${COMMIT1}.tar.gz -> 88x2bu-20210702.tar.gz
https://github.com/Anoncheg1/linux-drivers-install-scripts/archive/${COMMIT2}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/linux-drivers-install-scripts-main"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc x86"

# PATCHES=( "${FILESDIR}"/${P}-buildsystem.patch )


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
    dobin rtl8822bu-install.sh
    dobin rtl8822bu-remove.sh
    dosym rtl8822bu-install.sh /usr/bin/rtl8822bu-install
    dosym rtl8822bu-remove.sh /usr/bin/rtl8822bu-remove

    # S="${WORKDIR}/88x2bu-20210702-main"

    dodir /usr/share/${PN}
    # S=
    # elog "${ED}/usr/share/${PN}/${PN}.tar.gz"
    tar -C "${WORKDIR}/88x2bu-20210702-main" -czf "${ED}/usr/share/${PN}/${PN}.tar.gz" .
    # cp "${DISTDIR}/88x2bu-20210702.tar.gz" "${ED}/usr/share/${PN}/" || die "Failed to copy archive"


    # mkdir -p "/lib/modules/$(cat /usr/src/linux/include/config/kernel.release)/build" # gentoo way

    # # - Add driver to Kernel source tree
    # rm -r "/usr/src/linux/drivers/net/wireless/realtek/${RTL}" &> /dev/null
    # cp -r "${S}"/"${FOLDER}" "/usr/src/linux/drivers/net/wireless/realtek/${RTL}"
    # # - fix line in Makefile of installed driver
    # sed -i "s/export ${CONF_MOD} = m/export ${CONF_MOD} = y/" "/usr/src/linux/drivers/net/wireless/realtek/${RTL}/Makefile"

    # # - add line to parent Makefile to our folder
    # backup_or_restore "$parentMakefile"
    # echo 'obj-$('${CONF_MOD}')		+= '"${RTL}/" >> "$parentMakefile"

    # # - parent Kconfig - add section to Kconfig with path to our Kconfig
    # backup_or_restore "$parentKconfig"
    # sed -i '$d' "$parentKconfig" # remove last line
    # {
    #     echo "source \"drivers/net/wireless/realtek/${RTL}/Kconfig\""
    #     echo
    #     echo 'endif # WLAN_VENDOR_REALTEK'
    # } >> "$parentKconfig"

    # # - remove rtw88
    # backup_or_restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
    # backup_or_restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"
    # echo "" > "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
    # echo "" > "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"
}

# pkg_prerm() {
#     rm -r "/usr/src/linux/drivers/net/wireless/realtek/${RTL}"
#     sed -i '$d' "/usr/src/linux/drivers/net/wireless/realtek/${RTL}/Makefile"
#     restore "$parentMakefile"
#     restore "$parentKconfig"
#     restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
#     restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"
# }
