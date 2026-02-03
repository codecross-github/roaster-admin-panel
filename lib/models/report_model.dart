class PitchData {
  final String pitchType;
  final double velocity;
  final double ivb; // Induced Vertical Break
  final double hb; // Horizontal Break
  final int spinRate;

  PitchData({
    required this.pitchType,
    required this.velocity,
    required this.ivb,
    required this.hb,
    required this.spinRate,
  });

  factory PitchData.fromJson(Map<String, dynamic> json) {
    return PitchData(
      pitchType: json['pitchType'] ?? '',
      velocity: (json['velocity'] ?? 0).toDouble(),
      ivb: (json['ivb'] ?? 0).toDouble(),
      hb: (json['hb'] ?? 0).toDouble(),
      spinRate: json['spinRate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pitchType': pitchType,
      'velocity': velocity,
      'ivb': ivb,
      'hb': hb,
      'spinRate': spinRate,
    };
  }
}

class ScatterPoint {
  final double x;
  final double y;
  final String pitchType;

  ScatterPoint({
    required this.x,
    required this.y,
    required this.pitchType,
  });

  factory ScatterPoint.fromJson(Map<String, dynamic> json) {
    return ScatterPoint(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      pitchType: json['pitchType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'pitchType': pitchType,
    };
  }
}

class HitterStats {
  final double airPullPct;
  final double chasePct;
  final double ninetiethRV;
  final double bbPct;
  final double missPct;
  final double kPct;
  final double exitVelocity;
  final double battingAverage;

  HitterStats({
    required this.airPullPct,
    required this.chasePct,
    required this.ninetiethRV,
    required this.bbPct,
    required this.missPct,
    required this.kPct,
    required this.exitVelocity,
    required this.battingAverage,
  });

  factory HitterStats.fromJson(Map<String, dynamic> json) {
    return HitterStats(
      airPullPct: (json['airPullPct'] ?? 0).toDouble(),
      chasePct: (json['chasePct'] ?? 0).toDouble(),
      ninetiethRV: (json['ninetiethRV'] ?? 0).toDouble(),
      bbPct: (json['bbPct'] ?? 0).toDouble(),
      missPct: (json['missPct'] ?? 0).toDouble(),
      kPct: (json['kPct'] ?? 0).toDouble(),
      exitVelocity: (json['exitVelocity'] ?? 0).toDouble(),
      battingAverage: (json['battingAverage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airPullPct': airPullPct,
      'chasePct': chasePct,
      'ninetiethRV': ninetiethRV,
      'bbPct': bbPct,
      'missPct': missPct,
      'kPct': kPct,
      'exitVelocity': exitVelocity,
      'battingAverage': battingAverage,
    };
  }
}

class SprayChartPoint {
  final double x;
  final double y;
  final String hitType; // 'single', 'double', 'triple', 'homerun', 'out'

  SprayChartPoint({
    required this.x,
    required this.y,
    required this.hitType,
  });

  factory SprayChartPoint.fromJson(Map<String, dynamic> json) {
    return SprayChartPoint(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      hitType: json['hitType'] ?? 'out',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'hitType': hitType,
    };
  }
}

class ZoneHeatmap {
  // 3x3 grid representing strike zone
  // Values from 0.0 (low) to 1.0 (high) for probability
  final List<List<double>> zones;

  ZoneHeatmap({required this.zones});

  factory ZoneHeatmap.fromJson(Map<String, dynamic> json) {
    final rawZones = json['zones'] as List<dynamic>?;
    if (rawZones == null) {
      return ZoneHeatmap(zones: [
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
      ]);
    }
    return ZoneHeatmap(
      zones: rawZones.map((row) =>
          (row as List<dynamic>).map((val) => (val as num).toDouble()).toList()
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'zones': zones};
  }
}

class ReportModel {
  final String id;
  final String playerId;
  final String playerName;
  final String position;
  final String throwsHand;
  final String reportType; // 'pitcher' or 'hitter'
  final String createdAt;
  final String? videoUrl;
  final String scoutSummary;

  // Pitcher specific
  final double? peakVelocity;
  final int? avgSpinRate;
  final List<PitchData>? pitchData;
  final List<ScatterPoint>? scatterPoints;

  // Hitter specific
  final HitterStats? hitterStats;
  final List<SprayChartPoint>? sprayChartPoints;
  final ZoneHeatmap? zoneVsLHP;
  final ZoneHeatmap? zoneVsRHP;

  ReportModel({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.throwsHand,
    required this.reportType,
    required this.createdAt,
    this.videoUrl,
    required this.scoutSummary,
    this.peakVelocity,
    this.avgSpinRate,
    this.pitchData,
    this.scatterPoints,
    this.hitterStats,
    this.sprayChartPoints,
    this.zoneVsLHP,
    this.zoneVsRHP,
  });

  factory ReportModel.pitcher({
    required String id,
    required String playerId,
    required String playerName,
    required String position,
    required String throwsHand,
    required String createdAt,
    String? videoUrl,
    required String scoutSummary,
    required double peakVelocity,
    required int avgSpinRate,
    required List<PitchData> pitchData,
    required List<ScatterPoint> scatterPoints,
  }) {
    return ReportModel(
      id: id,
      playerId: playerId,
      playerName: playerName,
      position: position,
      throwsHand: throwsHand,
      reportType: 'pitcher',
      createdAt: createdAt,
      videoUrl: videoUrl,
      scoutSummary: scoutSummary,
      peakVelocity: peakVelocity,
      avgSpinRate: avgSpinRate,
      pitchData: pitchData,
      scatterPoints: scatterPoints,
    );
  }

  factory ReportModel.hitter({
    required String id,
    required String playerId,
    required String playerName,
    required String position,
    required String throwsHand,
    required String createdAt,
    String? videoUrl,
    required String scoutSummary,
    required HitterStats hitterStats,
    required List<SprayChartPoint> sprayChartPoints,
    required ZoneHeatmap zoneVsLHP,
    required ZoneHeatmap zoneVsRHP,
  }) {
    return ReportModel(
      id: id,
      playerId: playerId,
      playerName: playerName,
      position: position,
      throwsHand: throwsHand,
      reportType: 'hitter',
      createdAt: createdAt,
      videoUrl: videoUrl,
      scoutSummary: scoutSummary,
      hitterStats: hitterStats,
      sprayChartPoints: sprayChartPoints,
      zoneVsLHP: zoneVsLHP,
      zoneVsRHP: zoneVsRHP,
    );
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final reportType = json['reportType'] ?? 'pitcher';

    return ReportModel(
      id: json['id'] ?? '',
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      position: json['position'] ?? '',
      throwsHand: json['throwsHand'] ?? 'R',
      reportType: reportType,
      createdAt: json['createdAt'] ?? '',
      videoUrl: json['videoUrl'],
      scoutSummary: json['scoutSummary'] ?? '',
      peakVelocity: json['peakVelocity']?.toDouble(),
      avgSpinRate: json['avgSpinRate'],
      pitchData: json['pitchData'] != null
          ? (json['pitchData'] as List).map((e) => PitchData.fromJson(e)).toList()
          : null,
      scatterPoints: json['scatterPoints'] != null
          ? (json['scatterPoints'] as List).map((e) => ScatterPoint.fromJson(e)).toList()
          : null,
      hitterStats: json['hitterStats'] != null
          ? HitterStats.fromJson(json['hitterStats'])
          : null,
      sprayChartPoints: json['sprayChartPoints'] != null
          ? (json['sprayChartPoints'] as List).map((e) => SprayChartPoint.fromJson(e)).toList()
          : null,
      zoneVsLHP: json['zoneVsLHP'] != null
          ? ZoneHeatmap.fromJson(json['zoneVsLHP'])
          : null,
      zoneVsRHP: json['zoneVsRHP'] != null
          ? ZoneHeatmap.fromJson(json['zoneVsRHP'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'playerId': playerId,
      'playerName': playerName,
      'position': position,
      'throwsHand': throwsHand,
      'reportType': reportType,
      'createdAt': createdAt,
      'videoUrl': videoUrl,
      'scoutSummary': scoutSummary,
    };

    if (reportType == 'pitcher') {
      map['peakVelocity'] = peakVelocity;
      map['avgSpinRate'] = avgSpinRate;
      map['pitchData'] = pitchData?.map((e) => e.toJson()).toList();
      map['scatterPoints'] = scatterPoints?.map((e) => e.toJson()).toList();
    } else {
      map['hitterStats'] = hitterStats?.toJson();
      map['sprayChartPoints'] = sprayChartPoints?.map((e) => e.toJson()).toList();
      map['zoneVsLHP'] = zoneVsLHP?.toJson();
      map['zoneVsRHP'] = zoneVsRHP?.toJson();
    }

    return map;
  }
}
