# Dhairya Application - Complete Architecture & Flow Plan

## Document Overview
This document provides a comprehensive overview of the Dhairya education platform architecture, user flows, and system design for the new lecture request and teacher allocation system.

---

## Table of Contents
1. [System Overview](#system-overview)
2. [User Roles & Permissions](#user-roles--permissions)
3. [Complete Lecture Request Workflow](#complete-lecture-request-workflow)
4. [Technical Architecture](#technical-architecture)
5. [Database Schema Overview](#database-schema-overview)
6. [Notification System](#notification-system)
7. [Security & Privacy](#security--privacy)
8. [Implementation Timeline](#implementation-timeline)

---

## System Overview

### 1.1 What is Dhairya?
Dhairya is an education technology platform that connects:
- **Parents** → Request tutoring services for their children
- **Students** → Receive personalized education from qualified teachers
- **Teachers** → Offer their expertise to interested students
- **Admins** → Manage the entire ecosystem (approvals, allocations, disputes)

### 1.2 Core Features
1. **Lecture Request Management** - Parents request tutoring
2. **Teacher Interest System** - Teachers respond to opportunities
3. **Assignment Management** - Admins allocate teachers to students
4. **Attendance Tracking** - Teachers mark attendance for each session
5. **Recurring Lectures** - Support weekly/daily recurring classes
6. **Notification System** - Real-time updates via FCM + in-app

---

## User Roles & Permissions

### 2.1 Parent Role
**What they do**:
- Create children profiles (students)
- Request lectures for their children (specific subjects, time slots, frequency)
- View pending/approved requests
- See assigned teachers (name only, no personal contact)
- See scheduled lectures and attendance records
- Receive notifications about request status

**What they can see**:
- ✅ Their own student details
- ✅ Request status (pending/approved/assigned)
- ✅ Teacher name and qualifications only
- ❌ Teacher phone, email, address
- ❌ Other student details
- ❌ Attendance details of other students

**Notifications**:
- "Your lecture request has been approved"
- "Teacher allocated, classes starting on [date]"
- "Lecture starting in 10 minutes"
- "Attendance marked: Present/Absent"

---

### 2.2 Teacher Role
**What they do**:
- Create profile with qualifications and availability
- Receive interest notifications for lecture requests
- Show interest in teaching specific students
- View assigned students and schedules
- Conduct lectures and mark attendance
- Access meeting links for online classes

**What they can see**:
- ✅ Student grade (e.g., "Grade 10")
- ✅ Subject requested
- ✅ Available time slots
- ✅ Student name AFTER assignment only
- ❌ Parent contact information ever
- ❌ Student personal details (phone, address)
- ❌ Payment information

**Notifications**:
- "A Grade X student needs [Subject] tutoring"
- "You've been assigned to teach [Subject]!"
- "Lecture starting in 10 minutes"
- "Attendance submission reminder"

---

### 2.3 Admin Role
**What they do**:
- Approve/reject lecture requests
- Find matching teachers for approved requests
- View teacher interest responses
- Allocate teachers to students
- Set dates and time slots
- Manage disputes and cancellations
- View all analytics and reports

**What they can see**:
- ✅ Everything (Parent names, emails, phones)
- ✅ Everything (Teacher credentials, contact)
- ✅ All lecture requests and assignments
- ✅ Complete attendance records
- ✅ Analytics dashboard

**Notifications** (in-app only):
- "New lecture request: [Student Name] in [Subject]"
- "Teacher [Name] is interested in request [ID]"
- Manual task assignments

---

## Complete Lecture Request Workflow

### 3.1 Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      LECTURE REQUEST FLOW                       │
└─────────────────────────────────────────────────────────────────┘

STEP 1: PARENT CREATES REQUEST
┌──────────────────────────────────────────────────────────────┐
│ Parent opens app → My Children → Select Child               │
│ → Request Lecture → Fill form:                              │
│   - Subject(s)                                              │
│   - Preferred time slots (day + time)                       │
│   - Frequency (daily, weekly, biweekly, monthly)            │
│   - Start date                                              │
│   - Additional notes                                        │
│ → Submit Request                                            │
│                                                             │
│ Database: lecture_requests created with status='pending'   │
└──────────────────────────────────────────────────────────────┘
                            ↓
STEP 2: ADMIN RECEIVES & REVIEWS
┌──────────────────────────────────────────────────────────────┐
│ Admin opens Admin Dashboard → Pending Requests tab          │
│ Sees:                                                       │
│   - Student: [First Last], Grade [X], Subjects: [...]     │
│   - Parent: [First Last], Phone, Email                     │
│   - Request Details: Notes                                  │
│                                                             │
│ Admin Actions:                                              │
│   [View Details] → See full request info                   │
│   [Approve] → Request enters APPROVAL stage                │
│   [Reject] → Send rejection reason to parent               │
└──────────────────────────────────────────────────────────────┘
                            ↓
STEP 3: ADMIN APPROVES REQUEST
┌──────────────────────────────────────────────────────────────┐
│ Admin clicks "Approve" on a pending request                 │
│                                                             │
│ Backend actions:                                            │
│ 1. Update lecture_requests: status = 'approved'            │
│ 2. Find matching teachers:                                 │
│    - Where teachers.subjects CONTAINS requested subject    │
│    - Where teacher_availability overlaps time slots        │
│    - Where verification_status = 'approved'                │
│ 3. Create teacher_interest_requests for each match         │
│ 4. Send FCM to parent: "Your request is approved!"        │
│                                                             │
│ Database:                                                  │
│   - lecture_requests.status = 'approved'                   │
│   - teacher_interest_requests.* (new records)              │
│   - user_notifications.* (parent notification)             │
└──────────────────────────────────────────────────────────────┘
                            ↓
STEP 4: TEACHERS RECEIVE INTEREST NOTIFICATIONS
┌──────────────────────────────────────────────────────────────┐
│ Teachers receive FCM: "A Grade X student needs [Subject]"  │
│                       "Time: [Slots] | Click to show interest"
│                                                             │
│ Teacher app shows "Interest Requests" section              │
│ Shows:                                                      │
│   - Student Grade: "Grade 10"                              │
│   - Subject: "Mathematics"                                 │
│   - Time Slots: "Mon 4-5 PM, Wed 6-7 PM, Fri 5-6 PM"     │
│   - ❌ NOT shown: Student name, parent info                │
│                                                             │
│ Teacher Actions:                                            │
│   [Show Interest] → Update teacher_interest_requests       │
│   [Ignore] → Keep status as pending                        │
│   [Decline] → Update status to rejected                    │
└──────────────────────────────────────────────────────────────┘
                            ↓
STEP 5: ADMIN REVIEWS TEACHER RESPONSES
┌──────────────────────────────────────────────────────────────┐
│ Admin opens → Approved Requests tab                         │
│ Sees: List of all teachers interested in each request     │
│                                                             │
│ For each interested teacher, shows:                        │
│   - Teacher: [First Last]                                  │
│   - Email: [email]                                         │
│   - Phone: [phone]                                         │
│   - Subject: [subject]                                     │
│   - Student Grade: [grade]                                │
│   - Preferred Time: [slots]                                │
│                                                             │
│ Admin Actions:                                              │
│   [Select & Assign] → Open assignment form                 │
│   [View Teacher Profile] → See full credentials            │
│   [Contact Teacher] → Direct message/email                 │
└──────────────────────────────────────────────────────────────┘
                            ↓
STEP 6: ADMIN ASSIGNS TEACHER
┌──────────────────────────────────────────────────────────────┐
│ Admin clicks "Select & Assign" for a teacher               │
│ Form appears:                                               │
│   - Selected Teacher: [Name] (read-only)                   │
│   - Student: [Grade] (read-only)                           │
│   - Subject: [Subject] (read-only)                         │
│   - Start Date: [Date Picker]                              │
│   - Time Slots: [Select from teacher's availability]       │
│   - Frequency: [Weekly/Daily/etc]                          │
│   - End Date: [Optional date picker]                       │
│   - Notes: [Text field]                                    │
│                                                             │
│ Admin clicks "Confirm Assignment"                          │
│                                                             │
│ Backend actions:                                            │
│ 1. Create teacher_student_assignments record              │
│ 2. Create initial lectures (one per week/day based on freq)│
│ 3. Update lecture_requests: status = 'assigned'            │
│ 4. Send FCM notifications:                                 │
│    - To Teacher: "You've been assigned! Student details..." │
│    - To Parent: "Teacher allocated! [Teacher Name]"       │
│ 5. Mark teacher_interest_requests as processed             │
│                                                             │
│ Database:                                                  │
│   - teacher_student_assignments.* (new record)            │
│   - lectures.* (multiple new records, one per session)    │
│   - lecture_requests.status = 'assigned'                   │
│   - user_notifications.* (multiple notifications)          │
└──────────────────────────────────────────────────────────────┘
                            ↓
STEP 7: ONGOING CLASS MANAGEMENT
┌──────────────────────────────────────────────────────────────┐
│ Classes proceed as per schedule                            │
│                                                             │
│ Teacher Actions:                                            │
│ - See "Assigned Students" in app                           │
│ - View: Student Name (after assignment), Grade, Subject   │
│ - Receive reminder 10 mins before class                    │
│ - Join video call (if online)                              │
│ - Mark attendance when session ends                        │
│                                                             │
│ Parent Actions:                                             │
│ - See "Assigned Classes" in app                            │
│ - View: Teacher Name, Subject, Schedule                   │
│ - See: "Attendance Marked: Present"                        │
│ - Receive reminder 15 mins before class                    │
│ - Join video call (if online)                              │
│                                                             │
│ Database:                                                  │
│   - lectures.* (updated with start/end times)             │
│   - lecture_attendance.* (attendance records)              │
│   - user_notifications.* (reminders sent)                  │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Status Transitions

```
lecture_requests.status flow:
┌──────────┐
│ pending  │ ← Initial state after parent creates request
└─────┬────┘
      │
      ├─→ [ADMIN REJECTS] ──────────────┐
      │                                 ↓
      │                            rejected (END)
      │
      └─→ [ADMIN APPROVES] ────────────────┐
                                           ↓
                                      ┌──────────┐
                                      │ approved │ ← Waiting for teacher assignment
                                      └─────┬────┘
                                            │
                                            └─→ [ADMIN ASSIGNS TEACHER] ──┐
                                                                          ↓
                                                                    ┌──────────┐
                                                                    │ assigned │ ← Classes scheduled
                                                                    └──────────┘

teacher_interest_requests.interest_status flow:
┌─────────┐
│ pending │ ← Created when admin approves parent request
└────┬────┘
     │
     ├─→ [TEACHER SHOWS INTEREST] ──────────┐
     │                                      ↓
     │                                 ┌──────────┐
     │                                 │interested│
     │                                 └──────────┘
     │
     └─→ [TEACHER REJECTS/IGNORES] ────────┐
                                           ↓
                                        rejected (END)
```

---

## Technical Architecture

### 4.1 High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DHAIRYA ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────┘

                            ┌──────────────────┐
                            │   FLUTTER APP    │
                            │  (All user types)│
                            └────────┬─────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
            ┌───────▼─────┐  ┌───────▼─────┐  ┌─────▼──────┐
            │  BLoC Layer │  │  Use Cases  │  │  Entities  │
            └───────┬─────┘  └───────┬─────┘  └──────────────┘
                    │                │
                    └────────────────┼──────────────────┐
                                     │                  │
                            ┌────────▼────────┐  ┌─────▼──────┐
                            │   Repository    │  │  DataSource│
                            │   Interfaces    │  │  (Remote)  │
                            └────────┬────────┘  └─────┬──────┘
                                     │                  │
                                     └──────────────────┤
                                                        │
                            ┌───────────────────────────▼──────┐
                            │      SUPABASE (PostgreSQL)       │
                            │  - lecture_requests              │
                            │  - teacher_interest_requests     │
                            │  - teacher_student_assignments   │
                            │  - lectures                      │
                            │  - user_notifications           │
                            │  - user_fcm_tokens              │
                            └────────────────────────────────┘

                            ┌──────────────────────────────┐
                            │  FIREBASE (Messaging)        │
                            │  - FCM Tokens                │
                            │  - Push Notifications        │
                            └──────────────────────────────┘

                            ┌──────────────────────────────┐
                            │  Cloud Functions (Optional)  │
                            │  - Auto-approve requests     │
                            │  - Send bulk notifications   │
                            │  - Recurring lecture creation│
                            └──────────────────────────────┘
```

### 4.2 Data Flow for Lecture Request Approval

```
┌──────────────────────────────────────────────────────────────┐
│ DATA FLOW: Approving a Lecture Request                       │
└──────────────────────────────────────────────────────────────┘

1. UI LAYER (Admin Dashboard)
   ┌─────────────────────────────────────────────┐
   │ User clicks [Approve] button                │
   └─────────────────────┬───────────────────────┘
                         ↓
2. EVENT LAYER
   ┌─────────────────────────────────────────────┐
   │ AdminLecturesBloc.add(ApproveLectureRequest │
   │   (requestId, adminUid))                    │
   └─────────────────────┬───────────────────────┘
                         ↓
3. USE CASE LAYER
   ┌─────────────────────────────────────────────┐
   │ ApproveLectureRequest.call(params)          │
   │ - Validates admin permissions               │
   │ - Prepares data                             │
   └─────────────────────┬───────────────────────┘
                         ↓
4. REPOSITORY LAYER
   ┌─────────────────────────────────────────────┐
   │ AdminLectureRepository.approveLectureRequest│
   │ - Calls datasource                          │
   └─────────────────────┬───────────────────────┘
                         ↓
5. DATA SOURCE LAYER
   ┌─────────────────────────────────────────────┐
   │ AdminRemoteDatasource.approveLectureRequest │
   │                                             │
   │ Actions:                                    │
   │ 1. UPDATE lecture_requests SET status=...  │
   │ 2. Query matching teachers                  │
   │ 3. INSERT teacher_interest_requests         │
   │ 4. INSERT user_notifications (parent)       │
   │ 5. Call sendFCMNotification(parentUid)     │
   └─────────────────────┬───────────────────────┘
                         ↓
6. SUPABASE & FIREBASE
   ┌────────────────────────────────────────────────┐
   │ ✓ Lecture request updated                      │
   │ ✓ Teacher interest requests created            │
   │ ✓ Notifications stored in DB                   │
   │ ✓ FCM notification sent to parent's device     │
   └────────────────────────────────────────────────┘
                         ↓
7. STATE LAYER
   ┌─────────────────────────────────────────────┐
   │ AdminLecturesState.ApprovalSuccess emitted  │
   └─────────────────────┬───────────────────────┘
                         ↓
8. UI UPDATE
   ┌─────────────────────────────────────────────┐
   │ BlocBuilder rebuilds                        │
   │ Shows success message                       │
   │ Refreshes pending requests list              │
   │ Moves request to "Approved" tab             │
   └─────────────────────────────────────────────┘
```

---

## Database Schema Overview

### 5.1 Key Tables

**lecture_requests** (Parent-initiated requests)
```
- id (UUID, PK)
- parent_uid (FK to parents)
- student_id (FK to students)
- subjects (Array of strings)
- preferred_time_slots (JSONB: {day: "Mon", time: "4-5 PM"})
- status (pending, approved, rejected, assigned)
- priority_level (1-5)
- requested_start_date (Date)
- frequency (daily, weekly, biweekly, monthly)
- additional_notes (Text)
- created_at, updated_at
```

**teacher_interest_requests** (NEW - Teacher interest responses)
```
- id (UUID, PK)
- lecture_request_id (FK to lecture_requests)
- teacher_uid (FK to teachers)
- student_id (FK to students)
- subject (Text)
- preferred_time_slots (JSONB)
- student_grade (Text) ← Only grade, NOT name
- interest_status (pending, interested, rejected)
- created_at, updated_at
```

**teacher_student_assignments** (Actual assignments)
```
- id (UUID, PK)
- lecture_request_id (FK to lecture_requests)
- teacher_uid (FK to teachers)
- student_id (FK to students)
- subjects (Array)
- assigned_by (Admin UID)
- assignment_status (active, paused, completed, cancelled)
- start_date, end_date (Dates)
- notes (Text)
- created_at, updated_at
```

**lectures** (Individual class sessions)
```
- id (UUID, PK)
- assignment_id (FK to teacher_student_assignments)
- teacher_uid, student_id
- subject, scheduled_date, scheduled_time
- status (scheduled, in_progress, completed, cancelled)
- meeting_link (For online classes)
- created_at, updated_at
```

**user_notifications** (NEW - In-app notifications)
```
- id (UUID, PK)
- user_id (FK to users)
- title, message (Text)
- notification_type (lecture_request_approved, teacher_assigned, etc)
- related_lecture_request_id, related_assignment_id (FKs)
- is_read (Boolean)
- created_at, read_at (Timestamps)
```

**user_fcm_tokens** (For push notifications)
```
- id (UUID, PK)
- user_id (FK to users)
- fcm_token (Text)
- platform (android, ios, web)
- is_active (Boolean)
- created_at, last_used_at
```

### 5.2 Entity Relationships

```
parents (1) ──────→ (N) lecture_requests
                           │
                           ├──→ teacher_interest_requests (N)
                           │
                           └──→ teacher_student_assignments
                                    │
                                    └──→ lectures (N)

students (1) ──────→ (N) lecture_requests
                           │
                           └──→ lectures (N)

teachers (1) ──────→ (N) teacher_interest_requests
                    │
                    └──→ (N) teacher_student_assignments
                                 │
                                 └──→ (N) lectures

users (1) ──────→ (N) user_notifications
              │
              └──→ (N) user_fcm_tokens
```

---

## Notification System

### 6.1 Notification Types & Triggers

```
NOTIFICATION TYPES                      TRIGGERED BY              SENT TO
─────────────────────────────────────────────────────────────────────────
1. lecture_request_approved             Admin approves request    Parent
   "Your request is approved!"

2. teacher_interested                   Teacher shows interest    Admin (in-app only)
   "Teacher X is interested"

3. teacher_assigned                     Admin assigns teacher    Teacher & Parent
   "You've been assigned!"

4. lecture_starting_soon                15 mins before lecture   Teacher & Parent
   "Class starting in 15 minutes"

5. attendance_marked                    Teacher marks attendance  Parent
   "Attendance marked: Present"

6. lecture_cancelled                    Teacher/Admin cancels    Affected users
   "Class cancelled"

7. lecture_rescheduled                  Admin reschedules        Affected users
   "Class rescheduled to [date]"
```

### 6.2 Notification Delivery Mechanism

```
┌────────────────────────────────────────────────────────────┐
│                NOTIFICATION FLOW                           │
└────────────────────────────────────────────────────────────┘

Step 1: Trigger Event
├─ Admin approves lecture request
├─ Teacher shows interest
└─ Admin assigns teacher

Step 2: Create Database Record
├─ INSERT INTO user_notifications (...)
├─ title, message, type, user_id
└─ is_read = false

Step 3: Send FCM Push (if enabled)
├─ Query user_fcm_tokens for user_id
├─ Send via Firebase Cloud Messaging
├─ Device receives notification
└─ User sees notification in status bar

Step 4: In-App Display
├─ App loads user_notifications when opened
├─ Shows notification center badge count
├─ User can tap to view full notification
└─ Mark as read on tap

Step 5: User Action
├─ Tap notification → Navigate to relevant section
└─ Dismiss notification → Mark as read
```

### 6.3 FCM Configuration Steps

```
STEP 1: Firebase Project Setup
├─ Go to Firebase Console
├─ Create/select project
├─ Enable Firebase Cloud Messaging
└─ Download google-services.json (Android) & GoogleService-Info.plist (iOS)

STEP 2: Flutter Dependencies
Add to pubspec.yaml:
  firebase_messaging: ^14.0.0
  firebase_core: ^2.0.0

STEP 3: Initialize in main.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final token = await FirebaseMessaging.instance.getToken();
  
  // Store token in Supabase
  await supabaseClient
    .from('user_fcm_tokens')
    .insert({
      'user_id': currentUserId,
      'fcm_token': token,
      'platform': Platform.isAndroid ? 'android' : 'ios'
    });

STEP 4: Handle Foreground Messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received: ${message.notification?.title}');
    // Show in-app overlay
  });

STEP 5: Handle Background Messages
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    // Handle notification when app is in background
  }
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

STEP 6: Send from Backend (Optional - Cloud Functions)
  admin.messaging().sendMulticast({
    tokens: [fcm_token_1, fcm_token_2],
    notification: {
      title: "Your request is approved!",
      body: "Admin has approved your lecture request"
    },
    data: {
      type: "lecture_request_approved",
      lectureRequestId: "..."
    }
  });
```

---

## Security & Privacy

### 7.1 Privacy Rules

```
TEACHER SHOULD NEVER SEE:
❌ Parent name, email, phone
❌ Student name (before assignment)
❌ Student address, DOB, personal details
❌ Payment information
❌ Parent contact details
❌ Other student information

TEACHER CAN SEE (Before Assignment):
✅ Student grade (e.g., "Grade 10")
✅ Subject(s) requested
✅ Available time slots
✅ Preferred days/times

TEACHER CAN SEE (After Assignment):
✅ Student full name
✅ Student grade
✅ Subject(s)
✅ Scheduled lecture times
❌ Still NO personal contact
❌ Still NO personal details beyond academics

PARENT SHOULD NEVER SEE:
❌ Other student information
❌ Other parent information
❌ Teacher personal contact before assignment
❌ Admin operations/details

PARENT CAN SEE:
✅ Own student profiles
✅ Request status
✅ Assigned teacher name & qualifications
✅ Scheduled lectures and attendance
❌ After assignment, still NO teacher phone/email
❌ NO teacher residential address

ADMIN CAN SEE:
✅ Everything (complete transparency)
```

### 7.2 Database Row Level Security (RLS)

```sql
-- Teachers can only see interest requests and assignments for their students
CREATE POLICY teacher_see_own_assignments ON teacher_student_assignments
FOR SELECT USING (
  teacher_uid = auth.uid()
);

-- Parents can only see their own student requests
CREATE POLICY parent_see_own_requests ON lecture_requests
FOR SELECT USING (
  parent_uid = auth.uid()
);

-- Users can only see their own notifications
CREATE POLICY user_see_own_notifications ON user_notifications
FOR SELECT USING (
  user_id = auth.uid()
);
```

### 7.3 Field-Level Masking (Application Layer)

```dart
// When querying teacher for teacher_interest_requests
TeacherInterestModel.fromDatabase(data) {
  return TeacherInterestModel(
    subject: data['subject'],
    studentGrade: data['student_grade'], // Show
    preferredTimeSlots: data['preferred_time_slots'], // Show
    // Don't include: teacher_email, teacher_phone, student_name
  );
}

// When querying teacher for assignment details
TeacherModel.forStudentView(data) {
  return TeacherModel(
    name: data['first_name'] + ' ' + data['last_name'],
    subjects: data['subjects'],
    qualifications: data['qualifications'],
    // Don't include: phone_number, email, address
  );
}
```

---

## Implementation Timeline

### Phase 1: Backend Setup (Week 1)
- [ ] Create new tables: teacher_interest_requests, user_notifications
- [ ] Add indexes for performance
- [ ] Set up RLS policies
- [ ] Create notification templates

### Phase 2: Core Admin Flow (Week 2)
- [ ] Create AdminLectureRepository & Datasource
- [ ] Implement getLecturePendingRequests()
- [ ] Implement approveLectureRequest() (approve + find teachers)
- [ ] Implement rejectLectureRequest()
- [ ] Create AdminLecturesBloc & UI

### Phase 3: Teacher Interest System (Week 2-3)
- [ ] Implement getTeacherInterestRequests()
- [ ] Create teacher UI for showing interest
- [ ] Implement teacher interest submission
- [ ] Real-time updates for admin

### Phase 4: Assignment System (Week 3)
- [ ] Implement assignTeacherToStudent()
- [ ] Create lecture records automatically
- [ ] Send notifications to teacher & parent
- [ ] Create AssignmentUI

### Phase 5: Notifications (Week 3-4)
- [ ] Set up Firebase Cloud Messaging
- [ ] Implement FCM token storage
- [ ] Create notification service
- [ ] Build in-app notification center
- [ ] Test on Android & iOS

### Phase 6: Polish & Testing (Week 4)
- [ ] UI/UX improvements
- [ ] Security review
- [ ] Performance optimization
- [ ] End-to-end testing
- [ ] Deployment preparation

---

## Key Metrics & Monitoring

```
ADMIN DASHBOARD METRICS
├─ Pending requests: [Count]
├─ Approved requests awaiting assignment: [Count]
├─ Assigned lectures: [Count]
├─ Teachers (verified/pending): [Count]
├─ Average approval time: [Duration]
└─ Teacher acceptance rate: [Percentage]

NOTIFICATION METRICS
├─ FCM delivery rate: [Percentage]
├─ In-app notification reads: [Count]
├─ Notification click-through rate: [Percentage]
└─ Average time from trigger to delivery: [Duration]

QUALITY METRICS
├─ Request approval success rate: [Percentage]
├─ Teacher allocation success rate: [Percentage]
├─ Lecture completion rate: [Percentage]
└─ User satisfaction score: [1-5 rating]
```

---

## API Endpoints Overview

```
ADMIN ENDPOINTS
POST   /api/admin/lectures/requests/{id}/approve
POST   /api/admin/lectures/requests/{id}/reject
GET    /api/admin/lectures/requests/pending
GET    /api/admin/lectures/requests/approved
GET    /api/admin/lectures/teacher-interests/{requestId}
POST   /api/admin/lectures/assign-teacher

TEACHER ENDPOINTS
GET    /api/teacher/interest-requests
POST   /api/teacher/interest-requests/{id}/show-interest
POST   /api/teacher/interest-requests/{id}/decline
GET    /api/teacher/assigned-students
GET    /api/teacher/upcoming-lectures

PARENT ENDPOINTS
POST   /api/parent/lecture-requests
GET    /api/parent/lecture-requests
GET    /api/parent/assigned-teachers
GET    /api/parent/student-lectures/{studentId}

NOTIFICATION ENDPOINTS
GET    /api/notifications
POST   /api/notifications/{id}/mark-read
DELETE /api/notifications/{id}
```

---

## Success Criteria

✅ Parents can request lectures easily
✅ Admins can view all requests and approve them
✅ Teachers receive notifications without seeing student names
✅ Teachers can show interest in opportunities
✅ Admins can allocate teachers to students
✅ All stakeholders receive timely notifications
✅ Teachers and parents see appropriate information (privacy respected)
✅ System scales to handle 1000s of concurrent requests
✅ Notifications delivered within 30 seconds
✅ Zero PII leaks between user types

---

## Future Enhancements

1. **Auto-Approval System**: Admin sets rules, some requests auto-approve
2. **AI Matching**: Suggest best teachers based on availability, ratings, subjects
3. **Payment Integration**: Process payments for lectures
4. **Dispute Resolution**: Handle disagreements between teachers/parents
5. **Rating System**: Teachers & parents rate each other
6. **Performance Analytics**: Track student progress over time
7. **Mobile-only Verification**: Two-factor authentication
8. **Video Call Integration**: Integrated Zoom/Google Meet
9. **Batch Scheduling**: Admin bulk-assign teachers
10. **Recurring Lecture Templates**: Pre-set schedules with variations

---

## References & Resources

- Supabase Documentation: https://supabase.com/docs
- Firebase Messaging: https://firebase.flutter.dev/docs/messaging/overview
- Flutter BLoC: https://bloclibrary.dev/
- Material Design 3: https://m3.material.io/

---

**Document Version**: 1.0
**Last Updated**: March 8, 2026
**Status**: Ready for Implementation
