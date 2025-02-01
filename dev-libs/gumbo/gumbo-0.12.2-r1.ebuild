# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} pypy3 )
DISTUTILS_USE_PEP517="setuptools"
DISTUTILS_OPTIONAL=1
DISTUTILS_EXT=1

inherit autotools distutils-r1

DESCRIPTION="The HTML5 parsing algorithm implemented as a pure C99 library"
HOMEPAGE="https://codeberg.org/gumbo-parser/gumbo-parser"
SRC_URI="https://codeberg.org/gumbo-parser/gumbo-parser/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/gumbo-parser"

LICENSE="Apache-2.0"
SLOT="0/2" # gumbo SONAME
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="doc test python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-cpp/gtest )
        python? ( ${PYTHON_DEPS} )"
BDEPEND="doc? ( app-text/doxygen )
	 python? (
	     ${PYTHON_DEPS}
	     ${DISTUTILS_DEPS}
	     dev-python/setuptools[${PYTHON_USEDEP}]
	 )
	 test? ( dev-python/pytest[${PYTHON_USEDEP}] )
	 "
RDEPEND="python? ( ${PYTHON_DEPS} )"

distutils_enable_tests unittest
# pytest

PATCHES=(
    "${FILESDIR}"/${PN}-0.12.2-r1.patch
)

src_prepare() {
        # Ignore git operations:
	sed -i 's/git ls-files/find . -type f/g' setup.py || die
	default
	eautoreconf
	use python && distutils-r1_src_prepare
}

src_configure() {
	default

	# local myeconfargs=(
	#       $(use_enable python)
	#  $(use_enable test unittests)
	# )
	# econf # $myeconfargs[@]

	if use python; then
	        python_setup
   		# pushd python/gumbo || die
		# # distutils-r1_python_configure

		# popd || die
	fi
}


# python_test() {
#     cd "${S}/python/gumbo" || die
#     unittest_run_tests
# }

python_test() {
    local test_files=(
        gumboc_test
        html5lib_adapter_test
        soup_adapter_test
    )

    local test_file
    for test_file in "${test_files[@]}"; do
        einfo "Running tests in ${test_file}.py"
        "${EPYTHON}" -m unittest "${test_file}.py" || die "Tests failed in ${test_file}.py"
    done
}

src_compile() {
	default

	if use doc; then
		doxygen || die "doxygen failed"
		HTML_DOCS=( docs/html/. )
	fi

	if use python; then
		# distutils-r1_python_compilew
		python_optimize
		# python_foreach_impl run_in_build_dir distutils-r1_python_compile
	        # pushd python/gumbo || die

		# # distutils-r1_python_compile
		# popd || die
		distutils-r1_src_compile # --no-compile
	fi
}

src_install() {
	default
	use doc && doman docs/man/man3/*

	find "${ED}" -name '*.la' -delete || die

	if use python; then
		# pushd python/gumbo || die
		distutils-r1_src_install
		# popd || die
	fi
}
