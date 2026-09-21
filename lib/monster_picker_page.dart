import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:gm_tool/monster_model.dart';
import 'services/srd_service.dart';

class MonsterPickerPage extends StatefulWidget {
  const MonsterPickerPage({super.key});



  @override
  State<MonsterPickerPage> createState() => _MonsterPickerPageState();
}

class _MonsterPickerPageState extends State<MonsterPickerPage> {
  String _formatCr(double cr) {
    if (cr == 0.125) return '1/8';
    if (cr == 0.25) return '1/4';
    if (cr == 0.5) return '1/2';
    if (cr == cr.truncateToDouble()) return cr.toInt().toString();
    return cr.toString();
  }

  List<MonsterSummary> _monsters = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Object? _selectedCr = 'Qualsiasi';
  String _selectedType = 'Qualsiasi';
  List<String> _availableTypes = ['Qualsiasi'];

  final List<Object> _challengeRatings = [
    'Qualsiasi',
    0,
    0.125,
    0.25,
    0.5,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
  ];

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    try {
      final monsters = await SrdService().loadMonsters();
      final uniqueTypes = monsters.map((m) => m.type).toSet().toList()..sort();
      setState(() {
        _monsters = monsters;
        _availableTypes = ['Qualsiasi', ...uniqueTypes];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error loading monsters: $e');
    }
  }

  List<MonsterSummary> get _filteredMonsters {
    return _monsters.where((monster) {
      final matchesSearchQuery = _searchQuery.isEmpty ||
          monster.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCr = _selectedCr == 'Qualsiasi' ||
          (monster.challengeRating == (_selectedCr is int ? (_selectedCr as int).toDouble() : _selectedCr as double?));

      final matchesType = _selectedType == 'Qualsiasi' ||
          monster.type.toLowerCase() == _selectedType.toLowerCase();

      return matchesSearchQuery && matchesCr && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Villain'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Cerca per nome...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Object?>(
                          decoration: const InputDecoration(
                            labelText: 'Grado di Sfida (CR)',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedCr,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCr = newValue;
                            });
                          },
                          items: _challengeRatings.map<DropdownMenuItem<Object?>>((cr) {
                            final value = cr is num ? _formatCr(cr.toDouble()) : cr.toString();
                            return DropdownMenuItem<Object?>(
                              value: cr,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedType = newValue!;
                            });
                          },
                          items: _availableTypes.map<DropdownMenuItem<String>>((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type.replaceFirst(type[0], type[0].toUpperCase())),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredMonsters.length,
                    itemBuilder: (context, index) {
                      final monster = _filteredMonsters[index];
                      return ListTile(
                        title: Text(
                          monster.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'CR: ${_formatCr(monster.challengeRating)} | '
                          'Tipo: ${monster.type} | '
                          'PF: ${monster.hitPoints} | '
                          'CA: ${monster.armorClass}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context, monster);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
