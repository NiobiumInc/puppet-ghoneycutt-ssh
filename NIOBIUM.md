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

## Tags

- `3.62.0-upstream` — pristine Forge release
- `3.62.0-nb.1` — + the Ubuntu 22.04/24.04 arm (what production pins)
