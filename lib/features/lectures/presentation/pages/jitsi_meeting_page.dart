import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aparna_education/core/utils/jitsi_meeting_utils.dart';
import 'package:aparna_education/core/widgets/animations.dart';

class JitsiMeetingPage extends StatefulWidget {
  final String lectureId;
  final String roomName;
  final String userEmail;
  final String userName;
  final String userRole; // 'teacher', 'student', 'admin'
  final String? userProfilePicUrl;
  final Function(String eventType) onAttendanceEvent; // 'joined' or 'left'

  const JitsiMeetingPage({
    super.key,
    required this.lectureId,
    required this.roomName,
    required this.userEmail,
    required this.userName,
    required this.userRole,
    this.userProfilePicUrl,
    required this.onAttendanceEvent,
  });

  @override
  State<JitsiMeetingPage> createState() => _JitsiMeetingPageState();
}

class _JitsiMeetingPageState extends State<JitsiMeetingPage> {
  late String _meetingUrl;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _meetingUrl = JitsiMeetingUtils.generateMeetingUrl(
      roomName: widget.roomName,
      displayName: widget.userName,
      email: widget.userEmail,
      avatarUrl: widget.userProfilePicUrl,
      startWithAudioMuted: widget.userRole == 'student',
      startWithVideoMuted: false,
      showWatermark: true,
    );
    
    // Simulate join event (in real implementation, track via API)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAttendanceEvent('joined');
    });
  }

  Future<void> _launchMeeting() async {
    setState(() => _isLaunching = true);
    
    final Uri uri = Uri.parse(_meetingUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch meeting')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLaunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FadeInSlide(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.videocam,
                  size: 64,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Jitsi Meeting',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Room: ${widget.roomName}',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Joining as: ${widget.userName}',
                style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLaunching)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Opening meeting...',
                      style: tt.bodyMedium,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _launchMeeting,
                        icon: const Icon(Icons.launch),
                        label: const Text('Join Meeting'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'The meeting will open in your browser. Your name and email will be shared.',
                              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              if (!_isLaunching)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: tt.labelLarge?.copyWith(color: cs.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

