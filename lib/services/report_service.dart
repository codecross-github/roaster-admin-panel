import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/report_request_model.dart';
import 'fcm_service.dart';

class ReportService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // ── Report Requests ──

  CollectionReference get _requestsRef =>
      _firestore.collection('report_requests');

  /// Stream all report requests, ordered by requestedAt descending.
  Stream<List<ReportRequestModel>> streamReportRequests() {
    return _requestsRef
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return ReportRequestModel.fromJson(data);
            }).toList());
  }

  /// Update the status of a report request.
  Future<void> updateRequestStatus(
      String requestId, String newStatus) async {
    final update = <String, dynamic>{'status': newStatus};
    if (newStatus == 'Completed') {
      update['completedAt'] = DateTime.now().toIso8601String();
    }
    await _requestsRef.doc(requestId).update(update);
  }

  /// Link a completed report to the originating request.
  Future<void> linkReportToRequest(
      String requestId, String reportId) async {
    await _requestsRef.doc(requestId).update({
      'status': 'Completed',
      'completedAt': DateTime.now().toIso8601String(),
      'assignedReportId': reportId,
    });
  }

  // ── Reports ──

  CollectionReference get _reportsRef =>
      _firestore.collection('reports');

  /// Stream all reports, ordered by createdAt descending.
  Stream<List<ReportModel>> streamReports() {
    return _reportsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return ReportModel.fromJson(data);
            }).toList());
  }

  /// Create a new report and return the document ID.
  Future<String> createReport(ReportModel report) async {
    final json = report.toJson();
    json.remove('id');
    final docRef = await _reportsRef.add(json);
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  /// Delete a report by ID.
  Future<void> deleteReport(String reportId) async {
    await _reportsRef.doc(reportId).delete();
  }

  /// Get a single report by ID.
  Future<ReportModel?> getReport(String reportId) async {
    final doc = await _reportsRef.doc(reportId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ReportModel.fromJson(data);
  }

  // ── Video Upload ──

  /// Upload video bytes to Firebase Storage, return download URL.
  Future<String> uploadVideo(Uint8List bytes, String fileName) async {
    final ref = _storage
        .ref()
        .child('report_videos')
        .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'video/mp4'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  // ── Image Upload ──

  /// Upload player image bytes to Firebase Storage, return download URL.
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    final ref = _storage
        .ref()
        .child('report_images')
        .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  // ── Users ──

  CollectionReference get _usersRef => _firestore.collection('users');

  /// Fetch all users from the users collection.
  /// Returns a list of maps with id, name, email, isPremium.
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final snap = await _usersRef.orderBy('name').get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'isPremium': data['isPremium'] ?? false,
      };
    }).toList();
  }

  // ── Notifications ──

  /// Create a notification for a user when a report is published.
  /// Also sends an FCM push notification if the user has a device token.
  Future<void> createNotification({
    required String userId,
    required String reportId,
    required String playerName,
    required String reportType,
  }) async {
    const title = 'New Report Available';
    final message =
        'A $reportType report for $playerName is now available.';

    // 1. Create Firestore notification document
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': 'report',
      'reportId': reportId,
      'reportType': reportType,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // 2. Send FCM push notification
    try {
      final userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final fcmToken = userDoc.data()?['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('FCM: User $userId has no FCM token, skipping push.');
        return;
      }

      await FcmService.sendPushNotification(
        fcmToken: fcmToken,
        title: title,
        body: message,
        data: {
          'reportId': reportId,
          'reportType': reportType,
          'type': 'report',
        },
      );
    } catch (e) {
      debugPrint('Error sending FCM push: $e');
    }
  }

  // ── Dashboard Counts ──

  Future<int> getTotalReportsCount() async {
    final snap = await _reportsRef.count().get();
    return snap.count ?? 0;
  }

  Future<int> getPendingRequestsCount() async {
    final snap = await _requestsRef
        .where('status', isEqualTo: 'Pending')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> getInProgressRequestsCount() async {
    final snap = await _requestsRef
        .where('status', isEqualTo: 'In Progress')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> getCompletedRequestsCount() async {
    final snap = await _requestsRef
        .where('status', isEqualTo: 'Completed')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> getTotalRequestsCount() async {
    final snap = await _requestsRef.count().get();
    return snap.count ?? 0;
  }
}
