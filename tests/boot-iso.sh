#!/usr/bin/env bash
# Boot an ISO under KVM (UEFI) in a container and capture screenshots.
#   tests/boot-iso.sh out/iso/<file>.iso [seconds-to-run] [shot-interval]
# Screenshots: out/boot/shot-NNN.png. Serial console: out/boot/serial.log
# Needs /dev/kvm (user in the kvm group or /dev/kvm world-accessible).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../config.env
source "$root/config.env"
iso=$(realpath "${1:?usage: boot-iso.sh <iso> [seconds] [interval]}")
secs=${2:-240} every=${3:-20}
out="$root/out/boot"; mkdir -p "$out"; rm -f "$out"/shot-*.png
docker build -q -t hyprdev-qemu --build-arg FEDORA_VERSION="$FEDORA_VERSION" \
  -f "$root/tests/Containerfile.qemu" "$root/tests" >/dev/null
docker run --rm --device /dev/kvm -v "$iso:/boot.iso:ro" -v "$out:/out" \
  -e SECS="$secs" -e EVERY="$every" hyprdev-qemu bash -euo pipefail -c '
  cp /usr/share/edk2/ovmf/OVMF_VARS.fd /tmp/vars.fd
  qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -smp 4 -m 6144 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/ovmf/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/vars.fd \
    -cdrom /boot.iso -device virtio-vga -display none \
    -nic user,model=virtio-net-pci \
    -serial file:/out/serial.log -monitor unix:/tmp/mon.sock,server,nowait &
  qpid=$!
  sleep 2; kill -0 "$qpid" 2>/dev/null || { echo "qemu failed to start" >&2; exit 1; }
  n=0
  for ((t = 0; t < SECS; t += EVERY)); do
    sleep "$EVERY"; n=$((n + 1))
    kill -0 "$qpid" 2>/dev/null || { echo "qemu exited early" >&2; exit 1; }
    f=$(printf "/out/shot-%03d" "$n")
    echo "screendump $f.ppm" | socat - unix-connect:/tmp/mon.sock >/dev/null
    sleep 1; magick "$f.ppm" "$f.png" && rm -f "$f.ppm"
    echo "t=$((t + EVERY))s -> $(basename "$f").png"
  done
  kill "$qpid"; chown -R '"$(id -u):$(id -g)"' /out
'
