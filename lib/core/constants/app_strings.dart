/// Seluruh teks yang tampil ke pengguna disimpan di sini (agent.md §2.5).
/// Bahasa Indonesia saja. Jangan hardcode teks di widget.
library;

abstract final class AppStrings {
  // Identitas — "Terumbu Kita" adalah nama sementara (spec.md §13.1).
  static const appName = 'Terumbu Kita';
  static const appTagline = 'Satu aksi bebas plastik, satu karang tumbuh.';

  // Navigasi bawah (spec.md §6.3).
  static const navHome = 'Rumah';
  static const navQuest = 'Misi';
  static const navImpact = 'Dampak';
  static const navCommunity = 'Komunitas';
  static const navProfile = 'Profil';

  // Splash / Discovery (spec.md §6.1, §4.4 fase 1).
  static const splashNarration =
      'Terlalu banyak plastik sekali pakai berakhir di laut Indonesia. '
      'Kebiasaan kecilmu bisa memulihkannya.';
  static const splashJoinHint = '34 teman sekampusmu sudah bergabung';
  static const splashCta = 'Mulai Perjalanan';

  // Slide intro onboarding (spec.md §6.1).
  static const introSlide1Title = 'Kenapa terumbu karang?';
  static const introSlide1Body =
      'Karang adalah rumah bagi ribuan ikan. Saat plastik menumpuk, '
      'karang memudar dan ikan kehilangan rumahnya.';
  static const introSlide2Title = 'Aksimu, karangmu';
  static const introSlide2Body =
      'Setiap kali kamu menolak plastik sekali pakai, terumbu karang '
      'pribadimu tumbuh dan semakin hidup.';
  static const introSlide3Title = 'Mulai dari satu kebiasaan';
  static const introSlide3Body =
      'Tidak perlu sempurna. Pilih satu kebiasaan kecil, kami bantu kamu '
      'konsisten.';
  static const introNext = 'Lanjut';
  static const introStart = 'Ayo, pilih kebiasaan pertamaku';

  // Glowing Choice (spec.md §3.4.1). CD3: satu pilihan terang, tanpa formulir.
  static const choicePrompt = 'Mulai dari kebiasaan mana?';
  static const choiceRecommended = 'Disarankan untuk pemula';
  static const choiceConfirm = 'Mulai dengan kebiasaan ini';

  // Deskripsi fokus kebiasaan, per ActionType.id.
  static const habitLabels = {
    'tumbler': 'Bawa Tumbler',
    'tote': 'Bawa Tas Belanja',
    'no_straw': 'Tolak Sedotan',
    'own_container': 'Bawa Wadah Makan',
  };
  static const habitDescriptions = {
    'tumbler': 'Isi ulang minuman dengan botol/gelas sendiri.',
    'tote': 'Tolak kantong plastik, pakai tas sendiri.',
    'no_straw': 'Langsung minum dari gelasnya, tanpa sedotan.',
    'own_container': 'Kebiasan lama yang paling hemat plastik.',
  };

  // Input profil (spec.md §6.1 layar 2).
  static const profileTitle = 'Hampir selesai!';
  static const profileNicknameLabel = 'Nama panggilan';
  static const profileNicknameHint = 'Contoh: Rani';
  static const profileAvatarLabel = 'Pilih avatarmu';
  static const profileDone = 'Lahirnya terumbuku';

  // Home / Terumbu (spec.md §6.1 layar 3).
  static const homeGreetingPrefix = 'Hai';
  static const homeLevel = 'Level';
  static const homeStreakDays = 'hari beruntun';
  static const homeImpactCompact = 'plastik dihindari';
  static const homeLogAction = 'Catat Aksi';
  static const reefStageNames = {
    'tunas': 'Tunas Karang',
    'tumbuh': 'Karang Tumbuh',
    'subur': 'Terumbu Subur',
    'ekosistem': 'Ekosistem Laut',
  };

  // Catat Aksi (spec.md §6.1 layar 4).
  static const logActionTitle = 'Aksi apa yang baru kamu lakukan?';
  static const logActionSubtitle =
      'Satu centang kecil = satu langkah nyata untuk laut.';
  static const actionLabels = {
    'tumbler': 'Bawa Tumbler',
    'tote': 'Bawa Tas Belanja',
    'no_straw': 'Tolak Sedotan',
    'own_container': 'Bawa Wadah Makan',
    'refill': 'Isi Ulang Minuman',
    'no_cutlery': 'Tolak Alat Makan Plastik',
  };
  static const logActionRecommended = 'Kebiasaan utamamu';
  static const logActionDoneToday = 'Selesai hari ini';
  static const logActionAlreadyLogged =
      'Aksi ini sudah tercatat hari ini. Satu centang per hari sudah cukup!';
  static const logActionAllDone =
      'Semua aksi tercatat hari ini. Karangmu tumbuh — sampai jumpa besok!';
  static const logActionCancel = 'Batalkan aksi terakhir hari ini';
  static const logActionCancelDone = 'Aksi terakhir dibatalkan.';
  static const logActionCancelGone =
      'Aksi terakhir tidak lagi bisa dibatalkan.';
  static const logActionPhoto = 'Lampirkan foto bukti (simulasi)';
  static const logActionPhotoNote =
      'Foto hanya simulasi prototipe, tidak memakai kamera.';
  static const logActionSubmit = 'Simpan aksi';

  // Win-State #2: animasi setelah aksi dicatat (spec.md §3.3).
  static String winActionXp(int xp) => xp > 0 ? '+$xp XP' : 'Aksi tercatat';
  static const winActionImpactLabel = 'plastik dihindari aksi ini';
  static const winActionStreakLabel = 'hari beruntun';
  static const winActionFreezeNote =
      'Streak terselamatkan oleh streak freeze. Hebat, kamu konsisten!';
  static const winActionLevelUp = 'Naik level! Sekarang Level ';
  static const winActionBadgeNewDiver = 'Badge "Penyelam Baru" terbuka!';
  static const winActionPerfectDay =
      'Hari Sempurna! Semua 6 jenis aksi tercatat — bonus +10 XP.';
  static const winActionCta = 'Lihat terumbuku';

  static const badgeNames = {
    'penyelam_baru': 'Penyelam Baru',
    'streak_3': 'Konsisten 3 Hari',
    'streak_7': 'Konsisten 7 Hari',
    'streak_30': 'Konsisten 30 Hari',
    'stage_tumbuh': 'Karang Tumbuh',
    'stage_subur': 'Terumbu Subur',
    'stage_ekosistem': 'Ekosistem Laut',
  };

  // Win-State #1: terumbu pertama lahir (spec.md §3.3).
  static const winReefBornTitle = 'Terumbu pertamamu lahir!';
  static const winReefBornBody =
      'Mulai sekarang, setiap aksi bebas plastik akan menumbuhkannya.';
  static const winReefBornCta = 'Ayo mulai';

  // Placeholder layar yang belum dibangun (spec.md §12).
  static const placeholderCommunity =
      'Leaderboard & tim (mock) dibangun di Tahap 5.';
  static const placeholderProfile =
      'Profil, Demo Mode, dan reset data dibangun di Tahap 5.';

  // Quest harian & Mystery Chest (spec.md §6.1 layar 5).
  static const questTitle = 'Misi Harian';
  static const questDailyLoading = 'Misi harian hari ini';
  static const questDailyReward = 'Hadiah selesai: +15 XP';
  static const questCompleted = 'Selesai! Hadiah XP sudah masuk.';
  static const questProgressFormat = 'progress hari ini';
  static const questDailyThree = 'Catat 3 aksi bebas plastik hari ini';
  static const questDailyVariety =
      'Coba 2 jenis aksi yang belum kamu catat 3 hari terakhir';
  static const questWeeklyTitle = 'Target Mingguan';
  static const questWeeklyBody = 'Kumpulkan 12 aksi minggu ini.';
  static const questWeeklyDone =
      'Target mingguan tercapai! Spesies baru menantimu di Koleksi.';
  static const chestOpen = 'Buka Mystery Chest';
  static const chestLockedHint =
      'Selesaikan misi harian dulu untuk membuka chest hari ini.';
  static const chestOpenedToday =
      'Chest hari ini sudah dibuka. Sampai jumpa besok!';
  static const chestRewardTitle = 'Isi chest untukmu:';
  static const chestRewardXp = 'bonus XP dari laut.';
  static const chestRewardFreeze =
      'Streak freeze! Satu hari terlewat tidak akan memutus streak.';
  static const chestRewardDecoration = 'Dekorasi terumbu baru tersimpan.';
  static const chestRewardFact = 'Fakta laut baru untukmu:';

  // Layar Dampak (spec.md §6.1 layar 7).
  static const impactTitle = 'Dampak Nyata Aksimu';
  static const impactTotalLabel = 'total plastik dihindari';
  static const impactWeekLabel = '7 hari terakhir (gram)';
  static const impactNoData =
      'Belum ada aksi tercatat. Satu aksi pun sudah berarti.';
  static const impactShare = 'Bagikan kartu dampak';
  static const impactShareMock =
      'Kartu dampak (simulasi prototipe) siap dibagikan.';

  // Komunitas (spec.md §6.1 layar 9, mock §7.4).
  static const communityTitle = 'Komunitas';
  static const communityNationalLabel = 'Plastik dihindari bersama (mock)';
  static const communityLeaderboard = 'Peringkat Teman Kampus';
  static const communityTeams = 'Tim Karang';
  static const communityChallenges = 'Tantangan Bersama';
  static const communityChallengeBody =
      'Kumpulkan 500 aksi se-kampus minggu ini untuk membuka spesies musiman.';
  static const communityRewardsLink = 'Lihat Hadiah';

  // Hadiah (spec.md §6.1 layar 10, mock).
  static const rewardsTitle = 'Hadiah';
  static const rewardsRedeem = 'Tukar';
  static const rewardsQuotaLabel = 'kuota tersisa';
  static const rewardsRedeemMock =
      'Penukaran voucher hanya simulasi prototipe.';

  // Koleksi (spec.md §6.1 layar 8).
  static const collectionTitle = 'Koleksi';
  static const collectionSpecies = 'Spesies Karang';
  static const collectionDecorations = 'Dekorasi';
  static const collectionBadges = 'Badge';
  static const collectionLocked = 'Terkunci';
  static const collectionSpeciesHint = 'Terbuka pada ';
  static const collectionSpeciesHintSuffix = ' aksi';

  // Profil & Pengaturan + Demo Mode (spec.md §6.1 layar 11, §8).
  static const profileScreenTitle = 'Profil & Pengaturan';
  static const profileTitleLabel = 'Gelar';
  static const profileNotifications = 'Notifikasi pengingat (UI saja)';
  static const profileQualityTitle = 'Kualitas efek';
  static const profileQualityFull = 'Penuh';
  static const profileQualityHemat = 'Hemat';
  static const profileQualityHint =
      'Hemat memakai cahaya alternatif dan separuh gelembung.';
  static const profileCollectionLink = 'Buka Koleksi';
  static const profileRewardsLink = 'Buka Hadiah';
  static const demoModeTitle = 'Demo Mode';
  static const demoModeSubtitle =
      'Untuk presentasi: geser waktu dan isi data contoh.';
  static const demoAdvance1 = 'Maju 1 hari';
  static const demoAdvance7 = 'Maju 7 hari';
  static const demoBack1 = 'Mundur 1 hari';
  static const demoBack7 = 'Mundur 7 hari';
  static const demoSampleData = 'Isi data contoh 2 minggu';
  static const demoReset = 'Reset semua data';
  static const demoOffsetLabel = 'Offset waktu saat ini: ';
  static const demoOffsetDays = ' hari';

  // Mini-game "Pilah Cepat" (spec.md §6.1 layar 6).
  static const miniGameTitle = 'Pilah Cepat';
  static const miniGamePrompt =
      'Termasuk sekali pakai atau bisa dipakai ulang?';
  static const miniGameOnce = 'Sekali Pakai';
  static const miniGameReuse = 'Bisa Dipakai Ulang';
  static const miniGameScore = 'Skor: ';
  static String miniGameScoreText(int score) => '$miniGameScore$score/10';
  static String miniGameRewardNote(int xp) =>
      'Benar semua? $xp XP menanti. Mini-game ini simulasi ringan '
      'berbasis pengetahuan, bukan aksi nyata.';
  static const miniGameClaim = 'Ambil XP';

  // Event musiman (spec.md §6.1, CD6).
  static const eventTitle = 'Event Musiman';
  static const eventBody =
      'Spesies musiman "Karang Bulan" terbuka untuk aksi di akhir pekan '
      'ini. (Simulasi prototipe)';
  static const eventCta = 'Main Pilah Cepat untuk info';

  // Tentang Desain Octalysis (spec.md §6.1 layar 12, opsional).
  static const octalysisTitle = 'Tentang Desain Octalysis';
  static const octalysisIntro =
      'Delapan motivasi dasar (Core Drives) yang dipakai aplikasi ini, '
      'skala 0-10 sesuai target desain tim.';
}
