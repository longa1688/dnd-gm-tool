import 'package:flutter/material.dart';
import 'models.dart';
import 'monster_model.dart';
import 'monster_picker_page.dart';

class FightPage extends StatefulWidget {
  final List<Combatant> combatants;
  final Function(List<Combatant>) onUpdate;

  const FightPage({
    super.key,
    required this.combatants,
    required this.onUpdate,
  });

  @override
  State<FightPage> createState() => _FightPageState();
}

class _FightPageState extends State<FightPage> {
  MonsterSummary? _selectedVillainMonster;

  void _addFighter(Combatant c) {
    List<Combatant> newList = List.from(widget.combatants);
    newList.add(c);
    newList.sort((a, b) => b.initiative.compareTo(a.initiative));
    widget.onUpdate(newList);
  }

  void _removeFighter(int index) {
    List<Combatant> newList = List.from(widget.combatants);
    newList.removeAt(index);
    widget.onUpdate(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Gestione Iniziativa"),
        backgroundColor: const Color(0xFF1E1E2C),
        actions: [
          IconButton(
            tooltip: "Mantieni PG (Rimuovi Villain)",
            icon: const Icon(Icons.cleaning_services, color: Colors.greenAccent),
            onPressed: () {
              List<Combatant> newList = widget.combatants.where((c) => !c.isVillain).toList();
              widget.onUpdate(newList);
            },
          ),
          IconButton(
            tooltip: "Resetta tutto",
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: () => widget.onUpdate([]),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.combatants.length,
        itemBuilder: (context, index) {
          final f = widget.combatants[index];
          return InkWell(
            onTap: f.isVillain ? () => _showVillainStatblock(f) : null,
            child: Card(
              color: const Color(0xFF2D2D44),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: f.isVillain ? Colors.red[900] : Colors.blue[900],
                  child: Text("${f.initiative}", style: const TextStyle(color: Colors.white)),
                ),
                title: Row(
                  children: [
                    Text(f.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(width: 8),
                    if (f.isVillain)
                      IconButton(
                        icon: const Icon(Icons.menu_book, color: Colors.white),
                        onPressed: () => _showVillainStatblock(f),
                      ),
                  ],
                ),
                subtitle: f.isVillain
                    ? Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16, color: Colors.redAccent),
                            onPressed: () => setState(() => f.hpCurrent--),
                          ),
                          Text("${f.hpCurrent} / ${f.hpMax} HP", style: const TextStyle(color: Colors.white70)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16, color: Colors.greenAccent),
                            onPressed: () => setState(() => f.hpCurrent++),
                          ),
                        ],
                      )
                    : const Text("PG / PNG", style: TextStyle(color: Colors.white38)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white54),
                      onPressed: () => _showEditFighterDialog(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white24),
                      onPressed: () => _removeFighter(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA3BE8C),
        onPressed: _showAddFighterDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showVillainStatblock([Combatant? combatant]) {
    final monster = combatant?.monster ?? _selectedVillainMonster;
    if (monster == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun mostro SRD selezionato per questo villain.')),
      );
      return;
    }

    // Funzione di supporto per disegnare le statistiche e calcolare il modificatore
    Widget buildStat(String label, int score) {
      int mod = (score - 10) ~/ 2;
      String modStr = mod >= 0 ? '+$mod' : '$mod';
      return Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('$score ($modStr)', style: const TextStyle(color: Colors.white70)),
        ],
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D44),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statblock', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(monster.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${monster.type} • CR ${monster.challengeRating}', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                const Divider(color: Colors.white24, height: 24),
                
                // CA e PF
                Text('Classe Armatura: ${monster.armorClass}', style: const TextStyle(color: Colors.white)),
                Text('Punti Ferita: ${monster.hitPoints}', style: const TextStyle(color: Colors.white)),
                const Divider(color: Colors.white24, height: 24),
                
                // Griglia Statistiche
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildStat('FOR', monster.strength),
                    buildStat('DES', monster.dexterity),
                    buildStat('COS', monster.constitution),
                    buildStat('INT', monster.intelligence),
                    buildStat('SAG', monster.wisdom),
                    buildStat('CAR', monster.charisma),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                
                // Azioni
                if (monster.actions.isNotEmpty) ...[
                  const Text('Azioni', style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...monster.actions.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '${action['name'] ?? ''}. ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          TextSpan(text: action['desc'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                        ],
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditFighterDialog(int index) {
    final f = widget.combatants[index];
    final nameCtrl = TextEditingController(text: f.name);
    final initCtrl = TextEditingController(text: f.initiative.toString());
    final hpCtrl = TextEditingController(text: f.hpMax.toString());
    bool isVillain = f.isVillain;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D44),
          title: const Text("Modifica Combattente", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nome", labelStyle: TextStyle(color: Colors.grey))),
              TextField(controller: initCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Iniziativa", labelStyle: TextStyle(color: Colors.grey)), keyboardType: TextInputType.number),
              SwitchListTile(
                title: const Text("È un Villain?", style: TextStyle(color: Colors.white)),
                value: isVillain,
                onChanged: (val) => setLocalState(() => isVillain = val),
              ),
              if (isVillain)
                TextField(controller: hpCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "HP Max", labelStyle: TextStyle(color: Colors.grey)), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                List<Combatant> newList = List.from(widget.combatants);
                newList[index] = Combatant(
                  name: nameCtrl.text,
                  initiative: int.tryParse(initCtrl.text) ?? 0,
                  hpMax: int.tryParse(hpCtrl.text) ?? 10,
                  hpCurrent: isVillain ? (f.isVillain ? f.hpCurrent : (int.tryParse(hpCtrl.text) ?? 10)) : 10,
                  isVillain: isVillain,
                monster: isVillain ? (f.monster ?? _selectedVillainMonster) : null,
              );
              newList.sort((a, b) => b.initiative.compareTo(a.initiative));
              widget.onUpdate(newList);
              Navigator.pop(context);
            },
            child: const Text("Salva"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFighterDialog() {
    final nameCtrl = TextEditingController();
    final initCtrl = TextEditingController();
    final hpCtrl = TextEditingController(text: "10");
    bool isVillain = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D44),
          title: const Text("Nuovo Combattente", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nome", labelStyle: TextStyle(color: Colors.grey))),
              TextField(controller: initCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Iniziativa", labelStyle: TextStyle(color: Colors.grey)), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final selected = await Navigator.push<MonsterSummary>(context, MaterialPageRoute(builder: (_) => const MonsterPickerPage()));
                  if (selected != null) {
                    setLocalState(() {
                      nameCtrl.text = selected.name;
                      hpCtrl.text = selected.hitPoints.toString();
                      isVillain = true;
                      _selectedVillainMonster = selected;
                    });
                  }
                },
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text("Scegli da SRD", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("È un Villain?", style: TextStyle(color: Colors.white)),
                value: isVillain,
                onChanged: (val) => setLocalState(() => isVillain = val),
              ),
              if (isVillain)
                TextField(controller: hpCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "HP Max", labelStyle: TextStyle(color: Colors.grey)), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                final chosenMonster = isVillain ? _selectedVillainMonster : null;
                _addFighter(Combatant(
                  name: nameCtrl.text,
                  initiative: int.tryParse(initCtrl.text) ?? 0,
                  hpMax: int.tryParse(hpCtrl.text) ?? 10,
                  hpCurrent: int.tryParse(hpCtrl.text) ?? 10,
                  isVillain: isVillain,
                  monster: chosenMonster,
                ));
                Navigator.pop(context);
              },
              child: const Text("Aggiungi"),
            ),
          ],
        ),
      ),
    );
  }
}