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
  static const homeComingSoon = 'Pencatatan aksi hadir di tahap berikutnya.';
  static const reefStageNames = {
    'tunas': 'Tunas Karang',
    'tumbuh': 'Karang Tumbuh',
    'subur': 'Terumbu Subur',
    'ekosistem': 'Ekosistem Laut',
  };

  // Win-State #1: terumbu pertama lahir (spec.md §3.3).
  static const winReefBornTitle = 'Terumbu pertamamu lahir!';
  static const winReefBornBody =
      'Mulai sekarang, setiap aksi bebas plastik akan menumbuhkannya.';
  static const winReefBornCta = 'Ayo mulai';

  // Placeholder layar yang belum dibangun (spec.md §12).
  static const placeholderQuest =
      'Daily Quest & Mystery Chest dibangun di Tahap 4.';
  static const placeholderImpact =
      'Grafik dampak mingguan dibangun di Tahap 4.';
  static const placeholderCommunity =
      'Leaderboard & tim (mock) dibangun di Tahap 5.';
  static const placeholderProfile =
      'Profil, Demo Mode, dan reset data dibangun di Tahap 5.';
}
