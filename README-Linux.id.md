# Sengoku Basara 4 Sumeragi - Versi Linux Ringan (Low-Spec & Handheld Edition)

Fork ini dirancang khusus untuk pengguna **Linux Desktop, Laptop Hemat Daya, dan Steam Deck / Handheld** agar dapat menjalankan **Sengoku Basara 4 Sumeragi PC Port** dengan performa maksimal, konsumsi RAM/CPU yang lebih rendah, dan bebas dari *stuttering*.

---

## 🚀 Peningkatan & Optimasi Versi Linux Ringan

1. **Preset Performa Khusus (`config/presets/`)**:
   - **`lowspec.ini`**: Render di **720p (1280x720)** untuk memangkas ~55% beban pixel shader dibandingkan 1080p bawaan. Ditambah **RCAS (Robust Contrast Adaptive Sharpening)** dari AMD agar tampilan visual tetap tajam di layar 1080p tanpa membebani GPU.
   - **Batasan 60 FPS / 30 FPS**: Mengunci frame rate mesin (*engine rate*) dari 120 FPS bawaan ke 60 FPS, memotong konsumsi CPU dan temperatur laptop hingga 50%.
   - **Anti-Stuttering Shaders**: Mengaktifkan `async_shaders=1` dan `deferred_readback=1` agar kompilasi shader berjalan di thread latar belakang tanpa membuat game *freezing*.
   - **Memory Pacing**: Menggunakan `SPARTAN_STREAM_MEMORY=cached` untuk menghilangkan latensi bus PCIe pada GPU terintegrasi (Intel Iris/UHD, AMD Vega/RDNA APU).
   - **No MSAA**: Menonaktifkan multisample anti-aliasing yang berat di GPU kelas bawah.

2. **Runner Otomatis (`run-linux.sh`)**:
   - Skrip peluncur native Linux ringan tanpa ketergantungan GUI berat (seperti Python Tkinter / PyQt).
   - Deteksi GPU otomatis:
     - **AMD**: Mengaktifkan `RADV_PERFTEST=gpl,sam` dan presentation mode `mailbox`.
     - **Intel**: Mengaktifkan `ANV_GPL=1` fast pipeline linking.
     - **NVIDIA**: Mengaktifkan low-latency VRR mode.
   - Integrasi otomatis dengan **Feral GameMode** (`gamemoderun`) jika terpasang di sistem.

3. **Build System Lebih Ringan (`build.sh --lightweight`)**:
   - Dukungan build `-DCMAKE_BUILD_TYPE=Release` murni dengan flag `-O3 -DNDEBUG -fomit-frame-pointer`.
   - Pembersihan simbol debug otomatis (*binary stripping*) yang memangkas ukuran binary dari ratusan MB menjadi sangat ramping dan hemat RAM.
   - Opsi `--native` untuk memaksimalkan instruksi CPU lokal (AVX2, FMA, BMI1/2).

---

## 🛠️ Cara Build di Linux

Pastikan paket dependensi terpasang (di Arch Linux: `vulkan-headers vulkan-icd-loader sdl3 cmake ninja ffmpeg gcc`).

```bash
# Build versi ringan (Release + Stripped)
./build.sh --lightweight

# Atau build dengan optimasi instruksi CPU laptop/PC Anda sendiri:
./build.sh --lightweight --native
```

---

## 🎮 Cara Menjalankan

1. Letakkan hasil dump legal PS4 Anda (**CUSA01159**) di folder `game/`:
   ```text
   basara4-native-pc/
   ├── game/
   │   ├── eboot.bin
   │   └── ... (file game lainnya)
   ├── run-linux.sh
   └── ...
   ```

2. Jalankan runner dengan preset yang diinginkan:

```bash
# Untuk Laptop Spek Rendah / Intel UHD / AMD APU (Sangat Direkomendasikan)
./run-linux.sh --lowspec

# Untuk Steam Deck / ROG Ally / Handheld Linux
./run-linux.sh --deck

# Untuk PC Menengah / 1080p 60 FPS
./run-linux.sh --balanced

# Jika laptop sangat lemah, kunci di 30 FPS untuk kestabilan penuh:
./run-linux.sh --lowspec --fps 30

# Mode menu interaktif:
./run-linux.sh --menu
```

---

## ⌨️ Kontrol Keyboard & Gamepad

- **In-Game Overlay Menu**: Tekan <kbd>Insert</kbd> atau <kbd>R3</kbd> + <kbd>L2</kbd> di controller untuk mengatur grafik, FSR, dan cheat langsung saat bermain.
- **Controller**: Controller PlayStation, Xbox, atau generic didukung langsung via SDL3.
- **Keyboard**: Konfigurasi tombol dapat disesuaikan langsung lewat file `spartanport.ini`.

---

## 📄 Lisensi & Kredit

- Proyek ini adalah fork independen berbasis riset open-source oleh **Razz** (`razzconnect/basara4-native-pc`).
- Berlisensi **GPL v2.0+**. Tidak menyertakan berkas berhak cipta Capcom maupun Sony.
