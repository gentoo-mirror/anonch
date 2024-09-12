# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="Transformers, sans integration with Huggingface hub."
HOMEPAGE="
	https://github.com/Anoncheg1/unhubbed-transformers
	https://pypi.org/project/transformers/
"
MY_PV="${PV}.dev0"
MY_P="${PN}-${MY_PV}"
S=${WORKDIR}/${MY_P}
SRC_URI="https://github.com/Anoncheg1/${PN}/archive/refs/tags/${MY_PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test" # Need some modules, not yet packaged

# sci-libs/tokenizers[${PYTHON_SINGLE_USEDEP}]
# dev-python/pyyaml[${PYTHON_USEDEP}]
# sci-libs/huggingface_hub[${PYTHON_USEDEP}]
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		>=sci-libs/safetensors-0.4.1[${PYTHON_USEDEP}]
	')
"

distutils_enable_tests pytest
