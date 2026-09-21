import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../monster_model.dart';

class SrdService {
  static const String _gameVersionKey = 'game_version';

  Future<String> selectedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gameVersionKey) ?? '2014';
  }

  Future<String> _loadJsonFromPath(String fileName, {String? preferredVersion}) async {
    final cleanFileName = fileName.split('/').last;
    final versions = [preferredVersion, '2014', '2024'];

    for (final version in versions.whereType<String>()) {
      try {
        return await rootBundle.loadString('assets/$version/$cleanFileName');
      } catch (_) {
        // Continue to the next supported version.
      }
    }

    throw FlutterError('File SRD non trovato: $cleanFileName');
  }

  Future<String> loadJsonData(String fileName) async {
    return loadJsonDataForVersion(fileName, await selectedVersion());
  }

  Future<String> loadJsonDataForVersion(String fileName, String version) async {
    try {
      return await _loadJsonFromPath(fileName, preferredVersion: version);
    } catch (e) {
      debugPrint('File non trovato in $version, fallback su asset disponibili: $e');
      return await _loadJsonFromPath(fileName);
    }
  }

  Future<bool> isSrdDownloaded(String version) async => true;
  Future<void> downloadAndExtractSrd({required String version, required Function(double) onProgress}) async {}

  Future<List<MonsterSummary>> loadMonsters() async {
    final version = await selectedVersion();
    return loadMonstersForVersion(version);
  }

  Future<List<MonsterSummary>> loadMonstersForVersion(String version) async {
    try {
      final jsonData = await rootBundle.loadString(
        'assets/$version/5e-SRD-Monsters.json',
      );

      final List<dynamic> jsonList = json.decode(jsonData);
      final List<MonsterSummary> monsters = jsonList
          .map((item) => MonsterSummary.fromJson(item as Map<String, dynamic>))
          .toList();

      // The local 2024 SRD snapshot is intentionally small. Complete it
      // with 2014 entries, while keeping 2024 entries when indexes overlap.
      if (version == '2024' && monsters.length < 10) {
        final fallbackJson = await rootBundle.loadString(
          'assets/2014/5e-SRD-Monsters.json',
        );
        final fallback = (json.decode(fallbackJson) as List<dynamic>)
            .map((item) => MonsterSummary.fromJson(item as Map<String, dynamic>))
            .where((monster) => !monsters.any((item) => item.index == monster.index))
            .toList();
        monsters.addAll(fallback);
      }

      monsters.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return monsters;
    } catch (e) {
      debugPrint('Errore nel caricamento dei mostri: $e');
      return [];
    }
  }

  Future<List<dynamic>> loadRaces() async {
    return loadRacesForVersion(await selectedVersion());
  }

  Future<List<dynamic>> loadRacesForVersion(String version) async {
    final String response = version == '2024'
        ? await loadJsonDataForVersion('5e-SRD-Species.json', '2024')
        : await loadJsonDataForVersion('5e-SRD-Races.json', '2014');
    final data = json.decode(response);
    if (data is List && data.isNotEmpty) return data;

    final speciesResponse = await loadJsonDataForVersion('5e-SRD-Species.json', version);
    final species = json.decode(speciesResponse);
    return species is List ? species : const [];
  }

  Future<List<dynamic>> loadClasses() async {
    return loadClassesForVersion(await selectedVersion());
  }

  Future<List<dynamic>> loadClassesForVersion(String version) async {
    final String response = await loadJsonDataForVersion('5e-SRD-Classes.json', version);
    final data = json.decode(response);
    return data is List ? data : const [];
  }

  Future<List<dynamic>> loadBackgrounds() async {
    return loadBackgroundsForVersion(await selectedVersion());
  }

  Future<List<dynamic>> loadBackgroundsForVersion(String version) async {
    List<dynamic> loaded = const [];
    try {
      final String response = await loadJsonDataForVersion('5e-SRD-Backgrounds.json', version);
      final data = json.decode(response);

      if (data is List && data.isNotEmpty) {
        loaded = data;
      } else if (data is Map && data['results'] is List && (data['results'] as List).isNotEmpty) {
        loaded = data['results'] as List<dynamic>;
      }
    } catch (e) {
      developer.log('Errore caricamento background da file, uso fallback: $e', name: 'SrdService');
    }

    final catalog = version == '2024'
        ? _backgroundCatalog2024
        : _backgroundCatalog2014;
    final byName = <String, dynamic>{
      for (final item in catalog) item['name'] as String: item,
    };
    for (final item in loaded.whereType<Map>()) {
      final name = item['name']?.toString();
      if (name != null && name.isNotEmpty) {
        byName[name] = Map<String, dynamic>.from(item);
      }
    }
    return byName.values.toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  static const List<Map<String, dynamic>> _backgroundCatalog2014 = [
    {'name': 'Acolyte'}, {'name': 'Charlatan'}, {'name': 'Criminal'},
    {'name': 'Entertainer'}, {'name': 'Folk Hero'}, {'name': 'Guild Artisan'},
    {'name': 'Hermit'}, {'name': 'Noble'}, {'name': 'Outlander'},
    {'name': 'Sage'}, {'name': 'Sailor'}, {'name': 'Soldier'}, {'name': 'Urchin'},
  ];

  static const List<Map<String, dynamic>> _backgroundCatalog2024 = [
    {'name': 'Acolyte'}, {'name': 'Artisan'}, {'name': 'Charlatan'},
    {'name': 'Criminal'}, {'name': 'Entertainer'}, {'name': 'Farmer'},
    {'name': 'Guard'}, {'name': 'Guide'}, {'name': 'Hermit'},
    {'name': 'Merchant'}, {'name': 'Noble'}, {'name': 'Sage'},
    {'name': 'Sailor'}, {'name': 'Scribe'}, {'name': 'Soldier'},
    {'name': 'Wayfarer'},
  ];
}