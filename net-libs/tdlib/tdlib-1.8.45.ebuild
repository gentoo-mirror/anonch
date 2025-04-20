# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

PV_COMMIT="521aed8e497beb19d97c26ff39708542dc262023"

DESCRIPTION="Cross-platform library for building Telegram clients"
HOMEPAGE="https://core.telegram.org/tdlib"

SRC_URI="https://github.com/tdlib/td/archive/${PV_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/td-${PV_COMMIT}"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~x86"
RESTRICT="mirror bindist"
IUSE="clang cli debug doc +gcc java low-ram lto test"

REQUIRED_USE="
	gcc? ( !clang )
	!gcc? ( clang )
	java? ( !lto )"

# according to TDLib build instructions, lto excludes java
# also sys-kernel/linux-headers but I am not shure
BDEPEND="gcc? ( >=sys-devel/gcc-4.9.2 )
	>=dev-build/cmake-3.0.2
	dev-util/gperf
	lto? ( >=dev-build/cmake-3.9.0 )
	clang? ( >=sys-devel/clang-3.4:= )
	low-ram? ( dev-lang/php[cli] )
	doc? ( app-doc/doxygen )
	java? ( virtual/jdk:= )"

# todo: tdlib apparently uses sqlite but sqlite is not required in the build manual
# maybe we'll have to provide system-sqlite USE flag
# pg_overlay has sqlite-related stuff in its src_prepare

RDEPEND="dev-libs/openssl:0=
	sys-libs/zlib"

DOCS=( README.md )

# Some fix for clang
# suggested by Carlos @capezotte in Gentoogram
pre_src_prepare() {
	if use clang && ! has_version sys-devel/clang-runtime[sanitize] ; then
		einfo "Patching -fsanitize options because clang-runtime doesn't have sanitizers"
		find "$S" -name CMakeLists.txt -exec sed -i -- '/-fsanitize=/d' {} +;
	fi
}

src_prepare() {

	# eapply "${FILESDIR}/${PN}"-1.8.0-fix-runpath.patch

	# from pg_overlay
	if use test
	then
		sed -i -e '/run_all_tests/! {/all_tests/d}' \
			test/CMakeLists.txt || die
	else
		sed -i \
			-e '/enable_testing/d' \
			-e '/add_subdirectory.*test/d' \
			CMakeLists.txt || die
	fi
	# for now, tests segfault for me on glibc and musl

	cmake_src_prepare
}

src_configure(){
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=$(usex debug Debug Release)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DTD_ENABLE_LTO=$(usex lto ON OFF)
		-DTD_ENABLE_JNI=$(usex java ON OFF)
		# According to TDLib build instructions, DOTNET=ON is only needed
		# for using tdlib from C# under Windows through C++/CLI
		-DTD_ENABLE_DOTNET=OFF
	)
	# compiler switcher, from www-client/firefox
	if use clang ; then
		local version_clang=$(clang --version 2>/dev/null | grep -F -- 'clang version' | awk '{ print $3 }')
		[[ -n ${version_clang} ]] && version_clang=$(ver_cut 1 "${version_clang}")
		[[ -z ${version_clang} ]] && die "Failed to read clang version!"

		# if tc-is-gcc; then
		# 	have_switched_compiler=yes
		# fi

		AR=llvm-ar
		CC=${CHOST}-clang-${version_clang}
		CXX=${CHOST}-clang++-${version_clang}
		NM=llvm-nm
		RANLIB=llvm-ranlib

	# elif ! use clang && ! tc-is-gcc ; then
	elif use gcc ; then
		# have_switched_compiler=yes
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	cmake_src_configure

	if use low-ram; then
		cmake --build "${BUILD_DIR}" --target prepare_cross_compiling
		php SplitSource.php
		# todo: we need to die on errors here but I don't know how
	fi

}

src_compile() {

	cmake_src_compile

	# from pg_overlay
	if use doc ; then
		doxygen Doxyfile || die "Could not build docs with doxygen"
	fi
	# completes without errors but I don't know if it's sensible
}

src_install() {

	# was suggested by upstream but seems redundant
	# use low-ram && php SplitSource.php --undo

	cmake_src_install

	use cli && dobin "${BUILD_DIR}"/tg_cli
	# can't we just skip it during build?

	# from pg_overlay
	use doc && local HTML_DOCS=( docs/html/. )
	einstalldocs

}
