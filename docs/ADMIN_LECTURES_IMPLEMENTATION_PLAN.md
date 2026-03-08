# Admin Side - Lecture Request Management Implementation Plan

## Overview
This document outlines the implementation plan for the admin dashboard to manage lecture requests, approve them, handle teacher allocations, and send notifications.

---

## Phase 1: Lecture Request Viewing & Management

### 1.1 Admin Dashboard - Pending Requests View
**Objective**: Display all pending lecture requests from parents

**Implementation Steps**:
1. Create `admin_lecture_requests_page.dart` with three tabs:
   - **Pending** (status = 'pending')
   - **Approved** (status = 'approved')
   - **Assigned** (status = 'assigned')

2. **Pending Requests Tab**:
   - Display card for each pending request
   - Show student info: grade, subjects requested, preferred time slots
   - Show parent info: name, email, phone, priority level
   - Action buttons: "View Details", "Approve", "Reject"

3. **Data to fetch** from `lecture_requests`:
   ```sql
   SELECT 
     lr.id,
     lr.parent_uid,
     lr.student_id,
     lr.subjects,
     lr.preferred_time_slots,
     lr.priority_level,
     lr.requested_start_date,
     lr.additional_notes,
     s.standard,
     s.first_name, s.last_name,
     p.first_name as parent_name,
     p.phone_number,
     p.email
   FROM lecture_requests lr
   JOIN students s ON lr.student_id = s.student_id
   JOIN parents p ON lr.parent_uid = p.uid
   WHERE lr.status = 'pending'
   ORDER BY lr.priority_level DESC, lr.created_at ASC
   ```

4. **Create Dart Layer**:
   - `AdminLectureRepository` interface with methods:
     - `getPendingRequests()`
     - `getApprovedRequests()`
     - `getAssignedRequests()`
   - `AdminLectureRemoteDatasource` implementation
   - `AdminLectureBloc` for state management

---

## Phase 2: Lecture Request Approval

### 2.1 Approve Lecture Request
**Objective**: Admin approves a lecture request and sends notification to teachers

**Implementation Steps**:

1. **Update lecture_requests table**:
   ```sql
   UPDATE lecture_requests 
   SET status = 'approved', updated_at = NOW()
   WHERE id = ?
   ```

2. **Send Notification to Parents**:
   - Create notification template: "Your lecture request for [Student Name] in [Subject] has been approved. Teacher allocation is in progress."
   - Store in `user_notifications` table (if exists, else create)
   - Send FCM notification via `sendNotificationToUser(parentUid)`

3. **Find Matching Teachers**:
   - Query all teachers who:
     - Teach the requested subject(s)
     - Have verification_status = 'approved'
   - Don't filter by availability - send to all matching teachers as they might become available
   
   ```sql
   SELECT t.uid, t.email, t.phone_number, t.first_name, t.last_name
   FROM teachers t
   WHERE 
     t.subjects && ? (overlaps with requested subjects)
     AND t.verification_status = 'approved'
   ```

4. **Create `teacher_interest_requests` table** (NEW):
   ```sql
   CREATE TABLE public.teacher_interest_requests (
     id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
     lecture_request_id uuid NOT NULL REFERENCES lecture_requests(id),
     teacher_uid text NOT NULL REFERENCES teachers(uid),
     student_id uuid NOT NULL REFERENCES students(student_id),
     subject text NOT NULL,
     preferred_time_slots jsonb NOT NULL,
     student_grade text NOT NULL,
     interest_status text DEFAULT 'pending' 
       CHECK (interest_status IN ('pending', 'interested', 'rejected')),
     created_at timestamp DEFAULT NOW(),
     updated_at timestamp DEFAULT NOW()
   );
   ```

5. **Send Interest Requests to Teachers**:
   - For each matching teacher, create record in `teacher_interest_requests`
   - Send FCM notification: "A student in [Grade] needs help with [Subject] at [Time Slots]. Click to show interest."
   - Teachers see this in their "Interest Requests" section (not full details yet)

---

## Phase 3: Teacher Interest Management

### 3.1 Admin Views Teacher Responses
**Objective**: Display all teacher interest responses with their details

**Implementation Steps**:

1. **Create `admin_teacher_responses_page.dart`**:
   - Shows list of all teachers who expressed interest
   - Display:
     - Teacher name, email, phone number
     - Subject interested in
     - Time slots offered
     - Student grade (NOT name)
     - Accept/Reject buttons

2. **Fetch teacher responses**:
   ```sql
   SELECT 
     tir.id,
     tir.teacher_uid,
     tir.interest_status,
     tir.lecture_request_id,
     t.email,
     t.phone_number,
     t.first_name,
     t.last_name,
     tir.subject,
     tir.preferred_time_slots,
     tir.student_grade,
     s.student_id
   FROM teacher_interest_requests tir
   JOIN teachers t ON tir.teacher_uid = t.uid
   JOIN students s ON tir.student_id = s.student_id
   WHERE tir.interest_status = 'interested'
   ORDER BY tir.created_at ASC
   ```

---

## Phase 4: Teacher Assignment

### 4.1 Assign Teacher to Student
**Objective**: Admin selects a teacher, chooses dates and timeslots, creates assignment

**Implementation Steps**:

1. **Create `admin_assign_teacher_page.dart`**:
   - Modal/Page with form to:
     - Select teacher (from interested teachers)
     - Select start date
     - Select time slots (show teacher's available slots)
     - Select end date (optional)
     - Add notes

2. **On Assignment Confirmation**:
   
   a) **Create teacher_student_assignment**:
   ```sql
   INSERT INTO teacher_student_assignments 
   (lecture_request_id, teacher_uid, student_id, subjects, assigned_by, start_date, notes)
   VALUES (?, ?, ?, ?, ?, ?, ?)
   ```

   b) **Update lecture_requests status**:
   ```sql
   UPDATE lecture_requests 
   SET status = 'assigned', updated_at = NOW()
   WHERE id = ?
   ```

   c) **Create initial lectures** (one-time or recurring):
   ```sql
   INSERT INTO lectures 
   (assignment_id, teacher_uid, student_id, subject, scheduled_date, scheduled_time, status)
   VALUES (?, ?, ?, ?, ?, ?, 'scheduled')
   -- For each date/timeslot combination
   ```

3. **Send Notifications**:
   - **To Teacher**: "You have been assigned to teach [Subject] to a Grade [X] student. Classes scheduled from [date] at [time]"
   - **To Parent**: "A teacher has been assigned! Classes will start on [date]. You'll see teacher details (without personal info) in your dashboard."
   - Store in notifications table

---

## Phase 5: Notification Configuration

### 5.1 Create Notification Tables (if not exists)

```sql
CREATE TABLE public.user_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL REFERENCES users(uid),
  title text NOT NULL,
  message text NOT NULL,
  notification_type text NOT NULL 
    CHECK (notification_type IN ('lecture_request_approved', 'teacher_assigned', 'teacher_interested', 'lecture_reminder', 'other')),
  related_lecture_request_id uuid REFERENCES lecture_requests(id),
  related_assignment_id uuid REFERENCES teacher_student_assignments(id),
  is_read boolean DEFAULT false,
  created_at timestamp DEFAULT NOW(),
  read_at timestamp
);

CREATE TABLE public.notification_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL UNIQUE,
  title_template text NOT NULL,
  message_template text NOT NULL,
  variables text[] -- ['student_name', 'subject', 'grade', 'date', 'time', 'teacher_name']
);
```

### 5.2 Set Up Firebase Cloud Messaging (FCM)

**Backend Configuration** (if using Cloud Functions):
1. Store FCM tokens in `user_fcm_tokens` table
2. Create Cloud Function triggers for:
   - `on-lecture-request-approved` → Send parent notification
   - `on-teacher-interested` → Send admin notification
   - `on-teacher-assigned` → Send teacher & parent notifications

**Flutter Implementation**:
1. Initialize FCM in `main.dart`:
   ```dart
   await FirebaseMessaging.instance.requestPermission();
   final token = await FirebaseMessaging.instance.getToken();
   // Store token in user_fcm_tokens table
   ```

2. Handle notifications:
   ```dart
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     // Show in-app notification
     if (message.notification != null) {
       showInAppNotification(message.notification!);
     }
   });
   ```

3. Create `in_app_notifications` section in admin dashboard:
   - Uses `user_notifications` table
   - Real-time updates via Supabase realtime subscriptions
   - Mark as read functionality

---

## Phase 6: Admin Dashboard Layout

### 6.1 Main Admin Dashboard Structure

```
┌─────────────────────────────────────────────────┐
│         ADMIN DASHBOARD - LECTURES              │
├─────────────────────────────────────────────────┤
│  ┌─ TABS ─────────────────────────────────────┐ │
│  │ [Pending] [Approved] [Assigned] [Teachers] │ │
│  └────────────────────────────────────────────┘ │
│                                                 │
│  ┌─ TAB CONTENT ──────────────────────────────┐ │
│  │ • Pending Requests (10)                    │ │
│  │   ├─ [Request Card 1]                      │ │
│  │   │  Student: Grade 10, Math, Science     │ │
│  │   │  Parent: John Doe                      │ │
│  │   │  [View Details] [Approve] [Reject]    │ │
│  │   │                                        │ │
│  │   └─ [Request Card 2]                      │ │
│  │      ...                                   │ │
│  └────────────────────────────────────────────┘ │
│                                                 │
│  ┌─ IN-APP NOTIFICATIONS (Top Right)─────────┐ │
│  │ [Bell Icon with Badge] (3 new)            │ │
│  │ Click to open:                            │ │
│  │ • Teacher X interested in Request Y       │ │
│  │ • Request Z approved by parent            │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### 6.2 Approved Requests Tab
- Shows requests approved but not yet assigned
- Lists teacher interest responses
- Action: "Select Teacher & Assign"

### 6.3 Assigned Requests Tab
- Shows all assigned lectures
- Displays: Teacher name, student grade, subject, start date
- Actions: "View Details", "Modify", "Cancel"

### 6.4 Teachers Tab
- Manage teacher verification status (separate feature, but important context)
- View teacher availability
- Edit teacher subjects/availability

---

## Phase 7: Data Flow Diagram

```
1. PARENT REQUESTS LECTURE
   ↓
2. ADMIN SEES PENDING REQUEST
   ├─ View student details: grade, name, subject
   ├─ View parent details: name, email, phone
   └─ Action: APPROVE / REJECT
   
3. ADMIN APPROVES
   ├─ Update lecture_requests (status = 'approved')
   ├─ Send FCM to parents: "Request approved"
   ├─ Find matching teachers
   └─ Create teacher_interest_requests
   
4. TEACHERS RECEIVE INTEREST NOTIFICATION
   ├─ See: Grade, Subject, Time Slots
   ├─ NO: Student name or personal info
   └─ Action: SHOW INTEREST / IGNORE
   
5. ADMIN SEES TEACHER RESPONSES
   ├─ View: Teacher name, email, phone
   ├─ View: Subject, preferred timeslots
   ├─ View: Student grade
   └─ Action: SELECT & ASSIGN
   
6. ADMIN ASSIGNS TEACHER
   ├─ Create teacher_student_assignments
   ├─ Create initial lectures
   ├─ Update lecture_requests (status = 'assigned')
   ├─ Send FCM to teacher: Full student grade, subject
   └─ Send FCM to parent: "Teacher assigned, classes starting"
   
7. ONGOING
   ├─ Teachers see assigned students (grade only)
   └─ Parents see assigned teachers (no personal info)
```

---

## Phase 8: Privacy & Security Considerations

1. **Personal Information Filtering**:
   - Teachers should NEVER see: Parent name, parent contact, student name
   - Teachers should see: Student grade, subject, time slots
   - Parents should NEVER see: Teacher personal contact before assignment
   - Parents should see: Teacher name only in their dashboard

2. **Admin Can See Everything**: No restrictions

3. **Database-level filtering**:
   - Use RLS (Row Level Security) policies or filter in application layer
   - Create views for different user types if needed

---

## Phase 9: Testing Checklist

- [ ] Admin can view all pending lecture requests
- [ ] Admin can approve request and notifications sent to parents
- [ ] Teachers receive interest requests (without student names)
- [ ] Multiple teachers can show interest for same request
- [ ] Admin can view all interested teachers with their details
- [ ] Admin can assign one teacher to a student
- [ ] Teacher receives assignment notification with student grade
- [ ] Parent receives assignment notification
- [ ] Lectures are created with correct details
- [ ] Status updates flow correctly through states
- [ ] In-app notifications appear in real-time
- [ ] FCM notifications are received on all platforms

---

## Implementation Priority

1. **High Priority** (Week 1-2):
   - Phase 1: Pending requests view
   - Phase 2: Approve/Reject + parent notification
   - Phase 5: Basic notification setup

2. **High Priority** (Week 2-3):
   - Phase 3: Teacher interest responses
   - Phase 4: Teacher assignment

3. **Medium Priority** (Week 3-4):
   - Phase 6: Polish UI/UX
   - Phase 7: Data flow optimization
   - In-app notification section

4. **Testing & Deployment** (Week 4):
   - Phase 9: Complete testing
   - Deployment to production

---

## Database Migration Scripts

Run these before starting implementation:

```sql
-- Add teacher_interest_requests table
CREATE TABLE public.teacher_interest_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lecture_request_id uuid NOT NULL REFERENCES lecture_requests(id) ON DELETE CASCADE,
  teacher_uid text NOT NULL REFERENCES teachers(uid),
  student_id uuid NOT NULL REFERENCES students(student_id),
  subject text NOT NULL,
  preferred_time_slots jsonb NOT NULL,
  student_grade text NOT NULL,
  interest_status text DEFAULT 'pending' 
    CHECK (interest_status IN ('pending', 'interested', 'rejected')),
  created_at timestamp DEFAULT NOW(),
  updated_at timestamp DEFAULT NOW(),
  CONSTRAINT unique_teacher_interest UNIQUE(lecture_request_id, teacher_uid)
);

-- Add notification tables
CREATE TABLE public.user_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  notification_type text NOT NULL,
  related_lecture_request_id uuid REFERENCES lecture_requests(id),
  related_assignment_id uuid REFERENCES teacher_student_assignments(id),
  is_read boolean DEFAULT false,
  created_at timestamp DEFAULT NOW(),
  read_at timestamp
);

CREATE TABLE public.notification_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL UNIQUE,
  title_template text NOT NULL,
  message_template text NOT NULL
);

-- Create indexes for performance
CREATE INDEX idx_lecture_requests_status ON lecture_requests(status);
CREATE INDEX idx_teacher_interest_requests_status ON teacher_interest_requests(interest_status);
CREATE INDEX idx_user_notifications_user_id ON user_notifications(user_id);
CREATE INDEX idx_user_notifications_is_read ON user_notifications(is_read);
```

---

## Dart Layer Architecture

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
│       ├── get_pending_requests.dart
│       ├── approve_lecture_request.dart
│       ├── get_teacher_interests.dart
│       └── assign_teacher.dart
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
    │   └── admin_lectures_event.dart/state.dart
    └── pages/
        ├── admin_lectures_home_page.dart
        ├── pending_requests_page.dart
        ├── approved_requests_page.dart
        ├── assigned_requests_page.dart
        ├── teacher_responses_page.dart
        ├── assign_teacher_page.dart
        └── admin_notifications_page.dart
```

---

## Key Takeaways

✅ Admin can manage lecture requests end-to-end
✅ Teachers show interest without seeing student/parent personal info
✅ Parents notified at key milestones
✅ All communication via FCM + in-app notifications
✅ Clear separation of concerns and privacy
✅ Database tracks all state changes
✅ Scalable architecture for future enhancements
