# Jitsi Meeting Integration Guide for Dhairya

## Overview
This document outlines the complete Jitsi meeting integration for the Dhairya app, including lecture creation, attendance tracking, and notifications.

## Architecture

### 1. Meeting Creation Flow

```
Teacher Creates Lecture
    ↓
JitsiMeetingService generates room name & URL
    ↓
Lecture stored in DB with:
    - jitsi_room_name
    - jitsi_meeting_url
    ↓
Parent notified via notification (Edge Function)
    ↓
Notification scheduled for 10 mins before lecture
```

### 2. Meeting Attendance Flow

```
Participant joins meeting via URL
    ↓
JitsiMeetingPage opened with user details
    ↓
logAttendanceEvent('joined') recorded in DB
    ↓
Participant leaves/meeting ends
    ↓
logAttendanceEvent('left') recorded
    ↓
Attendance summary calculated
```

### 3. Notification Flow

```
Lecture created → Trigger Edge Function
    ↓
Get student's parent email
    ↓
Send notification via Firebase Messaging
    ↓
10 mins before: Send reminder to all participants
```

## Implementation Details

### Database Changes

**New Tables:**
- `lecture_attendance_events` - Track join/leave events with timestamps
- New columns in `lectures` table:
  - `jitsi_room_name` - Unique room identifier
  - `jitsi_meeting_url` - Full Jitsi meeting URL

**Indexes:**
- `idx_lecture_attendance_events_lecture_id`
- `idx_lecture_attendance_events_participant_id`
- `idx_lecture_attendance_events_event_time`

### Code Components

#### 1. Utilities (`jitsi_meeting_utils.dart`)
```dart
// Generate room name
String roomName = JitsiMeetingUtils.generateRoomName(lectureId);

// Generate meeting URL with user params
String url = JitsiMeetingUtils.generateMeetingUrl(
  roomName: roomName,
  displayName: userName,
  email: userEmail,
  avatarUrl: profilePicUrl,
  startWithAudioMuted: isStudent,
);
```

#### 2. Data Source (`lecture_attendance_data_source.dart`)
```dart
// Log join/leave
await dataSource.logAttendanceEvent(
  lectureId: lectureId,
  participantId: userId,
  participantName: userName,
  eventType: 'joined',
);

// Get summary
Map summary = await dataSource.getAttendanceSummary(lectureId);
// Returns: { totalParticipants, presentCount, participantsPresent }
```

#### 3. Service (`jitsi_meeting_service.dart`)
```dart
// Create meeting
Map meeting = JitsiMeetingService.createMeeting(lectureId);
// Returns: { roomName, meetingUrl }

// Generate user-specific URL
String userUrl = JitsiMeetingService.generateUserMeetingUrl(
  roomName: roomName,
  userName: currentUser.name,
  userEmail: currentUser.email,
  userProfilePicUrl: currentUser.profilePic,
  isTeacher: true,
);
```

#### 4. UI Page (`jitsi_meeting_page.dart`)
```dart
JitsiMeetingPage(
  lectureId: lectureId,
  roomName: roomName,
  userName: userName,
  userEmail: userEmail,
  userRole: 'teacher', // or 'student', 'admin'
  userProfilePicUrl: profileUrl,
  onAttendanceEvent: (event) {
    // 'joined' or 'left'
    logToBackend(event);
  },
)
```

## Integration Steps

### Step 1: Create Lecture with Jitsi Integration

In `teacher_create_lecture_page.dart`:

```dart
void _createLecture() {
  // ... validation ...
  
  // Generate Jitsi meeting
  final meetingData = JitsiMeetingService.createMeeting(lectureId);
  
  context.read<LecturesBloc>().add(
    CreateOneTimeLectureEvent(
      assignmentId: _selectedAssignment!.id,
      teacherUid: widget.teacherUid,
      studentUid: _selectedAssignment!.studentUid,
      subject: _selectedSubject!,
      scheduledDate: _selectedDate!,
      scheduledTime: timeSlot,
      meetingLink: meetingData['meetingUrl'], // Auto-generated URL
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    ),
  );
}
```

### Step 2: Notify Parent on Lecture Creation

Create Edge Function: `notify-lecture-created`

```typescript
// Trigger when lecture is created
// Get parent's FCM token
// Send notification with lecture details
```

### Step 3: Schedule Pre-Lecture Reminder

Use pg_cron or Firebase functions:

```sql
SELECT cron.schedule(
  'lecture_reminders',
  '*/5 * * * *', -- Every 5 minutes
  $$
    SELECT send_lecture_reminder()
  $$
);
```

### Step 4: Join Meeting and Track Attendance

In lecture details page:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JitsiMeetingPage(
          lectureId: lecture.id,
          roomName: lecture.jitsiRoomName!,
          userName: currentUser.name,
          userEmail: currentUser.email,
          userRole: 'student',
          onAttendanceEvent: (event) {
            // Log to backend
            context.read<LecturesBloc>().add(
              LogAttendanceEvent(
                lectureId: lecture.id,
                eventType: event, // 'joined' or 'left'
              ),
            );
          },
        ),
      ),
    );
  },
  child: const Text('Join Meeting'),
)
```

## Features Implemented

### ✅ Jitsi Meeting Creation
- Automatic room name generation (format: `lecture_{id}_{hash}`)
- URL generation with user parameters
- Support for teacher, student, admin roles

### ✅ Attendance Tracking
- Join event logging
- Leave event logging
- Duration calculation
- Present/absent determination

### ✅ Meeting Page
- Simple browser launch interface
- User information display
- Confirmation before joining

### ⏳ TODO: Edge Functions
- Lecture creation notification
- Parent notification on lecture created
- Pre-lecture (10 min) reminder
- Post-lecture attendance summary

### ⏳ TODO: Repository Integration
- Update LecturesRepository to handle Jitsi URLs
- Integration with attendance data source
- Notification repository updates

## Environment Variables

Add to `.env`:
```
JITSI_DOMAIN=meet.jitsi.us
JITSI_API_URL=https://meet.jitsi.us
```

Or configure in `jitsi_meeting_utils.dart`:
```dart
static const String jitsiDomain = 'meet.jitsi.us';
```

## Self-Hosting Option

If you want to self-host Jitsi:

```bash
# Clone docker compose
git clone https://github.com/jitsi/docker-jitsi-meet.git
cd docker-jitsi-meet

# Configure and run
docker-compose up -d

# Access at: https://your-domain.com
```

Then update `jitsi_meeting_utils.dart`:
```dart
static const String jitsiDomain = 'your-jitsi-domain.com';
```

## Testing

### Test Attendance Logging
```dart
test('logs join event', () async {
  await dataSource.logAttendanceEvent(
    lectureId: 'lecture1',
    participantId: 'student1',
    participantName: 'John Doe',
    eventType: 'joined',
  );
  
  final summary = await dataSource.getAttendanceSummary('lecture1');
  expect(summary['presentCount'], 1);
});
```

### Test Room Name Generation
```dart
test('generates valid room name', () {
  final roomName = JitsiMeetingUtils.generateRoomName('lecture123');
  expect(JitsiMeetingUtils.isValidRoomName(roomName), true);
  expect(roomName, contains('lecture_'));
});
```

## Security Considerations

1. **Room Access Control**
   - Jitsi rooms are public by default
   - Consider using JWT tokens for secure rooms (advanced)
   - Or use password-protected rooms

2. **Data Privacy**
   - Attendance events stored in Supabase
   - Participant names/emails logged
   - Implement data retention policies

3. **Meeting Recording**
   - Enable/disable recording per lecture
   - Store recordings securely
   - Get consent before recording

## Pricing Analysis

**Jitsi (Cloud - meet.jitsi.us)**: **$0** - Free forever, unlimited meetings
**Self-hosted**: **$0** - Free (infrastructure costs only)
**Google Meet**: $6-18/user/month (requires Google Workspace)
**Zoom**: $15.99/month pro, $10.99/student

**Recommendation**: Use Jitsi cloud (free, no limits, no setup)

## Troubleshooting

### Meeting URL not opening
- Check URL format validation
- Verify room name is valid (alphanumeric, hyphens, underscores only)
- Check internet connection

### Attendance not logging
- Verify database migration applied
- Check Supabase permissions on table
- Verify participant ID is captured correctly

### Notification not sent
- Check Firebase Cloud Messaging setup
- Verify user FCM tokens registered
- Check Edge Function logs

## Next Phase Features

1. Real-time participant list in app
2. In-app chat integration
3. Meeting recording storage
4. Attendance reports/analytics
5. Recurring meeting automation
6. Meeting waitlist/approval system
