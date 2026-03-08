# Phase 5: Push Notifications Setup Guide

## Overview
This phase implements server-side push notifications using Firebase Cloud Messaging (FCM) to send lecture reminders even when the app is closed.

## Architecture
- **Supabase Edge Functions** - Server-side notification logic (TypeScript/Deno)
- **Firebase Admin SDK** - Send push notifications to devices
- **Flutter Firebase Messaging** - Receive notifications in app
- **pg_cron** - Scheduled task runner for automatic notification processing

---

## 1. Firebase Setup

### A. Create/Get Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your existing project or create a new one
3. Add Android and iOS apps to your Firebase project

### B. Get Firebase Service Account Key
1. Go to **Project Settings** → **Service Accounts**
2. Click **Generate New Private Key**
3. Download the JSON file
4. Extract these values from the JSON:
   - `project_id`
   - `client_email`
   - `private_key`

### C. Configure Flutter App
1. Download `google-services.json` (Android) from Firebase Console
2. Place in `android/app/google-services.json`
3. Download `GoogleService-Info.plist` (iOS) from Firebase Console
4. Place in `ios/Runner/GoogleService-Info.plist`

---

## 2. Supabase Edge Functions Setup

### A. Set Supabase Secrets
Run these commands in your terminal:

```bash
# Navigate to project root
cd "c:\Flutter projects\Dhairya"

# Set Firebase configuration secrets
supabase secrets set FIREBASE_PROJECT_ID="your-project-id"
supabase secrets set FIREBASE_CLIENT_EMAIL="your-service-account-email@your-project.iam.gserviceaccount.com"
supabase secrets set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"

# Verify secrets
supabase secrets list
```

### B. Deploy Edge Functions
```bash
# Deploy send-lecture-notification function
supabase functions deploy send-lecture-notification

# Deploy process-pending-notifications function
supabase functions deploy process-pending-notifications

# Verify deployment
supabase functions list
```

---

## 3. Setup pg_cron Job

### A. Run Cron Setup SQL
1. Open Supabase Dashboard → **SQL Editor**
2. Run the SQL from `supabase/migrations/cron_jobs.sql`
3. **IMPORTANT:** Replace placeholders:
   - `YOUR_PROJECT_REF` → Your Supabase project reference (from URL)
   - `YOUR_SERVICE_ROLE_KEY` → Your service role key (Project Settings → API)

### B. Verify Cron Job
```sql
-- Check if job is scheduled
SELECT * FROM cron.job WHERE jobname = 'process-pending-notifications';

-- Check recent runs
SELECT * FROM cron.job_run_details 
WHERE jobname = 'process-pending-notifications' 
ORDER BY start_time DESC 
LIMIT 5;
```

---

## 4. Flutter App Configuration

### A. Add Firebase Messaging Package
Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

Run:
```bash
flutter pub get
```

### B. Initialize Firebase in App
Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_service.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Supabase (existing code)
  await Supabase.initialize(...);
  
  // ... rest of your initialization
  
  runApp(MyApp());
}
```

### C. Register FCM Service in Dependency Injection
Update `lib/init_dependencies.dart`:

```dart
import 'core/services/fcm_service.dart';

void _initServices() {
  serviceLocator
    ..registerLazySingleton(
      () => FCMService(serviceLocator<SupabaseClient>()),
    );
}

// Call in initDependencies()
Future<void> initDependencies() async {
  // ... existing initialization
  _initServices();
}
```

### D. Initialize FCM on Login
In your auth success handler:

```dart
// After successful login
final fcmService = serviceLocator<FCMService>();
await fcmService.initialize();
```

### E. Cleanup on Logout
```dart
// Before logout
final fcmService = serviceLocator<FCMService>();
await fcmService.deactivateToken();
```

---

## 5. Testing Notifications

### A. Test Sending Notification
```bash
# Call edge function directly
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-lecture-notification' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "notificationId": "notification-id-from-db",
    "userId": "user-uuid",
    "title": "Test Lecture Reminder",
    "body": "Your Math lecture starts in 10 minutes"
  }'
```

### B. Schedule Test Notification
```sql
-- Insert a test notification in Supabase SQL Editor
INSERT INTO lecture_notifications (
  lecture_id,
  scheduled_for,
  notification_type,
  is_sent
) VALUES (
  'your-lecture-id',
  NOW() + INTERVAL '1 minute', -- Will fire in 1 minute
  'lecture_reminder',
  false
);

-- Check if it gets processed by cron job
SELECT * FROM lecture_notifications 
WHERE id = 'the-id-you-just-inserted';
```

### C. Monitor Logs
```bash
# View Edge Function logs
supabase functions logs send-lecture-notification
supabase functions logs process-pending-notifications

# View cron job logs
-- In Supabase SQL Editor
SELECT * FROM cron.job_run_details 
WHERE jobname = 'process-pending-notifications' 
ORDER BY start_time DESC;
```

---

## 6. Android Configuration

Add to `android/app/build.gradle`:
```gradle
plugins {
    // ... existing plugins
    id 'com.google.gms.google-services'  // Add this
}
```

Add to `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'  // Add this
    }
}
```

---

## 7. iOS Configuration

Update `ios/Runner/Info.plist`:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

---

## 8. Notification Scheduling Flow

### When Teacher Creates Recurring Lecture Template:
```dart
// 1. Create template
final templateId = await createRecurringLectureTemplate(...);

// 2. Schedule notification for first occurrence
final firstLecture = occurrenceCalculator.getNextOccurrence(template);
final notificationTime = firstLecture.scheduledDate.subtract(
  Duration(minutes: template.notificationMinutesBefore)
);

await scheduleNotification(
  templateId: templateId,
  scheduledFor: notificationTime,
  notificationType: 'lecture_reminder',
);

// 3. Cron job will process it automatically when time comes
```

---

## Troubleshooting

### No notifications received?
1. Check FCM token is registered: `SELECT * FROM user_fcm_tokens WHERE user_id = 'your-user-id'`
2. Check notification is scheduled: `SELECT * FROM lecture_notifications WHERE is_sent = false`
3. Check cron job is running: `SELECT * FROM cron.job_run_details`
4. Check Edge Function logs: `supabase functions logs`

### Invalid FCM token errors?
- Tokens expire/change - the system automatically marks them inactive
- User may need to re-login to refresh token

### Cron job not running?
- Verify pg_cron extension is enabled: `SELECT * FROM pg_extension WHERE extname = 'pg_cron'`
- Check job exists: `SELECT * FROM cron.job`
- Ensure service role key in cron SQL is correct

---

## Security Notes
- **Never commit** Firebase private keys or service role keys to git
- Use environment variables/secrets for all sensitive data
- Service role key should only be used server-side (Edge Functions, cron jobs)
- Client apps use anon key (already configured)
