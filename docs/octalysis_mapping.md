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
| CD5 | Social Influence & Relatedness | Leaderboard mock, tim, share kartu | Komunitas, Dampak | sebagian | `splash_screen.dart` (sinyal "teman bergabung" mock); leaderboard belum |
| CD6 | Scarcity & Impatience | Spesies musiman, voucher kuota terbatas | Event, Hadiah | belum | Tahap 5/6 |
| CD7 | Unpredictability & Curiosity | Mystery Chest, fakta acak, mini-game | Quest, Home | belum | Tahap 4/6 |
| CD8 | Loss & Avoidance | Karang memudar (−25/hari mulai hari ke-4, pulih dgn 1 aksi), streak + freeze | Home | jadi | `core/utils/game_logic.dart` (`reefHealthOn` + pemulihan via aksi), `reef_painter.dart` (warna memudar) |

## Fitur Tahap 3 yang terlihat saat demo (2026-11-23)
- Layar **Catat Aksi**: 6 kartu aksi (XP per jenis sesuai spec §7.1), kebiasaan fokus dari Glowing Choice terpilih otomatis + label "Kebiasaan utamamu" (CD3), switch foto bukti simulasi (tanpa kamera).
- Logika penuh: XP + level-up berantai, streak + freeze (gap 1 hari terselamatkan, gap ≥2 putus), batas 10 aksi XP/hari (tetap dicatat tanpa XP, pesan non-punitif), karang pulih ke 100, memudar dihitung saat startup via Clock.
- Win-State #2: bottom sheet animasi (+XP, gram + padanan sedotan, streak, badge "Penyelam Baru"); Win-State #3 dipicu saat tahap terumbu/streak milestone naik.
- Home kini hidup: bar XP, streak, dan angka "plastik dihindari" terhubung ke data; terumbu bertambah besar saat total aksi melewati ambang tahap.
- Persistensi: ActionLog + badge Collection tersimpan lokal dan terverifikasi lewat tes.

## Fitur Tahap 2 yang terlihat saat demo (2026-11-23)
- Alur onboarding penuh: Splash bernarasi → 3 slide intro → **Glowing Choice** (4 kartu besar, "Bawa Tumbler" disarankan & terpilih otomatis) → nama + avatar → Home.
- Win-State #1: dialog "Terumbu pertamamu lahir!" sekali setelah onboarding; profil persist (flag `onboardingDone` untuk metrik §3.1).
- Home: terumbu prosedural (CustomPainter) dengan tahap Tunas→Ekosistem, bar XP, chip streak, tombol besar "Catat Aksi" (fungsi di Tahap 3).

## Keputusan aturan game yang disetujui pengguna (2026-11-23)
- Laju karang memudar: linear, mulai hari ke-4 tanpa aksi turun 25 poin kesehatan per hari, minimum 0; 1 aksi memulihkan penuh ke 100.
- Target mingguan: 5 aksi.
- Nama prototipe: "Terumbu Kita" (working title).

## Catatan
- Black Hat (CD6–8) tidak boleh menghukum: pesan kehilangan bernada ajakan, streak freeze selalu tersedia maks 2.
- Teks UI: `lib/core/constants/app_strings.dart`; angka game: `lib/core/constants/game_rules.dart`; angka dampak: `lib/core/constants/impact_constants.dart` (asumsi, perlu sumber).
