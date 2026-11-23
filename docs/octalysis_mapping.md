// Pemetaan fitur aplikasi → 8 Core Drives Octalysis (agent.md §3.8 traceability).
// Diperbarui setiap kali fitur gamifikasi dibuat. Sumber: spec.md §4–5.

# Octalysis Mapping — Terumbu Kita

Status kolom: `belum` = belum ada kode, `sebagian` = ada tapi belum lengkap, `jadi` = terlihat & berfungsi di prototipe.

| CD | Core Drive | Fitur (spec §5) | Layar | Status | File kode |
|---|---|---|---|---|---|
| CD1 | Epic Meaning & Calling | Narasi "Jaga laut Indonesia", counter kolektif, kartu fakta | Splash, Home, Komunitas | sebagian | `features/onboarding/presentation/splash_screen.dart` (narasi); counter belum |
| CD2 | Development & Accomplishment | XP, level, badge, target mingguan, progress terumbu | Log Aksi, Home | jadi | `core/utils/game_logic.dart`, `features/actions`, `features/home` (XP/streak/dampak hidup) |
| CD3 | Empowerment of Creativity & Feedback | Glowing Choice, pilih tantangan, dekorasi | Onboarding, Koleksi | sebagian | `features/onboarding/presentation/glowing_choice_screen.dart`; dekorasi belum |
| CD4 | Ownership & Possession | Terumbu pribadi, koleksi spesies/dekorasi | Home, Koleksi | sebagian | `shared/widgets/reef_painter.dart` (terumbu tumbuh per tahap, naik via aksi); dekorasi belum |
| CD5 | Social Influence & Relatedness | Leaderboard mock, tim, share kartu | Komunitas, Dampak | jadi | `features/community` (leaderboard/tim/challenge mock), share mock di `features/impact` |
| CD6 | Scarcity & Impatience | Spesies musiman, voucher kuota terbatas | Event, Hadiah | sebagian | `features/rewards` (kuota + label simulasi); event musiman Tahap 6 |
| CD7 | Unpredictability & Curiosity | Mystery Chest, fakta acak, mini-game | Quest, Home | jadi | `core/utils/chest.dart`, `features/minigame` (Pilah Cepat 30 detik) |
| CD8 | Loss & Avoidance | Karang memudar (−25/hari mulai hari ke-4, pulih dgn 1 aksi), streak + freeze | Home | jadi | `core/utils/game_logic.dart` (`reefHealthOn` + pemulihan via aksi), `reef_painter.dart` (warna memudar) |

## Fitur Tahap 3 yang terlihat saat demo (2026-11-23)
- Layar **Catat Aksi**: 6 kartu aksi (XP per jenis sesuai spec §7.1), kebiasaan fokus dari Glowing Choice terpilih otomatis + label "Kebiasaan utamamu" (CD3), switch foto bukti simulasi (tanpa kamera).
- Logika penuh: XP + level-up berantai, streak + freeze (gap 1 hari terselamatkan, gap ≥2 putus), karang pulih ke 100, memudar dihitung saat startup via Clock. (Batas lama "10 XP/hari" sudah diganti — lihat keputusan Unit A di bawah.)
- Win-State #2: bottom sheet animasi (+XP, gram + padanan sedotan, streak, badge "Penyelam Baru"); Win-State #3 dipicu saat tahap terumbu/streak milestone naik.
- Home kini hidup: bar XP, streak, dan angka "plastik dihindari" terhubung ke data; terumbu bertambah besar saat total aksi melewati ambang tahap.
- Persistensi: ActionLog + badge Collection tersimpan lokal dan terverifikasi lewat tes.

## Fitur Tahap 4 yang terlihat saat demo (2026-11-23)
- Layar **Misi**: Daily Quest "3 aksi hari ini" dengan bar progres, hadiah +15 XP otomatis saat selesai (Win-State #4), target mingguan 5 aksi, dan **Mystery Chest** 1x/hari (undian XP/freeze/dekorasi/fakta, dialog hadiah).
- Layar **Dampak**: total gram + padanan sedotan, grafik bar 7 hari (fl_chart), tombol share kartu dampak (simulasi toast).
- Streak freeze dari chest langsung dipakai logika aksi (gap 1 hari terselamatkan).

## Fitur Tahap 5 yang terlihat saat demo (2026-11-23)
- **Komunitas** (mock): counter kolektif nasional, leaderboard teman, tim + kontribusi, tantangan; tombol ke Hadiah.
- **Hadiah** (mock): voucher dengan bar kuota terbatas + disclaimer simulasi, tombol tukar → toast simulasi.
- **Koleksi**: spesies terbuka otomatis berdasar total aksi (kunci + syarat terlihat), dekorasi dari chest, badge dengan nama.
- **Profil & Demo Mode**: gelar (Calon Penyelam → Penyelam Baru → Penjaga Karang), switch notifikasi (UI), maju 1/7 hari, isi data contoh 2 minggu (28 aksi), reset total → kembali ke splash.

## Fitur Tahap 6 yang terlihat saat demo (2026-11-23)
- Mini-game **Pilah Cepat** 30 detik: 10 item diacak (seed deterministik), dua tombol kategori, skor → XP bonus via addBonusXp; diakses dari banner event di Misi dan dari Profil.
- Banner **Event Musiman** (spesies musiman simulasi, CD6) di layar Misi.
- Layar **Tentang Desain Octalysis**: radar chart 8 Core Drives (target §4.2) + kartu keseimbangan White/Black Hat — siap untuk pitch.
- Alur demo lengkap §6.2 teruji lewat tes widget (73 tes).

## Fitur Tahap 2 yang terlihat saat demo (2026-11-23)
- Alur onboarding penuh: Splash bernarasi → 3 slide intro → **Glowing Choice** (4 kartu besar, "Bawa Tumbler" disarankan & terpilih otomatis) → nama + avatar → Home.
- Win-State #1: dialog "Terumbu pertamamu lahir!" sekali setelah onboarding; profil persist (flag `onboardingDone` untuk metrik §3.1).
- Home: terumbu prosedural (CustomPainter) dengan tahap Tunas→Ekosistem, bar XP, chip streak, tombol besar "Catat Aksi" (fungsi di Tahap 3).

## Keputusan aturan game yang disetujui pengguna (2026-11-23)
- Laju karang memudar: linear, mulai hari ke-4 tanpa aksi turun 25 poin kesehatan per hari, minimum 0; 1 aksi memulihkan penuh ke 100.
- Target mingguan: 12 aksi (revisi Unit A; sebelumnya 5).
- Nama prototipe: "Terumbu Kita" (working title).

## Revisi Unit A — mekanisme "1 aksi per jenis per hari" (2026-11-23)
- **Aturan inti:** tiap jenis aksi (6 jenis, spec §7.1) hanya bisa dicatat 1× per hari kalender (via `Clock`, Demo Mode ikut). Batas lama "10 aksi/hari" dihapus — keberagaman, bukan frekuensi, yang dihargai (CD2: tantangan harian jadi "selesaikan variasi", bukan spam).
- **Plafon XP harian:** 55 XP aksi + 10 XP Hari Sempurna + 15 XP Daily Quest = maks 80/hari.
- **Hari Sempurna:** keenam jenis tercatat dalam satu hari → +10 XP + pesan perayaan (CD2 + CD7: target yang jarang tercapai memberi kejutan).
- **Daily Quest rotasi 2 hari** (CD7: variasi harian mencegah kebosanan): genap → "Catat 3 aksi bebas plastik hari ini"; gasal → "Coba 2 jenis aksi yang belum kamu catat 3 hari terakhir".
- **Ambang tahap terumbu** diturunkan agar sesuai ritme baru: Tunas 0–5, Tumbuh 6–17, Subur 18–39, Ekosistem 40+ (CD4/CD2: pertumbuhan terasa di 2 minggu uji).
- **Catatan aksi lama tidak ditulis ulang:** status "selesai hari ini" dihitung dari log hari ini; generator data contoh mematuhi aturan baru.

## Catatan
- Black Hat (CD6–8) tidak boleh menghukum: pesan kehilangan bernada ajakan, streak freeze selalu tersedia maks 2.
- Teks UI: `lib/core/constants/app_strings.dart`; angka game: `lib/core/constants/game_rules.dart`; angka dampak: `lib/core/constants/impact_constants.dart` (asumsi, perlu sumber).
