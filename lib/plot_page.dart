import 'package:flutter/material.dart';
import 'models.dart';

// --- DASHBOARD TRAMA CON COLORI PNG ---
class PlotPage extends StatefulWidget {
  final List<PlotStory> stories;
  final List<NPC> allNpcList;
  final Function(VoidCallback) onUpdate;

  // ignore: prefer_const_constructors_in_immutables
  PlotPage({
    super.key,
    required this.stories,
    required this.allNpcList,
    required this.onUpdate,
  });

  @override
  State<PlotPage> createState() => _PlotPageState();
}

class _PlotPageState extends State<PlotPage> {
  // LA TUA PALETTE COLORI UNIFICATA
  final Color bgDeep = const Color(0xFF121212);
  final Color navBarBg = const Color(0xFF2D2D44);
  final Color accentBlue = const Color(0xFF81A1C1);
  final Color textMain = const Color(0xFFECEFF4);
  final Color accentSage = const Color(0xFFA3BE8C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDeep,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentBlue,
        child: const Icon(Icons.library_add, color: Color(0xFF2D2D44)),
        onPressed: () => _showAddStoryDialog(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("CAMPAGNE", Icons.auto_awesome, accentBlue),
          ...widget.stories.where((s) => s.isCampaign).map((s) => _buildStoryCard(s, accentBlue)),
          const SizedBox(height: 30),
          _buildSectionTitle("AVVENTURE BREVI", Icons.map, accentSage),
          ...widget.stories.where((s) => !s.isCampaign).map((s) => _buildStoryCard(s, accentSage)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildStoryCard(PlotStory story, Color borderAccent) {
    return Card(
      color: navBarBg,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderAccent.withValues(alpha: 0.3), width: 1),
      ),
      child: ListTile(
        title: Text(story.title, style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
        subtitle: Text("${story.sessions.length} Sessioni", style: const TextStyle(color: Colors.white60)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              color: borderAccent,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showEditStoryDialog(story),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.redAccent,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _confirmDeleteStory(story),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: borderAccent, size: 14),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionListPage(
                story: story,
                allNpcList: widget.allNpcList,
                onUpdate: widget.onUpdate,
                themeColor: borderAccent,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditStoryDialog(PlotStory story) {
    final titleCtrl = TextEditingController(text: story.title);
    bool isCamp = story.isCampaign;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: navBarBg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text("Modifica Storia", style: TextStyle(color: textMain)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textMain),
                  decoration: InputDecoration(
                    labelText: "Titolo",
                    labelStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentBlue.withValues(alpha: 0.3))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentBlue)),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Campagna"),
                      selected: isCamp,
                      selectedColor: accentBlue,
                      onSelected: (val) => setLocalState(() => isCamp = true),
                    ),
                    const SizedBox(width: 15),
                    ChoiceChip(
                      label: const Text("Avventura"),
                      selected: !isCamp,
                      selectedColor: accentSage,
                      onSelected: (val) => setLocalState(() => isCamp = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  widget.onUpdate(() {
                    story.title = titleCtrl.text;
                    story.isCampaign = isCamp;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Salva", style: TextStyle(color: Color(0xFF2D2D44))),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteStory(PlotStory story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: navBarBg,
        title: Text("Elimina Storia", style: TextStyle(color: textMain)),
        content: Text("Sei sicuro di voler eliminare la storia \"${story.title}\"? Questa operazione non può essere annullata.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              widget.onUpdate(() {
                widget.stories.remove(story);
              });
              Navigator.pop(context);
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStoryDialog() {
    final titleCtrl = TextEditingController();
    bool isCamp = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: navBarBg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text("Nuova Storia", style: TextStyle(color: textMain)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textMain),
                  decoration: InputDecoration(
                    labelText: "Titolo",
                    labelStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentBlue.withValues(alpha: 0.3))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentBlue)),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Campagna"),
                      selected: isCamp,
                      selectedColor: accentBlue,
                      onSelected: (val) => setLocalState(() => isCamp = true),
                    ),
                    const SizedBox(width: 15),
                    ChoiceChip(
                      label: const Text("Avventura"),
                      selected: !isCamp,
                      selectedColor: accentSage,
                      onSelected: (val) => setLocalState(() => isCamp = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  widget.onUpdate(() {
                    widget.stories.add(PlotStory(title: titleCtrl.text, isCampaign: isCamp, sessions: []));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Crea", style: TextStyle(color: Color(0xFF2D2D44))),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECONDO LIVELLO: LISTA SESSIONI ---
class SessionListPage extends StatefulWidget {
  final PlotStory story;
  final List<NPC> allNpcList;
  final Function(VoidCallback) onUpdate;
  final Color themeColor;

  const SessionListPage({
    super.key,
    required this.story,
    required this.allNpcList,
    required this.onUpdate,
    required this.themeColor,
  });

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.story.title, style: const TextStyle(color: Color(0xFFECEFF4))),
        backgroundColor: const Color(0xFF2D2D44),
        iconTheme: const IconThemeData(color: Color(0xFFECEFF4)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.themeColor,
        child: const Icon(Icons.history_edu, color: Color(0xFF2D2D44)),
        onPressed: () => _showAddSessionDialog(context),
      ),
      body: widget.story.sessions.isEmpty
          ? const Center(child: Text("Nessuna sessione", style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.story.sessions.length,
              itemBuilder: (context, index) {
                final session = widget.story.sessions[index];
                return Card(
                  color: const Color(0xFF2D2D44),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.themeColor,
                      child: Text("${index + 1}", style: const TextStyle(color: Color(0xFF2D2D44), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(session.title, style: const TextStyle(color: Color(0xFFECEFF4), fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      session.linkedNpcNames.isEmpty 
                          ? session.date 
                          : "${session.date} • PNG: ${session.linkedNpcNames.length}", 
                      style: const TextStyle(color: Colors.white38)
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: widget.themeColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditSessionDialog(context, session),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.redAccent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmDeleteSession(context, session),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, color: widget.themeColor, size: 14),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionDetailPage(
                            session: session,
                            allNpcList: widget.allNpcList,
                            onUpdate: widget.onUpdate,
                            themeColor: widget.themeColor,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text("Nuova Sessione", style: TextStyle(color: Color(0xFFECEFF4))),
        content: TextField(
          controller: titleCtrl,
          style: const TextStyle(color: Color(0xFFECEFF4)),
          decoration: InputDecoration(
            labelText: "Titolo",
            labelStyle: const TextStyle(color: Colors.white38),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.themeColor)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                widget.onUpdate(() {
                  final now = DateTime.now();
                  widget.story.sessions.add(Session(title: titleCtrl.text, date: "${now.day}/${now.month}/${now.year}"));
                });
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("Aggiungi", style: TextStyle(color: Color(0xFF2D2D44))),
          ),
        ],
      ),
    );
  }

  void _showEditSessionDialog(BuildContext context, Session session) {
    final titleCtrl = TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text("Modifica Sessione", style: TextStyle(color: Color(0xFFECEFF4))),
        content: TextField(
          controller: titleCtrl,
          style: const TextStyle(color: Color(0xFFECEFF4)),
          decoration: InputDecoration(
            labelText: "Titolo",
            labelStyle: const TextStyle(color: Colors.white38),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.themeColor)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                widget.onUpdate(() {
                  session.title = titleCtrl.text;
                });
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("Salva", style: TextStyle(color: Color(0xFF2D2D44))),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text("Elimina Sessione", style: TextStyle(color: Color(0xFFECEFF4))),
        content: Text("Sei sicuro di voler eliminare la sessione \"${session.title}\"? Questa operazione non può essere annullata.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              widget.onUpdate(() {
                widget.story.sessions.remove(session);
              });
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- TERZO LIVELLO: DETTAGLIO SESSIONE CON COLLEGAMENTO PNG ---
class SessionDetailPage extends StatefulWidget {
  final Session session;
  final List<NPC> allNpcList;
  final Function(VoidCallback) onUpdate;
  final Color themeColor;

  const SessionDetailPage({
    super.key,
    required this.session,
    required this.allNpcList,
    required this.onUpdate,
    required this.themeColor,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late TextEditingController summaryCtrl;
  late Set<String> selectedNpcNames;

  @override
  void initState() {
    super.initState();
    summaryCtrl = TextEditingController(text: widget.session.summary);
    selectedNpcNames = Set<String>.from(widget.session.linkedNpcNames);
  }

  @override
  void dispose() {
    summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.session.title, style: const TextStyle(color: Color(0xFFECEFF4))),
        backgroundColor: const Color(0xFF2D2D44),
        iconTheme: const IconThemeData(color: Color(0xFFECEFF4)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: widget.themeColor),
            onPressed: () {
              widget.onUpdate(() {
                widget.session.summary = summaryCtrl.text;
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvato!")));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SEZIONE SELEZIONE PNG ASSOCIATI (USIAMO UN INKWELL CON CHECKBOX PERSONALIZZATA)
            ExpansionTile(
              title: Text(
                "PNG Incontrati (${selectedNpcNames.length})",
                style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF2D2D44),
              collapsedBackgroundColor: const Color(0xFF2D2D44),
              iconColor: widget.themeColor,
              collapsedIconColor: widget.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              children: [
                widget.allNpcList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Nessun PNG disponibile nella lista.", style: TextStyle(color: Colors.white38)),
                      )
                    : Column(
                        children: widget.allNpcList.map((npc) {
                          final isSelected = selectedNpcNames.contains(npc.name);

                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: widget.themeColor,
                            checkColor: const Color(0xFF2D2D44),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                            title: Text(
                              npc.name,
                              style: const TextStyle(
                                color: Color(0xFFECEFF4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${npc.race} - ${npc.role}",
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedNpcNames.add(npc.name);
                                } else {
                                  selectedNpcNames.remove(npc.name);
                                }
                                widget.session.linkedNpcNames =
                                    selectedNpcNames.toList();
                              });
                              widget.onUpdate(() {});
                            },
                          );
                        }).toList(),
                      ),
              ],
            ),
            const SizedBox(height: 16),
            // CAMPO SOMMARIO SESSIONE
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: summaryCtrl,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: Color(0xFFECEFF4)),
                  decoration: const InputDecoration(
                    hintText: "Scrivi qui il riassunto della sessione...",
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}