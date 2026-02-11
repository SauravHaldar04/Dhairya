# Lecture System - Integration Checklist

## ✅ Completed Work

### Backend Implementation (100%)
- ✅ SQL migration with 5 tables (teacher_availability, lecture_requests, teacher_student_assignments, lectures, lecture_history)
- ✅ RLS policies for all tables
- ✅ Database triggers for audit logging
- ✅ 5 Domain entities
- ✅ 4 Data models with serialization
- ✅ Repository interface (15+ methods)
- ✅ Remote datasource implementation (670+ lines)
- ✅ Repository implementation with error handling
- ✅ BLoC with 17 events and 15 states

### UI Implementation (100%)
- ✅ 4 Shared widgets (TimeSlotPicker, LectureCard, AssignmentCard, DaySelector)
- ✅ 5 Teacher pages (home, availability, create, list, details)
- ✅ 5 Parent pages (home, request, requests list, assignments, upcoming lectures)

### Documentation (100%)
- ✅ LECTURE_SYSTEM_IMPLEMENTATION.md - Implementation guide
- ✅ ADMIN_DASHBOARD_INTEGRATION.md - Admin dashboard specifications

---

## 🔧 Integration Steps Required

### Step 1: Database Setup

Run the SQL migration in Supabase:

```bash
# Navigate to Supabase dashboard
# SQL Editor > New Query
# Copy contents of add_lecture_system.sql
# Execute the query
```

**Verification**:
```sql
-- Check tables created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('teacher_availability', 'lecture_requests', 'teacher_student_assignments', 'lectures', 'lecture_history');

-- Check RLS enabled
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('teacher_availability', 'lecture_requests', 'teacher_student_assignments', 'lectures', 'lecture_history');
```

---

### Step 2: Dependency Injection Setup

**File**: `lib/init_dependencies.dart`

Add the following registrations:

```dart
// Lectures - Remote Datasource
serviceLocator.registerFactory<LecturesRemoteDataSource>(
  () => LecturesRemoteDataSourceImpl(
    supabaseClient: serviceLocator(),
  ),
);

// Lectures - Repository
serviceLocator.registerFactory<LecturesRepository>(
  () => LecturesRepositoryImpl(
    lecturesRemoteDataSource: serviceLocator(),
    connectionChecker: serviceLocator(),
  ),
);

// Lectures - BLoC (Teacher)
serviceLocator.registerLazySingleton(
  () => LecturesBloc(
    lecturesRepository: serviceLocator(),
  ),
);

// Note: If parent lectures use separate BLoC, register that too
// Or use the same BLoC for both teacher and parent features
```

---

### Step 3: BLoC Provider Setup

**File**: `lib/main.dart`

Add LecturesBloc to MultiBlocProvider:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => serviceLocator<AppUserCubit>(),
    ),
    // ... other providers
    BlocProvider(
      create: (_) => serviceLocator<LecturesBloc>(),
    ),
  ],
  child: MaterialApp(...),
)
```

---

### Step 4: Teacher Layout Integration

**File**: `lib/features/teachers/presentation/pages/teacher_layout_page.dart`

**Current structure** (assumed):
```dart
class TeacherLayoutPage extends StatefulWidget {
  final List<Widget> _pages = [
    TeacherHomePage(),
    TeacherStudentsPage(),
    // ... other pages
  ];
}
```

**Add lectures page**:

```dart
import 'package:dhairya_app/features/teachers/lectures/presentation/pages/teacher_lectures_home_page.dart';

class TeacherLayoutPage extends StatefulWidget {
  final List<Widget> _pages = [
    TeacherHomePage(),
    TeacherStudentsPage(),
    TeacherLecturesHomePage(), // ADD THIS
    // ... other pages
  ];
}
```

**Update BottomNavigationBar**:

```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Lectures'), // ADD THIS
    // ... other items
  ],
)
```

---

### Step 5: Parent Layout Integration

**File**: `lib/features/parents/presentation/pages/parent_layout_page.dart`

**Current structure** (assumed - Drawer navigation):
```dart
Drawer(
  child: ListView(
    children: [
      // ... drawer items
    ],
  ),
)
```

**Add lectures menu item**:

```dart
import 'package:dhairya_app/features/parents/lectures/presentation/pages/parent_lectures_home_page.dart';

ListTile(
  leading: const Icon(Icons.school),
  title: const Text('Lectures & Tutoring'),
  onTap: () {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(ParentLecturesHomePage.route());
  },
),
```

---

### Step 6: Add Missing Dependencies

**File**: `pubspec.yaml`

Ensure these dependencies exist:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies (verify these are present)
  flutter_bloc: ^8.1.3
  fpdart: ^1.1.0
  supabase_flutter: ^2.0.0
  intl: ^0.18.1
  
  # Add if missing
  url_launcher: ^6.2.2  # For opening meeting links
```

Run:
```bash
flutter pub get
```

---

### Step 7: Fix Import Paths

**Note**: The parent pages were created under `lib/features/parents/lectures/` structure.

You may need to adjust based on your actual parent feature structure:

**Option A**: Keep separate structure (recommended)
```
lib/features/
  ├── teachers/
  │   └── lectures/  (teacher lecture pages)
  └── parents/
      └── lectures/  (parent lecture pages)
```

**Option B**: Shared structure
```
lib/features/
  └── lectures/
      ├── teacher/  (teacher pages)
      └── parent/   (parent pages)
```

If using **Option B**, move files and update imports:
```bash
# PowerShell commands to reorganize
New-Item -ItemType Directory -Force -Path "lib/features/lectures/teacher"
New-Item -ItemType Directory -Force -Path "lib/features/lectures/parent"

# Move teacher pages
Move-Item "lib/features/teachers/lectures/*" "lib/features/lectures/teacher/"

# Move parent pages
Move-Item "lib/features/parents/lectures/*" "lib/features/lectures/parent/"
```

---

### Step 8: Copy Shared Widgets

The following widgets are needed by **both** teacher and parent features:

**Files to duplicate/share**:
1. `time_slot_picker.dart`
2. `lecture_card.dart`
3. `assignment_card.dart`
4. `day_selector.dart`

**Option A**: Create shared widgets folder
```
lib/features/lectures/presentation/widgets/
  ├── time_slot_picker.dart
  ├── lecture_card.dart
  ├── assignment_card.dart
  └── day_selector.dart
```

**Option B**: Keep in teacher folder, import in parent pages
- Update parent page imports to reference teacher widgets folder

---

### Step 9: Handle Student Loading

**Current Issue**: Parent pages use mock student data.

**Fix**: Load actual students from parent's profile

**File**: `parent_request_lecture_page.dart`

Replace mock data:
```dart
// CURRENT (Mock)
final List<Map<String, String>> _students = [
  {'id': '1', 'name': 'Student 1', 'standard': '10th'},
];

// REPLACE WITH (Real data)
@override
void initState() {
  super.initState();
  _loadStudents();
}

void _loadStudents() {
  final parentUid = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.uid;
  // Load students from parent profile
  // Assuming you have a students table linked to parent
  context.read<StudentsBloc>().add(GetParentStudentsEvent(parentUid));
}
```

---

### Step 10: Testing Checklist

#### Database Tests
- [ ] Tables created successfully
- [ ] RLS policies working (teachers can only see their data)
- [ ] Foreign key constraints working
- [ ] Triggers logging to lecture_history

#### Teacher Flow Tests
- [ ] Set availability (subjects, days, time slots)
- [ ] View assignments from admin
- [ ] Create one-time lecture
- [ ] Create recurring lectures (daily/weekly)
- [ ] View all lectures with filters
- [ ] Reschedule lecture
- [ ] Cancel lecture
- [ ] Mark attendance
- [ ] View lecture series

#### Parent Flow Tests
- [ ] View lectures dashboard
- [ ] Create lecture request (all fields)
- [ ] View all requests with status filters
- [ ] Cancel pending request
- [ ] View teacher assignments
- [ ] View upcoming lectures (list view)
- [ ] View upcoming lectures (calendar view)
- [ ] Filter by student/subject

#### Admin Flow (Separate App)
- [ ] View pending requests
- [ ] Approve request
- [ ] Reject request with reason
- [ ] Search teachers by subject
- [ ] Assign teacher to student
- [ ] View all assignments
- [ ] Pause/end assignment

---

## 🐛 Known Issues to Address

### 1. Student Names Not Showing
**Problem**: Pages show student IDs instead of names.

**Solution**: Join with students table or add student data to entities.

**Fix in datasource**:
```dart
// Example: getLectures method
final response = await _supabaseClient
  .from('lectures')
  .select('''
    *,
    assignment:teacher_student_assignments (
      student:students (
        first_name,
        last_name,
        standard
      )
    )
  ''')
  .eq('teacher_uid', teacherUid);
```

### 2. Teacher Names Not Showing
**Problem**: Assignment cards show teacher UIDs.

**Solution**: Join with teachers table.

**Fix**:
```dart
final response = await _supabaseClient
  .from('teacher_student_assignments')
  .select('''
    *,
    teacher:teachers (
      first_name,
      last_name,
      email,
      phone_number
    )
  ''')
  .eq('student_id', studentId);
```

### 3. Parent Loading Assignments
**Problem**: Parent pages need to load assignments for ALL their students.

**Solution**: Create new method in datasource.

**Add to datasource**:
```dart
Future<List<TeacherStudentAssignmentModel>> getParentStudentsAssignments(
  List<String> studentIds,
) async {
  final response = await _supabaseClient
    .from('teacher_student_assignments')
    .select()
    .in_('student_id', studentIds);
  
  // ... error handling and mapping
}
```

### 4. URL Launcher Missing
**Problem**: Meeting links won't open.

**Fix**: Add `url_launcher` dependency (see Step 6).

---

## 📱 Next Steps After Integration

### Phase 1: Core Integration (Priority)
1. ✅ Run database migration
2. ✅ Setup dependency injection
3. ✅ Add BLoC provider
4. ✅ Integrate teacher pages
5. ✅ Integrate parent pages
6. ✅ Test basic flows

### Phase 2: Data Enhancements
1. Load real student names
2. Load real teacher names
3. Parent multi-student support
4. Add user avatars to cards
5. Add notification system

### Phase 3: Admin Dashboard
1. Setup separate admin app/web
2. Implement request management
3. Implement teacher search
4. Implement assignment creation
5. Add analytics/reports

### Phase 4: Polish & Features
1. Add push notifications
2. Add meeting reminders
3. Add attendance reports
4. Add payment integration
5. Add chat between teacher-parent
6. Export lecture history (PDF)

---

## 🎯 Quick Start Commands

```bash
# 1. Get dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. Test on specific device
flutter run -d chrome  # Web
flutter run -d windows # Windows
flutter run -d <device-id> # Mobile

# 4. Check for errors
flutter analyze

# 5. Format code
dart format lib/

# 6. Generate code (if using freezed/json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📚 File Structure Overview

```
lib/features/
├── teachers/lectures/
│   ├── data/
│   │   ├── datasources/lectures_remote_datasource.dart
│   │   ├── models/
│   │   └── repositories/lectures_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   └── repositories/lectures_repository.dart
│   └── presentation/
│       ├── bloc/lectures_bloc.dart
│       ├── pages/
│       │   ├── teacher_lectures_home_page.dart
│       │   ├── teacher_availability_page.dart
│       │   ├── teacher_create_lecture_page.dart
│       │   ├── teacher_lectures_list_page.dart
│       │   └── teacher_lecture_details_page.dart
│       └── widgets/
│           ├── time_slot_picker.dart
│           ├── lecture_card.dart
│           ├── assignment_card.dart
│           └── day_selector.dart
│
└── parents/lectures/
    └── presentation/
        └── pages/
            ├── parent_lectures_home_page.dart
            ├── parent_request_lecture_page.dart
            ├── parent_lecture_requests_page.dart
            ├── parent_student_assignments_page.dart
            └── parent_upcoming_lectures_page.dart
```

---

## 💡 Tips for Success

1. **Test incrementally**: Integrate one feature at a time
2. **Check logs**: Use `print()` or `debugPrint()` for debugging
3. **Verify data**: Check Supabase dashboard to ensure data is being created
4. **Use DevTools**: Flutter DevTools for BLoC inspection
5. **Handle errors**: Add proper error messages for user feedback

---

## 🆘 Troubleshooting

### Issue: "Table does not exist"
**Solution**: Run SQL migration in Supabase dashboard

### Issue: "RLS policy violation"
**Solution**: Check if user UID matches policy conditions. Verify auth tokens.

### Issue: "BLoC not found"
**Solution**: Ensure BLoC is provided in `main.dart` MultiBlocProvider

### Issue: "Import errors"
**Solution**: Run `flutter pub get` and check import paths

### Issue: "Type mismatch in SQL"
**Solution**: Verify series_id is TEXT type, not UUID

---

## ✨ You're Ready to Integrate!

Follow the steps above in order, and you'll have a fully functional lecture management system. Good luck! 🚀
