# 🏢 Admin Quick Start Guide - Lecture Request Management

## Overview
This guide covers everything admins need to know to manage the new lecture request & teacher allocation system.

---

## Table of Contents
1. [Admin Dashboard Setup](#admin-dashboard-setup)
2. [Notification Flow for Admins](#notification-flow-for-admins)
3. [Core Admin Workflows](#core-admin-workflows)
4. [Edge Functions Configuration](#edge-functions-configuration)
5. [Testing Admin Features](#testing-admin-features)
6. [Troubleshooting](#troubleshooting)

---

## Admin Dashboard Setup

### Required Permissions
Ensure your admin user has these Supabase RLS policies:

```sql
-- Allow admin to see all lecture requests
CREATE POLICY admin_view_all_requests ON lecture_requests
  FOR SELECT USING (auth.jwt() ->> 'user_role' = 'admin');

-- Allow admin to update request status
CREATE POLICY admin_update_requests ON lecture_requests
  FOR UPDATE USING (auth.jwt() ->> 'user_role' = 'admin');

-- Allow admin to see all teacher interest requests
CREATE POLICY admin_view_teacher_interests ON teacher_interest_requests
  FOR SELECT USING (auth.jwt() ->> 'user_role' = 'admin');

-- Allow admin to see all assignments
CREATE POLICY admin_view_assignments ON teacher_student_assignments
  FOR SELECT USING (auth.jwt() ->> 'user_role' = 'admin');

-- Allow admin to create assignments
CREATE POLICY admin_create_assignments ON teacher_student_assignments
  FOR INSERT WITH CHECK (auth.jwt() ->> 'user_role' = 'admin');
```

### Admin App Structure

```
lib/features/admin/
├── domain/
│   ├── entities/
│   │   ├── lecture_request_entity.dart
│   │   ├── teacher_interest_entity.dart
│   │   └── assignment_entity.dart
│   ├── repositories/
│   │   └── admin_lecture_repository.dart
│   └── usecases/
│       ├── get_pending_requests_usecase.dart
│       ├── approve_lecture_request_usecase.dart
│       ├── get_teacher_interests_usecase.dart
│       ├── reject_lecture_request_usecase.dart
│       └── assign_teacher_usecase.dart
├── data/
│   ├── datasources/
│   │   └── admin_lecture_remote_datasource.dart
│   ├── models/
│   │   ├── lecture_request_model.dart
│   │   └── teacher_interest_model.dart
│   └── repositories/
│       └── admin_lecture_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── admin_lectures_bloc.dart
    │   ├── admin_lectures_event.dart
    │   └── admin_lectures_state.dart
    └── pages/
        ├── admin_dashboard_page.dart
        ├── pending_requests_page.dart
        ├── approved_requests_page.dart
        ├── assigned_requests_page.dart
        ├── teacher_responses_page.dart
        └── assign_teacher_modal.dart
```

---

## Notification Flow for Admins

### 📊 Complete Admin Notification Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                  ADMIN NOTIFICATION WORKFLOW                       │
└────────────────────────────────────────────────────────────────────┘

STEP 1: PARENT REQUESTS LECTURE
┌────────────────────────────────────────────────────────────────┐
│ Parent submits lecture request                                 │
│ → lecture_requests table gets new entry (status='pending')    │
│                                                                │
│ Triggers:                                                      │
│ 1. Database trigger fires                                      │
│ 2. Calls Edge Function: send-request-received-notification   │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 2: ADMIN RECEIVES NOTIFICATION
┌────────────────────────────────────────────────────────────────┐
│ Admin's device receives FCM push:                              │
│ "📋 New Lecture Request: [Student Grade] - [Subject]"         │
│                                                                │
│ Database Entry:                                                │
│ ├─ user_notifications.user_id = admin_uid                    │
│ ├─ notification_type = 'request_received'                    │
│ ├─ related_lecture_request_id = request_id                  │
│ └─ in_app_notifications shows badge count                   │
│                                                                │
│ Admin sees in dashboard:                                       │
│ ├─ Pending Requests tab (count incremented)                  │
│ └─ Bell icon badge with "1 new"                              │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 3: ADMIN REVIEWS REQUEST
┌────────────────────────────────────────────────────────────────┐
│ Admin opens pending request details:                           │
│                                                                │
│ ✅ Can see (Full visibility):                                 │
│   • Student: [Full Name], Grade [X]                          │
│   • Subject(s): [List]                                        │
│   • Parent: [Full Name]                                       │
│   • Parent Phone: [Number]                                    │
│   • Parent Email: [Email]                                     │
│   • Preferred Time Slots: [Days & Times]                      │
│   • Additional Notes: [Any notes]                             │
│   • Request Created: [Date/Time]                              │
│                                                                │
│ Action Buttons:                                                │
│   [Approve] [Reject] [View Full Details]                     │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 4: ADMIN APPROVES REQUEST
┌────────────────────────────────────────────────────────────────┐
│ Admin clicks "Approve" button                                  │
│                                                                │
│ Triggers Edge Function: send-teacher-interest-notification   │
│                                                                │
│ Backend Actions:                                               │
│ 1. UPDATE lecture_requests SET status='approved'              │
│ 2. Query matching teachers:                                   │
│    WHERE subjects && requested_subjects                       │
│    AND verification_status = 'approved'                       │
│ 3. FOR EACH matching teacher:                                 │
│    ├─ INSERT teacher_interest_requests                        │
│    └─ Queue FCM notification (grade + subject only)          │
│ 4. INSERT user_notifications for parent (approval message)   │
│ 5. Send FCM to parent: "Request approved!"                   │
│                                                                │
│ Database Updates:                                              │
│ ├─ lecture_requests.status = 'approved'                      │
│ ├─ teacher_interest_requests.* (N new records)               │
│ ├─ user_notifications.* (parent gets in-app notif)           │
│ └─ user_fcm_tokens (FCM sent to parent device)               │
│                                                                │
│ Admin See:                                                     │
│ • Request moves to "Approved" tab                            │
│ • In-app notification: "Request approved, N teachers sent"   │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 5: TEACHERS RESPOND WITH INTEREST
┌────────────────────────────────────────────────────────────────┐
│ Teachers receive notifications and respond                     │
│ → teacher_interest_requests.interest_status = 'interested'    │
│                                                                │
│ Triggers:                                                      │
│ 1. Database trigger on teacher_interest_requests UPDATE      │
│ 2. Calls Edge Function: send-teacher-interested-notification │
│                                                                │
│ Admin receives:                                                │
│ FCM: "🎯 Teacher X interested in Request Y"                  │
│                                                                │
│ Database Entry:                                                │
│ ├─ user_notifications.notification_type = 'teacher_interested'
│ ├─ related_lecture_request_id = request_id                  │
│ └─ Custom data: {teacher_uid, lecture_request_id}           │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 6: ADMIN REVIEWS TEACHER RESPONSES
┌────────────────────────────────────────────────────────────────┐
│ Admin opens "Approved Requests" tab                            │
│ Sees all teachers who expressed interest                       │
│                                                                │
│ For each interested teacher, shows:                            │
│ ├─ Teacher Name: [Full Name]                                 │
│ ├─ Email: [email@example.com]                                │
│ ├─ Phone: [+91-XXXXXXXXXX]                                   │
│ ├─ Subject Interested: [Subject]                             │
│ ├─ Student Grade: [Grade X]                                  │
│ ├─ Preferred Time: [Slots]                                   │
│ └─ [Select & Assign] button                                  │
│                                                                │
│ Admin can:                                                     │
│ • View full teacher profile                                  │
│ • See qualifications & experience                            │
│ • Check past student reviews (future feature)                │
│ • Compare multiple teachers for same request                 │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 7: ADMIN SELECTS & ASSIGNS TEACHER
┌────────────────────────────────────────────────────────────────┐
│ Admin clicks "Select & Assign" for a teacher                  │
│ → Opens assignment modal/form                                 │
│                                                                │
│ Form Fields:                                                   │
│ ├─ Teacher: [Name] (read-only)                               │
│ ├─ Student: [Name] (read-only)                               │
│ ├─ Grade: [Grade] (read-only)                                │
│ ├─ Subject: [Subject] (read-only)                            │
│ ├─ Start Date: [Date Picker] 📅                              │
│ ├─ Select Time Slots: [Checkboxes] ✓                         │
│ ├─ Frequency: [Weekly/Daily] (dropdown)                      │
│ ├─ End Date: [Optional Date Picker]                          │
│ └─ Admin Notes: [Text field]                                 │
│                                                                │
│ Admin clicks "Confirm Assignment"                             │
│                                                                │
│ Triggers Edge Function: send-assignment-notification         │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 8: ADMIN CONFIRMS - NOTIFICATIONS SENT
┌────────────────────────────────────────────────────────────────┐
│ Backend Actions on Assignment Confirmation:                   │
│                                                                │
│ 1. Create Assignment:                                         │
│    INSERT teacher_student_assignments {                       │
│      teacher_uid, student_id, start_date, ...                │
│    }                                                           │
│                                                                │
│ 2. Create Lectures:                                           │
│    FOR EACH date in range:                                   │
│      INSERT lectures {                                        │
│        assignment_id, teacher_uid, student_id,               │
│        scheduled_date, scheduled_time, status='scheduled'    │
│      }                                                         │
│                                                                │
│ 3. Update Request Status:                                     │
│    UPDATE lecture_requests SET status='assigned'              │
│                                                                │
│ 4. Send Notifications:                                        │
│                                                                │
│    ┌─ TO PARENT (FCM + In-app):                              │
│    │  "✅ Teacher Assigned!"                                 │
│    │  "Your request approved & teacher allocated"            │
│    │  "Classes starting [Date]"                              │
│    │                                                          │
│    ├─ Database:                                              │
│    │  ├─ user_notifications.notification_type = 'assigned'   │
│    │  ├─ related_assignment_id = assignment_id              │
│    │  └─ user_fcm_tokens (send push to parent)              │
│    │                                                          │
│    └─ TO TEACHER (FCM + In-app):                             │
│       "🎉 New Assignment!"                                   │
│       "You've been assigned to teach [Student Name]"         │
│       "Grade: [X], Subject: [Subject]"                       │
│       "Classes: [Dates & Times]"                             │
│                                                                │
│       Database:                                               │
│       ├─ user_notifications (for teacher)                    │
│       ├─ related_assignment_id = assignment_id              │
│       └─ user_fcm_tokens (send push to teacher)             │
│                                                                │
│ 5. Admin Dashboard Update:                                    │
│    • Request moved to "Assigned" tab                         │
│    • In-app notification: "Assignment created successfully"  │
│    • Can still view/modify assignment                        │
└────────────────────────────────────────────────────────────────┘
                            ↓
STEP 9: ONGOING - ADMIN MONITORS
┌────────────────────────────────────────────────────────────────┐
│ Admin Dashboard shows:                                         │
│                                                                │
│ Pending Requests Tab:                                         │
│ └─ Requests waiting for admin approval                        │
│                                                                │
│ Approved Requests Tab:                                        │
│ └─ Approved, waiting for teacher assignment                  │
│                                                                │
│ Assigned Requests Tab:                                        │
│ ├─ Active assignments                                        │
│ ├─ Class schedule & status                                   │
│ └─ Actions: [View Details] [Modify] [Cancel]                 │
│                                                                │
│ In-App Notifications Center:                                  │
│ ├─ All notifications (request received, approved, assigned)  │
│ ├─ Unread count                                              │
│ └─ Click to navigate to relevant section                     │
│                                                                │
│ Metrics/Dashboard:                                            │
│ ├─ Total pending: 5                                          │
│ ├─ Total approved: 12                                        │
│ ├─ Total assigned: 28                                        │
│ ├─ Avg approval time: 2.5 hours                              │
│ └─ Teacher acceptance rate: 85%                              │
└────────────────────────────────────────────────────────────────┘
```

### 🔔 Admin Notification Types Summary

```
NOTIFICATION TYPE              TRIGGERED BY            DATA VISIBLE TO ADMIN
─────────────────────────────────────────────────────────────────────────
1. request_received            Parent creates request   Full student + parent info
   "New Lecture Request"

2. request_approved            Admin approves request   Confirmation message
   "Request Approved"

3. teacher_interested          Teacher shows interest   Teacher name + contact
   "Teacher X Interested"

4. assignment_created          Admin assigns teacher    Assignment details
   "Assignment Created"

5. lecture_starting_soon       15 mins before lecture   Lecture details
   "Class Starting Soon"

6. attendance_marked           Teacher marks attendance Attendance info
   "Attendance Marked"

7. assignment_cancelled        Teacher/Admin cancels    Cancellation reason
   "Assignment Cancelled"
```

### 📱 Admin Notification Delivery Flow

```
Database Event
    ↓
Edge Function Triggered
    ↓
Queries admin's FCM tokens (user_fcm_tokens table)
    ↓
Creates in-app notification (user_notifications table)
    ↓
Sends push via Firebase Cloud Messaging
    ↓
Admin's device receives notification
    ↓
Shows in status bar
    ↓
Badge count on in-app notification bell icon
    ↓
Admin opens app → Sees notification in center
```

---

## Core Admin Workflows

### Workflow 1: View Pending Lecture Requests

**Admin Code:**
```dart
// lib/features/admin/presentation/bloc/admin_lectures_bloc.dart
class AdminLecturesBloc extends Bloc<AdminLecturesEvent, AdminLecturesState> {
  final GetPendingRequestsUsecase getPendingRequests;

  AdminLecturesBloc({required this.getPendingRequests}) : super(AdminLecturesInitial()) {
    on<GetPendingRequestsEvent>(_onGetPendingRequests);
  }

  Future<void> _onGetPendingRequests(
    GetPendingRequestsEvent event,
    Emitter<AdminLecturesState> emit,
  ) async {
    emit(AdminLecturesLoading());
    final result = await getPendingRequests(NoParams());
    result.fold(
      (failure) => emit(AdminLecturesError(failure.message)),
      (requests) => emit(AdminLecturesPendingRequestsLoaded(requests)),
    );
  }
}
```

**SQL Query (in datasource):**
```sql
SELECT 
  lr.id,
  lr.parent_uid,
  lr.student_id,
  lr.subjects,
  lr.preferred_time_slots,
  lr.requested_start_date,
  lr.additional_notes,
  lr.created_at,
  s.standard,
  s.first_name as student_first_name,
  s.last_name as student_last_name,
  p.first_name as parent_first_name,
  p.last_name as parent_last_name,
  p.phone_number,
  p.email as parent_email
FROM lecture_requests lr
JOIN students s ON lr.student_id = s.student_id
JOIN parents p ON lr.parent_uid = p.uid
WHERE lr.status = 'pending'
ORDER BY lr.created_at DESC
```

---

### Workflow 2: Approve Lecture Request

**Admin Code:**
```dart
class AdminLecturesBloc extends Bloc<AdminLecturesEvent, AdminLecturesState> {
  final ApproveLectureRequestUsecase approveLectureRequest;

  AdminLecturesBloc({required this.approveLectureRequest}) : super(AdminLecturesInitial()) {
    on<ApproveLectureRequestEvent>(_onApproveLectureRequest);
  }

  Future<void> _onApproveLectureRequest(
    ApproveLectureRequestEvent event,
    Emitter<AdminLecturesState> emit,
  ) async {
    emit(AdminLecturesLoading());
    final result = await approveLectureRequest(
      ApproveLectureRequestParams(
        lectureRequestId: event.requestId,
        adminUid: event.adminUid,
      ),
    );
    result.fold(
      (failure) => emit(AdminLecturesError(failure.message)),
      (_) => emit(AdminLectureRequestApproved()),
    );
  }
}
```

**Datasource Implementation:**
```dart
Future<void> approveLectureRequest({
  required String lectureRequestId,
  required String adminUid,
}) async {
  try {
    // 1. Update request status
    await supabaseClient
      .from('lecture_requests')
      .update({'status': 'approved', 'updated_at': DateTime.now().toIso8601String()})
      .eq('id', lectureRequestId);

    // 2. Create in-app notification for admin
    await supabaseClient
      .from('user_notifications')
      .insert({
        'user_id': adminUid,
        'notification_type': 'request_approved',
        'title': 'Request Approved',
        'message': 'Teachers are being notified of this request',
        'related_lecture_request_id': lectureRequestId,
        'is_read': false,
      });

    // 3. Edge Function will handle finding teachers and sending notifications
    // Call the Edge Function
    await supabaseClient.functions.invoke('send-teacher-interest-notification', body: {
      'lectureRequestId': lectureRequestId,
    });
  } catch (e) {
    throw ServerException(message: e.toString());
  }
}
```

---

### Workflow 3: View Teacher Interest Responses

**SQL Query:**
```sql
SELECT 
  tir.id,
  tir.lecture_request_id,
  tir.teacher_uid,
  tir.student_id,
  tir.subject,
  tir.preferred_time_slots,
  tir.student_grade,
  tir.interest_status,
  tir.created_at,
  t.first_name as teacher_first_name,
  t.last_name as teacher_last_name,
  t.email as teacher_email,
  t.phone_number as teacher_phone,
  t.subjects as teacher_subjects,
  s.standard
FROM teacher_interest_requests tir
JOIN teachers t ON tir.teacher_uid = t.uid
JOIN students s ON tir.student_id = s.student_id
JOIN lecture_requests lr ON tir.lecture_request_id = lr.id
WHERE lr.status = 'approved' 
  AND tir.interest_status = 'interested'
ORDER BY tir.created_at DESC
```

---

### Workflow 4: Assign Teacher to Student

**Admin Code:**
```dart
class AdminLecturesBloc extends Bloc<AdminLecturesEvent, AdminLecturesState> {
  final AssignTeacherUsecase assignTeacher;

  on<AssignTeacherEvent>(_onAssignTeacher);

  Future<void> _onAssignTeacher(
    AssignTeacherEvent event,
    Emitter<AdminLecturesState> emit,
  ) async {
    emit(AdminLecturesLoading());
    final result = await assignTeacher(
      AssignTeacherParams(
        lectureRequestId: event.lectureRequestId,
        teacherUid: event.teacherUid,
        studentId: event.studentId,
        startDate: event.startDate,
        timeSlots: event.timeSlots,
        frequency: event.frequency,
        notes: event.notes,
        adminUid: event.adminUid,
      ),
    );
    result.fold(
      (failure) => emit(AdminLecturesError(failure.message)),
      (_) => emit(AdminLectureAssignmentCreated()),
    );
  }
}
```

**Datasource Implementation:**
```dart
Future<void> assignTeacher({
  required String lectureRequestId,
  required String teacherUid,
  required String studentId,
  required DateTime startDate,
  required List<Map<String, dynamic>> timeSlots,
  required String frequency,
  required String notes,
  required String adminUid,
}) async {
  try {
    // 1. Create assignment
    final assignmentResult = await supabaseClient
      .from('teacher_student_assignments')
      .insert({
        'lecture_request_id': lectureRequestId,
        'teacher_uid': teacherUid,
        'student_id': studentId,
        'subjects': [/* from lecture_request */],
        'assigned_by': adminUid,
        'start_date': startDate.toIso8601String(),
        'notes': notes,
      })
      .select()
      .single();

    final assignmentId = assignmentResult['id'];

    // 2. Create lectures for each date/slot combination
    for (var slot in timeSlots) {
      await supabaseClient.from('lectures').insert({
        'assignment_id': assignmentId,
        'teacher_uid': teacherUid,
        'student_id': studentId,
        'subject': slot['subject'],
        'scheduled_date': slot['date'],
        'scheduled_time': slot['time'],
        'status': 'scheduled',
      });
    }

    // 3. Update request status
    await supabaseClient
      .from('lecture_requests')
      .update({'status': 'assigned'})
      .eq('id', lectureRequestId);

    // 4. Call Edge Function to send notifications
    await supabaseClient.functions.invoke('send-assignment-notification', body: {
      'assignmentId': assignmentId,
      'lectureRequestId': lectureRequestId,
      'teacherUid': teacherUid,
    });
  } catch (e) {
    throw ServerException(message: e.toString());
  }
}
```

---

## Edge Functions Configuration

### Edge Function 1: send-request-received-notification

```typescript
// supabase/functions/send-request-received-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import * as admin from "https://www.gstatic.com/firebasedev/0.5.2/firebase-admin.js";

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const firebaseKey = Deno.env.get("FIREBASE_PRIVATE_KEY");

serve(async (req: Request) => {
  const { lectureRequestId } = await req.json();

  try {
    // Get lecture request details
    const { data: request } = await fetch(`${supabaseUrl}/rest/v1/lecture_requests?id=eq.${lectureRequestId}`)
      .then(r => r.json());

    if (!request || request.length === 0) {
      return new Response(JSON.stringify({ error: "Request not found" }), { status: 404 });
    }

    const req = request[0];

    // Get admin FCM tokens
    const { data: adminTokens } = await fetch(
      `${supabaseUrl}/rest/v1/user_fcm_tokens?user_id=in.(${adminIds.join(',')})`,
      { headers: { "Authorization": `Bearer ${supabaseKey}` } }
    ).then(r => r.json());

    // Create in-app notification for admin
    await fetch(`${supabaseUrl}/rest/v1/user_notifications`, {
      method: "POST",
      headers: { "Authorization": `Bearer ${supabaseKey}` },
      body: JSON.stringify({
        user_id: adminId,
        notification_type: "request_received",
        title: "New Lecture Request",
        message: `Grade ${req.standard} - ${req.subjects.join(", ")}`,
        related_lecture_request_id: lectureRequestId,
        is_read: false,
      }),
    });

    // Send FCM notifications to all admin devices
    for (const token of adminTokens) {
      await admin.messaging().send({
        token: token.fcm_token,
        notification: {
          title: "📋 New Lecture Request",
          body: `Grade ${req.standard} - ${req.subjects.join(", ")}`,
        },
        data: {
          type: "request_received",
          lectureRequestId: lectureRequestId,
        },
      });
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
```

### Edge Function 2: send-teacher-interest-notification

```typescript
// supabase/functions/send-teacher-interest-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import * as admin from "https://www.gstatic.com/firebasedev/0.5.2/firebase-admin.js";

serve(async (req: Request) => {
  const { lectureRequestId } = await req.json();

  try {
    // Get lecture request
    const { data: request } = await fetch(`${supabaseUrl}/rest/v1/lecture_requests?id=eq.${lectureRequestId}`)
      .then(r => r.json());

    const lr = request[0];

    // Find matching teachers
    const { data: teachers } = await fetch(
      `${supabaseUrl}/rest/v1/teachers?verification_status=eq.approved&subjects=ov.{${lr.subjects.join(',')}}`,
      { headers: { "Authorization": `Bearer ${supabaseKey}` } }
    ).then(r => r.json());

    // For each matching teacher
    for (const teacher of teachers) {
      // Create teacher_interest_requests
      const { data: interestReq } = await fetch(`${supabaseUrl}/rest/v1/teacher_interest_requests`, {
        method: "POST",
        headers: { "Authorization": `Bearer ${supabaseKey}` },
        body: JSON.stringify({
          lecture_request_id: lectureRequestId,
          teacher_uid: teacher.uid,
          student_id: lr.student_id,
          subject: lr.subjects[0],
          preferred_time_slots: lr.preferred_time_slots,
          student_grade: lr.standard,
          interest_status: "pending",
        }),
      }).then(r => r.json());

      // Get teacher FCM tokens
      const { data: tokens } = await fetch(
        `${supabaseUrl}/rest/v1/user_fcm_tokens?user_id=eq.${teacher.uid}`,
        { headers: { "Authorization": `Bearer ${supabaseKey}` } }
      ).then(r => r.json());

      // Send FCM to each teacher device
      for (const token of tokens) {
        await admin.messaging().send({
          token: token.fcm_token,
          notification: {
            title: "🎯 New Interest Request",
            body: `Grade ${lr.standard} - ${lr.subjects.join(", ")}`,
          },
          data: {
            type: "teacher_interest",
            lectureRequestId: lectureRequestId,
            studentGrade: lr.standard,
          },
        });
      }
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
```

### Edge Function 3: send-assignment-notification

```typescript
// supabase/functions/send-assignment-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import * as admin from "https://www.gstatic.com/firebasedev/0.5.2/firebase-admin.js";

serve(async (req: Request) => {
  const { assignmentId, lectureRequestId, teacherUid } = await req.json();

  try {
    // Get assignment details
    const { data: assignment } = await fetch(`${supabaseUrl}/rest/v1/teacher_student_assignments?id=eq.${assignmentId}`)
      .then(r => r.json());

    const assign = assignment[0];

    // Get lecture request for parent info
    const { data: lectureReq } = await fetch(`${supabaseUrl}/rest/v1/lecture_requests?id=eq.${lectureRequestId}`)
      .then(r => r.json());

    const lr = lectureReq[0];

    // Get student info
    const { data: student } = await fetch(`${supabaseUrl}/rest/v1/students?student_id=eq.${assign.student_id}`)
      .then(r => r.json());

    // NOTIFY PARENT
    const { data: parentTokens } = await fetch(
      `${supabaseUrl}/rest/v1/user_fcm_tokens?user_id=eq.${lr.parent_uid}`,
      { headers: { "Authorization": `Bearer ${supabaseKey}` } }
    ).then(r => r.json());

    // Create in-app notification for parent
    await fetch(`${supabaseUrl}/rest/v1/user_notifications`, {
      method: "POST",
      headers: { "Authorization": `Bearer ${supabaseKey}` },
      body: JSON.stringify({
        user_id: lr.parent_uid,
        notification_type: "teacher_assigned",
        title: "✅ Teacher Assigned!",
        message: "Your request approved & teacher allocated",
        related_assignment_id: assignmentId,
        is_read: false,
      }),
    });

    for (const token of parentTokens) {
      await admin.messaging().send({
        token: token.fcm_token,
        notification: {
          title: "✅ Teacher Assigned!",
          body: "Classes starting soon. Check your dashboard.",
        },
        data: {
          type: "teacher_assigned",
          assignmentId: assignmentId,
        },
      });
    }

    // NOTIFY TEACHER
    const { data: teacherTokens } = await fetch(
      `${supabaseUrl}/rest/v1/user_fcm_tokens?user_id=eq.${teacherUid}`,
      { headers: { "Authorization": `Bearer ${supabaseKey}` } }
    ).then(r => r.json());

    // Create in-app notification for teacher
    await fetch(`${supabaseUrl}/rest/v1/user_notifications`, {
      method: "POST",
      headers: { "Authorization": `Bearer ${supabaseKey}` },
      body: JSON.stringify({
        user_id: teacherUid,
        notification_type: "assignment_received",
        title: "🎉 New Assignment!",
        message: `You've been assigned to teach Grade ${student[0].standard}`,
        related_assignment_id: assignmentId,
        is_read: false,
      }),
    });

    for (const token of teacherTokens) {
      await admin.messaging().send({
        token: token.fcm_token,
        notification: {
          title: "🎉 New Assignment!",
          body: `Grade ${student[0].standard} - ${assign.subjects.join(", ")}`,
        },
        data: {
          type: "assignment_received",
          assignmentId: assignmentId,
        },
      });
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
```

---

## Testing Admin Features

### Test 1: Admin Views Pending Requests
```bash
# Prerequisites
1. Parent has created a lecture request
2. Admin is logged in

# Test Steps
1. Admin opens Admin Dashboard
2. Click "Pending Requests" tab
3. Should see parent request with:
   - Student name, grade, subjects
   - Parent name, phone, email
   - Time slots & priority

# Expected Result
✅ Request visible in pending list
✅ All details visible to admin
```

### Test 2: Admin Approves Request
```bash
# Test Steps
1. Admin clicks "Approve" on a pending request
2. Wait 3 seconds

# Expected Results
✅ Request moves to "Approved" tab
✅ Parent receives FCM notification
✅ Teachers matching subjects receive interest notifications
✅ In-app notification: "Request approved, teachers notified"

# Database Verification
SELECT * FROM lecture_requests WHERE id = 'request_id' AND status = 'approved';
SELECT * FROM teacher_interest_requests WHERE lecture_request_id = 'request_id';
SELECT * FROM user_notifications WHERE related_lecture_request_id = 'request_id';
```

### Test 3: Admin Views Teacher Responses
```bash
# Prerequisites
1. At least one request approved
2. At least one teacher expressed interest

# Test Steps
1. Admin opens "Approved Requests" tab
2. Sees list of teachers interested in each request

# Expected Results
✅ Teacher name visible
✅ Teacher contact (email, phone) visible
✅ Student grade visible (NOT name)
✅ Subject and preferred time slots visible
✅ [Select & Assign] button available
```

### Test 4: Admin Assigns Teacher
```bash
# Test Steps
1. Admin clicks [Select & Assign] for a teacher
2. Fill form:
   - Select start date
   - Check preferred time slots
   - Set frequency (weekly)
   - Add notes (optional)
3. Click "Confirm Assignment"

# Expected Results
✅ Assignment created in database
✅ Lectures generated for date range
✅ Teacher gets FCM: "You've been assigned!"
✅ Parent gets FCM: "Teacher allocated!"
✅ Request moves to "Assigned" tab
✅ In-app notification: "Assignment successful"

# Database Verification
SELECT * FROM teacher_student_assignments WHERE id = 'assignment_id';
SELECT COUNT(*) FROM lectures WHERE assignment_id = 'assignment_id';
SELECT * FROM user_notifications WHERE related_assignment_id = 'assignment_id';
```

---

## Privacy Rules Enforcement

### What Admin CAN See
```dart
// Admin Query - Full Data
SELECT 
  lr.id,
  s.first_name, s.last_name,  // ✅ Student name
  p.first_name, p.last_name,  // ✅ Parent name
  p.phone_number,              // ✅ Parent contact
  p.email,                      // ✅ Parent email
  t.first_name, t.last_name,  // ✅ Teacher name
  t.phone_number,              // ✅ Teacher contact
  t.email                       // ✅ Teacher email
FROM lecture_requests lr
JOIN students s ON lr.student_id = s.student_id
JOIN parents p ON lr.parent_uid = p.uid
-- Admin sees everything
```

### What Teachers CANNOT See (Before Assignment)
```dart
// Teacher Query - Masked Data
SELECT 
  tir.student_grade,            // ✅ Grade (e.g., "Grade 10")
  tir.subject,                  // ✅ Subject
  tir.preferred_time_slots      // ✅ Time slots
  -- NO: student_name
  -- NO: parent_name, parent_email, parent_phone
  -- NO: parent address
FROM teacher_interest_requests tir
```

### Implementation in Datasource
```dart
// lib/features/admin/data/datasources/admin_lecture_remote_datasource.dart

Future<List<LectureRequestModel>> getPendingRequests() async {
  // Admin can see full details
  final response = await supabaseClient
    .from('lecture_requests')
    .select('''
      id,
      parent_uid,
      student_id,
      subjects,
      preferred_time_slots,
      additional_notes,
      created_at,
      students(standard, first_name, last_name),
      parents(first_name, last_name, phone_number, email)
    ''')  // ✅ Admin sees FULL JOIN with all details
    .eq('status', 'pending')
    .order('created_at', ascending: false);

  return (response as List)
    .map((json) => LectureRequestModel.fromJson(json))
    .toList();
}

Future<List<TeacherInterestModel>> getTeacherInterests(String requestId) async {
  // Get teacher details for admin (full info)
  final response = await supabaseClient
    .from('teacher_interest_requests')
    .select('''
      id,
      teacher_uid,
      subject,
      preferred_time_slots,
      student_grade,
      interest_status,
      teachers(first_name, last_name, email, phone_number, subjects)
    ''')
    .eq('lecture_request_id', requestId)
    .eq('interest_status', 'interested');

  return (response as List)
    .map((json) => TeacherInterestModel.fromJson(json))
    .toList();
}
```

---

## Troubleshooting

### Problem: Admin not receiving notifications
**Solution:**
```sql
-- Check admin's FCM tokens
SELECT * FROM user_fcm_tokens WHERE user_id = 'admin_uid';

-- Check if admin has active tokens
SELECT COUNT(*) FROM user_fcm_tokens 
WHERE user_id = 'admin_uid' AND is_active = true;

-- Check notification table
SELECT * FROM user_notifications 
WHERE user_id = 'admin_uid' 
ORDER BY created_at DESC LIMIT 10;

-- Check Edge Function logs
supabase functions logs send-teacher-interest-notification --follow
```

### Problem: Teachers not receiving interest notifications
**Solution:**
```sql
-- Check if teacher_interest_requests created
SELECT COUNT(*) FROM teacher_interest_requests 
WHERE lecture_request_id = 'request_id';

-- Check teacher FCM tokens
SELECT * FROM user_fcm_tokens WHERE user_id = 'teacher_uid';

-- Verify Firebase is configured
supabase secrets list | grep FIREBASE
```

### Problem: Assignment doesn't create lectures
**Solution:**
```sql
-- Check if assignment created
SELECT * FROM teacher_student_assignments 
WHERE id = 'assignment_id';

-- Check if lectures were created
SELECT * FROM lectures 
WHERE assignment_id = 'assignment_id';

-- Check Edge Function logs
supabase functions logs send-assignment-notification --follow
```

---

## Admin Dashboard Metrics

Display these on admin dashboard:

```sql
-- Pending requests count
SELECT COUNT(*) as pending_count 
FROM lecture_requests 
WHERE status = 'pending';

-- Approved requests count
SELECT COUNT(*) as approved_count 
FROM lecture_requests 
WHERE status = 'approved';

-- Assigned requests count
SELECT COUNT(*) as assigned_count 
FROM lecture_requests 
WHERE status = 'assigned';

-- Average approval time
SELECT AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/3600) as avg_approval_hours
FROM lecture_requests 
WHERE status IN ('approved', 'assigned', 'rejected');

-- Teacher acceptance rate
SELECT 
  ROUND(
    (SELECT COUNT(*) FROM teacher_interest_requests WHERE interest_status = 'interested')::NUMERIC 
    / NULLIF((SELECT COUNT(*) FROM teacher_interest_requests), 0) * 100, 
    2
  ) as teacher_acceptance_rate;
```

---

**Next Steps:**
1. ✅ Read the ADMIN_LECTURES_IMPLEMENTATION_PLAN.md
2. ✅ Set up admin app structure
3. ✅ Configure Edge Functions
4. ✅ Test each admin workflow
5. ✅ Deploy to production
