import 'package:aparna_education/core/utils/jitsi_meeting_utils.dart';

/// Service for managing Jitsi meeting creation and URLs
class JitsiMeetingService {
  /// Create a Jitsi meeting for a lecture
  /// Returns map with room name and meeting URL
  static Map<String, String> createMeeting(String lectureId) {
    final roomName = JitsiMeetingUtils.generateRoomName(lectureId);
    final meetingUrl = JitsiMeetingUtils.generateMeetingUrl(
      roomName: roomName,
      displayName: 'Lecturer',
    );

    return {
      'roomName': roomName,
      'meetingUrl': meetingUrl,
    };
  }

  /// Generate user-specific meeting URL
  static String generateUserMeetingUrl({
    required String roomName,
    required String userName,
    required String userEmail,
    String? userProfilePicUrl,
    bool isTeacher = false,
  }) {
    return JitsiMeetingUtils.generateMeetingUrl(
      roomName: roomName,
      displayName: userName,
      email: userEmail,
      avatarUrl: userProfilePicUrl,
      startWithAudioMuted: !isTeacher, // Mute students by default
      startWithVideoMuted: false,
      showWatermark: true,
    );
  }

  /// Validate meeting URL
  static bool isValidMeetingUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' && uri.host.contains('meet.jitsi.us');
    } catch (e) {
      return false;
    }
  }
}
