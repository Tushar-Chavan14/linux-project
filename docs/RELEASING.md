# Publishing and updating hyprdev

There are two release channels, and they update independently:

| Channel | What it carries | How users get it |
|---|---|---|
| **COPR repo** `tushar1402/hyprdev` | RPMs for dotfiles, themes, the welcome app, branding and missing packages | `sudo dnf upgrade` on installed systems |
| **GitHub Releases** | The live/installer ISO | Download for new installs |

Most changes (dotfiles, scripts, themes) only need a COPR build. Rebuild the ISO for new
Fedora releases, or every so often so new installs start fresh.

---

## 1. One-time setup

### 1.1 Push the code to GitHub

```bash
cd ~/projects/my-linux
git add -A
git commit -m "hyprdev: initial import"
gh repo create linux-project --public --source=. --push
```

`.gitignore` already leaves out `out/`, `*.iso` and `.cache/`, so build output never gets committed.
After the first push, update the `URL:` field in `packaging/*.spec` to your real repo URL.

### 1.2 Create the COPR project (for `dnf upgrade` updates)

1. Log in at <https://copr.fedorainfracloud.org> with a Fedora account. Create one at <https://accounts.fedoraproject.org> if needed.
2. **New Project** → name `hyprdev` (COPR names can't be renamed later). Chroots: `fedora-44-x86_64`, and later `fedora-45-x86_64` too.
   - Under **External repositories**, add the COPRs we depend on, so builds can resolve them:
     `copr://sdegler/hyprland`, `copr://atim/starship`, `copr://atim/lazygit`,
     `copr://lihaohong/yazi`, `copr://erikreider/swayosd`
   - Tick **Enable internet access during builds**. `spectool` downloads upstream sources (fonts, cursors) during the SRPM step.
3. Add one **package** per spec. For each, choose *SCM*:
   - Clone URL: `https://github.com/Tushar-Chavan14/linux-project.git`
   - Spec file: e.g. `packaging/hyprdev-desktop.spec` (also `packaging/extra/nwg-dock-hyprland.spec`, and so on)
   - SRPM build method: **make_srpm** (uses `.copr/Makefile`)
   - Turn on **Auto-rebuild**
4. In COPR, open **Settings → Integrations** and copy the GitHub webhook URL.
   Add it on GitHub under **Settings → Webhooks** (content type `application/json`, push events).
   From then on, every push to `main` rebuilds the packages.
5. Set `COPR_OWNER` in `config.env` to your COPR username. Then add `"<you>/hyprdev"` to
   `COPRS=(…)` so ISOs ship with your repo enabled and installed systems pick up updates.

Build order the first time: `orbitron-fonts`, `symbols-nerd-fonts` and `catppuccin-cursors`
first, then `hyprdev-release` and `hyprdev-branding`, then `hyprdev-welcome`,
`hyprdev-settings` and `hyprdev-sddm-theme`, and `hyprdev-desktop` last.

> `nwg-dock-hyprland` was dropped (the dock is now a Waybar instance). If it is still
> listed as a COPR package, delete it there: **Packages → nwg-dock-hyprland → Delete**.
> Add the new **`hyprdev-settings`** package (spec `packaging/hyprdev-settings.spec`, make_srpm).

### 1.3 GitHub Actions

Nothing needs configuring:

- `.github/workflows/ci.yml` runs on every push and PR. It lints the scripts, runs
  `Hyprland --verify-config` and builds every RPM.
- `.github/workflows/release.yml` runs on a `v*` tag. It builds the ISO on a runner with KVM and
  attaches it to a GitHub Release.

---

## 2. Everyday workflow: changing the desktop

```bash
# 1. Edit dotfiles/, firstboot/, branding/, sddm-theme/ …
# 2. Bump the version of each package you changed, e.g. packaging/hyprdev-desktop.spec:
#      Version: 0.1.1
#    and add a %changelog entry (rpmdev-bumpspec does both).
# 3. Check locally
packaging/build-rpms.sh hyprdev-desktop
# 4. Push
git commit -am "waybar: show CPU temperature"
git push
```

CI checks the change, COPR rebuilds the package, and every installed hyprdev
system gets it on its next `sudo dnf upgrade`.

### How users get dotfile updates

RPM updates refresh the copies in `/usr/share/hyprdev/skel` and `/etc/skel`, never the files
already in a user's home. That's deliberate, so nobody's customisations get overwritten.
Users pull in new defaults with:

```bash
hyprdev-reset-config   # copies new defaults, backs up changed files to ~/.config/hyprdev/backup-*/
hyprctl reload
```

Personal tweaks that should survive resets go in `~/.config/hypr/user.conf` and
`~/.config/hyprdev/location`.

---

## 3. Releasing a new ISO

```bash
# Optional: build and test locally first
build/build-iso.sh                       # -> out/iso/HyprDev-HyprDev-Live-*.iso
tests/boot-iso.sh out/iso/*.iso 300 30   # boots it under KVM, screenshots in out/boot/

git tag v0.2.0
git push origin v0.2.0                   # release.yml builds and publishes the ISO
```

GitHub limits each release file to **2 GiB**. The workflow publishes a `.sha256` and, if the ISO is
larger, splits it into `.part0`, `.part1`, … The release notes explain how to join the parts
(`cat *.part* > hyprdev.iso`).

To publish an ISO you built locally instead:

```bash
cd out/iso
sha256sum *.iso > SHA256SUMS
split -b 1900M -d -a 1 HyprDev-*.iso HyprDev.iso.part   # only if > 2 GiB
gh release create v0.2.0 HyprDev.iso.part* SHA256SUMS --title "hyprdev v0.2.0" \
  --notes-file ../../docs/RELEASE_NOTES_TEMPLATE.md
```

If split downloads get annoying, mirror the ISO on SourceForge, which many small distros use for
large files, and link it from the release notes.

---

## 4. Moving to a new Fedora release (e.g. 44 → 45)

1. Check the Hyprland COPR has the new chroot. Look for `fedora-45-x86_64` at
   <https://copr.fedorainfracloud.org/coprs/sdegler/hyprland/>, and do the same for the other COPRs in `config.env`.
2. Add the `fedora-45-x86_64` chroot to your own COPR project and rebuild everything.
3. Set `FEDORA_VERSION="45"` in `config.env`. `build-iso.sh` then switches to the
   `f45` branch of Fedora's KIWI descriptions automatically.
4. Build and boot-test the ISO, then tag a release.
5. Existing installs upgrade the usual Fedora way:
   ```bash
   sudo dnf system-upgrade download --releasever=45
   sudo dnf system-upgrade reboot
   ```

---

## 5. Version scheme

| Thing | Scheme | Example |
|---|---|---|
| Our packages | `Version:` per spec, bumped when that package changes | `hyprdev-desktop 0.3.2` |
| `hyprdev-release` | Follows the Fedora version | `44-1` |
| ISO / git tag | `v<major>.<minor>.<patch>` | `v0.2.0` |
| Upstream repackages (`packaging/extra`) | Upstream's version | `nwg-dock-hyprland 0.4.11` |

---

## 6. Local build tooling and clean-up

Every build step runs in Docker. These are the images the project creates:

```text
hyprdev-lint  hyprdev-rpmbuild  hyprdev-kiwi  hyprdev-qemu
registry.fedoraproject.org/fedora:44  fedora:44
```

Caches under `.cache/` (all safe to delete, but they make rebuilds faster):

| Path | What | Size |
|---|---|---|
| `.cache/kiwi-boxes` | KIWI's build VM image | ~750 MB |
| `.cache/pkg-cache` | Every RPM in the image (`build/cache-packages.sh`) | ~2.5 GB |
| `.cache/vm` | The `tests/run-vm.sh` VM disk | grows to 40 GB max |

To remove the images and the build caches:

```bash
docker rmi hyprdev-lint hyprdev-rpmbuild hyprdev-kiwi hyprdev-qemu registry.fedoraproject.org/fedora:44 fedora:44
rm -rf .cache/kiwi-desc .cache/go-build    # keep kiwi-boxes and pkg-cache to keep rebuilds fast
```
