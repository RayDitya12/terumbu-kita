import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';
import 'package:terumbu_kita/data/repositories/local_storage_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LocalStorageRepository> repoWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return LocalStorageRepository.create();
  }

  group('LocalStorageRepository', () {
    test('data kosong mengembalikan default tanpa crash', () async {
      final repo = await repoWith({});
      expect(await repo.loadProfile(), isNull);
      expect(await repo.loadProgress(), const Progress());
      expect(await repo.loadActionLogs(), isEmpty);
      expect(await repo.loadQuests(), isEmpty);
      expect(await repo.loadSettings().then((s) => s.demoMode), isFalse);
    });

    test('round-trip profil, progres, log, pengaturan', () async {
      final repo = await repoWith({});
      final profile = UserProfile(
        nickname: 'Dimas',
        avatarId: 1,
        focusHabit: ActionType.tumbler,
        onboardingDone: true,
        createdAt: DateTime(2026, 11, 1),
      );
      await repo.saveProfile(profile);
      await repo.saveProgress(const Progress(xp: 75, level: 2, streak: 3));
      await repo.saveActionLogs([
        ActionLog(
          id: 'x',
          actionType: 'tumbler',
          timestamp: DateTime(2026, 11, 23),
          xpGained: 10,
          plasticGrams: 30,
        ),
      ]);
      await repo.saveSettings(const AppSettings(demoMode: true));

      expect((await repo.loadProfile())?.nickname, 'Dimas');
      expect((await repo.loadProgress()).level, 2);
      expect((await repo.loadActionLogs()).single.id, 'x');
      expect((await repo.loadSettings()).demoMode, isTrue);
    });

    test('json korup jatuh ke default, bukan melempar', () async {
      final repo = await repoWith({
        'terumbu.profile': 'bukan json{',
        'terumbu.progress': '["juga bukan map"]',
        'terumbu.actionLogs': '{"bukan":"list"}',
      });
      expect(await repo.loadProfile(), isNull);
      expect(await repo.loadProgress(), const Progress());
      expect(await repo.loadActionLogs(), isEmpty);
    });

    test('clearAll menghapus semua kunci game', () async {
      final repo = await repoWith({});
      await repo.saveSettings(const AppSettings(simulatedDateOffsetDays: 7));
      expect((await repo.loadSettings()).simulatedDateOffsetDays, 7);
      await repo.clearAll();
      expect((await repo.loadSettings()).simulatedDateOffsetDays, 0);
    });

    test('list action log tersimpan sebagai json valid', () async {
      final repo = await repoWith({});
      await repo.saveActionLogs([
        ActionLog(
          id: 'y',
          actionType: 'no_straw',
          timestamp: DateTime(2026, 11, 23, 7, 30),
          xpGained: 5,
          plasticGrams: 1,
        ),
      ]);
      final raw = SharedPreferences.getInstance().then(
        (p) => p.getString('terumbu.actionLogs'),
      );
      final decoded = jsonDecode((await raw)!) as List;
      expect(decoded.single['id'], 'y');
    });
  });
}
