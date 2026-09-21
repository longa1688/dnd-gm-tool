import 'package:flutter_test/flutter_test.dart';
import 'package:gm_tool/models.dart';
import 'package:gm_tool/monster_model.dart';
import 'package:gm_tool/services/srd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('NPC.fromMap preserves level and parses numeric values from strings', () {
    final npc = NPC.fromMap({
      'name': 'Mira',
      'race': 'Elf',
      'role': 'Wizard',
      'level': '5',
      'hpMax': '24',
      'hpCurrent': '18',
      'str': '12',
      'dex': '14',
      'con': '13',
      'intl': '16',
      'wis': '10',
      'cha': '11',
    });

    expect(npc.level, 5);
    expect(npc.hpMax, 24);
    expect(npc.hpCurrent, 18);
    expect(npc.str, 12);
    expect(npc.intl, 16);
  });

  test('MonsterSummary.fromJson parses string values and list armor values', () {
    final monster = MonsterSummary.fromJson({
      'index': 'goblin',
      'name': 'Goblin',
      'type': 'humanoid',
      'challenge_rating': '0.25',
      'hit_points': '7',
      'armor_class': [
        {'type': 'natural', 'value': 15},
      ],
      'strength': '8',
      'dexterity': '14',
      'constitution': '10',
      'intelligence': '10',
      'wisdom': '8',
      'charisma': '8',
      'actions': [
        {'name': 'Scimitar', 'desc': 'Melee attack.'},
      ],
    });

    expect(monster.challengeRating, 0.25);
    expect(monster.hitPoints, 7);
    expect(monster.armorClass, 15);
    expect(monster.actions, isNotEmpty);
    expect(monster.name, 'Goblin');
  });

  test('Combatant round-trip keeps initiative and villain state', () {
    final original = Combatant(
      name: 'Boss',
      initiative: 18,
      hpCurrent: 42,
      hpMax: 50,
      isVillain: true,
    );

    final encoded = Combatant.encode([original]);
    final decoded = Combatant.decode(encoded);

    expect(decoded, hasLength(1));
    expect(decoded.first.name, 'Boss');
    expect(decoded.first.initiative, 18);
    expect(decoded.first.isVillain, isTrue);
  });

  test('SrdService loads versioned data from the selected SRD', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_version', '2024');

    final service = SrdService();
    final backgrounds = await service.loadBackgrounds();
    final races = await service.loadRaces();

    expect(backgrounds, isNotEmpty);
    expect(races, isNotEmpty);
    expect(backgrounds.first['name'], isA<String>());
    expect(backgrounds.map((item) => item['name']), contains('Wayfarer'));

    await prefs.setString('game_version', '2014');
    final classicBackgrounds = await service.loadBackgrounds();
    expect(classicBackgrounds.map((item) => item['name']), contains('Urchin'));
  });

  test('SrdService completes the small 2024 monster snapshot with 2014 monsters', () async {
    final service = SrdService();
    final monsters2024 = await service.loadMonstersForVersion('2024');
    final monsters2014 = await service.loadMonstersForVersion('2014');

    expect(monsters2024.length, equals(monsters2014.length));
    expect(monsters2024.map((monster) => monster.index), contains('aboleth'));
    expect(monsters2024.map((monster) => monster.index), contains('adult-black-dragon'));
  });
}
