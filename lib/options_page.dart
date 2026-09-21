import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsPage extends StatefulWidget {
  final Function(String) onVersionChanged;

  const OptionsPage({super.key, required this.onVersionChanged});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  String _selectedVersion = '2014';
  bool _isLoading = true;


  final Color bgDark = const Color(0xFF1E1E2C);
  final Color navBarBg = const Color(0xFF2D2D44);
  final Color accentBlue = const Color(0xFF81A1C1);
  final Color textMain = const Color(0xFFECEFF4);

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVersion = prefs.getString('game_version') == '2024' ? '2024' : '2014';
      _isLoading = false;
    });
  }

  Future<void> _saveVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_version', version);
    setState(() {
      _selectedVersion = version;
    });
    widget.onVersionChanged(version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text('Opzioni', style: TextStyle(color: textMain)),
        backgroundColor: navBarBg,
        iconTheme: IconThemeData(color: textMain),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Versione di Gioco',
                    style: TextStyle(
                      color: textMain,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seleziona la versione delle regole di Dungeons & Dragons che desideri utilizzare.',
                    style: TextStyle(
                      color: textMain.withAlpha((255 * 0.7).round()),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                   color: navBarBg,
                   shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(10),
   ),
   child: RadioGroup<String>(
     groupValue: _selectedVersion,
     onChanged: (value) {
       if (value != null) _saveVersion(value);
     },
     child: Column(
       children: [
         RadioListTile<String>(
           title: Text(
             'D&D 5e (2014)',
             style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
           ),
           subtitle: Text(
             'Regole classiche della quinta edizione',
             style: TextStyle(color: textMain.withAlpha((255 * 0.6).round())),
           ),
           value: '2014',
         ),
         Divider(color: bgDark, height: 1),
         RadioListTile<String>(
           title: Text(
             'D&D One / 5.5e (2024)',
             style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
           ),
           subtitle: Text(
             'Nuove regole aggiornate della quinta edizione',
             style: TextStyle(color: textMain.withAlpha((255 * 0.6).round())),
           ),
           value: '2024',
         ),
       ],
     ),
   ),
 )
                ],
              ),
            ),
     );
   }
}
