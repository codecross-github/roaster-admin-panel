import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../core/service_account.dart';

/// Service for sending FCM push notifications via the FCM HTTP v1 API.
///
/// Uses a Firebase service account to authenticate, then sends push
/// notifications directly — no Cloud Functions needed.
class FcmService {
  static const String _projectId = 'roster-radar-d95ff';
  static const String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  /// Cached access token to avoid re-authenticating on every call.
  static AccessCredentials? _cachedCredentials;

  /// Get a valid OAuth2 access token using the service account.
  static Future<String?> _getAccessToken() async {
    try {
      // Check if service account credentials are configured
      if (serviceAccountCredentials.isEmpty) {
        debugPrint('FCM: Service account credentials not configured.');
        return null;
      }

      // Re-use cached token if still valid (with 60s buffer)
      if (_cachedCredentials != null &&
          _cachedCredentials!.accessToken.expiry
              .isAfter(DateTime.now().add(const Duration(seconds: 60)))) {
        return _cachedCredentials!.accessToken.data;
      }

      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountCredentials);

      final client = http.Client();
      try {
        _cachedCredentials = await obtainAccessCredentialsViaServiceAccount(
          accountCredentials,
          _scopes,
          client,
        );
        return _cachedCredentials!.accessToken.data;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('FCM: Error getting access token: $e');
      return null;
    }
  }

  /// Send an FCM push notification to a specific device token.
  ///
  /// Returns `true` if the message was sent successfully.
  static Future<bool> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      debugPrint('FCM: No access token, skipping push.');
      return false;
    }

    try {
      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          if (data != null) 'data': data,
          'android': {
            'notification': {
              'channel_id': 'report_notifications',
              'sound': 'default',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'badge': 1,
                'sound': 'default',
              },
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM: Push notification sent successfully.');
        return true;
      } else {
        debugPrint('FCM: Failed (${response.statusCode}): ${response.body}');

        // If token is invalid, return false so caller can clean it up
        if (response.statusCode == 404 || response.statusCode == 400) {
          final responseBody = jsonDecode(response.body);
          final errorCode = responseBody['error']?['details']?[0]
                  ?['errorCode'] ??
              '';
          if (errorCode == 'UNREGISTERED' || errorCode == 'INVALID_ARGUMENT') {
            debugPrint('FCM: Token is invalid/unregistered.');
          }
        }
        return false;
      }
    } catch (e) {
      debugPrint('FCM: Error sending push: $e');
      return false;
    }
  }
}
