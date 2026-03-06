# Dhairya - Education Management Platform

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Technology Stack](#-technology-stack)
- [Architecture](#-architecture)
- [Features Implemented](#-features-implemented)
- [User Flows](#-user-flows)
- [Database Schema](#-database-schema)
- [Features Roadmap](#-features-roadmap)
- [Setup Instructions](#-setup-instructions)

---

## 🎯 Project Overview

**Dhairya** is a comprehensive education management platform built with Flutter and Supabase, designed to connect parents, teachers, and language learners in a seamless learning ecosystem. The platform facilitates lecture scheduling, profile management, and educational interactions between all stakeholders.

### Key Objectives
- Simplify parent-teacher communication and scheduling
- Provide teachers with tools to manage students and lectures efficiently
- Enable flexible lecture scheduling with recurring patterns
- Offer real-time updates and notifications
- Support multiple user types with role-based access

### Current Status
**Overall Progress: ~80% Complete**

---

## 🛠 Technology Stack

### Frontend
- **Framework:** Flutter 3.3.0+
- **Language:** Dart
- **State Management:** BLoC (flutter_bloc 8.1.6)
- **Routing:** Navigator 2.0
- **UI/UX:** Material Design 3 with custom animations

### Backend
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Storage:** Supabase Storage (profile pictures, documents)
- **Real-time:** Supabase Real-time subscriptions

### Key Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.6          # State management
  fpdart: ^1.1.0                # Functional programming
  supabase_flutter: ^2.x.x      # Backend integration
  intl: ^0.19.0                 # Internationalization & date formatting
  file_picker: ^8.0.7           # File selection
  logger: ^2.x.x                # Logging
  connectivity_plus: ^x.x.x     # Network connectivity
```

### Architecture Pattern
- **Clean Architecture** with clear separation of concerns
- **Domain-Driven Design (DDD)**
- **Repository Pattern** for data abstraction
- **Use Cases** for business logic encapsulation
- **BLoC Pattern** for state management

---

## 🏗 Architecture

### Layer Structure
```
lib/
├── core/                           # Shared utilities and base classes
│   ├── entities/                   # Core domain entities
│   ├── error/                      # Error handling
│   ├── theme/                      # App theming
│   ├── utils/                      # Helper functions
│   └── widgets/                    # Reusable widgets
│
├── features/                       # Feature modules (Clean Architecture)
│   ├── auth/                       # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/       # Remote/Local data sources
│   │   │   ├── models/            # Data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business logic
│   │   └── presentation/
│   │       ├── bloc/              # State management
│   │       ├── pages/             # UI screens
│   │       └── widgets/           # Feature-specific widgets
│   │
│   ├── lectures/                   # Lecture management
│   ├── profile/                    # User profiles
│   ├── parents/                    # Parent-specific features
│   ├── teachers/                   # Teacher-specific features
│   └── home/                       # Dashboard & navigation
│
├── dependency_injection.dart       # DI configuration
└── main.dart                       # App entry point
```

### Data Flow
```
UI (Pages) 
  ↓
BLoC (Events/States)
  ↓
Use Cases (Business Logic)
  ↓
Repository Interface (Contract)
  ↓
Repository Implementation
  ↓
Data Sources (Remote/Local)
  ↓
Supabase / API
```

---

## ✨ Features Implemented

### 🔐 1. Authentication System (100% Complete)

#### Features
- ✅ Email/Password authentication
- ✅ Google OAuth integration
- ✅ Email verification flow
- ✅ Password reset capability
- ✅ Persistent session management
- ✅ Automatic routing based on user type
- ✅ Secure logout

#### Flow
1. **Sign Up**
   - User enters: First Name, Middle Name, Last Name, Email, Password
   - System creates account in Supabase Auth
   - Sends verification email
   - Redirects to verification page

2. **Email Verification**
   - User clicks verification link in email
   - System updates `email_verified` status
   - Redirects to profile selection

3. **Profile Selection**
   - User chooses role: Parent / Teacher / Language Learner
   - System updates `usertype` in database
   - Redirects to role-specific profile completion

4. **Login**
   - User enters email and password
   - System validates credentials
   - If verified: Routes to dashboard
   - If not verified: Routes to verification page

5. **Google Sign In**
   - One-click authentication
   - Auto-creates account
   - Routes to profile selection if new user

#### Technical Implementation
```dart
// BLoC Events
- AuthSignUp
- AuthLogIn
- AuthGoogleSignIn
- AuthLogout
- AuthEmailVerification
- AuthIsUserLoggedIn

// States
- AuthInitial
- AuthLoading
- AuthSuccess
- AuthFailure
- AuthUserLoggedIn
- AuthEmailVerificationSuccess
```

---

### 👨‍👩‍👧 2. Parent Module (85% Complete)

#### Profile Management ✅
- **Complete profile creation with:**
  - Personal information (name, DOB, gender)
  - Contact details (phone, email)
  - Address information (city, state, country, pincode)
  - Occupation details
  - Profile picture upload (Supabase Storage)
- **Profile editing and updates**
- **Modern profile view with gradient design**
- **Animated UI components**

#### Student Management ✅
- **Add multiple students (children)**
  ```dart
  Student {
    student_id: UUID (auto-generated)
    parent_uid: FK -> parents.uid
    first_name, middle_name, last_name
    standard: String (e.g., "Class 10")
    subjects: List<String>
    board: Enum (CBSE, ICSE, State Board, IB, Cambridge)
    medium: Enum (English, Hindi, Regional)
    profile_pic_url: String?
    created_at, updated_at
  }
  ```
- **View all students in modern card layout**
- **Student profile information display**
- ✅ **Edit student profiles** (recently implemented)
- ⏳ Delete student profiles (Pending)

#### Dashboard Features ✅
- **Welcome header with parent name**
- **Quick access cards:**
  - View all students
  - Add new student
  - View reports
  - Manage schedules
- **Student list overview with profile pictures**
- **Modern animations and transitions**
- **Bottom navigation:** Home, Students, Lectures, Calendar, Profile

#### Lecture Features 🔄 (60% Complete)
- ✅ **Request lectures from teachers**
  - Select student
  - Choose subject
  - Pick preferred days and time slots
  - Add notes/requirements
- ✅ **View lecture requests status**
  - Pending requests
  - Accepted requests
  - Declined requests
- ✅ **View teacher-student assignments**
- ✅ **View upcoming lectures**
- ⏳ Cancel lectures (Pending)
- ⏳ Reschedule requests (Pending)

#### Technical Details
```dart
// Key Files
lib/features/parents/
├── lectures/
│   └── presentation/pages/
│       ├── parent_lectures_home_page.dart
│       ├── parent_request_lecture_page.dart
│       ├── parent_lecture_requests_page.dart
│       ├── parent_student_assignments_page.dart
│       └── parent_upcoming_lectures_page.dart

// Database Tables
- parents (profile data)
- students (children data)
- lecture_requests (lecture requests)
- teacher_student_assignments (approved relationships)
- lectures (scheduled lectures)
```

---

### 👨‍🏫 3. Teacher Module (75% Complete)

#### Profile Management ✅
- **Complete profile creation:**
  - Personal information
  - Contact details
  - Address information
  - Teaching credentials
  - Subjects taught
  - Experience and qualifications
  - Profile picture upload
  - Verification status (Pending/Approved/Rejected)
- **Profile editing**
- **Verification system** (Admin approval required)

#### Dashboard Features ✅
- **Teacher home page with statistics**
- **Bottom navigation:** Home, Students, Classes, Reports, Profile
- **Quick access to:**
  - Upcoming lectures
  - Student list
  - Lecture creation
  - Availability management

#### Lecture Management ✅ (90% Complete)
- ✅ **Create one-time lectures**
  - Select student from assignments
  - Choose subject
  - Set date, start time, and end time
  - Add meeting link (for online classes)
  - Add notes
- ✅ **Create recurring lectures** (Alarm-clock pattern)
  - Select days of week (Mon-Sun)
  - Set start and end date
  - Set time slot
  - Template-based generation (one master record)
  - Automatic instance creation on-demand
- ✅ **View all lectures**
  - Grouped by recurring series
  - Shows "MON-WED-FRI" patterns
  - Lecture count display
  - Filter by status (Scheduled, Completed, Cancelled)
- ✅ **Lecture details view**
- ✅ **Set availability schedule**
- ⏳ Reschedule lectures (Pending)
- ⏳ Mark attendance (Pending)
- ⏳ Update lecture status (Pending)

#### Student Management ✅
- **View assigned students**
- **View lecture requests**
  - Accept/Decline requests
  - Auto-creates teacher-student assignments
- **Student performance tracking** (UI ready, logic pending)

#### Technical Highlights

**Recurring Lectures - Alarm Clock Pattern:**
```dart
// Template-based system (no bulk inserts)
RecurringLectureTemplate {
  id: UUID
  series_id: String (groups lectures)
  recurrence_pattern: 'weekly' | 'daily'
  recurrence_days: ['monday', 'wednesday', 'friday']
  start_date, end_date
  scheduled_time: TimeSlot {start, end}
  is_active: boolean
}

// Instances generated lazily
Lecture {
  id: UUID
  template_id: FK? (links to template)
  series_id: String (groups recurring lectures)
  is_recurring: boolean
  scheduled_date: Date
  scheduled_time: TimeSlot
  status: 'scheduled' | 'completed' | 'cancelled'
}

// Auto-generation on query
getLectures(fromDate, toDate) {
  1. Find active templates overlapping date range
  2. Generate missing instances for each template
  3. Check existing instances (avoid duplicates)
  4. Bulk insert only missing instances
  5. Return all lectures in range
}
```

**UI Grouping:**
```dart
// Recurring lectures grouped by series_id
RecurringLectureGroupCard {
  - Shows: "MON-WED-FRI lecture"
  - Displays: "8 lectures"
  - Date range: "12 Feb - 15 Mar 2026"
  - Actions: Reschedule series, Cancel series
}

// One-time lectures shown individually
LectureCard {
  - Single lecture details
  - Actions: Reschedule, Cancel
}
```

---

### 🎓 4. Language Learner Module (60% Complete)

#### Profile Management ✅
- **Profile creation:**
  - Personal information
  - Native language
  - Languages learning
  - Proficiency levels
  - Learning goals
  - Profile picture upload
- **Profile editing**

#### Dashboard 🔄 (40% Complete)
- ✅ Basic layout
- ⏳ Course enrollment (Pending)
- ⏳ Progress tracking (Pending)
- ⏳ Lessons and modules (Pending)

---

### 📚 5. Lecture System (85% Complete)

#### Core Features ✅
- **One-time lecture creation**
- **Recurring lecture templates** (Alarm-clock pattern)
- **Automatic instance generation**
- **Lecture grouping by series**
- **Status management** (scheduled, completed, cancelled)
- **Meeting link support** (online classes)
- **Notes and description**

#### Request System ✅
- **Parents can request lectures**
  - Choose student and subject
  - Select preferred days/times
  - Add requirements
- **Teachers can accept/decline**
  - Creates teacher-student assignment on acceptance
  - Notifies parent of decision

#### Views ✅
- **Teacher views:**
  - All lectures (grouped recurring)
  - Upcoming lectures
  - Filter by status
  - Lecture details
- **Parent views:**
  - Upcoming lectures for all students
  - Filter by student
  - Lecture requests status

#### Data Models
```dart
Lecture {
  id: UUID
  assignment_id: FK -> teacher_student_assignments
  teacher_uid, student_id
  subject: String
  scheduled_date: Date
  scheduled_time: TimeSlot {start, end}
  
  // Recurring info
  is_recurring: boolean
  series_id: String?
  template_id: UUID? (FK -> recurring_lecture_templates)
  recurrence_pattern: 'one-time' | 'daily' | 'weekly'
  recurrence_days: String[]?
  recurrence_end_date: Date?
  
  // Status
  status: String
  
  // Optional
  notes: String?
  meeting_link: String?
  attendance_marked: boolean
  
  // Joins
  student: {first_name, last_name, standard}
}

RecurringLectureTemplate {
  id: UUID
  assignment_id: FK
  teacher_uid, student_id
  subject: String
  recurrence_pattern: 'daily' | 'weekly'
  recurrence_days: String[]
  start_date: Date
  end_date: Date?
  scheduled_time: TimeSlot
  notes: String?
  meeting_link: String?
  is_active: boolean
  series_id: String
}

LectureRequest {
  id: UUID
  parent_uid: FK
  student_id: FK
  subject: String
  preferred_days: String[]
  preferred_time_slots: TimeSlot[]
  notes: String?
  status: 'pending' | 'accepted' | 'declined'
  created_at, updated_at
}

TeacherStudentAssignment {
  id: UUID
  teacher_uid: FK
  student_id: FK
  parent_uid: FK
  subject: String
  status: 'active' | 'inactive'
  created_from_request_id: UUID?
  created_at
}
```

---

### 🎨 6. UI/UX System (90% Complete)

#### Design System ✅
- **Material Design 3**
- **Custom color palette:**
  ```dart
  primaryColor: Color(0xFF6C5CE7)
  secondaryColor: Color(0xFF00B894)
  backgroundColor: Color(0xFFF5F5F5)
  errorColor: Color(0xFFD63031)
  ```
- **Typography system** (Poppins font family)
- **Consistent spacing and sizing**
- **Dark mode support** (Pending)

#### Animations ✅
- **ScaleInAnimation** - Scale and fade entrance
- **SlideInAnimation** - Slide from bottom
- **FadeInAnimation** - Smooth fade in
- **RotateAnimation** - Rotation effects
- **Page transitions**
- **Loading states with shimmer** (Pending)

#### Custom Widgets ✅
- **AuthButton** - Gradient buttons for auth
- **ProjectButton** - Primary action buttons
- **AuthTextfield** - Styled input fields
- **CustomLoader** - Loading indicators
- **LectureCard** - Lecture display card
- **RecurringLectureGroupCard** - Grouped recurring lectures
- **StudentCard** - Student profile card
- **DaySelector** - Day of week picker
- **TimeSlotPicker** - Time range selector

#### Responsive Design 🔄 (70% Complete)
- ✅ Mobile layouts
- ✅ Tablet considerations
- ⏳ Web responsiveness (Pending)

---

## 🔄 User Flows

### 1. Parent Registration to Lecture Request
```
1. Landing Page
   ↓ [Sign Up]
2. Sign Up Page
   - Enter: First Name, Middle Name, Last Name, Email, Password
   ↓ [Submit]
3. Email Verification Page
   - Check email for verification link
   ↓ [Verify Email]
4. Profile Selection Page
   - Select: Parent
   ↓ [Continue]
5. Parent Profile Completion
   - Enter: Personal info, Contact, Address, Occupation
   - Upload profile picture
   ↓ [Complete Profile]
6. Parent Dashboard
   - View welcome screen
   ↓ [Add Student]
7. Add Student Page
   - Enter: Student details, Standard, Subjects, Board
   ↓ [Add Student]
8. Students Page
   - View all students
   ↓ [Navigate to Lectures]
9. Parent Lectures Home
   - View options: Request Lecture, View Requests, Upcoming Lectures
   ↓ [Request Lecture]
10. Request Lecture Page
    - Select: Student, Subject
    - Choose: Preferred days, Time slots
    - Add notes
    ↓ [Submit Request]
11. Lecture Requests Page
    - View status: Pending
    ↓ [Wait for teacher acceptance]
```

### 2. Teacher Registration to Lecture Creation
```
1. Landing Page
   ↓ [Sign Up]
2. Sign Up Page
   ↓ [Submit]
3. Email Verification
   ↓ [Verify]
4. Profile Selection
   - Select: Teacher
   ↓ [Continue]
5. Teacher Profile Completion
   - Enter: Credentials, Subjects, Experience
   - Upload documents
   ↓ [Submit for Verification]
6. Pending Verification Page
   - Wait for admin approval
   ↓ [Approved]
7. Teacher Dashboard
   - View stats, upcoming lectures
   ↓ [View Lecture Requests]
8. Lecture Requests (from parents)
   - Review request details
   ↓ [Accept Request]
9. Create Assignment
   - Auto-creates teacher-student assignment
   ↓ [Navigate to Create Lecture]
10. Create Lecture Page
    - Select: Student (from assignments), Subject
    - Choose: One-time or Recurring
    
    [One-time]:
    - Select: Date, Start Time, End Time
    - Add: Meeting link, Notes
    ↓ [Create Lecture]
    
    [Recurring]:
    - Select: Days (Mon-Sun checkboxes)
    - Select: Start Date, End Date
    - Set: Time slot
    - Add: Meeting link, Notes
    ↓ [Create Template]
    
11. Lectures List Page
    - View grouped recurring lectures
    - View individual lectures
    - Filter by status
```

### 3. Recurring Lecture Auto-Generation Flow
```
1. Teacher creates recurring template
   - Days: Monday, Wednesday, Friday
   - Start: Feb 12, 2026
   - End: Mar 15, 2026
   - Time: 10:00 AM - 11:00 AM
   ↓
2. Template stored in database
   - No individual lectures created yet
   ↓
3. Parent/Teacher queries lectures for Feb 12-20
   ↓
4. System auto-generates instances
   - Checks template: Should lecture occur on each date?
   - Monday Feb 12: ✅ Create
   - Tuesday Feb 13: ❌ Skip
   - Wednesday Feb 14: ✅ Create
   - Thursday Feb 15: ❌ Skip
   - Friday Feb 16: ✅ Create
   - etc.
   ↓
5. Check for existing instances
   - Query by series_id and dates
   - Only insert missing ones
   ↓
6. Return all lectures in range
   - One-time + Recurring instances
```

---

## 💾 Database Schema

### Supabase Tables

#### 1. `auth.users` (Supabase Auth)
```sql
id: UUID (PK)
email: VARCHAR
email_confirmed_at: TIMESTAMP
created_at: TIMESTAMP
updated_at: TIMESTAMP
```

#### 2. `users`
```sql
uid: TEXT (PK, FK -> auth.users.id)
first_name: TEXT
middle_name: TEXT
last_name: TEXT
email: TEXT (UNIQUE)
usertype: TEXT (parent, teacher, language_learner, none)
email_verified: BOOLEAN
created_at: TIMESTAMPTZ
updated_at: TIMESTAMPTZ
```

#### 3. `parents`
```sql
uid: TEXT (PK, FK -> users.uid)
first_name, middle_name, last_name: TEXT
email: TEXT
phone: TEXT
date_of_birth: DATE
gender: TEXT
address_line1, address_line2: TEXT
city, state, country: TEXT
pincode: TEXT
occupation: TEXT
profile_pic_url: TEXT
created_at, updated_at: TIMESTAMPTZ
```

#### 4. `students`
```sql
student_id: UUID (PK)
parent_uid: TEXT (FK -> parents.uid)
first_name, middle_name, last_name: TEXT
standard: TEXT (e.g., "Class 10")
subjects: TEXT[] (array of subjects)
board: TEXT (CBSE, ICSE, State Board, IB, Cambridge)
medium: TEXT (English, Hindi, Regional)
profile_pic_url: TEXT
created_at, updated_at: TIMESTAMPTZ
```

#### 5. `teachers`
```sql
uid: TEXT (PK, FK -> users.uid)
first_name, middle_name, last_name: TEXT
email: TEXT
phone: TEXT
date_of_birth: DATE
gender: TEXT
address: TEXT (JSONB)
subjects_taught: TEXT[]
experience: TEXT
qualifications: TEXT
profile_pic_url: TEXT
verification_status: TEXT (pending, approved, rejected)
created_at, updated_at: TIMESTAMPTZ
```

#### 6. `lecture_requests`
```sql
id: UUID (PK)
parent_uid: TEXT (FK -> parents.uid)
student_id: UUID (FK -> students.student_id)
subject: TEXT
preferred_days: TEXT[]
preferred_time_slots: JSONB[]
notes: TEXT
status: TEXT (pending, accepted, declined)
created_at, updated_at: TIMESTAMPTZ
```

#### 7. `teacher_student_assignments`
```sql
id: UUID (PK)
teacher_uid: TEXT (FK -> teachers.uid)
student_id: UUID (FK -> students.student_id)
parent_uid: TEXT (FK -> parents.uid)
subject: TEXT
status: TEXT (active, inactive)
created_from_request_id: UUID (FK -> lecture_requests.id)
created_at: TIMESTAMPTZ
```

#### 8. `recurring_lecture_templates`
```sql
id: UUID (PK)
assignment_id: UUID (FK -> teacher_student_assignments.id)
teacher_uid: TEXT (FK -> teachers.uid)
student_id: UUID (FK -> students.student_id)
subject: TEXT
recurrence_pattern: TEXT (daily, weekly)
recurrence_days: TEXT[]
start_date: DATE
end_date: DATE
scheduled_time: JSONB {day, start, end}
notes: TEXT
meeting_link: TEXT
is_active: BOOLEAN
series_id: TEXT (unique identifier for grouping)
created_at, updated_at: TIMESTAMPTZ
```

#### 9. `lectures`
```sql
id: UUID (PK)
assignment_id: UUID (FK -> teacher_student_assignments.id)
teacher_uid: TEXT (FK -> teachers.uid)
student_id: UUID (FK -> students.student_id)
subject: TEXT
scheduled_date: DATE
scheduled_time: JSONB {day, start, end}

-- Recurring info
is_recurring: BOOLEAN
series_id: TEXT (groups recurring lectures)
template_id: UUID (FK -> recurring_lecture_templates.id)
recurrence_pattern: TEXT (one-time, daily, weekly)
recurrence_days: TEXT[]
recurrence_end_date: DATE

-- Status
status: TEXT (scheduled, in_progress, completed, cancelled, rescheduled)

-- Rescheduling
original_date: DATE
original_time: JSONB
rescheduled_reason: TEXT

-- Additional
notes: TEXT
meeting_link: TEXT
attendance_marked: BOOLEAN
created_at, updated_at: TIMESTAMPTZ
```

#### 10. `teacher_availability`
```sql
teacher_uid: TEXT (PK, FK -> teachers.uid)
available_days: TEXT[]
time_slots: JSONB[]
created_at, updated_at: TIMESTAMPTZ
```

### Foreign Key Relationships
```
users (uid)
  ├─→ parents (uid)
  ├─→ teachers (uid)
  └─→ language_learners (uid)

parents (uid)
  └─→ students (parent_uid)

students (student_id)
  ├─→ lecture_requests (student_id)
  └─→ teacher_student_assignments (student_id)

teachers (uid)
  ├─→ teacher_student_assignments (teacher_uid)
  └─→ teacher_availability (teacher_uid)

teacher_student_assignments (id)
  ├─→ lectures (assignment_id)
  └─→ recurring_lecture_templates (assignment_id)

recurring_lecture_templates (id)
  └─→ lectures (template_id)

lecture_requests (id)
  └─→ teacher_student_assignments (created_from_request_id)
```

### Indexes
```sql
-- Performance optimization
CREATE INDEX idx_students_parent ON students(parent_uid);
CREATE INDEX idx_lectures_teacher ON lectures(teacher_uid);
CREATE INDEX idx_lectures_student ON lectures(student_id);
CREATE INDEX idx_lectures_date ON lectures(scheduled_date);
CREATE INDEX idx_lectures_series ON lectures(series_id) WHERE is_recurring = true;
CREATE INDEX idx_templates_active ON recurring_lecture_templates(is_active) WHERE is_active = true;
CREATE INDEX idx_templates_dates ON recurring_lecture_templates(start_date, end_date);
```

---

## 🗺 Features Roadmap

### Phase 1: Core Functionality (Current - 80% Complete)
- [x] Authentication system
- [x] User profile management (Parent, Teacher, Language Learner)
- [x] Student management (Parent side)
- [x] Lecture request system
- [x] One-time lecture creation
- [x] Recurring lecture templates
- [x] Lecture viewing and grouping
- [ ] Lecture rescheduling (In Progress)
- [ ] Lecture cancellation (In Progress)

### Phase 2: Enhanced Lecture Management (Next)
- [ ] **Attendance System**
  - Mark attendance
  - Attendance history
  - Attendance reports
  - Automated reminders

- [ ] **Lecture Status Updates**
  - In-progress status
  - Completed status
  - Late markers
  - No-show tracking

- [ ] **Notifications**
  - Push notifications
  - Email notifications
  - Lecture reminders (30 min before)
  - Status change alerts
  - Request acceptance/decline alerts

- [ ] **Calendar Integration**
  - Full calendar view
  - Month/week/day views
  - Sync with Google Calendar
  - Export to iCal

### Phase 3: Advanced Features
- [ ] **Payment Integration**
  - Lecture fees management
  - Payment history
  - Invoice generation
  - Multi-currency support
  - Razorpay/Stripe integration

- [ ] **Video Conferencing**
  - Integrated video calls (Agora/Jitsi)
  - Screen sharing
  - Recording capabilities
  - Chat during sessions

- [ ] **Reports & Analytics**
  - Parent dashboard:
    - Student performance
    - Attendance statistics
    - Subject-wise progress
  - Teacher dashboard:
    - Earnings summary
    - Lecture statistics
    - Student engagement metrics

- [ ] **Homework & Assignments**
  - Create assignments
  - Submit assignments (file upload)
  - Grade assignments
  - Feedback system
  - Due date reminders

### Phase 4: Communication & Collaboration
- [ ] **Messaging System**
  - Parent-Teacher chat
  - Group discussions
  - File sharing
  - Voice messages

- [ ] **Progress Tracking**
  - Student performance graphs
  - Subject-wise progress
  - Test scores
  - Goal setting and tracking

- [ ] **Document Management**
  - Study materials upload
  - Resource library
  - Shared documents
  - Version control

### Phase 5: Admin Panel
- [ ] **Teacher Verification**
  - Document verification
  - Background checks
  - Approval workflow

- [ ] **Platform Management**
  - User management
  - Dispute resolution
  - Content moderation
  - System configuration

- [ ] **Analytics Dashboard**
  - Platform statistics
  - User engagement metrics
  - Revenue reports
  - Growth tracking

### Phase 6: Language Learning Features
- [ ] **Course Management**
  - Create courses
  - Module structure
  - Lesson content
  - Quizzes and assessments

- [ ] **Progress Tracking**
  - Proficiency levels
  - XP and achievements
  - Leaderboards
  - Certificates

- [ ] **Interactive Learning**
  - Flashcards
  - Interactive exercises
  - Pronunciation practice
  - Conversation practice

### Phase 7: Mobile App Enhancements
- [ ] **Offline Mode**
  - Cache lecture data
  - Offline note-taking
  - Sync when online

- [ ] **Biometric Authentication**
  - Fingerprint login
  - Face recognition

- [ ] **Dark Mode**
  - Complete dark theme
  - Auto-switch based on time

### Phase 8: Web Platform
- [ ] **Responsive Web App**
  - Desktop layouts
  - Tablet optimization
  - Browser compatibility

- [ ] **Admin Web Dashboard**
  - User management
  - Analytics and reports
  - System configuration

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (3.3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Supabase account
- Firebase account (for push notifications)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/SauravHaldar04/Dhairya.git
   cd Dhairya
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Copy your Supabase URL and anon key
   - Create a file `lib/core/secrets/supabase_secrets.dart`:
     ```dart
     class SupabaseSecrets {
       static const String supabaseUrl = 'YOUR_SUPABASE_URL';
       static const String supabaseAnonKey = 'YOUR_ANON_KEY';
     }
     ```

4. **Run database migrations**
   - Execute SQL migrations in Supabase SQL Editor:
     ```bash
     docs/private/migrations/001_add_recurring_lecture_templates.sql
     docs/private/migrations/002_migrate_existing_recurring_lectures.sql
     ```

5. **Configure Firebase (Optional - for push notifications)**
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)
   - Place in respective directories

6. **Run the app**
   ```bash
   flutter run
   ```

### Database Setup

1. **Create tables** (in Supabase SQL Editor):
   ```sql
   -- Run migration scripts in order
   -- See docs/private/migrations/ folder
   ```

2. **Set up Row Level Security (RLS)**:
   ```sql
   -- Enable RLS on all tables
   ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
   ALTER TABLE students ENABLE ROW LEVEL SECURITY;
   ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
   ALTER TABLE lectures ENABLE ROW LEVEL SECURITY;
   ALTER TABLE recurring_lecture_templates ENABLE ROW LEVEL SECURITY;
   
   -- Create policies (see migration files for details)
   ```

3. **Set up Storage buckets**:
   - Create bucket: `profile-pictures`
   - Create bucket: `documents`
   - Set appropriate access policies

### Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📝 Known Issues & Limitations

### Current Limitations
1. **No real-time updates** - UI requires manual refresh
2. **Limited error handling** - Some edge cases not covered
3. **No offline mode** - Requires internet connection
4. **Teacher verification** - Manual process (no admin panel yet)
5. **No payment integration** - Free platform currently
6. **Single language** - English only
7. **No video conferencing** - External links only

### Bugs to Fix
- [ ] Profile picture upload occasionally fails
- [ ] Lecture grouping doesn't handle timezone edge cases
- [ ] Back button behavior inconsistent in some flows
- [ ] Loading states missing in some screens

---

## 🤝 Contributing

### Development Workflow
1. Create feature branch: `git checkout -b feature/your-feature`
2. Follow Clean Architecture principles
3. Write tests for new features
4. Update documentation
5. Submit pull request

### Code Style
- Follow Dart style guide
- Use `flutter analyze` before committing
- Format code: `dart format .`
- Use meaningful variable names
- Add comments for complex logic

---

## 📞 Support & Contact

- **Developer:** Saurav Haldar
- **Email:** sauravhaldar04@gmail.com
- **GitHub:** [@SauravHaldar04](https://github.com/SauravHaldar04)

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Material Design team for design guidelines
- Open-source community for various packages

---

**Last Updated:** March 6, 2026  
**Version:** 1.0.0  
**Status:** Active Development
