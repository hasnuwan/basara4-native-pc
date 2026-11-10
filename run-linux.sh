#!/usr/bin/env bash
# ==============================================================================
# SENGOKU BASARA 4 SUMERAGI - LIGHTWEIGHT LINUX RUNNER
# Optimized for low-end PCs, laptops, Steam Deck, & budget iGPUs
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Warna Output Terminal
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_CYAN="\033[36m"

print_banner() {
    cat << "EOF"
  ____                               _  _   
 | __ )   __ _  ___   __ _  _ __  __ _| || |  
 |  _ \  / _` |/ __| / _` || '__|/ _` | || |_ 
 | |_) || (_| |\__ \| (_| || |  | (_| |__   _|
 |____/  \__,_||___/ \__,_||_|   \__,_|   |_|  
     SENGOKU BASARA 4 SUMERAGI // LINUX PORT
EOF
    echo -e "${C_CYAN}  Optimized Lightweight Runtime for Linux Desktop & Handhelds${C_RESET}"
    echo ""
}

show_help() {
    print_banner
    echo -e "${C_BOLD}PENGGUNAAN:${C_RESET}"
    echo "  ./run-linux.sh [OPSI]"
    echo ""
    echo -e "${C_BOLD}PRESET PERFORMA:${C_RESET}"
    echo "  --lowspec, -l     Preset paling ringan (720p, 60 FPS cap, no MSAA, cached stream, RCAS)"
    echo "  --deck, -d        Preset optimal untuk Steam Deck & handheld PC (1280x720 / 1280x800)"
    echo "  --balanced, -b    Preset seimbang 1080p 60 FPS"
    echo "  --menu, -m        Buka menu pemilihan preset interaktif"
    echo ""
    echo -e "${C_BOLD}PENGATURAN TAMBAHAN:${C_RESET}"
    echo "  --fps <N>         Paksa batas FPS (misal: --fps 30, --fps 45, --fps 60)"
    echo "  --res <WxH>       Atur resolusi render (misal: --res 1280x720, --res 960x540)"
    echo "  --no-msaa         Matikan MSAA secara paksa"
    echo "  --no-audio        Jalankan tanpa audio (hemat CPU untuk PC sangat rendah)"
    echo "  --game-dir <DIR>  Tentukan lokasi folder game CUSA01159 secara manual"
    echo "  --check           Periksa kesiapan hardware (CPU instruction set, Gamepad, Display)"
    echo "  --help, -h        Tampilkan bantuan ini"
    echo ""
    echo -e "${C_BOLD}CONTOH:${C_RESET}"
    echo "  ./run-linux.sh --lowspec"
    echo "  ./run-linux.sh --fps 30 --lowspec"
    exit 0
}

# Nilai Bawaan
PRESET_MODE="lowspec"
OVERRIDE_FPS=""
OVERRIDE_RES=""
FORCE_NO_MSAA="1"
DISABLE_AUDIO="0"
CUSTOM_GAME_DIR=""
INTERACTIVE_MENU="0"
CHECK_ONLY="0"

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --lowspec|-l)
            PRESET_MODE="lowspec"
            shift
            ;;
        --deck|-d)
            PRESET_MODE="deck"
            shift
            ;;
        --balanced|-b)
            PRESET_MODE="balanced"
            shift
            ;;
        --menu|-m)
            INTERACTIVE_MENU="1"
            shift
            ;;
        --fps)
            OVERRIDE_FPS="$2"
            shift 2
            ;;
        --res)
            OVERRIDE_RES="$2"
            shift 2
            ;;
        --no-msaa)
            FORCE_NO_MSAA="1"
            shift
            ;;
        --no-audio)
            DISABLE_AUDIO="1"
            shift
            ;;
        --game-dir)
            CUSTOM_GAME_DIR="$2"
            shift 2
            ;;
        --check)
            CHECK_ONLY="1"
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo -e "${C_RED}Opsi tidak dikenal: $1${C_RESET}"
            show_help
            ;;
    esac
done

print_banner

# Menu interaktif jika diminta
if [[ "$INTERACTIVE_MENU" == "1" ]]; then
    echo -e "${C_BOLD}Pilih Preset Performa:${C_RESET}"
    echo "1) Low-Spec / Laptop Kentang (720p, 60 FPS, paling enteng)"
    echo "2) Steam Deck & Handheld Linux (1280x720/800)"
    echo "3) Balanced (1080p, 60 FPS)"
    read -rp "Pilihan Anda [1-3, default: 1]: " menu_choice
    case "$menu_choice" in
        2) PRESET_MODE="deck" ;;
        3) PRESET_MODE="balanced" ;;
        *) PRESET_MODE="lowspec" ;;
    esac
fi

# 1. Cek Executable
PROBE_BIN=""
CANDIDATES=(
    "$SCRIPT_DIR/out/spartanport-probe"
    "$SCRIPT_DIR/out/basara4-core"
    "$SCRIPT_DIR/bin/spartanport-probe"
    "$SCRIPT_DIR/bin/basara4-core.exe"
)

for bin in "${CANDIDATES[@]}"; do
    if [[ -x "$bin" || -f "$bin" ]]; then
        PROBE_BIN="$bin"
        break
    fi
done

if [[ -z "$PROBE_BIN" ]]; then
    echo -e "${C_RED}[ERROR] Binary spartanport-probe belum di-build.${C_RESET}"
    echo -e "Jalankan build terlebih dahulu dengan:"
    echo -e "  ${C_CYAN}./build.sh --lightweight${C_RESET}"
    exit 1
fi

if [[ "$CHECK_ONLY" == "1" ]]; then
    echo -e "${C_BOLD}=== PEMERIKSAAN KESIAPAN HARDWARE ===${C_RESET}"
    echo -n "Instruksi CPU: "
    "$PROBE_BIN" --cpu-features
    echo -n "Gamepad / Controller: "
    "$PROBE_BIN" --gamepad
    echo "Layar / Display: "
    "$PROBE_BIN" --displays
    exit 0
fi

# 2. Terapkan Preset Konfigurasi ke spartanport.ini
PRESET_FILE="$SCRIPT_DIR/config/presets/${PRESET_MODE}.ini"
TARGET_INI="$SCRIPT_DIR/spartanport.ini"

if [[ -f "$PRESET_FILE" ]]; then
    echo -e "${C_GREEN}[+] Menerapkan Preset: ${PRESET_MODE^^}${C_RESET} (${PRESET_FILE})"
    cp "$PRESET_FILE" "$TARGET_INI"
else
    echo -e "${C_YELLOW}[!] Preset file tidak ditemukan, menggunakan setting bawaan.${C_RESET}"
fi

# Terapkan override resolusi jika ada
if [[ -n "$OVERRIDE_RES" && -f "$TARGET_INI" ]]; then
    sed -i "s/^render_resolution=.*/render_resolution=${OVERRIDE_RES}/" "$TARGET_INI"
    sed -i "s/^output_res=.*/output_res=${OVERRIDE_RES}/" "$TARGET_INI"
    echo -e "${C_GREEN}[+] Override Resolusi:${C_RESET} ${OVERRIDE_RES}"
fi

# Terapkan override FPS jika ada
if [[ -n "$OVERRIDE_FPS" && -f "$TARGET_INI" ]]; then
    sed -i "s/^engine_fps=.*/engine_fps=${OVERRIDE_FPS}/" "$TARGET_INI"
    sed -i "s/^fps_limit=.*/fps_limit=${OVERRIDE_FPS}/" "$TARGET_INI"
    echo -e "${C_GREEN}[+] Override FPS Limit:${C_RESET} ${OVERRIDE_FPS}"
fi

# 3. Deteksi Lingkungan Hardware & Driver Vulkan
echo -e "${C_CYAN}[i] Mengoptimalkan Driver Vulkan & Pengaturan Memori...${C_RESET}"

# Pengaturan Memori & Pacing bawaan untuk Low-Spec Linux
export SPARTAN_STREAM_MEMORY="cached" # Menghindari PCIe latency stall di iGPU / laptop
export SPARTAN_NO_MSAA="$FORCE_NO_MSAA"
export SPARTAN_PRESENT_THREAD="1"
export SPARTAN_ASYNC_SHADERS="1"
export SPARTAN_DEFERRED_READBACK="1"
export SPARTAN_STALE_READBACK="1"

# Matikan trace/debug logging yang memakan performa
export SPARTAN_AUDIO_DEBUG=""
export SPARTAN_FRAME_STATS="0"
export SPARTAN_DCB_STATS="0"
export SPARTAN_BUFFER_STATS="0"

if [[ "$DISABLE_AUDIO" == "1" ]]; then
    echo -e "${C_YELLOW}[!] Audio dimatikan secara paksa (--no-audio).${C_RESET}"
    export SPARTAN_AUDIO="none"
fi

# Tweak Vulkan Driver Berdasarkan GPU
if command -v lspci >/dev/null 2>&1; then
    GPU_INFO=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' || true)
    if echo "$GPU_INFO" | grep -qi 'amd'; then
        echo -e "${C_GREEN}[+] AMD GPU terdeteksi:${C_RESET} Mengaktifkan RADV Graphics Pipeline Library (GPL) & SAM"
        export RADV_PERFTEST="gpl,sam"
        export MESA_VK_WSI_PRESENT_MODE="mailbox"
    elif echo "$GPU_INFO" | grep -qi 'intel'; then
        echo -e "${C_GREEN}[+] Intel GPU terdeteksi:${C_RESET} Mengaktifkan ANV GPL fast shader linking"
        export ANV_GPL="1"
        export MESA_VK_WSI_PRESENT_MODE="mailbox"
    elif echo "$GPU_INFO" | grep -qi 'nvidia'; then
        echo -e "${C_GREEN}[+] NVIDIA GPU terdeteksi:${C_RESET} Mengaktifkan low-latency tearing / VRR"
        export __GL_VRR_ALLOWED="1"
        export __GL_SYNC_TO_VBLANK="0"
    fi
fi

# 4. Pencarian Direktori Game Basara 4 (CUSA01159)
GAME_DIR=""
SEARCH_DIRS=(
    "$CUSTOM_GAME_DIR"
    "${SPARTAN_GAME_DIR:-}"
    "$SCRIPT_DIR/game"
    "$SCRIPT_DIR/CUSA01159"
    "$SCRIPT_DIR/../CUSA01159"
    "$HOME/Games/SengokuBasara4"
    "$HOME/Games/CUSA01159"
)

for dir in "${SEARCH_DIRS[@]}"; do
    if [[ -n "$dir" && -f "$dir/eboot.bin" ]]; then
        GAME_DIR="$dir"
        break
    fi
done

if [[ -n "$GAME_DIR" ]]; then
    echo -e "${C_GREEN}[+] Folder Game Ditemukan:${C_RESET} $GAME_DIR"
    export SPARTAN_GAME_DIR="$GAME_DIR"
else
    echo -e "${C_RED}[!] Game dump belum terdeteksi.${C_RESET}"
    echo -e "    Letakkan dump game PS4 Sengoku Basara 4 Sumeragi (CUSA01159)"
    echo -e "    di dalam folder: ${C_CYAN}$SCRIPT_DIR/game/${C_RESET} (pastikan ada file ${C_BOLD}eboot.bin${C_RESET})."
    echo -e "    Atau tentukan lokasinya secara langsung:"
    echo -e "      ${C_CYAN}./run-linux.sh --game-dir /jalur/ke/game/CUSA01159${C_RESET}"
    exit 1
fi

# 5. Jalankan Game
mkdir -p "$SCRIPT_DIR/user"
echo -e "${C_GREEN}[*] Memulai Sengoku Basara 4 Sumeragi dengan spartanport-probe...${C_RESET}"

RUNNER=""
if command -v gamemoderun >/dev/null 2>&1; then
    echo -e "${C_GREEN}[+] Feral GameMode terdeteksi & diaktifkan.${C_RESET}"
    RUNNER="gamemoderun"
fi

exec $RUNNER "$PROBE_BIN" "$GAME_DIR/eboot.bin" --app0 "$GAME_DIR" --user "$SCRIPT_DIR/user" "$@"
