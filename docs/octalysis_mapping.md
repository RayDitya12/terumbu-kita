// Pemetaan fitur aplikasi → 8 Core Drives Octalysis (agent.md §3.8 traceability).
// Diperbarui setiap kali fitur gamifikasi dibuat. Sumber: spec.md §4–5.

# Octalysis Mapping — Terumbu Kita

Status kolom: `belum` = belum ada kode, `sebagian` = ada tapi belum lengkap, `jadi` = terlihat & berfungsi di prototipe.

| CD | Core Drive | Fitur (spec §5) | Layar | Status | File kode |
|---|---|---|---|---|---|
| CD1 | Epic Meaning & Calling | Narasi "Jaga laut Indonesia", counter kolektif, kartu fakta | Splash, Home, Komunitas | sebagian | `features/onboarding/presentation/splash_screen.dart` (narasi); counter belum |
| CD2 | Development & Accomplishment | XP, level, badge, target mingguan, progress terumbu | Log Aksi, Home | sebagian | `core/utils/game_logic.dart`, `features/home` (bar XP statis) |
| CD3 | Empowerment of Creativity & Feedback | Glowing Choice, pilih tantangan, dekorasi | Onboarding, Koleksi | sebagian | `features/onboarding/presentation/glowing_choice_screen.dart`; dekorasi belum |
| CD4 | Ownership & Possession | Terumbu pribadi, koleksi spesies/dekorasi | Home, Koleksi | sebagian | `shared/widgets/reef_painter.dart` (terumbu tumbuh per tahap) |
| CD5 | Social Influence & Relatedness | Leaderboard mock, tim, share kartu | Komunitas, Dampak | sebagian | `splash_screen.dart` (sinyal "teman bergabung" mock); leaderboard belum |
| CD6 | Scarcity & Impatience | Spesies musiman, voucher kuota terbatas | Event, Hadiah | belum | Tahap 5/6 |
| CD7 | Unpredictability & Curiosity | Mystery Chest, fakta acak, mini-game | Quest, Home | belum | Tahap 4/6 |
| CD8 | Loss & Avoidance | Karang memudar (−25/hari mulai hari ke-4, pulih dgn 1 aksi), streak + freeze | Home | sebagian | `core/constants/game_rules.dart`; visual memudar belum aktif |

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
