# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit tree-sitter-grammar

DESCRIPTION="YAML grammar for Tree-sitter"
HOMEPAGE="https://github.com/tree-sitter/tree-sitter-ocaml"

SRC_URI="https://github.com/tree-sitter-grammars/${PN}/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

# S="${WORKDIR}/${P}/yaml"
IUSE="test"

RESTRICT="mirror bindist !test? ( test )"

TEST_DEPEND="dev-util/tree-sitter-cli"

PATCHES=(
	"${FILESDIR}"/${P}-stdint.patch
	"${FILESDIR}"/${P}-highlight-test.patch
)
