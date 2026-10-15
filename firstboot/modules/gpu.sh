# GPU detection: NVIDIA proprietary driver + hybrid graphics config.
# shellcheck shell=bash
gpu_detect() {
  local l; l=$(lspci -nn | grep -Ei 'vga|3d|display')
  HAS_NVIDIA=0; HAS_IGPU=0
  grep -qi nvidia <<<"$l" && HAS_NVIDIA=1
  grep -qiE 'intel|amd|ati' <<<"$l" && HAS_IGPU=1
  log "gpu: nvidia=$HAS_NVIDIA igpu=$HAS_IGPU"
}

module_gpu() {
  gpu_detect
  if (( ! HAS_NVIDIA )); then step "No NVIDIA GPU found — Mesa drivers already cover Intel/AMD."; return 0; fi
  module_rpmfusion
  step "Installing NVIDIA driver (akmod-nvidia). The kernel module builds in the background."
  dnf_install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power libva-nvidia-driver libva-utils
  $SUDO systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service 2>/dev/null || true

  local conf="$HOME/.config/hypr/gpu.conf"
  if (( HAS_IGPU )); then
    step "Hybrid graphics: desktop stays on the integrated GPU; use 'prime-run <app>' for NVIDIA."
    $SUDO install -m755 /dev/stdin /usr/local/bin/prime-run <<'PRIME'
#!/bin/sh
export __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json
exec "$@"
PRIME
    cat > "$conf" <<'CONF'
# Hybrid: Hyprland renders on the integrated GPU (written by hyprdev-welcome)
# Use `prime-run <app>` to offload apps to NVIDIA.
CONF
  else
    step "NVIDIA-only system: configuring Hyprland for the NVIDIA GPU."
    cat > "$conf" <<'CONF'
# NVIDIA-only (written by hyprdev-welcome)
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
cursor {
    no_hardware_cursors = true
}
CONF
  fi
  if mokutil --sb-state 2>/dev/null | grep -q enabled; then
    warn "Secure Boot is on: after the akmod builds, run 'sudo kmodgenca -a && sudo mokutil --import /etc/pki/akmods/certs/public_key.der', reboot and enroll the key."
  fi
}
