class ReportRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String playerId;
  final String playerName;
  final String playerPosition;
  final String reportType; // 'pitcher' or 'hitter'
  final String status; // 'Pending', 'In Progress', 'Completed'
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? assignedReportId;

  ReportRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.playerId,
    required this.playerName,
    required this.playerPosition,
    required this.reportType,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.assignedReportId,
  });

  factory ReportRequestModel.fromJson(Map<String, dynamic> json) {
    return ReportRequestModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      playerPosition: json['playerPosition'] ?? '',
      reportType: json['reportType'] ?? 'pitcher',
      status: json['status'] ?? 'Pending',
      requestedAt: DateTime.parse(json['requestedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      assignedReportId: json['assignedReportId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'playerId': playerId,
      'playerName': playerName,
      'playerPosition': playerPosition,
      'reportType': reportType,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'assignedReportId': assignedReportId,
    };
  }
}
