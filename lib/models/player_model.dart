import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerModel {
  final String id;

  // Player bio
  final String fullName;
  final String profilePictureUrl;
  final String jerseyNumber;
  final String position;
  final String bats;
  final String throws_;
  final String height;
  final String weight;
  final String status;
  final String age;
  final String birthdate;
  final String birthplace;

  // Team / transaction info
  final String date;
  final String team;
  final String teamLogoUrl;
  final String player;
  final String transactionType;
  final String transaction;
  final String playerUrl;

  // Draft info
  final String draftYear;
  final String draftTeam;
  final String draftRound;
  final String draftOverallPick;
  final String college;
  final String mlbDebut;

  // Level
  final String affiliateLevel;
  final String highestLevel;

  // MiLB Pitching
  final String milbPW;
  final String milbPL;
  final String milbPEra;
  final String milbPG;
  final String milbPGS;
  final String milbPSV;
  final String milbPIP;
  final String milbPSO;
  final String milbPWhip;

  // MLB Pitching
  final String mlbPW;
  final String mlbPL;
  final String mlbPEra;
  final String mlbPG;
  final String mlbPGS;
  final String mlbPSV;
  final String mlbPIP;
  final String mlbPSO;
  final String mlbPWhip;

  // MiLB Batting
  final String milbBAB;
  final String milbBR;
  final String milbBH;
  final String milbBHR;
  final String milbBRBI;
  final String milbBSB;
  final String milbBAvg;
  final String milbBObp;
  final String milbBOps;

  // MLB Batting
  final String mlbBAB;
  final String mlbBR;
  final String mlbBH;
  final String mlbBHR;
  final String mlbBRBI;
  final String mlbBSB;
  final String mlbBAvg;
  final String mlbBObp;
  final String mlbBOps;

  final DateTime? createdAt;

  PlayerModel({
    required this.id,
    this.fullName = '',
    this.profilePictureUrl = '',
    this.jerseyNumber = '',
    this.position = '',
    this.bats = '',
    this.throws_ = '',
    this.height = '',
    this.weight = '',
    this.status = '',
    this.age = '',
    this.birthdate = '',
    this.birthplace = '',
    this.date = '',
    this.team = '',
    this.teamLogoUrl = '',
    this.player = '',
    this.transactionType = '',
    this.transaction = '',
    this.playerUrl = '',
    this.draftYear = '',
    this.draftTeam = '',
    this.draftRound = '',
    this.draftOverallPick = '',
    this.college = '',
    this.mlbDebut = '',
    this.affiliateLevel = '',
    this.highestLevel = '',
    this.milbPW = '',
    this.milbPL = '',
    this.milbPEra = '',
    this.milbPG = '',
    this.milbPGS = '',
    this.milbPSV = '',
    this.milbPIP = '',
    this.milbPSO = '',
    this.milbPWhip = '',
    this.mlbPW = '',
    this.mlbPL = '',
    this.mlbPEra = '',
    this.mlbPG = '',
    this.mlbPGS = '',
    this.mlbPSV = '',
    this.mlbPIP = '',
    this.mlbPSO = '',
    this.mlbPWhip = '',
    this.milbBAB = '',
    this.milbBR = '',
    this.milbBH = '',
    this.milbBHR = '',
    this.milbBRBI = '',
    this.milbBSB = '',
    this.milbBAvg = '',
    this.milbBObp = '',
    this.milbBOps = '',
    this.mlbBAB = '',
    this.mlbBR = '',
    this.mlbBH = '',
    this.mlbBHR = '',
    this.mlbBRBI = '',
    this.mlbBSB = '',
    this.mlbBAvg = '',
    this.mlbBObp = '',
    this.mlbBOps = '',
    this.createdAt,
  });

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlayerModel(
      id: doc.id,
      fullName: data['Full_Name'] ?? '',
      profilePictureUrl: data['Profile_Picture_URL'] ?? '',
      jerseyNumber: data['Jersey_Number'] ?? '',
      position: data['Position'] ?? '',
      bats: data['Bats'] ?? '',
      throws_: data['Throws'] ?? '',
      height: data['Height'] ?? '',
      weight: data['Weight'] ?? '',
      status: data['Status'] ?? '',
      age: data['Age'] ?? '',
      birthdate: data['Birthdate'] ?? '',
      birthplace: data['Birthplace'] ?? '',
      date: data['Date'] ?? '',
      team: data['Team'] ?? '',
      teamLogoUrl: data['Team_Logo_URL'] ?? '',
      player: data['Player'] ?? '',
      transactionType: data['Transaction_Type'] ?? '',
      transaction: data['Transaction'] ?? '',
      playerUrl: data['Player_URL'] ?? '',
      draftYear: data['Draft_Year'] ?? '',
      draftTeam: data['Draft_Team'] ?? '',
      draftRound: data['Draft_Round'] ?? '',
      draftOverallPick: data['Draft_Overall_Pick'] ?? '',
      college: data['College'] ?? '',
      mlbDebut: data['MLB_Debut'] ?? '',
      affiliateLevel: data['Affiliate_Level'] ?? '',
      highestLevel: data['Highest_Level'] ?? '',
      milbPW: data['MiLB_P_W'] ?? '',
      milbPL: data['MiLB_P_L'] ?? '',
      milbPEra: data['MiLB_P_ERA'] ?? '',
      milbPG: data['MiLB_P_G'] ?? '',
      milbPGS: data['MiLB_P_GS'] ?? '',
      milbPSV: data['MiLB_P_SV'] ?? '',
      milbPIP: data['MiLB_P_IP'] ?? '',
      milbPSO: data['MiLB_P_SO'] ?? '',
      milbPWhip: data['MiLB_P_WHIP'] ?? '',
      mlbPW: data['MLB_P_W'] ?? '',
      mlbPL: data['MLB_P_L'] ?? '',
      mlbPEra: data['MLB_P_ERA'] ?? '',
      mlbPG: data['MLB_P_G'] ?? '',
      mlbPGS: data['MLB_P_GS'] ?? '',
      mlbPSV: data['MLB_P_SV'] ?? '',
      mlbPIP: data['MLB_P_IP'] ?? '',
      mlbPSO: data['MLB_P_SO'] ?? '',
      mlbPWhip: data['MLB_P_WHIP'] ?? '',
      milbBAB: data['MiLB_B_AB'] ?? '',
      milbBR: data['MiLB_B_R'] ?? '',
      milbBH: data['MiLB_B_H'] ?? '',
      milbBHR: data['MiLB_B_HR'] ?? '',
      milbBRBI: data['MiLB_B_RBI'] ?? '',
      milbBSB: data['MiLB_B_SB'] ?? '',
      milbBAvg: data['MiLB_B_AVG'] ?? '',
      milbBObp: data['MiLB_B_OBP'] ?? '',
      milbBOps: data['MiLB_B_OPS'] ?? '',
      mlbBAB: data['MLB_B_AB'] ?? '',
      mlbBR: data['MLB_B_R'] ?? '',
      mlbBH: data['MLB_B_H'] ?? '',
      mlbBHR: data['MLB_B_HR'] ?? '',
      mlbBRBI: data['MLB_B_RBI'] ?? '',
      mlbBSB: data['MLB_B_SB'] ?? '',
      mlbBAvg: data['MLB_B_AVG'] ?? '',
      mlbBObp: data['MLB_B_OBP'] ?? '',
      mlbBOps: data['MLB_B_OPS'] ?? '',
      createdAt: (data['_createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Full_Name': fullName,
      'Profile_Picture_URL': profilePictureUrl,
      'Jersey_Number': jerseyNumber,
      'Position': position,
      'Bats': bats,
      'Throws': throws_,
      'Height': height,
      'Weight': weight,
      'Status': status,
      'Age': age,
      'Birthdate': birthdate,
      'Birthplace': birthplace,
      'Date': date,
      'Team': team,
      'Team_Logo_URL': teamLogoUrl,
      'Player': player,
      'Transaction_Type': transactionType,
      'Transaction': transaction,
      'Player_URL': playerUrl,
      'Draft_Year': draftYear,
      'Draft_Team': draftTeam,
      'Draft_Round': draftRound,
      'Draft_Overall_Pick': draftOverallPick,
      'College': college,
      'MLB_Debut': mlbDebut,
      'Affiliate_Level': affiliateLevel,
      'Highest_Level': highestLevel,
      'MiLB_P_W': milbPW,
      'MiLB_P_L': milbPL,
      'MiLB_P_ERA': milbPEra,
      'MiLB_P_G': milbPG,
      'MiLB_P_GS': milbPGS,
      'MiLB_P_SV': milbPSV,
      'MiLB_P_IP': milbPIP,
      'MiLB_P_SO': milbPSO,
      'MiLB_P_WHIP': milbPWhip,
      'MLB_P_W': mlbPW,
      'MLB_P_L': mlbPL,
      'MLB_P_ERA': mlbPEra,
      'MLB_P_G': mlbPG,
      'MLB_P_GS': mlbPGS,
      'MLB_P_SV': mlbPSV,
      'MLB_P_IP': mlbPIP,
      'MLB_P_SO': mlbPSO,
      'MLB_P_WHIP': mlbPWhip,
      'MiLB_B_AB': milbBAB,
      'MiLB_B_R': milbBR,
      'MiLB_B_H': milbBH,
      'MiLB_B_HR': milbBHR,
      'MiLB_B_RBI': milbBRBI,
      'MiLB_B_SB': milbBSB,
      'MiLB_B_AVG': milbBAvg,
      'MiLB_B_OBP': milbBObp,
      'MiLB_B_OPS': milbBOps,
      'MLB_B_AB': mlbBAB,
      'MLB_B_R': mlbBR,
      'MLB_B_H': mlbBH,
      'MLB_B_HR': mlbBHR,
      'MLB_B_RBI': mlbBRBI,
      'MLB_B_SB': mlbBSB,
      'MLB_B_AVG': mlbBAvg,
      'MLB_B_OBP': mlbBObp,
      'MLB_B_OPS': mlbBOps,
    };
  }

  bool get isPitcher {
    final pos = position.toUpperCase();
    return pos == 'P' || pos == 'RHP' || pos == 'LHP';
  }

  String get displayName => fullName.isNotEmpty ? fullName : player;

  String get statsDisplay {
    if (isPitcher) {
      final era = milbPEra.isNotEmpty ? milbPEra : 'N/A';
      final whip = milbPWhip.isNotEmpty ? milbPWhip : 'N/A';
      return 'ERA: $era | WHIP: $whip';
    } else {
      final avg = milbBAvg.isNotEmpty ? milbBAvg : 'N/A';
      final hr = milbBHR.isNotEmpty ? milbBHR : '0';
      final rbi = milbBRBI.isNotEmpty ? milbBRBI : '0';
      return 'AVG: $avg | HR: $hr | RBI: $rbi';
    }
  }

  /// Infer league from Firestore data.
  String get league {
    final level = highestLevel.toUpperCase();
    if (level.contains('MLB')) return 'MLB';
    return 'MiLB';
  }
}
