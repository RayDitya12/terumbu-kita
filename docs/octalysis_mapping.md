// Pemetaan fitur aplikasi → 8 Core Drives Octalysis (agent.md §3.8 traceability).
// Diperbarui setiap kali fitur gamifikasi dibuat. Sumber: spec.md §4–5.

# Octalysis Mapping — Terumbu Kita

Status kolom: `belum` = belum ada kode, `sebagian` = ada tapi belum lengkap, `jadi` = terlihat & berfungsi di prototipe.

| CD | Core Drive | Fitur (spec §5) | Layar | Status | File kode |
|---|---|---|---|---|---|
| CD1 | Epic Meaning & Calling | Narasi "Jaga laut Indonesia", counter kolektif, kartu fakta | Splash, Home, Komunitas | belum | Tahap 2/4 |
| CD2 | Development & Accomplishment | XP, level, badge, target mingguan, progress terumbu | Log Aksi, Home | sebagian | `core/constants/game_rules.dart` |
| CD3 | Empowerment of Creativity & Feedback | Glowing Choice, pilih tantangan, dekorasi | Onboarding, Koleksi | belum | Tahap 2 |
| CD4 | Ownership & Possession | Terumbu pribadi, koleksi spesies/dekorasi | Home, Koleksi | sebagian | `data/models/collection.dart` |
| CD5 | Social Influence & Relatedness | Leaderboard mock, tim, share kartu | Komunitas, Dampak | belum | Tahap 5 |
| CD6 | Scarcity & Impatience | Spesies musiman, voucher kuota terbatas | Event, Hadiah | belum | Tahap 5/6 |
| CD7 | Unpredictability & Curiosity | Mystery Chest, fakta acak, mini-game | Quest, Home | belum | Tahap 4/6 |
| CD8 | Loss & Avoidance | Karang memudar (−25/hari mulai hari ke-4, pulih dgn 1 aksi), streak + freeze | Home | sebagian | `core/constants/game_rules.dart` |

## Keputusan aturan game yang disetujui pengguna (2026-11-23)
- Laju karang memudar: linear, mulai hari ke-4 tanpa aksi turun 25 poin kesehatan per hari, minimum 0; 1 aksi memulihkan penuh ke 100.
- Target mingguan: 5 aksi.
- Nama prototipe: "Terumbu Kita" (working title).

## Catatan
- Black Hat (CD6–8) tidak boleh menghukum: pesan kehilangan bernada ajakan, streak freeze selalu tersedia maks 2.
- Teks UI: `lib/core/constants/app_strings.dart`; angka game: `lib/core/constants/game_rules.dart`; angka dampak: `lib/core/constants/impact_constants.dart` (asumsi, perlu sumber).
