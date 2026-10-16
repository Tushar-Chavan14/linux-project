#!/usr/bin/env bash
# Run hyprdev in a persistent KVM VM you can see and use.
#   tests/run-vm.sh out/iso/<file>.iso   # first time: boot the ISO, install to the VM disk
#   tests/run-vm.sh                      # afterwards: boot the installed system
# Display: VNC on localhost:5901 (local only). Viewer, once: sudo apt install tigervnc-viewer
#   vncviewer localhost:5901
# Disk: .cache/vm/disk.qcow2 (40 GB, grows on demand). Delete it to start over.
# Inside the VM the host is reachable at 10.0.2.2 (see packaging/serve-repo.sh).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../config.env
source "$root/config.env"
vm="$root/.cache/vm"; mkdir -p "$vm"
iso_args=()
if [[ -n ${1:-} ]]; then
  iso=$(realpath "$1")
  iso_args=(-v "$iso:/boot.iso:ro")
fi

docker build -q --network host -t hyprdev-qemu --build-arg FEDORA_VERSION="$FEDORA_VERSION" \
  -f "$root/tests/Containerfile.qemu" "$root/tests" >/dev/null
echo "VM starting - connect a VNC viewer to localhost:5901 (Ctrl+C here to power off)"
# Host networking: the VM's 10.0.2.2 then reaches services on this machine.
docker run --rm -it --device /dev/kvm --network host \
  -v "$vm:/vm" "${iso_args[@]}" hyprdev-qemu bash -euo pipefail -c '
  [[ -f /vm/disk.qcow2 ]] || qemu-img create -q -f qcow2 /vm/disk.qcow2 40G
  [[ -f /vm/vars.fd ]] || cp /usr/share/edk2/ovmf/OVMF_VARS.fd /vm/vars.fd
  cdrom=(); [[ -f /boot.iso ]] && cdrom=(-cdrom /boot.iso -boot order=dc)
  exec qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -smp 4 -m 6144 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/ovmf/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/vm/vars.fd \
    -drive file=/vm/disk.qcow2,if=virtio "${cdrom[@]}" \
    -device virtio-vga -display vnc=127.0.0.1:1 \
    -device qemu-xhci -device usb-tablet \
    -nic user,model=virtio-net-pci
'
