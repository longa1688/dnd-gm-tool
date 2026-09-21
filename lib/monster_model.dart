class MonsterSummary {
  final String index;
  final String name;
  final String type;
  final double challengeRating;
  final int hitPoints;
  final int armorClass;
  
  // Statistiche aggiuntive
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final List<Map<String, dynamic>> actions;

  MonsterSummary({
    required this.index,
    required this.name,
    required this.type,
    required this.challengeRating,
    required this.hitPoints,
    required this.armorClass,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.actions,
  });

  factory MonsterSummary.fromJson(Map<String, dynamic> json) {
    final String index = json['index'] as String? ?? '';
    final String name = json['name'] as String? ?? 'Sconosciuto';
    final String type = (json['type'] as String? ?? 'sconosciuto').toLowerCase();

    double challengeRating = 0.0;
    final challengeValue = json['challenge_rating'];
    if (challengeValue is num) {
      challengeRating = challengeValue.toDouble();
    } else if (challengeValue is String) {
      challengeRating = double.tryParse(challengeValue) ?? 0.0;
    }

    int hitPoints = 10;
    final hitPointsValue = json['hit_points'];
    if (hitPointsValue is num) {
      hitPoints = hitPointsValue.toInt();
    } else if (hitPointsValue is String) {
      hitPoints = int.tryParse(hitPointsValue) ?? 10;
    }

    int armorClass = 10;
    final armorValue = json['armor_class'];
    if (armorValue is int) {
      armorClass = armorValue;
    } else if (armorValue is num) {
      armorClass = armorValue.toInt();
    } else if (armorValue is String) {
      armorClass = int.tryParse(armorValue) ?? 10;
    } else if (armorValue is List && armorValue.isNotEmpty) {
      final dynamic firstArmorClassEntry = armorValue.first;
      if (firstArmorClassEntry is Map<String, dynamic> && firstArmorClassEntry.containsKey('value')) {
        final value = firstArmorClassEntry['value'];
        if (value is num) {
          armorClass = value.toInt();
        } else if (value is String) {
          armorClass = int.tryParse(value) ?? 10;
        }
      }
    }

    final actions = (json['actions'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return MonsterSummary(
      index: index,
      name: name,
      type: type,
      challengeRating: challengeRating,
      hitPoints: hitPoints,
      armorClass: armorClass,
      strength: (json['strength'] is num) ? (json['strength'] as num).toInt() : 10,
      dexterity: (json['dexterity'] is num) ? (json['dexterity'] as num).toInt() : 10,
      constitution: (json['constitution'] is num) ? (json['constitution'] as num).toInt() : 10,
      intelligence: (json['intelligence'] is num) ? (json['intelligence'] as num).toInt() : 10,
      wisdom: (json['wisdom'] is num) ? (json['wisdom'] as num).toInt() : 10,
      charisma: (json['charisma'] is num) ? (json['charisma'] as num).toInt() : 10,
      actions: actions,
    );
  }
}