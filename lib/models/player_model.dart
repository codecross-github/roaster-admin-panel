class PlayerModel {
  final String id;
  final String name;
  final String? photo;
  final String position;
  final int age;
  final String level;
  final String team;
  final String throwsHand;
  final String batsHand;
  final String playerType; // 'Pitcher' or 'Hitter'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Pitcher stats
  final double? era;
  final double? whip;
  final int? strikeouts;
  final int? wins;
  final int? losses;

  // Hitter stats
  final double? battingAverage;
  final int? homeRuns;
  final int? rbi;
  final int? hits;
  final double? obp;
  final double? slg;

  PlayerModel({
    required this.id,
    required this.name,
    this.photo,
    required this.position,
    required this.age,
    required this.level,
    required this.team,
    required this.throwsHand,
    required this.batsHand,
    required this.playerType,
    required this.createdAt,
    required this.updatedAt,
    this.era,
    this.whip,
    this.strikeouts,
    this.wins,
    this.losses,
    this.battingAverage,
    this.homeRuns,
    this.rbi,
    this.hits,
    this.obp,
    this.slg,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'],
      position: json['position'] ?? '',
      age: json['age'] ?? 0,
      level: json['level'] ?? '',
      team: json['team'] ?? '',
      throwsHand: json['throwsHand'] ?? 'R',
      batsHand: json['batsHand'] ?? 'R',
      playerType: json['playerType'] ?? 'Hitter',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      era: json['era']?.toDouble(),
      whip: json['whip']?.toDouble(),
      strikeouts: json['strikeouts'],
      wins: json['wins'],
      losses: json['losses'],
      battingAverage: json['battingAverage']?.toDouble(),
      homeRuns: json['homeRuns'],
      rbi: json['rbi'],
      hits: json['hits'],
      obp: json['obp']?.toDouble(),
      slg: json['slg']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'position': position,
      'age': age,
      'level': level,
      'team': team,
      'throwsHand': throwsHand,
      'batsHand': batsHand,
      'playerType': playerType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'era': era,
      'whip': whip,
      'strikeouts': strikeouts,
      'wins': wins,
      'losses': losses,
      'battingAverage': battingAverage,
      'homeRuns': homeRuns,
      'rbi': rbi,
      'hits': hits,
      'obp': obp,
      'slg': slg,
    };
  }
}
