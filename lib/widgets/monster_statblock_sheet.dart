import 'package:flutter/material.dart';

// Placeholder for MonsterDetail, as its actual definition is not provided.
// This class is defined here to make the MonsterStatblockSheet widget self-contained
// and runnable for demonstration purposes. In a real application, this would
// likely be imported from a data model file.
class MonsterDetail {
  final String name;
  final String size;
  final String type;
  final String alignment;
  final List<dynamic> armorClass; // e.g., [15, {'type': 'natural armor'}] or [13]
  final int hitPoints;
  final String hitDice;
  final Map<String, dynamic> speed; // e.g., {'walk': 30, 'fly': 60}
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final List<Map<String, String>> actions;
  final List<Map<String, String>> specialAbilities; // traits like Nimble Escape
  final List<Map<String, String>> legendaryActions;
  final List<String> senses; // e.g., ['Darkvision 60 ft.', 'Passive Perception 9']
  final List<String> languages;
  final String challengeRating; // e.g., "1/4 (50 XP)"

  MonsterDetail({
    required this.name,
    required this.size,
    required this.type,
    required this.alignment,
    required this.armorClass,
    required this.hitPoints,
    required this.hitDice,
    required this.speed,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    this.actions = const [],
    this.specialAbilities = const [],
    this.legendaryActions = const [],
    this.senses = const [],
    this.languages = const [],
    required this.challengeRating,
  });

  // Example factory constructor for testing
  factory MonsterDetail.example() {
    return MonsterDetail(
      name: 'Drago Rosso Giovane',
      size: 'Large',
      type: 'Drago',
      alignment: 'Caotico Malvagio',
      armorClass: [18, {'type': 'Armatura Naturale'}],
      hitPoints: 178,
      hitDice: '17d10 + 85',
      speed: {'walk': 40, 'fly': 80, 'burrow': 20},
      strength: 23,
      dexterity: 10,
      constitution: 21,
      intelligence: 14,
      wisdom: 11,
      charisma: 19,
      specialAbilities: [
        {
          'name': 'Fearsome Presence',
          'desc':
              'Each creature of the dragon\'s choice that is within 120 feet of the dragon and aware of it must succeed on a DC 16 Wisdom saving throw or become frightened for 1 minute. A creature can repeat the saving throw at the end of each of its turns, ending the effect on itself on a success. If a creature\'s saving throw is successful or the effect ends for it, the creature is immune to the dragon\'s Fearsome Presence for the next 24 hours.',
        },
        {
          'name': 'Legendary Resistance (3/Day)',
          'desc':
              'If the dragon fails a saving throw, it can choose to succeed instead.',
        }
      ],
      actions: [
        {
          'name': 'Multiattack',
          'desc':
              'The dragon can use its Fearsome Presence. It then makes three attacks: one with its bite and two with its claws.',
        },
        {
          'name': 'Bite',
          'desc':
              'Melee Weapon Attack: +10 to hit, reach 10 ft., one target. Hit: 17 (2d10 + 6) piercing damage plus 7 (2d6) fire damage.',
        },
        {
          'name': 'Claw',
          'desc':
              'Melee Weapon Attack: +10 to hit, reach 5 ft., one target. Hit: 13 (2d6 + 6) slashing damage.',
        },
        {
          'name': 'Fire Breath (Recharge 5-6)',
          'desc':
              'The dragon exhales fire in a 30-foot cone. Each creature in that area must make a DC 18 Dexterity saving throw, taking 56 (16d6) fire damage on a failed save, or half as much damage on a successful one.',
        }
      ],
      legendaryActions: [
        {
          'name': 'Detect',
          'desc': 'The dragon makes a Wisdom (Perception) check.',
        },
        {
          'name': 'Tail Attack',
          'desc':
              'The dragon makes one tail attack. (+10 to hit, reach 15 ft., one target. Hit: 15 (2d8 + 6) bludgeoning damage.)',
        },
        {
          'name': 'Wing Attack (Costs 2 Actions)',
          'desc':
              'The dragon beats its wings. Each creature within 10 feet of the dragon must succeed on a DC 18 Dexterity saving throw or take 13 (2d6 + 6) bludgeoning damage and be knocked prone. The dragon can then fly up to half its flying speed.',
        },
      ],
      senses: ['Perception Passiva 21', 'Scurovisione 120 ft.'],
      languages: ['Draconico', 'Comune'],
      challengeRating: '10 (5,900 XP)',
    );
  }
}


class MonsterStatblockSheet extends StatelessWidget {
  final MonsterDetail monster;

  const MonsterStatblockSheet({super.key, required this.monster});

  // Helper to calculate attribute modifier
  String _getModifier(int score) {
    final int mod = (score - 10) ~/ 2;
    return '${mod >= 0 ? '+' : ''}$mod';
  }

  // Helper to format AC
  String _formatArmorClass(List<dynamic> ac) {
    if (ac.isEmpty) return 'N/A';
    String result = '${ac[0]}';
    if (ac.length > 1 && ac[1] is Map<String, dynamic> && ac[1]['type'] != null) {
      result += ' (${ac[1]['type']})';
    }
    return result;
  }

  // Helper to format speed
  String _formatSpeed(Map<String, dynamic> speed) {
    List<String> speedParts = [];
    speed.forEach((key, value) {
      speedParts.add('$key $value ft.');
    });
    return speedParts.join(', ');
  }



  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeHeader(String name) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeCell(int score) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(
          '$score (${_getModifier(score)})',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheda Mostro'),
        backgroundColor: Colors.red[900], // Themed AppBar
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.brown[50], // Light parchment-like background
            border: Border.all(color: Colors.brown, width: 2),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header: Name, size, type, alignment
              Text(
                monster.name,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              Text(
                '${monster.size} ${monster.type}, ${monster.alignment}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
              ),
              const Divider(color: Colors.brown, thickness: 1.5, height: 24),
              
              // AC, HP, Speed
              _buildStatRow('Classe Armatura', _formatArmorClass(monster.armorClass)),
              _buildStatRow('Punti Ferita', '${monster.hitPoints} (${monster.hitDice})'),
              _buildStatRow('Velocità', _formatSpeed(monster.speed)),
              const Divider(color: Colors.brown, thickness: 1.5, height: 24),

              // Attributes Grid
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(), 1: FlexColumnWidth(),
                  2: FlexColumnWidth(), 3: FlexColumnWidth(),
                  4: FlexColumnWidth(), 5: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      _buildAttributeHeader('FOR'), _buildAttributeHeader('DES'),
                      _buildAttributeHeader('COS'), _buildAttributeHeader('INT'),
                      _buildAttributeHeader('SAG'), _buildAttributeHeader('CAR'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildAttributeCell(monster.strength), _buildAttributeCell(monster.dexterity),
                      _buildAttributeCell(monster.constitution), _buildAttributeCell(monster.intelligence),
                      _buildAttributeCell(monster.wisdom), _buildAttributeCell(monster.charisma),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.brown, thickness: 1.5, height: 24),


              // Special Abilities / Traits
              if (monster.specialAbilities.isNotEmpty) ...[
                _buildSectionTitle('Tratti Speciali'),
                ...monster.specialAbilities.map((trait) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${trait['name']}. ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: trait['desc']),
                          ],
                        ),
                      ),
                    )),
                const Divider(color: Colors.brown, thickness: 1.5, height: 24),
              ],

              // Senses, Languages, CR
              _buildInfoRow('Sensi', monster.senses.join(', ')),
              _buildInfoRow('Linguaggi', monster.languages.join(', ')),
              _buildInfoRow('Challenge Rating', monster.challengeRating),
              const Divider(color: Colors.brown, thickness: 1.5, height: 24),

              // Actions
              if (monster.actions.isNotEmpty) ...[
                _buildSectionTitle('Azioni'),
                ...monster.actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${action['name']}. ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: action['desc']),
                          ],
                        ),
                      ),
                    )),
                const Divider(color: Colors.brown, thickness: 1.5, height: 24),
              ],

              // Legendary Actions
              if (monster.legendaryActions.isNotEmpty) ...[
                _buildSectionTitle('Azioni Leggendarie'),
                // Assuming description for legendary actions explains how many and when
                // For simplicity, just listing them like normal actions for now
                ...monster.legendaryActions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${action['name']}. ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: action['desc']),
                          ],
                        ),
                      ),
                    )),
                const Divider(color: Colors.brown, thickness: 1.5, height: 24),
              ],

            ],
          ),
        ),
      ),
    );
  }
}
