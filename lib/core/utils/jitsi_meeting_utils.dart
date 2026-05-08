import 'package:crypto/crypto.dart';

/// Jitsi Meeting configuration and utilities
class JitsiMeetingUtils {
  // Environment configuration
  static const String jitsiDomain = 'meet.jitsi.us'; // Can be changed to self-hosted
  static const String baseUrl = 'https://$jitsiDomain';

  /// Generate a unique room name based on lecture ID and timestamp
  /// Format: lecture_{lectureId}_{timestamp}_{randomHash}
  static String generateRoomName(String lectureId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHash = md5.convert('$lectureId$timestamp'.codeUnits).toString().substring(0, 8);
    return 'lecture_${lectureId}_${randomHash}'.toLowerCase();
  }

  /// Generate full Jitsi meeting URL with parameters
  static String generateMeetingUrl({
    required String roomName,
    required String displayName,
    String? email,
    String? avatarUrl,
    bool startWithAudioMuted = false,
    bool startWithVideoMuted = false,
    bool showWatermark = false,
  }) {
    final buffer = StringBuffer('$baseUrl/$roomName?');

    // Add display name
    buffer.write('displayName=${Uri.encodeComponent(displayName)}&');

    // Add email if provided
    if (email != null && email.isNotEmpty) {
      buffer.write('email=${Uri.encodeComponent(email)}&');
    }

    // Add avatar if provided
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      buffer.write('avatarUrl=${Uri.encodeComponent(avatarUrl)}&');
    }

    // Audio/Video configuration
    buffer.write('config.startWithAudioMuted=$startWithAudioMuted&');
    buffer.write('config.startWithVideoMuted=$startWithVideoMuted&');

    // UI configuration
    buffer.write('interfaceConfig.SHOW_JITSI_WATERMARK=$showWatermark&');
    buffer.write('interfaceConfig.SHOW_WATERMARK_FOR_GUESTS=false&');

    // Remove trailing &
    return buffer.toString().replaceAll(RegExp(r'&$'), '');
  }

  /// Parse room name from URL
  static String? getRoomNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    } catch (e) {
      return null;
    }
  }

  /// Validate room name format
  static bool isValidRoomName(String roomName) {
    // Jitsi allows alphanumeric, hyphens, and underscores
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(roomName);
  }
}
