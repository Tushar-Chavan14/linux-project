## Download

If the ISO is split into `.part0`, `.part1`, … (GitHub limits each file to 2 GiB), join the parts and check them first:

```bash
cat tushar-os-*.iso.part* > tushar-os.iso
sha256sum -c <(sed 's/  .*/  tushar-os.iso/' tushar-os-*.iso.sha256)
```

Write it to a USB stick with Fedora Media Writer, balenaEtcher or `dd`. Boot it, try the live session,
then click **Install to Hard Drive** in the dock. After installing, the setup app opens on first login.
