# SPEC — Prototipe Gamifikasi "Terumbu Kita" (Pengurangan Plastik Sekali Pakai)

> Status: DRAFT v0.1 — nama aplikasi masih *working title*.
> Mata kuliah: Gamifikasi | Proyek Akhir: *Redesigning Real-World Problems in Indonesia through Octalysis Framework*
> Format kelompok: maks. 3 anggota

---

## 1. Ringkasan Proyek

**Masalah nyata:** Penggunaan plastik sekali pakai (kantong belanja, sedotan, gelas/botol, kemasan makanan) di Indonesia masih tinggi. Pendekatan yang ada umumnya *function-focused*: imbauan, larangan, atau kampanye satu arah. Pendekatan ini mengabaikan motivasi pengguna sehingga kepatuhannya bersifat jangka pendek.

**Solusi:** Aplikasi mobile yang membuat kebiasaan menolak plastik sekali pakai terasa bermakna, terukur, dan menyenangkan (*human-focused design*) dengan Octalysis Framework (8 Core Drives).

**Metafora inti:** Setiap aksi bebas plastik membuat **terumbu karang virtual milik pengguna tumbuh**. Jika pengguna lama tidak beraksi, karangnya perlahan *memudar* (bleaching), tetapi bisa dipulihkan.

**Tipe gamifikasi (rekomendasi): Hybrid, didominasi implisit.**
- *Implisit (±80%)*: progress terumbu, streak, dampak terukur, feedback visual di alur UX utama.
- *Eksplisit (±20%)*: satu mini-game ringan "Pilah Cepat" (menggeser item ke kategori *Sekali Pakai* atau *Bisa Dipakai Ulang*) dan *Mystery Chest* harian.
- Alasan: aksi inti terjadi di dunia nyata (bawa tumbler, tolak sedotan), jadi gamifikasi harus melekat pada pencatatan aksi, bukan menggantikannya. Mini-game dipakai sebagai pintu masuk edukasi dan unsur kejutan.

---

## 2. Tujuan & Ruang Lingkup Prototipe

### 2.1 Tujuan
1. Menghasilkan **prototipe interaktif yang berfungsi** dan siap didemokan dalam pitch 10 menit.
2. Memperlihatkan dengan jelas **mekanisme feedback, Glowing Choice, dan Win-State** (syarat luaran tugas).
3. Setiap fitur dapat **ditelusuri ke Core Drive tertentu** (tabel di §5), karena Core Drives bernilai 25% penilaian.

### 2.2 Dalam ruang lingkup
- Aplikasi mobile **Flutter** (Android sebagai target utama).
- Seluruh data **lokal** (penyimpanan perangkat). Tidak ada backend.
- Data komunitas, leaderboard, dan voucher berupa **mock data**.
- Bahasa antarmuka: **Bahasa Indonesia**.
- **Demo Mode** (§8) untuk mensimulasikan hari berganti saat presentasi.

### 2.3 Di luar ruang lingkup
- Backend, autentikasi sungguhan, sinkronisasi cloud.
- Verifikasi foto otomatis (AI). Foto bukti hanya simulasi.
- Voucher/hadiah nyata dan integrasi pembayaran.
- iOS, tablet, dan web.

---

## 3. Octalysis Strategy Dashboard (5 Pilar)

### 3.1 Business / Social Metrics
Metrik ini dipakai di laporan. Angka target bersifat **asumsi desain** dan harus disesuaikan atau disitasi oleh tim.

| Metrik | Target (asumsi) | Cara ukur di prototipe |
|---|---|---|
| Aksi bebas plastik per pengguna aktif per minggu | ≥ 5 aksi | Counter aksi di Impact screen |
| Retensi 7 hari | ≥ 40% | Streak & hari aktif |
| Estimasi plastik sekali pakai yang dihindari | Ditampilkan kumulatif (gram/item) | Kalkulasi dari konstanta dampak (§7.3) |
| Penyelesaian onboarding | ≥ 80% | Flag `onboardingDone` |

### 3.2 Target Users
**Persona utama:** Mahasiswa dan pekerja muda urban, usia 18–30, pengguna smartphone harian, sering membeli minuman/makanan take-away, peduli lingkungan tetapi sulit konsisten.

| Persona | Kebutuhan | Hambatan |
|---|---|---|
| Rani, 20, mahasiswa | Hemat, ingin terlihat peduli di lingkungan sosial | Lupa bawa tumbler, merasa "cuma sekali" |
| Dimas, 25, karyawan | Praktis, rutinitas padat | Kebiasaan beli kopi take-away |
| Sari, 22, aktivis komunitas | Ingin dampak terlihat dan bisa dibagikan | Sulit melihat hasil aksi pribadi |

> TODO tim: validasi persona dengan survei/wawancara singkat dan tempel hasilnya di laporan.

### 3.3 Desired Actions & Win-States

| # | Desired Action | Win-State |
|---|---|---|
| 1 | Menyelesaikan onboarding dan memilih fokus kebiasaan (Glowing Choice) | Terumbu pertama "lahir" + pesan selamat datang |
| 2 | Mencatat aksi bebas plastik pertama | Karang pertama tumbuh + badge "Penyelam Baru" |
| 3 | Mencatat aksi secara rutin (streak 3 → 7 → 30 hari) | Terumbu naik tahap + badge streak |
| 4 | Menyelesaikan Daily Quest | XP bonus + peluang Mystery Chest |
| 5 | Mencapai target mingguan (mis. 5 aksi) | Spesies baru dibuka + notifikasi pencapaian |
| 6 | Bergabung di tim/komunitas dan ikut tantangan | Kontribusi tim naik + badge sosial |
| 7 | Menjadi mentor (membagikan tips/mengundang teman) | Gelar "Penjaga Karang" |

### 3.4 Feedback Mechanics
- **Progress terumbu karang** (visual utama di Home): tahap Tunas → Tumbuh → Subur → Ekosistem.
- **Impact counter** realtime: gram plastik dihindari dan padanannya ("≈ 12 sedotan").
- **XP bar & level** dengan animasi saat naik level.
- **Streak flame** + peringatan lembut ketika streak terancam putus.
- **Micro-feedback** setiap aksi dicatat: animasi, haptic, ucapan positif.
- **Weekly summary card** (ringkasan akhir pekan).

### 3.4.1 Glowing Choice (wajib ditunjukkan)
Di onboarding, **layar pertama setelah intro langsung memberi satu pilihan terang dan jelas**: "Mulai dari kebiasaan mana?" dengan 4 kartu besar (Bawa Tumbler, Bawa Tas Belanja, Tolak Sedotan, Bawa Wadah Makan). Satu kartu diberi highlight/"disarankan". Tidak ada formulir panjang dan tidak ada kemungkinan "bingung harus apa".

### 3.5 Incentives & Rewards
| Jenis | Contoh |
|---|---|
| Intrinsik | Terumbu yang tumbuh, spesies langka, rasa dampak |
| Status | Level, gelar ("Penyelam Baru" → "Penjaga Karang"), badge |
| Sosial | Peringkat teman/kampus, kontribusi tim |
| Dunia nyata (**mock**) | Voucher diskon kafe partner yang memberi diskon bagi pembawa tumbler (hanya tampilan) |

---

## 4. Desain Octalysis

### 4.1 Peta 8 Core Drives

| CD | Nama | Penerapan di aplikasi | Hat |
|---|---|---|---|
| CD1 | Epic Meaning & Calling | Narasi "Jaga laut Indonesia"; counter kolektif seluruh pengguna; kartu fakta dampak | White |
| CD2 | Development & Accomplishment | XP, level, badge, target mingguan, progress terumbu | White |
| CD3 | Empowerment of Creativity & Feedback | Glowing Choice memilih fokus; memilih jenis tantangan sendiri; kustomisasi terumbu (dekorasi) | White |
| CD4 | Ownership & Possession | Terumbu pribadi, koleksi spesies, inventori dekorasi | White/Left |
| CD5 | Social Influence & Relatedness | Leaderboard teman/kampus (mock), tantangan tim, mentor, share kartu dampak | White/Right |
| CD6 | Scarcity & Impatience | Spesies musiman terbatas, event mingguan, voucher kuota terbatas | Black |
| CD7 | Unpredictability & Curiosity | Mystery Chest harian, fakta acak, kejutan spesies | Black |
| CD8 | Loss & Avoidance | Karang memudar bila tidak aktif, streak (dengan *streak freeze*) | Black |

### 4.2 Target Octalysis Radar Chart (skala 0–10, bisa disesuaikan)

| CD1 | CD2 | CD3 | CD4 | CD5 | CD6 | CD7 | CD8 |
|---|---|---|---|---|---|---|---|
| 8 | 8 | 6 | 8 | 7 | 4 | 5 | 5 |

**Alasan:** White Hat dominan agar motivasi berasal dari makna dan pencapaian, bukan tekanan. Black Hat (CD6–8) dipakai **secukupnya** dan selalu dengan jalan keluar (streak freeze, karang bisa dipulihkan) agar tidak membuat frustrasi.

### 4.3 Keseimbangan
- **White vs Black Hat:** ±70 : 30.
- **Left Brain (Extrinsic)** — CD2, CD4, CD6: poin, level, koleksi, event terbatas.
- **Right Brain (Intrinsic)** — CD3, CD5, CD7: pilihan bebas, sosial, kejutan.
- Prototipe memuat layar **"Tentang Desain Octalysis"** (opsional, untuk demo/pitch) yang menampilkan radar chart di atas.

### 4.4 Empat Experience Phases (Player Journey)

| Fase | Tujuan | Fitur utama | CD |
|---|---|---|---|
| 1. Discovery | Pengguna tertarik mencoba | Splash bernarasi, kartu fakta dampak, "teman sudah bergabung" (mock), ajakan share | CD7, CD5, CD1 |
| 2. Onboarding | Langkah pertama tanpa bingung | Glowing Choice, terumbu pertama lahir, aksi pertama dipandu | CD3, CD2 |
| 3. Scaffolding | Membentuk kebiasaan | Daily Quest, streak, target mingguan, Mystery Chest, level up | CD2, CD4, CD7, CD8 |
| 4. Endgame | Retensi pengguna lama | Event musiman, mentor/Penjaga Karang, tim, koleksi spesies langka, tantangan buatan sendiri | CD1, CD5, CD4, CD6 |

---

## 5. Pemetaan Fitur → Core Drive (untuk rubrik)

| Fitur | CD utama | Layar |
|---|---|---|
| Terumbu karang tumbuh | CD4, CD2 | Home |
| Catat aksi + animasi | CD2 | Log Aksi |
| Impact counter | CD1, CD2 | Home, Dampak |
| Counter kolektif nasional (mock) | CD1 | Home, Komunitas |
| Daily Quest | CD2, CD8 | Quest |
| Streak + streak freeze | CD8 | Home |
| Karang memudar | CD8 | Home |
| Mystery Chest | CD7 | Quest/Home |
| Mini-game "Pilah Cepat" | CD2, CD7 | Mini-game |
| Spesies musiman/event | CD6 | Event |
| Leaderboard & tim (mock) | CD5 | Komunitas |
| Share kartu dampak | CD5, CD1 | Dampak |
| Glowing Choice | CD3 | Onboarding |
| Dekorasi terumbu | CD3, CD4 | Koleksi |
| Voucher (mock) | CD6, CD2 | Hadiah |

---

## 6. Layar & Alur

### 6.1 Daftar layar
1. **Splash/Intro** — narasi singkat masalah plastik (Discovery).
2. **Onboarding** — 2–3 slide intro, lalu **Glowing Choice**, lalu input nama panggilan/avatar.
3. **Home (Terumbu)** — terumbu karang, streak, XP bar, impact ringkas, tombol besar "Catat Aksi".
4. **Catat Aksi** — pilih jenis aksi, (opsional) foto bukti simulasi, konfirmasi, animasi reward (Win-State).
5. **Quest** — Daily Quest, target mingguan, Mystery Chest.
6. **Mini-game "Pilah Cepat"** — 30–45 detik, hasil memberi XP.
7. **Dampak** — grafik mingguan, total plastik dihindari, padanan, tombol share kartu dampak.
8. **Koleksi** — spesies, dekorasi, badge.
9. **Komunitas** — leaderboard, tim, tantangan (mock).
10. **Hadiah** — voucher mock dengan tampilan kuota terbatas.
11. **Profil & Pengaturan** — level, gelar, notifikasi (UI saja), **Demo Mode**, reset data.
12. **Tentang Desain Octalysis** *(opsional)* — radar chart dan ringkasan CD untuk pitch.

### 6.2 Alur utama (happy path untuk demo)
Intro → Glowing Choice → Terumbu lahir → Catat aksi pertama → Win-State (karang tumbuh + badge) → Quest harian → Mystery Chest → Level up → Dampak → Komunitas.

### 6.3 Navigasi
Bottom navigation: **Home · Quest · Dampak · Komunitas · Profil**. Layar lain diakses dari tombol/kartu.

---

## 7. Aturan Game & Model Data

### 7.1 Jenis aksi (dapat diatur di satu file konstanta)
| ID | Aksi | XP | Plastik dihindari (asumsi) |
|---|---|---|---|
| `tumbler` | Bawa tumbler/botol sendiri | 10 | 1 gelas/botol |
| `tote` | Bawa tas belanja | 10 | 1 kantong |
| `no_straw` | Tolak sedotan | 5 | 1 sedotan |
| `own_container` | Bawa wadah makan sendiri | 15 | 1 kemasan |
| `refill` | Isi ulang di refill station | 10 | 1 botol |
| `no_cutlery` | Tolak sendok/garpu plastik | 5 | 1 set |

> **Penting:** gram per item adalah **asumsi placeholder** (`lib/core/constants/impact_constants.dart`). Tim harus mengganti dengan angka bersumber dan mencantumkan sitasinya di laporan.

### 7.2 Progres
- **Level:** `xpNeeded(level) = 50 + 25 * (level - 1)` (mudah dituning).
- **Tahap terumbu:** Tunas (0–9 aksi), Tumbuh (10–29), Subur (30–69), Ekosistem (70+).
- **Streak:** bertambah jika ada ≥1 aksi di hari kalender yang berbeda; putus jika 1 hari terlewat, kecuali ada *streak freeze* (maks. 2, didapat dari quest/chest).
- **Karang memudar:** setelah 3 hari tanpa aksi, tingkat kesehatan karang turun bertahap; pulih penuh dengan 1 aksi. Selalu tampilkan pesan yang memotivasi, bukan menghukum.
- **Batas aksi harian:** maks. 10 aksi/hari yang menghasilkan XP (mencegah *abuse*).
- **Mystery Chest:** 1x/hari setelah Daily Quest selesai; hadiah acak berbobot (XP, streak freeze, dekorasi, fakta).

### 7.3 Model data (disimpan lokal sebagai JSON)
```
UserProfile { nickname, avatarId, focusHabit, onboardingDone, createdAt }
Progress    { xp, level, streak, longestStreak, lastActionDate, freezes, reefHealth, totalActions }
ActionLog   { id, actionType, timestamp, xpGained, plasticGrams, note? }
Quest       { id, title, targetCount, progress, date, completed, rewardXp }
Collection  { speciesUnlocked[], decorationsOwned[], badges[] }
Settings    { demoMode, simulatedDateOffsetDays, notificationsEnabled }
```

### 7.4 Mock data
JSON di `assets/mock/`: `community.json` (teman, tim, leaderboard), `rewards.json` (voucher), `facts.json` (fakta dampak), `species.json`.

---

## 8. Demo Mode (wajib untuk presentasi)
Pengaturan tersembunyi di Profil untuk:
- **Maju 1 hari / 7 hari** (menguji streak, karang memudar, quest baru, event mingguan).
- **Isi data contoh** (profil dengan riwayat 2 minggu).
- **Reset data** (kembali ke kondisi awal).
- Semua logika waktu memakai `Clock` yang bisa digeser, bukan `DateTime.now()` langsung.

---

## 9. Persyaratan Teknis

| Aspek | Keputusan |
|---|---|
| Framework | **Flutter** (stable terbaru), Dart |
| Target | Android (emulator/perangkat), portrait |
| State management | `flutter_riverpod` |
| Penyimpanan lokal | `shared_preferences` (padanan *localStorage* di mobile); boleh `hive` bila data membesar |
| Navigasi | `go_router` |
| Grafik / Radar | `fl_chart` |
| Animasi | Animasi bawaan Flutter; `lottie`/`confetti` opsional |
| UI | Material 3, tema kustom bernuansa laut |
| Lokalisasi | Teks Bahasa Indonesia dalam satu file string (`app_strings.dart`) |

**Non-fungsional:** berjalan offline; waktu start < 3 detik; tidak crash saat data kosong/korup; teks terbaca (kontras cukup, ukuran ≥ 14sp); tombol aksi utama mudah dijangkau jempol.

---

## 10. Struktur Folder (usulan)
```
lib/
  main.dart
  app.dart
  core/
    constants/        # impact_constants.dart, game_rules.dart, app_strings.dart
    theme/
    utils/            # clock.dart, formatters.dart
  data/
    models/
    repositories/     # local_storage_repository.dart
    mock/             # loader mock JSON
  features/
    onboarding/
    home/
    log_action/
    quests/
    minigame/
    impact/
    collection/
    community/
    rewards/
    profile/
    octalysis_info/
  shared/widgets/
assets/
  mock/ images/ animations/
docs/
  spec.md  agent.md  octalysis_mapping.md
```

---

## 11. Kriteria Penerimaan (Acceptance Criteria)

Dipetakan ke rubrik penilaian (total 100%).

| Rubrik | Bobot | Dipenuhi jika |
|---|---|---|
| Analisis masalah | 15% | Intro menampilkan masalah nyata; dokumen laporan memuat keterbatasan function-focused design (di luar kode) |
| Strategy Dashboard | 20% | §3 lengkap dan konsisten dengan isi aplikasi |
| Penerapan 8 Core Drives | 25% | Setiap CD punya ≥1 fitur yang **terlihat dan berfungsi** di app; tabel §5 akurat; layar Octalysis (opsional) menampilkan radar chart |
| 4 Experience Phases | 15% | Alur demo menunjukkan keempat fase; Demo Mode dapat memicu Scaffolding dan Endgame |
| Prototipe | 25% | Semua layar utama berjalan tanpa crash; data tersimpan setelah app ditutup; Glowing Choice, feedback, dan Win-State terlihat jelas; UI konsisten dan rapi |

**Checklist fungsional minimum (MVP):**
- [ ] Onboarding + Glowing Choice, lalu masuk Home
- [ ] Catat aksi menambah XP, plastik dihindari, dan pertumbuhan terumbu
- [ ] Animasi Win-State setelah aksi dicatat
- [ ] Streak, level, dan target mingguan bekerja
- [ ] Daily Quest + Mystery Chest
- [ ] Layar Dampak dengan grafik mingguan
- [ ] Koleksi (spesies, badge) bertambah sesuai progres
- [ ] Komunitas & Hadiah (mock) tampil
- [ ] Progres tetap ada setelah restart app
- [ ] Demo Mode berfungsi (maju hari, data contoh, reset)

**Nice-to-have:** mini-game Pilah Cepat, event musiman, share kartu dampak (gambar), layar Octalysis, haptic & suara.

---

## 12. Rencana Pengerjaan (usulan)

| Tahap | Isi |
|---|---|
| 1 | Setup proyek, tema, struktur folder, model & repository lokal, `Clock` |
| 2 | Onboarding + Glowing Choice, Home dengan terumbu (statis) |
| 3 | Catat aksi → XP/level/terumbu/streak + animasi Win-State |
| 4 | Quest, Mystery Chest, Dampak (grafik) |
| 5 | Koleksi, Komunitas & Hadiah (mock), Profil + Demo Mode |
| 6 | Mini-game, event, layar Octalysis, polish UI, uji alur demo |

---

## 13. Pertanyaan Terbuka (perlu keputusan tim)
1. Nama final aplikasi dan identitas visual (warna, maskot).
2. Pilihan Flutter sudah final? (Draft ini mengasumsikan Flutter.)
3. Angka dampak per aksi dan sumber sitasinya.
4. Apakah mini-game "Pilah Cepat" dimasukkan ke MVP?
5. Apakah ada desain Figma yang sudah disepakati, atau UI dirancang langsung di kode?
6. Perangkat/emulator demo (ukuran layar) untuk presentasi.
