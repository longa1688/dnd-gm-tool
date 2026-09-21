import 'dart:math';
import 'package:flutter/material.dart';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  int totalRoll = 0;
  int diceCount = 1;
  String lastRollDetail = "Tira i dadi!";
  List<String> history = [];

  // Funzione per calcolare il modificatore (es. 16 -> +3)
  int calculateModifier(int score) {
    return ((score - 10) / 2).floor();
  }

  void rollDice(int faces) {
    setState(() {
      int temporaryTotal = 0;
      List<int> individualRolls = [];
      for (int i = 0; i < diceCount; i++) {
        int r = Random().nextInt(faces) + 1;
        individualRolls.add(r);
        temporaryTotal += r;
      }
      totalRoll = temporaryTotal;
      lastRollDetail = "${diceCount}d$faces ($individualRolls)";
      history.insert(0, "Lancio $lastRollDetail: Totale $totalRoll");
      if (history.length > 10) history.removeLast();
    });
  }

  // Funzione per il tiro delle caratteristiche (D20 + Modificatore)
  void rollStat(String label, int statScore) {
    int mod = calculateModifier(statScore);
    int r = Random().nextInt(20) + 1;
    setState(() {
      totalRoll = r + mod;
      lastRollDetail = "D20 ($r) + Mod. $label ($mod)";
      history.insert(0, "Prova $label: $totalRoll (Dado: $r)");
      if (history.length > 10) history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Selettore quantità dadi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[850],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Quantità: ", style: TextStyle(color: Colors.white, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => setState(() => diceCount > 1 ? diceCount-- : null),
                ),
                Text('$diceCount', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => setState(() => diceCount++),
                ),
              ],
            ),
          ),
          
          // Display Risultato
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lastRollDetail, style: const TextStyle(color: Colors.grey, fontSize: 18)),
                Text('$totalRoll', style: const TextStyle(color: Colors.yellow, fontSize: 80, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Bottoni Dadi Classici
          Wrap(
            spacing: 10, runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [4, 6, 8, 10, 12, 20, 100].map((f) => buildBtn(f)).toList(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text("PROVE CARATTERISTICA (D20 + MOD)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          ),

          // Bottoni Big Six (Caratteristiche)
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              statBtn("FOR", 10),
              statBtn("DES", 10),
              statBtn("COS", 10),
              statBtn("INT", 10),
              statBtn("SAG", 10),
              statBtn("CAR", 10),
            ],
          ),

          const Divider(color: Colors.red, height: 30),

          // Cronologia
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.history, color: Colors.red, size: 20),
                visualDensity: VisualDensity.compact,
                title: Text(history[index], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget bottone dadi rossi (il tuo originale)
  Widget buildBtn(int faces) {
    return ElevatedButton(
      onPressed: () => rollDice(faces),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[900], 
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('D$faces'),
    );
  }

  // Widget bottone caratteristiche (blu scuro per differenziare)
  Widget statBtn(String label, int statValue) {
    return ElevatedButton(
      onPressed: () => rollStat(label, statValue),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}