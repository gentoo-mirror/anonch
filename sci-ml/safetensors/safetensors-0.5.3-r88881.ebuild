# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1

CRATES="
	autocfg@1.4.0
	cfg-if@1.0.0
	heck@0.5.0
	indoc@2.0.6
	itoa@1.0.15
	libc@0.2.172
	memchr@2.7.4
	memmap2@0.9.5
	memoffset@0.9.1
	once_cell@1.21.3
	proc-macro2@1.0.95
	pyo3-build-config@0.23.5
	pyo3-ffi@0.23.5
	pyo3-macros-backend@0.23.5
	pyo3-macros@0.23.5
	pyo3@0.23.5
	quote@1.0.40
	ryu@1.0.20
	safetensors@0.5.3
	serde@1.0.219
	serde_derive@1.0.219
	serde_json@1.0.140
	syn@2.0.101
	target-lexicon@0.12.16
	unicode-ident@1.0.18
	unindent@0.2.4
	portable-atomic@1.11.0
"
# safetensors@0.5.3
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{10..13} )

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
KEYWORDS="~amd64 ~arm64"

QA_FLAGS_IGNORED="usr/lib/.*"
RESTRICT="test" #depends on single pkg ( pytorch )

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	test? (
		dev-python/h5py[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	rm tests/test_{tf,paddle,flax}_comparison.py || die
	rm benches/test_{pt,tf,paddle,flax}.py || die
	# - replace dependencies.
	cp ${FILESDIR}/Cargo-${PVR}.toml "$WORKDIR"/${PN}-${PV}/${PN}/Cargo.toml
	cp ${FILESDIR}/Cargo-safetensors-python-${PVR}.toml "$WORKDIR"/${PN}-${PV}/bindings/python/Cargo.toml
}

src_configure() {
	cargo_src_configure
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
