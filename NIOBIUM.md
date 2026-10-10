# Niobium fork of ghoneycutt-ssh 3.62.0

This repository is Forge `ghoneycutt-ssh 3.62.0` (tag `3.62.0-upstream`, byte-identical
to the Forge tarball) plus **one patch**: a `'22.04', '24.04', '26.04'` arm in
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
- `3.62.0+nb.2` — same code, honest metadata and checksums
- `3.62.0+nb.3` — + `'26.04'` in the same arm (NiobiumInc/slurm#1211); also lists `NOTICE` and
  `.scanoss-curations.json`, which org automation added to `main` without checksum entries
- `3.62.0+nb.4` — no stdlib functions that stdlib 9 removed: `functions/` reimplements the ten it
  used, and the 112 calls use them (NiobiumInc/it#360). No catalog change.

## 2026-10-09: 26.04

`'26.04'` (resolute) joins the same arm, with the 24.04 values. Without it every
Ubuntu 26.04 catalog fails (`Operating System : 26.04 not supported`), found by compiling a
26.04 fact set for gollum (NiobiumInc/slurm#1211). OpenSSH on 26.04 is newer than the
24.04 values were written against; `sshd -t` on the first 26.04 node is the check.

## 2026-10-09: stdlib 9 (nb.4)

The control repo is moving to puppetlabs-stdlib 9 so its modules can run on Puppet/OpenVox 8
(NiobiumInc/it#360). stdlib 9 removed 34 functions that Puppet core does not provide; this module
called ten of them 112 times (`validate_re` 41, `validate_array` 19, `type3x` 14,
`validate_absolute_path` 12, `validate_string` 11, `validate_bool` 6, `is_integer` 4,
`validate_hash` 3, `validate_numeric` 1, `is_array` 1). Under stdlib 9.7.0 every Linux catalog
failed at the first (`validate_absolute_path`, `init.pp:547`).

`functions/*.pp` reimplements each as `ssh::<name>` with **stdlib 6.5's exact contract**, read
from its source -- the lenient cases included: `validate_string` accepts undef, `is_integer` and
`type3x` treat a digit String (`'22'`) as an integer, `validate_numeric` accepts numeric Strings
and arrays. The calls were renamed mechanically, nothing else in `manifests/` changed. Checked
against stdlib 6.5's own functions over 25 inputs (digit/float/negative/leading-zero strings,
numbers, booleans, undef, arrays, hashes, POSIX/Windows/relative paths): 74 return values and 175
pass/fail outcomes identical. These work on stdlib 6.5 and 9 alike, so the pin moves before the
stdlib bump; `type3x` also no longer depends on Ruby's Bignum/Fixnum (gone in Ruby 3.2).

Not in nb.4: the legacy facts and the String-to-Integer coercion that Puppet 8's strict mode
rejects (`init.pp` ~497). Those are OpenVox 8 work for a separate release.
