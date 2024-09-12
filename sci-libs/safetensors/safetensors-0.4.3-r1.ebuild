# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1

CRATES="
		ryu@1.0.17
		memchr@2.7.4
		itoa@1.0.11
	serde_json@1.0.115

			syn@2.0.59
			quote@1.0.36
				unicode-ident@1.0.12
			proc-macro2@1.0.80
		serde_derive@1.0.197
	serde@1.0.197

	memmap2@0.9.4

		pyo3-ffi@0.21.1
		portable-atomic@1.6.0
			parking_lot_core@0.9.9
				scopeguard@1.2.0
			lock_api@0.4.11
		parking_lot@0.12.3
			autocfg@1.2.0
		memoffset@0.9.1
		libc@0.2.153
		cfg-if@1.0.0
			target-lexicon@0.12.16
			once_cell@1.19.0
		pyo3-build-config@0.21.1
	pyo3@0.21.1
"

# RDEPEND="
# sci-libs/pytorch[${PYTHON_SINGLE_USEDEP}]
# 	$(python_gen_cond_dep '
# 		dev-python/numpy[${PYTHON_USEDEP}]
# 		sci-libs/pytorch[${PYTHON_USEDEP}]
# 	')
# "

DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 cargo

DESCRIPTION="Simple, safe way to store and distribute tensors"
HOMEPAGE="
	https://pypi.org/project/safetensors/
	https://huggingface.co/
"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}"/${P}/bindings/python

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

QA_FLAGS_IGNORED="usr/lib/.*"
RESTRICT="test" #depends on single pkg ( pytorch )

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	test? (
		dev-python/h5py[${PYTHON_USEDEP}]
	)
"

ECARGO_OFFLINE=true

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	rm tests/test_{tf,paddle,flax}_comparison.py || die
	rm benches/test_{pt,tf,paddle,flax}.py || die
}

src_configure() {
	cargo_src_configure --no-default-features
	# clear default = [ ...] to empty [], to disable defalut features
	rm Cargo.lock
	for f in "${ECARGO_HOME}"/gentoo/* ; do
		# echo $f # /var/tmp/portage/sci-libs/safetensors-0.4.3-r1/work/cargo_home/gentoo/pyo3-0.21.1
		sed -i -z -E 's/default = \[[^]]*\]/default = \[\]/g' "$f"/Cargo.toml
		rm "$f"/Cargo.lock
	done

	distutils-r1_src_configure
}

python_compile() {
	cargo_src_compile
	distutils-r1_python_compile
}

src_compile() {
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
}
