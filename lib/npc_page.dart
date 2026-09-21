import 'package:flutter/material.dart';
import 'dart:math';
import 'models.dart';
import 'services/srd_service.dart';

class NPCSection extends StatefulWidget {
  final List<NPC> npcList;
  final List<PlotStory> stories;
  final Function(VoidCallback) parentSetter;

  const NPCSection({
    super.key, 
    required this.npcList, 
    required this.stories,
    required this.parentSetter,
  });

  @override
  State<NPCSection> createState() => _NPCSectionState();
}

class _NPCSectionState extends State<NPCSection> {
  final Color navBarBg = const Color(0xFF2D2D44);
  final Color accentBlue = const Color(0xFF81A1C1);
  final Color textMain = const Color(0xFFECEFF4);
  final Color accentSage = const Color(0xFFA3BE8C);

  String searchQuery = "";
  final SrdService _srdService = SrdService();

  // --- FUNZIONE: GENERAZIONE RANDOMICA SRD CON LIVELLO ---
  Future<void> _generateRandomNPC() async {
    try {
      final races = await _srdService.loadRaces();
      final classes = await _srdService.loadClasses();
      final backgrounds = await _srdService.loadBackgrounds();
      final version = await _srdService.selectedVersion();

      if (!mounted) return;

      final random = Random();

      final randomRaceData = races.isNotEmpty ? races[random.nextInt(races.length)] : {'name': 'Umano'};
      final randomClassData = classes.isNotEmpty ? classes[random.nextInt(classes.length)] : {'name': 'Guerriero'};
      final randomBgData = backgrounds.isNotEmpty ? backgrounds[random.nextInt(backgrounds.length)] : {'name': 'Accolito'};

      String raceName = randomRaceData['name'] ?? 'Umano';
      String className = randomClassData['name'] ?? 'Guerriero';
      String bgName = randomBgData['name'] ?? 'Accolito';

      final firstNames = ['Thorin', 'Lyra', 'Kaelen', 'Varis', 'Aelar', 'Dorn', 'Miri', 'Beren', 'Zora', 'Thalric'];
      String randomName = firstNames[random.nextInt(firstNames.length)];

      int level = random.nextInt(10) + 1; // Livello random tra 1 e 10

      final generated = _generateSrdScores(
        level: level,
        version: version,
        race: Map<String, dynamic>.from(randomRaceData),
        characterClass: Map<String, dynamic>.from(randomClassData),
        background: Map<String, dynamic>.from(randomBgData),
      );
      final str = generated['str']!;
      final dex = generated['dex']!;
      final con = generated['con']!;
      final intl = generated['intl']!;
      final wis = generated['wis']!;
      final cha = generated['cha']!;
      final hp = _generatedHitPoints(
        level,
        con,
        _hitDie(Map<String, dynamic>.from(randomClassData)),
      );

      widget.parentSetter(() {
        widget.npcList.add(NPC(
          name: randomName,
          race: raceName,
          role: className,
          notes: "Background: $bgName. Generato automaticamente da SRD.",
          srdVersion: version,
          level: level,
          hpMax: hp,
          hpCurrent: hp,
          str: str,
          dex: dex,
          con: con,
          intl: intl,
          wis: wis,
          cha: cha,
        ));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Generato: $randomName (Lv.$level $raceName $className, ${version == '2024' ? '5.5e' : '5e'})"),
          backgroundColor: accentSage,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore durante la generazione: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- SCHEDA DETTAGLI (SOLA LETTURA + DADI + STORICO SESSIONI) ---
  void _showNPCDetails(NPC n) {
    List<String> matchedSessions = [];
    for (var story in widget.stories) {
      for (var session in story.sessions) {
        if (session.linkedNpcNames.contains(n.name)) {
          matchedSessions.add("${story.title} > ${session.title}");
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: navBarBg,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text("${n.name} (Lv.${n.level}) • ${n.srdVersion == '2024' ? '5.5e' : '5e'}", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
                int idx = widget.npcList.indexOf(n);
                _showAddNPCDialog(index: idx);
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text("${n.race} - ${n.role}", style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text(
                      "Regole: ${n.srdVersion == '2024' ? '5.5e' : '5e'}",
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () {
                          widget.parentSetter(() {
                            if (n.hpCurrent > 0) n.hpCurrent--;
                            setLocalState(() {});
                          });
                        },
                      ),
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        "HP: ${n.hpCurrent} / ${n.hpMax}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                        onPressed: () {
                          widget.parentSetter(() {
                            if (n.hpCurrent < n.hpMax) n.hpCurrent++;
                            setLocalState(() {});
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const Divider(color: Colors.white24, height: 25),
              const Center(child: Text("TOCCO PER TIRARE I DADI", style: TextStyle(color: Colors.grey, fontSize: 10))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _statRollBtn("FOR", n.str),
                  _statRollBtn("DES", n.dex),
                  _statRollBtn("COS", n.con),
                  _statRollBtn("INT", n.intl),
                  _statRollBtn("SAG", n.wis),
                  _statRollBtn("CAR", n.cha),
                ],
              ),
              if (n.notes.isNotEmpty) ...[
                const Divider(color: Colors.white24, height: 25),
                Text(n.notes, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
              const Divider(color: Colors.white24, height: 25),
              const Text("Sessioni Incontrato:", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              matchedSessions.isEmpty
                  ? const Text("Nessuna sessione associata.", style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: matchedSessions.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text("• $s", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      )).toList(),
                    ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Chiudi")),
        ],
      ),
    );
  }

  Widget _statRollBtn(String label, int score) {
    int modVal = ((score - 10) / 2).floor();
    String modStr = modVal >= 0 ? "+$modVal" : "$modVal";

    return InkWell(
      onTap: () {
        int d20 = Random().nextInt(20) + 1;
        int totale = d20 + modVal;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$label: $totale (Dado: $d20 | Mod: $modStr)"),
            backgroundColor: accentBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Text("$score", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(modStr, style: TextStyle(color: accentBlue, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.npcList.where((npc) {
      return npc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
             npc.role.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cerca PNG o Ruolo...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: navBarBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("NUOVO"),
                  onPressed: () => _showAddNPCDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentSage, 
                    foregroundColor: const Color(0xFF1E1E2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.casino),
                  label: const Text("GENERA RANDOM"),
                  onPressed: _generateRandomNPC,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue, 
                    foregroundColor: const Color(0xFF1E1E2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredList.isEmpty 
            ? const Center(child: Text("Nessun PNG trovato", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final n = filteredList[index];
                  final originalIndex = widget.npcList.indexOf(n);
                  
                  return Card(
                    color: navBarBg,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text("${n.name} (Lv.${n.level})", style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                      leading: Chip(
                        label: Text(
                          n.srdVersion == '2024' ? '5.5e' : '5e',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1E1E2C)),
                        ),
                        backgroundColor: accentBlue,
                        visualDensity: VisualDensity.compact,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${n.race} - ${n.role}", style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 4),
                                Text("HP: ${n.hpCurrent} / ${n.hpMax}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12, runSpacing: 4,
                              children: [
                                _statLabel("FOR", n.str, n.getMod(n.str).toString()),
                                _statLabel("DES", n.dex, n.getMod(n.dex).toString()),
                                _statLabel("COS", n.con, n.getMod(n.con).toString()),
                                _statLabel("INT", n.intl, n.getMod(n.intl).toString()),
                                _statLabel("SAG", n.wis, n.getMod(n.wis).toString()),
                                _statLabel("CAR", n.cha, n.getMod(n.cha).toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: "Aumenta livello",
                            icon: const Icon(Icons.arrow_upward, color: Colors.greenAccent),
                            onPressed: () => _levelUp(n),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => widget.parentSetter(() => widget.npcList.removeAt(originalIndex)),
                          ),
                        ],
                      ),
                      onTap: () => _showNPCDetails(n),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _statLabel(String label, int val, String mod) {
    return Text("$label: $val ($mod)", style: TextStyle(color: accentBlue.withValues(alpha: 0.8), fontSize: 11));
  }

  List<String> _primaryAbilities(Map<String, dynamic>? characterClass) {
    final primary = <String>[];
    final primaryData = characterClass?['primary_ability'];
    if (primaryData is Map && primaryData['ability_scores'] is List) {
      for (final item in primaryData['ability_scores']) {
        if (item is Map && item['index'] is String) {
          primary.add(item['index'] as String);
        }
      }
    }
    if (primary.isNotEmpty) return primary;

    const fallback = <String, List<String>>{
      'barbarian': ['str', 'con'],
      'bard': ['cha', 'dex'],
      'cleric': ['wis', 'str'],
      'druid': ['wis', 'con'],
      'fighter': ['str', 'con'],
      'monk': ['dex', 'wis'],
      'paladin': ['str', 'cha'],
      'ranger': ['dex', 'wis'],
      'rogue': ['dex', 'int'],
      'sorcerer': ['cha', 'con'],
      'warlock': ['cha', 'con'],
      'wizard': ['int', 'dex'],
    };
    return fallback[characterClass?['index']] ?? ['str', 'con'];
  }

  Future<void> _levelUp(NPC npc) async {
    if (npc.level >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Il PNG è già al livello massimo.")),
      );
      return;
    }

    try {
      final nextLevel = npc.level + 1;
      final classes = await _srdService.loadClassesForVersion(npc.srdVersion);
      final classData = classes.whereType<Map>().cast<Map<String, dynamic>>().firstWhere(
        (item) => item['name']?.toString() == npc.role,
        orElse: () => <String, dynamic>{},
      );
      final hitDie = _hitDie(classData);
      final conModifier = npc.getMod(npc.con);
      final hpGain = max(1, (hitDie / 2).ceil() + conModifier);
      var str = npc.str;
      var dex = npc.dex;
      var con = npc.con;
      var intl = npc.intl;
      var wis = npc.wis;
      var cha = npc.cha;
      final asiLevels = npc.srdVersion == '2024' ? [4, 8, 12, 16] : [4, 8, 12, 16, 19];

      if (asiLevels.contains(nextLevel)) {
        final primary = _primaryAbilities(classData);
        final primaryAbility = primary.first;
        switch (primaryAbility) {
          case 'str':
            str = min(20, str + 2);
          case 'dex':
            dex = min(20, dex + 2);
          case 'con':
            con = min(20, con + 2);
          case 'int':
            intl = min(20, intl + 2);
          case 'wis':
            wis = min(20, wis + 2);
          case 'cha':
            cha = min(20, cha + 2);
        }
      }

      widget.parentSetter(() {
        npc.level = nextLevel;
        npc.hpMax += hpGain;
        npc.hpCurrent += hpGain;
        npc.str = str;
        npc.dex = dex;
        npc.con = con;
        npc.intl = intl;
        npc.wis = wis;
        npc.cha = cha;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${npc.name} è salito al livello $nextLevel.")),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossibile aumentare il livello: $error")),
      );
    }
  }

  Map<String, int> _generateSrdScores({
    required int level,
    required String version,
    required Map<String, dynamic>? race,
    required Map<String, dynamic>? characterClass,
    required Map<String, dynamic>? background,
  }) {
    final abilities = ['str', 'dex', 'con', 'intl', 'wis', 'cha'];
    final scores = <String, int>{for (final ability in abilities) ability: 8};
    final standardArray = [15, 14, 13, 12, 10, 8];

    final primary = _primaryAbilities(characterClass);

    final priority = <String>[
      ...primary,
      ...abilities.where((ability) => !primary.contains(ability)),
    ];
    for (var i = 0; i < priority.length; i++) {
      scores[priority[i]] = standardArray[i];
    }

    if (version == '2014') {
      final bonuses = race?['ability_bonuses'];
      if (bonuses is List) {
        for (final item in bonuses) {
          if (item is Map &&
              item['ability_score'] is Map &&
              item['ability_score']['index'] is String &&
              item['bonus'] is num) {
            final ability = item['ability_score']['index'] as String;
            scores[ability] = (scores[ability] ?? 8) + (item['bonus'] as num).toInt();
          }
        }
      }
    } else {
      final backgroundAbilities = <String>[];
      final backgroundData = background?['ability_scores'];
      if (backgroundData is List) {
        for (final item in backgroundData) {
          if (item is Map && item['index'] is String) {
            backgroundAbilities.add(item['index'] as String);
          }
        }
      }
      final allowed = backgroundAbilities.where(scores.containsKey).toList();
      if (allowed.isNotEmpty) scores[allowed[0]] = scores[allowed[0]]! + 2;
      if (allowed.length > 1) scores[allowed[1]] = scores[allowed[1]]! + 1;
    }

    // ASI/feat levels: for an automatically generated NPC, apply the
    // default +2 to its primary ability. Manual scores remain untouched.
    final asiLevels = version == '2024' ? [4, 8, 12, 16] : [4, 8, 12, 16, 19];
    for (final asiLevel in asiLevels) {
      if (level >= asiLevel && primary.isNotEmpty && scores[primary.first]! < 20) {
        scores[primary.first] = (scores[primary.first]! + 2).clamp(1, 20);
      }
    }
    return scores;
  }

  int _hitDie(Map<String, dynamic>? characterClass) {
    final value = characterClass?['hit_die'];
    return value is num ? value.toInt() : 8;
  }

  int _generatedHitPoints(int level, int constitution, int hitDie) {
    final conMod = ((constitution - 10) / 2).floor();
    final averageAfterFirst = (hitDie / 2).ceil();
    return (hitDie + ((averageAfterFirst + conMod) * (level - 1))).clamp(1, 999);
  }

  // --- DIALOG AGGIUNTA / MODIFICA PNG CON LIVELLO E SCALING STATS ---
  void _showAddNPCDialog({int? index}) {
    final nameCtrl = TextEditingController(text: index != null ? widget.npcList[index].name : "");
    final raceCtrl = TextEditingController(text: index != null ? widget.npcList[index].race : "");
    final classCtrl = TextEditingController(text: index != null ? widget.npcList[index].role : "");
    final notesCtrl = TextEditingController(text: index != null ? widget.npcList[index].notes : "");
    final backgroundCtrl = TextEditingController(
      text: index != null && widget.npcList[index].notes.startsWith("Background: ")
          ? widget.npcList[index].notes.substring("Background: ".length)
          : "",
    );
    final levelCtrl = TextEditingController(text: index != null ? widget.npcList[index].level.toString() : "1");
    
    final hpMaxCtrl = TextEditingController(text: index != null ? widget.npcList[index].hpMax.toString() : "10");
    final hpCurrentCtrl = TextEditingController(text: index != null ? widget.npcList[index].hpCurrent.toString() : "10");
    
    final strCtrl = TextEditingController(text: index != null ? widget.npcList[index].str.toString() : "10");
    final dexCtrl = TextEditingController(text: index != null ? widget.npcList[index].dex.toString() : "10");
    final conCtrl = TextEditingController(text: index != null ? widget.npcList[index].con.toString() : "10");
    final intCtrl = TextEditingController(text: index != null ? widget.npcList[index].intl.toString() : "10");
    final wisCtrl = TextEditingController(text: index != null ? widget.npcList[index].wis.toString() : "10");
    final chaCtrl = TextEditingController(text: index != null ? widget.npcList[index].cha.toString() : "10");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: navBarBg,
        title: Text(index == null ? "Nuovo PNG" : "Modifica PNG", style: TextStyle(color: textMain)),
        content: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _srdService.loadRaces(),
            _srdService.loadClasses(),
            _srdService.loadBackgrounds(),
          ]).then((results) => [results[0], results[1], results[2]]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            List<dynamic> races = [];
            List<dynamic> classes = [];
            List<dynamic> backgrounds = [];

            if (snapshot.hasData && snapshot.data != null) {
              races = snapshot.data![0];
              classes = snapshot.data![1];
              backgrounds = snapshot.data![2];
            }

            return SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _inputField("Nome", nameCtrl),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _inputField("Livello", levelCtrl, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Dropdown Razze SRD
                      DropdownButtonFormField<String>(
                        initialValue: races.any((r) => r['name'] == raceCtrl.text) ? raceCtrl.text : null,
                        dropdownColor: navBarBg,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Razza (SRD)", labelStyle: TextStyle(color: Colors.grey)),
                        items: races.map<DropdownMenuItem<String>>((r) {
                          String rName = r['name'] ?? '';
                          return DropdownMenuItem<String>(
                            value: rName,
                            child: Text(rName, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              raceCtrl.text = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      // Dropdown Classi SRD
                      DropdownButtonFormField<String>(
                        initialValue: classes.any((c) => c['name'] == classCtrl.text) ? classCtrl.text : null,
                        dropdownColor: navBarBg,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Classe / Ruolo (SRD)", labelStyle: TextStyle(color: Colors.grey)),
                        items: classes.map<DropdownMenuItem<String>>((c) {
                          String cName = c['name'] ?? '';
                          return DropdownMenuItem<String>(
                            value: cName,
                            child: Text(cName, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              classCtrl.text = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      // Dropdown Background SRD
                      InkWell(
                        onTap: () async {
                          final selected = await showDialog<String>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: navBarBg,
                              title: const Text("Background (SRD)", style: TextStyle(color: Colors.white)),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 320,
                                child: ListView.builder(
                                  itemCount: backgrounds.length,
                                  itemBuilder: (context, index) {
                                    final name = backgrounds[index]['name']?.toString() ?? '';
                                    return ListTile(
                                      title: Text(name, style: const TextStyle(color: Colors.white)),
                                      selected: name == backgroundCtrl.text,
                                      selectedTileColor: accentBlue.withValues(alpha: 0.2),
                                      onTap: () => Navigator.pop(dialogContext, name),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                          if (selected != null) {
                            setDialogState(() {
                              backgroundCtrl.text = selected;
                              notesCtrl.text = "Background: $selected";
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Background (SRD)",
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                          child: Text(
                            backgroundCtrl.text.isEmpty ? "Seleziona background" : backgroundCtrl.text,
                            style: TextStyle(
                              color: backgroundCtrl.text.isEmpty ? Colors.white54 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _inputField("Note / Descrizione", notesCtrl),
                      const SizedBox(height: 10),
                      Row(children: [_statField("HP Max", hpMaxCtrl), _statField("HP Att", hpCurrentCtrl)]),
                      const Divider(color: Colors.grey, height: 20),
                      Row(children: [_statField("FOR", strCtrl), _statField("DES", dexCtrl), _statField("COS", conCtrl)]),
                      Row(children: [_statField("INT", intCtrl), _statField("SAG", wisCtrl), _statField("CAR", chaCtrl)]),
                    ],
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () async {
              int lvl = int.tryParse(levelCtrl.text) ?? 1;
              lvl = lvl.clamp(1, 20);

              int str = int.tryParse(strCtrl.text) ?? 10;
              int dex = int.tryParse(dexCtrl.text) ?? 10;
              int con = int.tryParse(conCtrl.text) ?? 10;
              int intl = int.tryParse(intCtrl.text) ?? 10;
              int wis = int.tryParse(wisCtrl.text) ?? 10;
              int cha = int.tryParse(chaCtrl.text) ?? 10;

              final version = await _srdService.selectedVersion();
              final loadedRules = await Future.wait([
                _srdService.loadRaces(),
                _srdService.loadClasses(),
                _srdService.loadBackgrounds(),
              ]);
              final races = loadedRules[0];
              final classes = loadedRules[1];
              final backgrounds = loadedRules[2];
              final raceData = races.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item?['name'] == raceCtrl.text,
                orElse: () => null,
              );
              final classData = classes.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item?['name'] == classCtrl.text,
                orElse: () => null,
              );
              final backgroundData = backgrounds.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item?['name'] == backgroundCtrl.text,
                orElse: () => null,
              );

              // Default fields (all 10) use SRD standard array and progression.
              // Explicit manual scores are preserved exactly as entered.
              final enteredScores = [str, dex, con, intl, wis, cha];
              if (enteredScores.every((score) => score == 10) &&
                  raceData != null &&
                  classData != null) {
                final generated = _generateSrdScores(
                  level: lvl,
                  version: version,
                  race: raceData,
                  characterClass: classData,
                  background: backgroundData,
                );
                str = generated['str']!;
                dex = generated['dex']!;
                con = generated['con']!;
                intl = generated['intl']!;
                wis = generated['wis']!;
                cha = generated['cha']!;
              }

              int hpMax = int.tryParse(hpMaxCtrl.text) ?? 10;
              if (hpMax == 10 && lvl > 1 && classData != null) {
                hpMax = _generatedHitPoints(lvl, con, _hitDie(classData));
              }
              int hpCurrent = int.tryParse(hpCurrentCtrl.text) ?? hpMax;

              widget.parentSetter(() {
                NPC updated = NPC(
                  name: nameCtrl.text.isNotEmpty ? nameCtrl.text : "Senza Nome", 
                  race: raceCtrl.text, 
                  role: classCtrl.text, 
                  notes: notesCtrl.text,
                  srdVersion: index == null ? version : widget.npcList[index].srdVersion,
                  level: lvl,
                  hpMax: hpMax, 
                  hpCurrent: hpCurrent,
                  str: str, 
                  dex: dex,
                  con: con, 
                  intl: intl,
                  wis: wis, 
                  cha: cha,
                );
                if (index == null) {
                  widget.npcList.add(updated);
                } else {
                  widget.npcList[index] = updated;
                }
              });
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: label.contains("Note") ? 3 : 1, minLines: 1,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _statField(String label, TextEditingController ctrl) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextField(
          controller: ctrl, keyboardType: TextInputType.number,
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 10), border: const OutlineInputBorder()),
        ),
      ),
    );
  }
}