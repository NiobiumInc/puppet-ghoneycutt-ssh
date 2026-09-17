# Niobium fork of ghoneycutt-ssh 3.62.0

This repository is Forge `ghoneycutt-ssh 3.62.0` (tag `3.62.0-upstream`, byte-identical
to the Forge tarball) plus **one patch**: a `'22.04', '24.04'` arm in
`manifests/init.pp`'s Ubuntu case, mirroring the `'20.04'` block's values. Upstream
3.62.0 knows Ubuntu only up to 20.04 and `fail()`s on anything newer.

## Why a fork

The patch ran in production on `superalloy` from 2026-01-23 as a **hand edit of the
deployed module** — nowhere in git, one file on one server, invisible to r10k and to
the Puppetfile (metadata.json still said 3.62.0). r10k never refreshes an existing
environment's modules, which is the only reason it survived; any module refresh or fresh
environment restored pristine 3.62.0, and every Ubuntu 22.04/24.04 catalog failed to
compile. Every branch environment got the pristine module, so no Ubuntu host could be
canaried from a branch. NiobiumInc/it#175 has the history; the fix is this repository,
pinned by commit from the control repo's Puppetfile.

## Upgrade path

Upstream (`ghoneycutt/puppet-module-ssh`) is at 6.0.0 with native 22.04/24.04/26.04
support. 3.62.0 → 6.0.0 renames parameters and changes catalogs on every host, so it is
a separate, staged change — not this fork's job. Until then, a new Ubuntu release is one
more entry in the same case arm here.

## Versioning and checksums

A Forge module ships two claims about itself: `metadata.json`'s `version`, and a
`checksums.json` holding an md5 of every other file. `puppet module changes` compares the
two against what is on disk. A fork that patches a file and leaves both untouched therefore
reports its own patch as an unexplained modification — indistinguishable from tampering,
which is the failure this fork exists to remove (NiobiumInc/it#222).

**So every patch release re-stamps both, in the same commit as the patch:**

1. Bump `metadata.json` `version` to the next `3.62.0+nb.N`.
2. Recompute the md5 of every file that changed **and of `metadata.json` itself**, which the
   bump in step 1 has just invalidated. Add an entry for any file the fork adds (this file
   has one). `checksums.json` never contains an entry for itself.
3. Tag the merge commit with the same string as the version.
4. Update the `commit:` pin in the control repo's `Puppetfile`, and prove nothing moved:
   `scripts/catalog-diff-gate.sh <branch-env> nb-gh01.niobiummicrosystems.com momo.niobiummicrosystems.com`
   must read *identical* for both (`momo` is Ubuntu 24.04, so it exercises the patched arm).

Verify at any time by recomputing every entry: zero mismatches, zero listed-but-absent, and
the only unlisted file is `checksums.json`.

**Why `+nb.N` and not `-nb.N`.** Both are valid SemVer, but a `-` suffix is a *prerelease*
and sorts **before** the release it names, so `3.62.0-nb.1` claims to be older than the
3.62.0 it is built from. `+nb.N` is build metadata, ignored in precedence, which sorts equal
and reads as what it is: 3.62.0 plus our build. Nothing here is published to the Forge, so
the `+` costs nothing; git accepts it in a tag name.

## Tags

- `3.62.0-upstream` — pristine Forge release
- `3.62.0-nb.1` — + the Ubuntu 22.04/24.04 arm. Its `metadata.json` still said `3.62.0` and
  its `checksums.json` still held the stock digest for `init.pp`: the module claimed to be
  pristine while carrying the patch (it#222).
- `3.62.0+nb.2` — same code, honest metadata and checksums (what production pins)
