import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aparna_education/core/router/app_router.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/pages/teacher_interest_list_page.dart' as aparna_education_interest_page;

/// Service to manage Firebase Cloud Messaging tokens and notifications
/// Handles token registration, refresh, and notification reception
class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabaseClient;

  FCMService(this._supabaseClient);

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      // Request notification permissions (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('FCM: User granted provisional notification permissions');
      } else {
        debugPrint('FCM: User declined notification permissions');
        return;
      }

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _registerToken(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _registerToken(newToken);
      });

      // Setup message handlers
      _setupMessageHandlers();

    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// Register FCM token in Supabase
  Future<void> _registerToken(String token) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('FCM: No authenticated user, skipping token registration');
        return;
      }

      // Check if token already exists
      final existingToken = await _supabaseClient
          .from('user_fcm_tokens')
          .select('id')
          .eq('user_id', userId)
          .eq('fcm_token', token)
          .maybeSingle();

      if (existingToken != null) {
        // Update existing token (mark as active)
        await _supabaseClient
            .from('user_fcm_tokens')
            .update({
              'is_active': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('fcm_token', token);
        
        debugPrint('FCM: Updated existing token');
      } else {
        // Insert new token
        await _supabaseClient
            .from('user_fcm_tokens')
            .insert({
              'user_id': userId,
              'fcm_token': token,
              'platform': _getPlatform(),
              'is_active': true,
            });
        
        debugPrint('FCM: Registered new token');
      }
    } catch (e) {
      debugPrint('FCM: Token registration error: $e');
    }
  }

  /// Deactivate FCM token (call on logout)
  Future<void> deactivateToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (token != null && userId != null) {
        await _supabaseClient
            .from('user_fcm_tokens')
            .update({
              'is_active': false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('fcm_token', token);
        
        debugPrint('FCM: Token deactivated');
      }
    } catch (e) {
      debugPrint('FCM: Token deactivation error: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM: Foreground message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // Handle foreground notification
      _handleForegroundMessage(message);
    });

    // Background message tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM: Background message tapped');
      debugPrint('Data: ${message.data}');

      // Handle notification tap
      _handleNotificationTap(message);
    });

    // Terminated state - get initial message
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('FCM: App opened from terminated state');
        debugPrint('Data: ${message.data}');

        // Handle notification tap
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle foreground message (show in-app notification)
  void _handleForegroundMessage(RemoteMessage message) {
    // TODO: Show in-app notification banner/dialog
    // This will be implemented in UI layer
    // For now, just log
    debugPrint('Foreground notification: ${message.notification?.title}');
  }

  /// Handle notification tap (navigate to relevant screen)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped data: \${message.data}');
    final notificationType = message.data['notificationType'];

    // Delay slightly to ensure UI is ready if app was terminated
    Future.delayed(const Duration(milliseconds: 500), () {
      final navigatorState = navigatorKey.currentState;
      if (navigatorState == null) return;

      if (notificationType == 'TEACHER_INTEREST_REQUEST') {
        final requestId = message.data['requestId'];
        if (requestId != null) {
          // Navigate to Teacher Interest list (as we only have current user's UID in auth, we can just push)
          final currentUser = _supabaseClient.auth.currentUser;
          if (currentUser != null) {
            navigatorState.push(MaterialPageRoute(
               builder: (_) => aparna_education_interest_page.TeacherInterestListPage(teacherUid: currentUser.id)
            ));
          }
        }
      } else if (notificationType == 'TEACHER_ASSIGNED') {
        // ...
      }
    });

    final lectureId = message.data['lectureId'];
    final templateId = message.data['templateId'];
    
    // Existing logic for lectureId / templateId can go here.
    debugPrint('Notification tapped - lectureId: $lectureId, templateId: $templateId');
  }

  /// Get device type for logging
  String _getDeviceType() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'windows';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macos';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'linux';
    } else {
      return 'web';
    }
  }

  /// Get platform for database
  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'windows';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macos';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'linux';
    } else {
      return 'web';
    }
  }

  /// Delete all tokens for current user (useful for cleanup)
  Future<void> deleteAllTokens() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        await _supabaseClient
            .from('user_fcm_tokens')
            .delete()
            .eq('user_id', userId);
        
        debugPrint('FCM: All tokens deleted');
      }
    } catch (e) {
      debugPrint('FCM: Token deletion error: $e');
    }
  }
}

/// Background message handler (must be top-level function)
/// Called when app is in background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM: Background message handler triggered');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  
  // Handle background message processing here
  // Keep it lightweight - heavy work should be done when app opens
}
