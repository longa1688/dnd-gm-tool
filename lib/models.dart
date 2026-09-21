import 'dart:convert';

int _readIntValue(dynamic value, {required int fallback}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class NPC {
  String name;
  String race;
  String role;
  String description;
  String notes;
  String srdVersion;
  int level;
  int hpMax;
  int hpCurrent;
  int str;
  int dex;
  int con;
  int intl;
  int wis;
  int cha;

  NPC({
    required this.name,
    this.race = "",
    this.role = "",
    this.description = "",
    this.notes = "",
    this.srdVersion = "2014",
    this.level = 1,
    required this.hpMax,
    required this.hpCurrent,
    this.str = 10,
    this.dex = 10,
    this.con = 10,
    this.intl = 10,
    this.wis = 10,
    this.cha = 10,
  });

  int getMod(int stat) {
    return ((stat - 10) / 2).floor();
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'race': race,
        'role': role,
        'description': description,
        'notes': notes,
        'srdVersion': srdVersion,
        'level': level,
        'hpMax': hpMax,
        'hpCurrent': hpCurrent,
        'str': str,
        'dex': dex,
        'con': con,
        'intl': intl,
        'wis': wis,
        'cha': cha,
      };

  factory NPC.fromMap(Map<String, dynamic> map) => NPC(
        name: map['name']?.toString() ?? "",
        race: map['race']?.toString() ?? "",
        role: map['role']?.toString() ?? "",
        description: map['description']?.toString() ?? "",
        notes: map['notes']?.toString() ?? "",
        srdVersion: map['srdVersion']?.toString() == '2024' ? '2024' : '2014',
        level: _readIntValue(map['level'], fallback: 1),
        hpMax: _readIntValue(map['hpMax'], fallback: 10),
        hpCurrent: _readIntValue(map['hpCurrent'], fallback: 10),
        str: _readIntValue(map['str'], fallback: 10),
        dex: _readIntValue(map['dex'], fallback: 10),
        con: _readIntValue(map['con'], fallback: 10),
        intl: _readIntValue(map['intl'], fallback: 10),
        wis: _readIntValue(map['wis'], fallback: 10),
        cha: _readIntValue(map['cha'], fallback: 10),
      );

  static String encode(List<NPC> npcs) =>
      json.encode(npcs.map<Map<String, dynamic>>((npc) => npc.toMap()).toList());

  static List<NPC> decode(String npcs) =>
      (json.decode(npcs) as List<dynamic>)
          .map<NPC>((item) => NPC.fromMap(item))
          .toList();
}

// --- CLASSI PER LA TRAMA ---

class Session {
  String title;
  String date;
  String summary;
  String hooks;
  List<String> linkedNpcNames; // <--- LISTA DEI PNG ASSOCIATI ALLA SESSIONE/EVENTO

  Session({
    required this.title,
    required this.date,
    this.summary = "",
    this.hooks = "",
    this.linkedNpcNames = const [],
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'summary': summary,
        'hooks': hooks,
        'linkedNpcNames': linkedNpcNames,
      };

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        title: map['title']?.toString() ?? "",
        date: map['date']?.toString() ?? "",
        summary: map['summary']?.toString() ?? "",
        hooks: map['hooks']?.toString() ?? "",
        linkedNpcNames: map['linkedNpcNames'] != null 
            ? List<String>.from(map['linkedNpcNames']) 
            : [],
      );
}

class PlotStory {
  String title;
  String description;
  bool isCampaign;
  List<Session> sessions;

  PlotStory({
    required this.title,
    this.description = "",
    this.isCampaign = true,
    required this.sessions,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'isCampaign': isCampaign,
        'sessions': sessions.map((s) => s.toMap()).toList(),
      };

  factory PlotStory.fromMap(Map<String, dynamic> map) => PlotStory(
        title: map['title']?.toString() ?? "",
        description: map['description']?.toString() ?? "",
        isCampaign: map['isCampaign'] ?? true,
        sessions: map['sessions'] != null
            ? (map['sessions'] as List<dynamic>)
                .map((s) => Session.fromMap(s))
                .toList()
            : [],
      );

  static String encode(List<PlotStory> stories) =>
      json.encode(stories.map<Map<String, dynamic>>((s) => s.toMap()).toList());

  static List<PlotStory> decode(String stories) =>
      (json.decode(stories) as List<dynamic>)
          .map<PlotStory>((item) => PlotStory.fromMap(item))
          .toList();
}

class Combatant {
  String name;
  int initiative;
  int hpCurrent;
  int hpMax;
  bool isVillain;
  dynamic monster;

  Combatant({
    required this.name,
    required this.initiative,
    this.hpCurrent = 10,
    this.hpMax = 10,
    this.isVillain = false,
    this.monster,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'initiative': initiative,
        'hpCurrent': hpCurrent,
        'hpMax': hpMax,
        'isVillain': isVillain,
      };

  factory Combatant.fromMap(Map<String, dynamic> map) => Combatant(
        name: map['name']?.toString() ?? '',
        initiative: _readIntValue(map['initiative'], fallback: 0),
        hpCurrent: _readIntValue(map['hpCurrent'], fallback: 10),
        hpMax: _readIntValue(map['hpMax'], fallback: 10),
        isVillain: map['isVillain'] == true,
      );

  static String encode(List<Combatant> combatants) =>
      json.encode(combatants.map((combatant) => combatant.toMap()).toList());

  static List<Combatant> decode(String encoded) =>
      (json.decode(encoded) as List<dynamic>)
          .map<Combatant>((item) => Combatant.fromMap(item))
          .toList();
}