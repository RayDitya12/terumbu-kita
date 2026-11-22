# AGENT — Panduan untuk AI Agent (Qoder)

Dokumen ini adalah aturan kerja untuk agent yang membantu membangun proyek ini. **Baca `spec.md` terlebih dahulu**: isinya adalah sumber kebenaran untuk fitur, aturan game, dan kriteria penerimaan. Jika dokumen ini bertentangan dengan `spec.md`, tanyakan kepada pengguna.

---

## 1. Konteks Proyek

- **Apa ini:** Prototipe aplikasi mobile **Flutter** untuk proyek akhir mata kuliah **Gamifikasi**. Topiknya pengurangan penggunaan plastik sekali pakai di Indonesia, dengan **Octalysis Framework** (8 Core Drives).
- **Sifat:** *Prototipe untuk demo dan penilaian akademik*, bukan produk produksi. Prioritasnya: **berfungsi stabil, tampilan rapi, dan mekanisme gamifikasi terlihat jelas saat didemokan**.
- **Penilaian terbesar:** penerapan 8 Core Drives (25%) dan kualitas prototipe (25%). Setiap fitur harus bisa dijelaskan dengan Core Drive mana ia bekerja.
- **Pengguna dokumen:** mahasiswa (maks. 3 orang), bahasa kerja **Bahasa Indonesia**.

---

## 2. Aturan Utama (WAJIB)

1. **Ikuti `spec.md`.** Jangan menambah fitur besar di luar spec tanpa persetujuan. Jika ide bagus muncul, usulkan dulu.
2. **Tanya jika ambigu.** Lebih baik satu pertanyaan singkat daripada menebak keputusan desain atau gamifikasi. Jangan mengarang aturan game baru secara diam-diam.
3. **Jangan memakai backend/jaringan.** Semua data lokal (`shared_preferences`) dan mock JSON di `assets/mock/`.
4. **Jangan memakai `DateTime.now()` langsung** di logika game. Gunakan abstraksi `Clock` (`core/utils/clock.dart`) agar Demo Mode berfungsi.
5. **Semua teks yang tampil ke pengguna dalam Bahasa Indonesia** dan disimpan di `core/constants/app_strings.dart` (bukan hardcode tersebar).
6. **Semua angka game** (XP, level, ambang tahap terumbu, dampak per aksi) berada di satu tempat: `core/constants/game_rules.dart` dan `impact_constants.dart`. Jangan menyebar *magic number*.
7. **Angka dampak adalah asumsi.** Beri komentar `// ASUMSI: perlu sumber` pada konstanta dampak. Jangan mengklaim statistik nasional sebagai fakta kecuali pengguna memberi sumbernya.
8. **Jangan menghapus atau menimpa file milik pengguna** (laporan, desain, aset) tanpa konfirmasi.
9. **Jangan menambah dependency baru** di luar daftar di `spec.md` §9 tanpa menyebutkan alasannya dan meminta persetujuan.

---

## 3. Prinsip Desain Gamifikasi

- **White Hat dominan.** Motivasi utama: makna (CD1), pencapaian (CD2), kreativitas (CD3), kepemilikan (CD4), sosial (CD5).
- **Black Hat (CD6–8) secukupnya dan tidak menghukum.** Karang memudar harus bisa dipulihkan dengan satu aksi. Pesan kehilangan memakai nada ajakan, bukan rasa bersalah. Selalu sediakan *streak freeze*.
- **Feedback instan.** Setiap aksi pengguna menghasilkan respons visual (animasi/angka naik) dalam < 1 detik.
- **Glowing Choice.** Di onboarding hanya ada satu pilihan utama yang jelas. Hindari formulir panjang atau terlalu banyak opsi.
- **Cegah abuse.** Terapkan batas XP harian sesuai spec.
- **Etika & inklusif.** Hindari dark pattern (notifikasi mengancam, hitung mundur palsu). Teks mudah dibaca, kontras cukup.
- **Traceability.** Saat membuat fitur gamifikasi, tambahkan komentar singkat di kode: `// CDx: <alasan>` dan perbarui `docs/octalysis_mapping.md`.

---

## 4. Teknologi & Konvensi Kode

**Stack:** Flutter (stable), Dart, `flutter_riverpod`, `go_router`, `shared_preferences`, `fl_chart`.

**Arsitektur:** berbasis fitur (*feature-first*). Struktur folder lihat `spec.md` §10.
- `data/models` : model immutable dengan `toJson/fromJson`.
- `data/repositories` : satu-satunya lapisan yang menyentuh penyimpanan lokal.
- `features/<nama>` : `presentation/` (screen, widget), `application/` (provider/controller), bila perlu `domain/`.
- Logika game (hitung XP, level, streak, tahap terumbu) ditulis sebagai **fungsi/kelas murni** yang mudah diuji, terpisah dari UI.

**Gaya kode:**
- Ikuti `flutter_lints`. Jalankan `dart format .` sebelum menyelesaikan tugas.
- Nama file `snake_case`, kelas `PascalCase`, variabel/fungsi `camelCase`.
- Gunakan `const` bila memungkinkan. Pecah widget besar (> ~150 baris).
- Tangani data kosong/korup saat membaca penyimpanan (jangan crash; fallback ke default).
- Gunakan `ThemeData` Material 3 terpusat. Jangan hardcode warna/ukuran di tiap widget.
- Komentar kode boleh Bahasa Indonesia atau Inggris, tetapi konsisten dalam satu file.

---

## 5. Cara Kerja yang Diharapkan

Untuk setiap tugas:
1. **Baca** bagian relevan di `spec.md`. Sebutkan bagian mana yang kamu pakai.
2. **Rencanakan singkat** (daftar file yang akan dibuat/diubah) sebelum menulis kode untuk tugas besar.
3. **Kerjakan bertahap**, satu fitur/tahap per kali (lihat rencana di `spec.md` §12). Jangan membangun semua layar sekaligus.
4. **Verifikasi:**
   ```bash
   flutter pub get
   dart format .
   flutter analyze
   flutter test
   ```
   Jika `flutter run` memungkinkan, pastikan alur utama berjalan.
5. **Commit** hasil kerja sesuai aturan di §11 (Git) sebelum lanjut ke unit berikutnya.
6. **Laporkan** di akhir: apa yang dibuat, file yang berubah, cara mengujinya, commit yang dibuat, dan hal yang belum selesai atau perlu keputusan.

**Pengujian minimum:** unit test untuk logika game (XP/level, streak, tahap terumbu, batas harian, karang memudar) dan untuk serialisasi model. Widget test untuk alur onboarding sudah cukup.

---

## 6. Definition of Done (per fitur)

- [ ] Sesuai `spec.md` dan kriteria penerimaan terkait
- [ ] Tidak ada error/warning di `flutter analyze`
- [ ] Teks dalam Bahasa Indonesia, lewat `app_strings.dart`
- [ ] Data tersimpan dan bisa dimuat ulang setelah app ditutup
- [ ] Kondisi kosong/error ditangani
- [ ] Komentar `// CDx` ada dan `docs/octalysis_mapping.md` diperbarui
- [ ] Bisa didemokan lewat Demo Mode bila terkait waktu (streak, memudar, event)
- [ ] Perubahan sudah di-commit dengan pesan sesuai §11

---

## 7. Demo Mode

Demo Mode wajib ada dan bekerja pada semua logika berbasis waktu:
- Maju 1/7 hari, isi data contoh, reset data.
- Logika waktu hanya boleh membaca waktu dari `Clock`.
- Tidak boleh muncul di alur pengguna biasa selain lewat Profil → Pengaturan.

---

## 8. Hal yang TIDAK Boleh Dilakukan

- Menambah backend, login sungguhan, analytics, atau iklan.
- Mengklaim voucher/hadiah itu nyata. Semua hadiah berlabel **simulasi**.
- Mengganti pilihan framework (Flutter) atau state management tanpa izin.
- Mengubah aturan game di `spec.md` tanpa persetujuan. Jika perlu perubahan, usulkan dan minta pengguna memperbarui spec.
- Memasukkan aset berhak cipta (gambar/musik) tanpa lisensi jelas. Prioritaskan ilustrasi buatan sendiri, ikon bawaan, atau aset berlisensi bebas yang mencantumkan atribusi di `docs/credits.md`.
- Melanggar aturan Git di §11 (force push, mengubah history, commit file build/secret, pesan commit asal-asalan).
- Menyalin teks dari slide tugas atau sumber lain sebagai konten aplikasi tanpa disesuaikan.

---

## 9. Kapan Harus Bertanya

Tanyakan kepada pengguna jika:
- Spec belum menentukan perilaku (mis. rumus, teks, aset).
- Ada konflik antara dua bagian spec.
- Perlu dependency atau perubahan arsitektur.
- Sebuah fitur akan memakan waktu jauh lebih besar dari perkiraan (usulkan versi sederhana).
- Ada pilihan visual penting (palet warna, maskot, gaya ilustrasi).

Format pertanyaan: singkat, beri 2–3 opsi dengan rekomendasimu.

---

## 10. Pegangan Cepat

| Hal | Lokasi |
|---|---|
| Fitur & alur | `spec.md` §6 |
| Aturan game | `spec.md` §7 → `core/constants/game_rules.dart` |
| Pemetaan CD | `spec.md` §4–5 → `docs/octalysis_mapping.md` |
| Kriteria penerimaan | `spec.md` §11 |
| Teks UI | `core/constants/app_strings.dart` |
| Data mock | `assets/mock/*.json` |
| Aturan Git & format commit | `agent.md` §11 |

---

## 11. Aturan Git

### 11.1 Inisialisasi repo
Di awal sesi, jalankan `git rev-parse --is-inside-work-tree`.
- **Jika belum ada repo:** jalankan `git init -b main`, buat `.gitignore` untuk Flutter/Dart dan IDE, lalu buat commit pertama (`chore: initialize flutter project` atau yang setara).
- **Jika sudah ada:** jangan inisialisasi ulang. Cek `git status` dan `git log --oneline -5` agar gaya commit tetap konsisten.
- `.gitignore` minimal memuat: `.dart_tool/`, `build/`, `.flutter-plugins*`, `*.iml`, `.idea/`, `.vscode/` (kecuali konfigurasi yang memang dibagikan), `local.properties`, `*.keystore`, `*.jks`, `.env*`, `.DS_Store`.
- Jangan pernah meng-commit secret, keystore, `.env`, atau folder hasil build.

### 11.2 Kapan commit
- **Commit setiap selesai satu unit kerja yang utuh dan bisa dijelaskan dalam satu kalimat**, mis. satu model, satu layar, satu aturan game beserta tesnya, satu perbaikan bug. Jangan menumpuk banyak fitur dalam satu commit.
- Sebelum commit, jalankan `dart format .` dan `flutter analyze`. Jangan meng-commit kode yang tidak bisa dikompilasi. Jika kerja belum selesai tetapi perlu disimpan, gunakan prefix `wip:` dan jangan biarkan commit `wip` bertahan sebagai hasil akhir tahap.
- Pisahkan commit berdasarkan tujuan: refactor, fitur, tes, dokumentasi, dan konfigurasi tidak dicampur.
- Cek isi commit dengan `git status` dan `git diff --staged` sebelum `git commit`. Hanya stage file yang relevan (hindari `git add .` buta jika ada file tak terkait).
- Di akhir setiap tahap di `spec.md` §12, pastikan working tree bersih. Boleh beri tag, mis. `git tag stage-3` (tanyakan dulu bila ragu).

### 11.3 Format pesan commit
Gunakan **Conventional Commits**, ditulis dalam **bahasa Inggris**, mode perintah (*imperative*):

```
<type>(<scope opsional>): <ringkasan>

<isi opsional: jelaskan KENAPA, bukan mengulang diff>
```

- **type:** `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `build`, `wip`.
- **scope** (opsional): nama fitur, mis. `onboarding`, `home`, `streak`, `quests`, `storage`.
- Baris ringkasan: huruf kecil di awal, tanpa titik di akhir, **maksimal 72 karakter**, spesifik.
- Isi (body) hanya jika ada alasan atau keputusan yang tidak terlihat dari diff. Pisahkan dengan satu baris kosong, bungkus ±72 karakter.

**Contoh yang baik:**
```
chore: initialize flutter project with feature-first structure
feat(onboarding): add glowing choice screen for focus habit
feat(streak): reset streak after one missed day unless freeze is available
fix(reef): stop health from dropping below zero after demo date skip
test(game-rules): cover level thresholds and daily xp cap
docs: map core drives to implemented features
```

**Contoh yang buruk (dilarang):**
```
update files
fix bug
Implement a robust and comprehensive streak system ✨
feat: add amazing new seamless onboarding experience
Refactor code for better readability and maintainability
```

### 11.4 Gaya penulisan (hindari "AI slop")
- **Tanpa emoji** di pesan commit.
- **Tanpa kata hiperbola/pengisi:** *robust, comprehensive, seamless, enhance, leverage, streamline, elegant, powerful, amazing, various improvements*.
- **Tanpa tambahan otomatis:** jangan menyertakan `Co-authored-by`, `Generated by`, atau tagar/tanda tangan alat AI di pesan commit.
- **Jangan menjelaskan hal yang sudah jelas** dari diff atau mengulang daftar file. Satu commit satu pesan yang menyatakan apa yang berubah dan, bila perlu, mengapa.
- **Jangan menyamarkan perubahan.** Jika commit memperbaiki bug, tulis `fix`. Jika hanya merapikan, tulis `refactor`. Jangan menulis `feat` untuk perubahan kecil.
- Akurat lebih penting daripada panjang. Pesan satu baris yang tepat lebih baik daripada paragraf yang kabur.

### 11.5 Hal yang tidak boleh dilakukan di Git
- `git push --force`, `git reset --hard` pada commit yang sudah ada, `git rebase` atau `commit --amend` pada commit yang sudah di-push, kecuali pengguna meminta secara eksplisit.
- Menghapus branch atau history tanpa konfirmasi.
- Meng-push ke remote jika remote belum dikonfigurasi pengguna. Jika belum ada remote, cukup commit lokal dan ingatkan pengguna untuk menambah remote (`git remote add origin <url>`). Jika remote sudah ada, push hanya bila diminta atau di akhir tahap setelah menanyakan.
- Mengubah `git config` global. Jika `user.name`/`user.email` belum terset di repo, **tanyakan** kepada pengguna, jangan mengarang identitas.

### 11.6 Branching
- Default: bekerja langsung di `main` untuk sesi agent tunggal.
- Jika pengguna meminta atau tim bekerja paralel, gunakan branch pendek dengan pola `feat/<nama-fitur>`, `fix/<nama-bug>`, atau `docs/<topik>`, lalu gabungkan dengan riwayat yang bersih. Tanyakan dulu sebelum membuat strategi branching yang lebih rumit.
