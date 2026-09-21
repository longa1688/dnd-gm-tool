import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'dice_page.dart';
import 'npc_page.dart';
import 'plot_page.dart';
import 'fight_page.dart';
import 'credits_page.dart';
import 'options_page.dart';
import 'services/srd_service.dart';

void main() {
  runApp(const MaterialApp(
    title: 'DndApp',
    home: MainDashboard(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  bool _isHomeScreen = true;
  int _selectedIndex = 0;
  List<NPC> npcList = [];
  List<PlotStory> stories = [];
  List<Combatant> combatants = [];

  final SrdService _srdService = SrdService();
  String _selectedVersion = '2014';
  bool _isSrdDownloading = false;
  double _downloadProgress = 0.0;
  bool _srdDownloaded = false;

  @override
  void initState() {
    super.initState();
    _initializeSrd();
    _loadData();
  }

  Future<void> _initializeSrd() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedVersion = '2014';
    await prefs.setString('game_version', _selectedVersion);
    await _checkAndDownloadSrd();
  }

  Future<void> _checkAndDownloadSrd() async {
    _srdDownloaded = await _srdService.isSrdDownloaded(_selectedVersion);
    if (!_srdDownloaded) {
      setState(() {
        _isSrdDownloading = true;
        _downloadProgress = 0.0;
      });
      try {
        await _srdService.downloadAndExtractSrd(
          version: _selectedVersion,
          onProgress: (progress) {
            setState(() {
              _downloadProgress = progress;
            });
          },
        );
        setState(() {
          _srdDownloaded = true;
          _isSrdDownloading = false;
        });
      } catch (e) {
        setState(() {
          _isSrdDownloading = false;
        });
        debugPrint('Error downloading SRD: $e');
      }
    }
  }

  // --- LOGICA DI SALVATAGGIO E CARICAMENTO ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final String? npcString = prefs.getString('npc_storage');
      if (npcString != null) npcList = NPC.decode(npcString);

      final String? storiesString = prefs.getString('plot_storage');
      if (storiesString != null) stories = PlotStory.decode(storiesString);

      final String? combatantsString = prefs.getString('combatant_storage');
      if (combatantsString != null) combatants = Combatant.decode(combatantsString);
    });
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('npc_storage', NPC.encode(npcList));
    await prefs.setString('plot_storage', PlotStory.encode(stories));
    await prefs.setString('combatant_storage', Combatant.encode(combatants));
  }

  void _updateAndSave(VoidCallback action) {
    setState(action);
    _saveAll();
  }
  // ---------------------------------------------

  final Color bgDark = const Color(0xFF1E1E2C);
  final Color navBarBg = const Color(0xFF2D2D44);
  final Color accentBlue = const Color(0xFF81A1C1);
  final Color textMain = const Color(0xFFECEFF4);

  Widget _getBody() {
    if (_isSrdDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: _downloadProgress),
            const SizedBox(height: 20),
            Text(
              'Downloading SRD Data: ${(_downloadProgress * 100).toInt()}%',
              style: TextStyle(color: textMain),
            ),
          ],
        ),
      );
    } else if (_isHomeScreen) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GM TOOL',
              style: TextStyle(
                color: textMain,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'by Longa',
              style: TextStyle(
                color: textMain.withAlpha((255 * 0.7).round()),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue,
                foregroundColor: textMain,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Crediti',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return PlotPage(
          stories: stories,
          allNpcList: npcList,
          onUpdate: _updateAndSave,
        );
      case 1:
        return NPCSection(
          npcList: npcList,
          stories: stories,
          parentSetter: _updateAndSave,
        );
      case 2:
        return FightPage(
          combatants: combatants,
          onUpdate: (newList) {
            setState(() {
              combatants = newList;
            });
          },
        );
      case 3:
        return const DicePage();
      default:
        return const Center(child: Text('Pagina non trovata'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text('GM Tool', style: TextStyle(color: textMain)),
        backgroundColor: navBarBg,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textMain),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OptionsPage(
                  onVersionChanged: (newVersion) {
                    setState(() {
                      _selectedVersion = newVersion;
                      _srdDownloaded = false;
                      _checkAndDownloadSrd();
                    });
                  },
                )),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.home, color: textMain),
            onPressed: () {
              setState(() {
                _isHomeScreen = true;
              });
            },
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: navBarBg,
        selectedItemColor: _isHomeScreen ? Colors.white : accentBlue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _isHomeScreen = false;
          _selectedIndex = index;
        }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Trama'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'PNG'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Fight'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Dadi'),
        ],
      ),
    );
  }
}