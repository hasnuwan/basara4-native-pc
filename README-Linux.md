# Sengoku Basara 4 Sumeragi - Lightweight Linux Port (Low-Spec & Handheld Edition)

This fork is tailored for **Linux Desktop, Battery-Efficient Laptops, and Steam Deck / Handheld** users to run the native **Sengoku Basara 4 Sumeragi PC Port** with minimal CPU/RAM overhead, stutter-free Vulkan presentation, and optimized frame pacing.

---

## 🚀 Key Improvements & Optimizations

1. **Lightweight Presets (`config/presets/`)**:
   - **`lowspec.ini`**: Renders at **720p (1280x720)** to reduce ~55% pixel shader load compared to 1080p. Combined with AMD **RCAS (Robust Contrast Adaptive Sharpening)** for high visual clarity with negligible GPU cost.
   - **60 FPS / 30 FPS Cap**: Clamps the game engine down from 120 FPS to 60 FPS (or 30 FPS for budget chips), slashing CPU cycles and power draw in half.
   - **Async Shaders & Deferred Readback**: Prevents shader compilation hitches and micro-stutters during heavy combat.
   - **Optimized Memory Pacing**: Sets `SPARTAN_STREAM_MEMORY=cached` to eliminate PCIe BAR latency penalties on iGPUs.
   - **No MSAA**: Disables heavy multi-sampling on low-end hardware.

2. **Zero-Bloat CLI Runner (`run-linux.sh`)**:
   - Standalone bash runner without heavy GUI runtime dependencies (no Qt, Tkinter, or Python freeze packages).
   - Dynamic GPU detection & driver tuning:
     - **AMD**: Enables `RADV_PERFTEST=gpl,sam` & `MESA_VK_WSI_PRESENT_MODE=mailbox`.
     - **Intel**: Enables `ANV_GPL=1` fast pipeline linking.
     - **NVIDIA**: Low-latency tearing / VRR.
   - Native integration with **Feral GameMode** (`gamemoderun`) if installed.

3. **Optimized Build System (`build.sh --lightweight`)**:
   - Clean `-DCMAKE_BUILD_TYPE=Release` compilation with `-O3 -DNDEBUG -fomit-frame-pointer`.
   - Automatic binary stripping to minimize file size and runtime memory footprints.
   - Optional `--native` flag for local CPU architecture extensions (AVX2, FMA, BMI1/2).

---

## 🛠️ Building on Linux

Ensure required dependencies are installed (`vulkan-headers`, `sdl3`, `cmake`, `ninja`, `ffmpeg`, `gcc`):

```bash
# Lightweight Release build (Stripped)
./build.sh --lightweight

# Or optimized for your host CPU:
./build.sh --lightweight --native
```

---

## 🎮 Running the Game

1. Place your legally extracted PS4 game dump (**CUSA01159**) inside the `game/` folder:
   ```text
   basara4-native-pc/
   ├── game/
   │   ├── eboot.bin
   │   └── ... (game data)
   ├── run-linux.sh
   └── ...
   ```

2. Launch with your preferred preset:

```bash
# Low-Spec / Integrated GPU (Recommended for laptops):
./run-linux.sh --lowspec

# Steam Deck / Handheld:
./run-linux.sh --deck

# Balanced (1080p 60 FPS):
./run-linux.sh --balanced

# Lock at 30 FPS for ultra-budget processors:
./run-linux.sh --lowspec --fps 30
```

---

## 📄 License & Credits

- Forked from the native PC port project by **Razz** (`razzconnect/basara4-native-pc`).
- Licensed under **GPL v2.0+**. No copyrighted Capcom or Sony assets are included.
