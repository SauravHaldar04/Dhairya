# Lecture System Implementation Guide

## Overview
This document provides the complete implementation guide for the lecture request and assignment system. The system follows a three-tier flow:
1. **Parents** request lectures for their students
2. **Admin** (separate dashboard) reviews requests and assigns teachers to students
3. **Teachers** create and manage lectures for their assigned students

---

## ✅ Completed Implementation

### Backend & Data Layer
- ✅ SQL Migration (`add_lecture_system.sql`) - 5 tables with RLS policies
- ✅ Domain Entities (LectureRequest, Lecture, TeacherStudentAssignment, TeacherAvailability)
- ✅ Data Models with serialization
- ✅ Repository interface with 15+ methods
- ✅ Supabase datasource implementation
- ✅ Repository implementation with error handling
- ✅ BLoC with 17 events and 15 states

### UI Widgets (Completed)
- ✅ `TimeSlotPicker` - Time range selection widget
- ✅ `LectureCard` - Display lecture details with actions
- ✅ `AssignmentCard` - Display teacher-student assignments
- ✅ `DaySelector` - Multi-select day picker for weekly schedules

### Teacher Pages (Partial)
- ✅ `TeacherLecturesHomePage` - Dashboard with quick actions and upcoming lectures

---

## 📋 Remaining UI Pages to Implement

### 1. Teacher Pages

#### `teacher_availability_page.dart`
**Purpose**: Set up teacher's availability schedule
**Features**:
- Display current availability or empty state
- Add/edit available days
- Add multiple time slots per day
- List subjects they can teach
- Save/Update availability

**Key Components**:
```dart
- DaySelector for selecting available days
- TimeSlotPicker for each time slot
- Chips for adding/removing subjects
- Save button with BLoC integration
```

**BLoC Events**: 
- `GetTeacherAvailabilityEvent`
- `UpdateTeacherAvailabilityEvent`

**States**: 
- `TeacherAvailabilityLoaded`
- `TeacherAvailabilityUpdated`

---

#### `teacher_create_lecture_page.dart`
**Purpose**: Create one-time or recurring lectures
**Features**:
- Select from assigned students (dropdown)
- Choose subject from assignment subjects
- Toggle: One-time vs Recurring
- **One-time**: Date picker + Time slot picker
- **Recurring**: 
  - Start date & End date pickers
  - Recurrence pattern (daily/weekly dropdown)
  - Day selector (for weekly)
  - Time slot picker
- Optional: Notes, Meeting link
- Create button with validation

**BLoC Events**:
- `GetTeacherAssignmentsEvent` (to load students)
- `CreateOneTimeLectureEvent`
- `CreateRecurringLecturesEvent`

**States**:
- `TeacherAssignmentsLoaded`
- `LectureCreated`
- `RecurringLecturesCreated`

**Validation**:
- Ensure assignment selected
- Ensure dates/times selected
- For recurring weekly, ensure at least one day selected
- End date must be after start date

---

#### `teacher_lectures_list_page.dart`
**Purpose**: View all lectures with filters
**Features**:
- Filter tabs: All / Scheduled / Completed / Cancelled
- Date range filter (This Week / This Month / Custom)
- List of lectures with LectureCard
- Pull to refresh
- Search by subject

**BLoC Events**:
- `GetLecturesEvent` with filters

**States**:
- `LecturesLoaded`

---

#### `teacher_lecture_details_page.dart`
**Purpose**: View and manage single lecture
**Features**:
- Full lecture details
- Reschedule button (opens reschedule dialog)
- Cancel button (opens cancel dialog)
- Mark attendance button (for completed status)
- Update status dropdown (scheduled/in_progress/completed)
- View if part of recurring series (link to series)

**BLoC Events**:
- `RescheduleLectureEvent`
- `CancelLectureEvent`
- `UpdateLectureStatusEvent`
- `MarkAttendanceEvent`

---

### 2. Parent Pages

#### `parent_lectures_home_page.dart`
**Purpose**: Parent dashboard for lecture management
**Features**:
- Quick action cards:
  - Request New Lecture
  - View My Requests
  - View Student Assignments
  - Upcoming Lectures
- Summary stats (pending requests, active assignments, upcoming lectures)
- List of next 3 upcoming lectures

**BLoC Events**:
- `GetLectureRequestsEvent`
- `GetStudentAssignmentsEvent`
- `GetUpcomingLecturesEvent`

---

#### `parent_request_lecture_page.dart`
**Purpose**: Create new lecture request
**Features**:
- Student selector (dropdown from parent's students)
- Multi-select subjects
- Preferred time slots (add multiple with TimeSlotPicker + DaySelector)
- Requested start date
- Frequency dropdown (daily/weekly/biweekly/monthly)
- Priority level (1-5 slider)
- Additional notes textarea
- Submit button

**BLoC Events**:
- `CreateLectureRequestEvent`

**States**:
- `LectureRequestCreated`

**Navigation**: After success, show success message and navigate back

---

#### `parent_lecture_requests_page.dart`
**Purpose**: View all lecture requests with status
**Features**:
- Filter tabs: All / Pending / Approved / Rejected / Assigned
- List of requests with status badges
- For pending: Cancel button
- For rejected: Show rejection reason
- For assigned: Show assigned teacher (from assignment)
- Pull to refresh

**BLoC Events**:
- `GetLectureRequestsEvent` with status filter
- `CancelLectureRequestEvent`

**States**:
- `LectureRequestsLoaded`
- `LectureRequestCancelled`

---

#### `parent_student_assignments_page.dart`
**Purpose**: View teacher assignments for each student
**Features**:
- List of assignments grouped by student
- Each assignment shows:
  - Teacher name (would need to fetch from teachers table)
  - Subjects being taught
  - Assignment status
  - Start/end dates
- Tap to view lectures for that assignment

**BLoC Events**:
- `GetStudentAssignmentsEvent`

**States**:
- `StudentAssignmentsLoaded`

---

#### `parent_upcoming_lectures_page.dart`
**Purpose**: View upcoming lectures for all students
**Features**:
- Calendar view or list view toggle
- Filter by student
- Filter by date range
- LectureCard for each lecture (read-only, no actions)
- Group by date

**BLoC Events**:
- `GetUpcomingLecturesEvent` with studentUid filter

**States**:
- `UpcomingLecturesLoaded`

---

## 🔧 Integration Steps

### 1. Add Lectures BLoC to Provider
**File**: `lib/init_dependencies.dart` or `lib/main.dart`

```dart
BlocProvider<LecturesBloc>(
  create: (context) => serviceLocator<LecturesBloc>(),
),
```

### 2. Register Dependencies
**File**: `lib/init_dependencies.dart`

```dart
// Data Sources
serviceLocator.registerFactory<LecturesRemoteDataSource>(
  () => LecturesRemoteDataSourceImpl(serviceLocator()),
);

// Repositories
serviceLocator.registerFactory<LecturesRepository>(
  () => LecturesRepositoryImpl(
    serviceLocator(),
    serviceLocator(),
  ),
);

// BLoC
serviceLocator.registerLazySingleton(
  () => LecturesBloc(serviceLocator()),
);
```

### 3. Update Teacher Layout
**File**: `lib/features/teacher/presentation/pages/teacher_layout_page.dart`

Add lectures page to bottom navigation:
```dart
pages: [
  TeacherHomePage(),
  TeacherStudentsPage(),
  TeacherLecturesHomePage(teacherUid: currentUser.uid),  // NEW
  TeacherClassesPage(),
  TeacherProfilePage(),
],
```

Update BottomNavigationBar items:
```dart
BottomNavigationBarItem(
  icon: Icon(Icons.school_outlined),
  label: 'Lectures',
),
```

### 4. Update Parent Layout
**File**: `lib/features/parent/presentation/pages/parent_layout_page.dart`

Add lectures to drawer:
```dart
ListTile(
  leading: Icon(Icons.school_outlined, color: Pallete.primaryColor),
  title: Text('Lectures'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentLecturesHomePage(
          parentUid: currentUser.uid,
        ),
      ),
    );
  },
),
```

---

## 📊 Database Setup

### Run SQL Migration
1. Open Supabase Dashboard
2. Go to SQL Editor
3. Copy entire `add_lecture_system.sql` content
4. Execute query
5. Verify tables created:
   - `teacher_availability`
   - `lecture_requests`
   - `teacher_student_assignments`
   - `lectures`
   - `lecture_history`

### Test RLS Policies
- Login as teacher → Should see only own availability, assignments, lectures
- Login as parent → Should see only own requests, student assignments, student lectures

---

## 🎨 UI/UX Guidelines

### Color Scheme
- **Primary**: Teal (#64C3BF) - Main actions, headers
- **Secondary**: Blue (#0338B4) - Accents, chips
- **Success**: Green - Completed, active status
- **Warning**: Orange - Rescheduled, paused status
- **Error**: Red - Cancelled, rejected status

### Typography
- **Headers**: Poppins Bold, 20-24px
- **Body**: Poppins Regular/Medium, 14-16px
- **Captions**: Poppins Regular, 12-13px

### Spacing
- Card padding: 16px
- Section spacing: 20px
- Between elements: 8-12px

### Animations
- Use `FadeInSlide` for list items
- Use `ScaleInAnimation` for dialogs
- Use `StaggeredAnimation` for multiple items

---

## 🧪 Testing Checklist

### Teacher Flow
- [ ] Set up availability
- [ ] View assigned students
- [ ] Create one-time lecture
- [ ] Create recurring lecture (daily)
- [ ] Create recurring lecture (weekly)
- [ ] View all lectures
- [ ] Filter lectures by status
- [ ] Reschedule a lecture
- [ ] Cancel a lecture
- [ ] Mark attendance
- [ ] Update lecture status

### Parent Flow
- [ ] Request new lecture
- [ ] View pending requests
- [ ] Cancel pending request
- [ ] View approved/rejected requests
- [ ] View student assignments
- [ ] View upcoming lectures for students

---

## 📱 Sample Screenshots Structure

### Teacher
1. **Lectures Home** - Quick actions + upcoming lectures
2. **Availability** - Day selector + time slots + subjects
3. **Create Lecture** - Form with student selector, dates, times
4. **Lectures List** - Filtered list of lectures
5. **Lecture Details** - Full details with actions

### Parent
1. **Lectures Home** - Stats + quick actions
2. **Request Lecture** - Form with student, subjects, preferences
3. **My Requests** - List with status badges
4. **Assignments** - Teacher-student assignments
5. **Upcoming Lectures** - Calendar/list view

---

## 🚀 Next Steps

1. **Implement remaining pages** (teacher availability, create lecture, parent pages)
2. **Add dependency injection** for BLoC
3. **Update layouts** to include lecture pages
4. **Test complete flow** with real data
5. **Add error handling** and loading states
6. **Implement search/filter** functionality
7. **Add notifications** for lecture reminders
8. **Implement deep linking** for lecture details

---

## 📝 Code Quality Standards

- Use `const` constructors where possible
- Handle null safety properly
- Show loading states during async operations
- Show meaningful error messages
- Validate all form inputs
- Use pull-to-refresh for data lists
- Implement empty states with helpful messages
- Add confirmation dialogs for destructive actions

---

## 🔗 Related Files

### Core
- `lib/core/theme/app_pallete.dart` - Colors
- `lib/core/theme/app_theme.dart` - Theme config
- `lib/core/common/widgets/custom_loader.dart` - Loading indicator
- `lib/core/common/animations/` - Animation widgets

### Features
- `lib/features/lectures/domain/` - Entities
- `lib/features/lectures/data/` - Models, datasources, repositories
- `lib/features/lectures/presentation/` - Pages, widgets, BLoC

---

## 💡 Pro Tips

1. **Reuse existing widgets**: StudentCard pattern can be adapted for lecture cards
2. **Follow existing patterns**: Check ParentStudentsPage for form patterns
3. **Error handling**: Use BlocConsumer for showing snackbars
4. **Date formatting**: Use `intl` package's `DateFormat`
5. **Time conversion**: Store in 24-hour format, display in 12-hour
6. **Validation**: Use GlobalKey<FormState> for forms
7. **Navigation**: Use Navigator.push with .then() for callbacks
8. **State management**: Reload data after create/update operations

---

## 🐛 Common Issues & Solutions

### Issue: BLoC not found
**Solution**: Ensure BLoC is provided in widget tree via BlocProvider

### Issue: Time slots not saving
**Solution**: Check TimeSlot.toMap() returns correct format

### Issue: RLS denying access
**Solution**: Verify auth.uid() matches teacher_uid/parent_uid in policies

### Issue: Recurring lectures not generating
**Solution**: Check date calculation logic in _generateRecurringDates()

### Issue: Student assignments not showing
**Solution**: Ensure admin has created assignments in admin dashboard

---

This implementation guide should be referenced alongside the Admin Dashboard Integration Guide (next document) for complete system implementation.
