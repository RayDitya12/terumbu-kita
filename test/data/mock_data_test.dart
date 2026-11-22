import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/data/mock/mock_data.dart';

void main() {
  MockDataLoader loaderWith(Map<String, String> files) =>
      MockDataLoader(reader: (path) async => files[path] ?? 'invalid{');

  test('community.json termuat ke typed model', () async {
    final loader = loaderWith({
      'assets/mock/community.json':
          '{"campus":"UC","leaderboard":[{"name":"Rani","xp":10,"avatarId":1}],'
          '"teams":[],"nationalCounterGrams":99,"joinHint":"halo"}',
    });
    final data = await loader.loadCommunity();
    expect(data.campus, 'UC');
    expect(data.leaderboard.single.name, 'Rani');
    expect(data.nationalCounterGrams, 99);
  });

  test('rewards memberi daftar voucher + disclaimer simulasi', () async {
    final loader = loaderWith({
      'assets/mock/rewards.json':
          '{"vouchers":[{"id":"v1","title":"Diskon","partner":"P",'
          '"condition":"C","quotaTotal":10,"quotaLeft":3}],'
          '"disclaimer":"simulasi"}',
    });
    final data = await loader.loadRewards();
    expect(data.vouchers.single.quotaLeft, 3);
    expect(data.disclaimer, 'simulasi');
  });

  test('aset korup menghasilkan data kosong, bukan exception', () async {
    final loader = loaderWith({});
    expect((await loader.loadCommunity()).leaderboard, isEmpty);
    expect(await loader.loadFacts(), isEmpty);
    expect(await loader.loadSpecies(), isEmpty);
  });

  test('facts dan species termuat sebagai list', () async {
    final loader = loaderWith({
      'assets/mock/facts.json':
          '{"facts":[{"text":"a","source":"s"},{"text":"b"}]}',
      'assets/mock/species.json':
          '{"species":[{"id":"x","name":"X","rarity":"umum","minActions":0}]}',
    });
    final facts = await loader.loadFacts();
    expect(facts, hasLength(2));
    expect(facts[1].source, '');
    final species = await loader.loadSpecies();
    expect(species.single.name, 'X');
  });
}
