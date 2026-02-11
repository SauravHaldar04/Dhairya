# Admin Dashboard Integration Guide
## Lecture Request & Assignment System

---

## 🎯 Overview

This document specifies the admin dashboard requirements for managing the lecture request and assignment system. The admin dashboard is a **separate application** that connects to the same Supabase backend.

### Admin Responsibilities
1. Review lecture requests from parents
2. Approve or reject requests
3. Assign teachers to students based on requests
4. Monitor system health and assignments
5. Manage teacher-student relationships

---

## 📊 Database Schema Reference

### Tables Managed by Admin

#### 1. `lecture_requests`
Parents create requests → Admin reviews

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| parent_uid | TEXT | Parent who made request |
| student_id | UUID | Student needing tutoring |
| subjects | TEXT[] | Subjects requested |
| preferred_time_slots | JSONB | Array of time slot objects |
| status | TEXT | pending/approved/rejected/assigned |
| priority_level | INTEGER | 1-5 priority |
| additional_notes | TEXT | Parent's notes |
| requested_start_date | DATE | When to start |
| frequency | TEXT | daily/weekly/biweekly/monthly |
| rejection_reason | TEXT | If rejected, why |
| created_at | TIMESTAMPTZ | Request timestamp |
| updated_at | TIMESTAMPTZ | Last modified |

**Status Flow**:
- `pending` → Initial state when parent creates
- `approved` → Admin approves (ready for teacher assignment)
- `rejected` → Admin rejects with reason
- `assigned` → Admin has assigned teacher to student

#### 2. `teacher_student_assignments`
**Admin creates these** to link teachers with students

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| lecture_request_id | UUID | FK to lecture_requests |
| teacher_uid | TEXT | FK to teachers |
| student_id | UUID | FK to students |
| subjects | TEXT[] | Subjects teacher will teach |
| assigned_by | TEXT | Admin UID who assigned |
| assignment_status | TEXT | active/paused/completed/cancelled |
| start_date | DATE | Assignment start |
| end_date | DATE | Assignment end (nullable) |
| notes | TEXT | Admin notes |
| created_at | TIMESTAMPTZ | Assignment timestamp |
| updated_at | TIMESTAMPTZ | Last modified |

**Important**: Once assignment is created, teacher can create lectures for that student.

#### 3. `teacher_availability` (Read-Only for Admin)
Teachers manage their own availability

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| teacher_uid | TEXT | Teacher reference |
| available_days | TEXT[] | Days available |
| time_slots | JSONB | Available time slots |
| subjects_offered | TEXT[] | Subjects they teach |
| is_active | BOOLEAN | Currently available |

**Admin Use**: Query to find suitable teachers for requests

---

## 🖥️ Admin Dashboard Pages

### 1. Dashboard / Overview Page

**Route**: `/admin/dashboard`

**Purpose**: High-level system metrics

**Widgets**:
- **Stats Cards** (4 cards in row):
  - Pending Requests (count with trend)
  - Active Assignments (count)
  - Total Teachers (count)
  - Total Students (count)
  
- **Recent Activity Timeline**:
  - Last 10 lecture requests (with time ago)
  - Last 10 assignments created
  - Recent rejections

- **Quick Actions**:
  - "Review Pending Requests" button → navigates to requests page
  - "Create Assignment" button → opens assignment form
  - "View All Assignments" button → navigates to assignments page

**API Queries**:
```sql
-- Pending requests count
SELECT COUNT(*) FROM lecture_requests WHERE status = 'pending'

-- Active assignments count
SELECT COUNT(*) FROM teacher_student_assignments WHERE assignment_status = 'active'

-- Total teachers
SELECT COUNT(*) FROM teachers WHERE verified = true

-- Total students
SELECT COUNT(*) FROM students

-- Recent requests
SELECT * FROM lecture_requests 
ORDER BY created_at DESC 
LIMIT 10
```

---

### 2. Lecture Requests Management Page

**Route**: `/admin/lecture-requests`

**Purpose**: Review and manage all lecture requests

**Layout**:
```
┌─────────────────────────────────────────────┐
│  Lecture Requests                           │
│  ┌──────┬──────┬──────┬──────────┐         │
│  │ All  │Pending│Approved│Rejected│  (Tabs) │
│  └──────┴──────┴──────┴──────────┘         │
│                                              │
│  🔍 Search: [________] 🗓️ Date: [______]   │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │ Request Card #1                        │ │
│  │ ○ Parent: John Doe                     │ │
│  │ ○ Student: Jane Doe (Grade 10)        │ │
│  │ ○ Subjects: Math, Physics             │ │
│  │ ○ Priority: ⭐⭐⭐⭐                    │ │
│  │ ○ Requested: 15 Feb 2026              │ │
│  │ ○ Status: Pending                     │ │
│  │ [View Details] [Approve] [Reject]     │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │ Request Card #2                        │ │
│  │ ...                                    │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**Features**:

1. **Filter Tabs**:
   - All (default)
   - Pending (action needed)
   - Approved
   - Rejected
   - Assigned

2. **Search & Filter**:
   - Search by parent name, student name, subjects
   - Date range filter
   - Priority filter (1-5)
   - Sort by: Date, Priority, Status

3. **Request Card Display**:
   - Parent name + email
   - Student name + standard + board
   - Subjects list (chips)
   - Preferred time slots (expandable)
   - Frequency
   - Priority level (star rating)
   - Status badge (color-coded)
   - Additional notes (collapsible)
   - Requested start date
   - Created date

4. **Actions per Request**:
   - **View Details**: Opens modal with full request info
   - **Approve**: Changes status to 'approved', enables assignment
   - **Reject**: Opens dialog for rejection reason
   - **Assign Teacher** (if approved): Opens teacher selection modal

**API Endpoints**:
```typescript
// Get requests with filters
GET /rest/v1/lecture_requests?status=eq.pending&order=priority_level.desc,created_at.desc

// Update request status
PATCH /rest/v1/lecture_requests?id=eq.{request_id}
Body: { status: 'approved' }

// Reject request
PATCH /rest/v1/lecture_requests?id=eq.{request_id}
Body: { 
  status: 'rejected', 
  rejection_reason: 'Not enough teachers available for subjects'
}

// Get full request with parent and student details
GET /rest/v1/lecture_requests?id=eq.{request_id}&select=*,parents(*),students(*)
```

---

### 3. Request Details Modal

**Triggered by**: Clicking "View Details" on request card

**Content**:
```
┌────────────────────────────────────────────┐
│ Request Details               [X]           │
├────────────────────────────────────────────┤
│                                             │
│ Request ID: abc-123-def                     │
│ Status: Pending ⏳                          │
│ Created: 15 Feb 2026, 10:30 AM            │
│                                             │
│ ┌─ Parent Information ──────────────────┐  │
│ │ Name: John Doe                        │  │
│ │ Email: john@example.com               │  │
│ │ Phone: +1 234 567 8900                │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Student Information ─────────────────┐  │
│ │ Name: Jane Doe                        │  │
│ │ Standard: 10th Grade                  │  │
│ │ Board: CBSE                           │  │
│ │ Medium: English                       │  │
│ │ Current Subjects: Math, Physics, Chem │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Request Details ─────────────────────┐  │
│ │ Subjects Requested: Math, Physics     │  │
│ │ Priority: ⭐⭐⭐⭐ (4/5)              │  │
│ │ Frequency: Weekly                     │  │
│ │ Start Date: 20 Feb 2026               │  │
│ │                                       │  │
│ │ Preferred Time Slots:                 │  │
│ │ • Monday: 4:00 PM - 6:00 PM          │  │
│ │ • Wednesday: 4:00 PM - 6:00 PM       │  │
│ │ • Friday: 4:00 PM - 6:00 PM          │  │
│ │                                       │  │
│ │ Additional Notes:                     │  │
│ │ "Student needs help preparing for     │  │
│ │  board exams. Weak in trigonometry."  │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Actions ─────────────────────────────┐  │
│ │ [Approve & Assign Teacher]            │  │
│ │ [Approve Only]                        │  │
│ │ [Reject Request]                      │  │
│ │ [Close]                               │  │
│ └───────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

---

### 4. Teacher Selection Modal

**Triggered by**: "Assign Teacher" button or "Approve & Assign"

**Purpose**: Find and assign suitable teacher to student

**Layout**:
```
┌────────────────────────────────────────────┐
│ Select Teacher for Jane Doe     [X]         │
├────────────────────────────────────────────┤
│                                             │
│ Required Subjects: Math, Physics            │
│                                             │
│ 🔍 Search: [________]  Filter: [_____]     │
│                                             │
│ ┌─────────────────────────────────────────┐│
│ │ ✓ Mr. Rajesh Kumar                      ││
│ │   📧 rajesh@example.com                 ││
│ │   📚 Subjects: Math, Physics, Chemistry ││
│ │   ⏰ Available: Mon, Wed, Fri 4-8 PM   ││
│ │   👥 Active Students: 5                 ││
│ │   [Select]                              ││
│ └─────────────────────────────────────────┘│
│                                             │
│ ┌─────────────────────────────────────────┐│
│ │ ✓ Ms. Priya Sharma                      ││
│ │   📧 priya@example.com                  ││
│ │   📚 Subjects: Math, Physics            ││
│ │   ⏰ Available: Tue, Thu, Sat 3-7 PM   ││
│ │   👥 Active Students: 3                 ││
│ │   [Select]                              ││
│ └─────────────────────────────────────────┘│
│                                             │
│ ℹ️  Showing teachers who:                   │
│    • Teach requested subjects               │
│    • Have active availability               │
│    • Are verified                           │
└────────────────────────────────────────────┘
```

**Selection Flow**:
1. Click [Select] on teacher
2. Opens assignment form (next section)

**Teacher Matching Logic**:
```sql
SELECT t.*, ta.* 
FROM teachers t
LEFT JOIN teacher_availability ta ON t.uid = ta.teacher_uid
WHERE 
  t.verified = true AND
  ta.is_active = true AND
  ta.subjects_offered @> ARRAY['Math', 'Physics'] -- Contains requested subjects
ORDER BY 
  (SELECT COUNT(*) FROM teacher_student_assignments 
   WHERE teacher_uid = t.uid AND assignment_status = 'active') ASC -- Fewest students first
```

---

### 5. Create Assignment Form

**Triggered by**: Selecting a teacher from teacher selection modal

**Purpose**: Create teacher-student assignment

**Form Fields**:
```
┌────────────────────────────────────────────┐
│ Create Assignment                [X]        │
├────────────────────────────────────────────┤
│                                             │
│ Teacher: Mr. Rajesh Kumar (read-only)       │
│ Student: Jane Doe (read-only)               │
│ Request: #abc-123 (read-only)               │
│                                             │
│ Subjects to Teach: *                        │
│ ☑ Math  ☑ Physics                          │
│                                             │
│ Start Date: *                               │
│ [📅 20 Feb 2026]                           │
│                                             │
│ End Date: (optional)                        │
│ [📅 Select date] or ☐ Ongoing              │
│                                             │
│ Assignment Status:                          │
│ ● Active  ○ Paused                         │
│                                             │
│ Notes: (optional)                           │
│ ┌─────────────────────────────────────────┐│
│ │ Student needs help with board exam prep ││
│ │ Focus on trigonometry and mechanics     ││
│ └─────────────────────────────────────────┘│
│                                             │
│ [Cancel]  [Create Assignment]               │
└────────────────────────────────────────────┘
```

**Validation**:
- At least one subject must be selected
- Start date is required
- End date must be after start date (if provided)

**On Submit**:
```typescript
// 1. Create assignment
POST /rest/v1/teacher_student_assignments
Body: {
  lecture_request_id: 'abc-123-def',
  teacher_uid: 'teacher_uid_here',
  student_id: 'student_uuid_here',
  subjects: ['Math', 'Physics'],
  assigned_by: 'admin_uid_here', // From auth.user()
  assignment_status: 'active',
  start_date: '2026-02-20',
  end_date: null, // or specific date
  notes: 'Student needs help with board exam prep...'
}

// 2. Update lecture request status
PATCH /rest/v1/lecture_requests?id=eq.abc-123-def
Body: {
  status: 'assigned'
}

// 3. Show success message
// 4. Send notification to teacher (future feature)
// 5. Send notification to parent (future feature)
```

---

### 6. Assignments Management Page

**Route**: `/admin/assignments`

**Purpose**: View and manage all teacher-student assignments

**Layout**:
```
┌─────────────────────────────────────────────┐
│  Teacher-Student Assignments                 │
│  ┌──────┬──────┬──────┬──────────┐          │
│  │ All  │Active│Paused│Completed │  (Tabs)  │
│  └──────┴──────┴──────┴──────────┘          │
│                                              │
│  🔍 Search: [________]  Filter: [_____]     │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │ Assignment #1                          │ │
│  │                                        │ │
│  │ Teacher: Mr. Rajesh Kumar              │ │
│  │ Student: Jane Doe (Grade 10)           │ │
│  │ Subjects: Math, Physics                │ │
│  │ Status: Active 🟢                      │ │
│  │ Duration: 20 Feb - Ongoing             │ │
│  │ Lectures Created: 8 (3 upcoming)       │ │
│  │                                        │ │
│  │ [View Details] [Pause] [End]          │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │ Assignment #2                          │ │
│  │ ...                                    │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**Features**:

1. **Filter Tabs**:
   - All
   - Active (ongoing assignments)
   - Paused (temporarily stopped)
   - Completed (ended)
   - Cancelled

2. **Search & Filter**:
   - Search by teacher name, student name, subjects
   - Date range (by start date)
   - Assigned by admin

3. **Assignment Card**:
   - Teacher name + email (clickable)
   - Student name + standard (clickable)
   - Subjects list
   - Status badge
   - Start date - End date (or "Ongoing")
   - Statistics:
     - Total lectures created
     - Upcoming lectures count
     - Completed lectures count
   - Notes preview
   - Assigned by admin name
   - Assigned date

4. **Actions per Assignment**:
   - **View Details**: Opens modal with full info + lecture list
   - **Pause**: Changes status to 'paused' (prevents new lecture creation)
   - **Resume**: Changes status back to 'active'
   - **End Assignment**: Sets end_date to today, status to 'completed'
   - **Cancel**: Status to 'cancelled' with reason

**API Queries**:
```sql
-- Get assignments with teacher and student details
SELECT 
  tsa.*,
  t.first_name as teacher_fname, t.last_name as teacher_lname, t.email as teacher_email,
  s.first_name as student_fname, s.last_name as student_lname, s.standard,
  (SELECT COUNT(*) FROM lectures WHERE assignment_id = tsa.id) as lecture_count,
  (SELECT COUNT(*) FROM lectures WHERE assignment_id = tsa.id AND status IN ('scheduled', 'rescheduled')) as upcoming_count
FROM teacher_student_assignments tsa
JOIN teachers t ON t.uid = tsa.teacher_uid
JOIN students s ON s.student_id = tsa.student_id
WHERE tsa.assignment_status = 'active'
ORDER BY tsa.created_at DESC
```

---

### 7. Assignment Details Modal

**Content**:
```
┌────────────────────────────────────────────┐
│ Assignment Details            [X]           │
├────────────────────────────────────────────┤
│                                             │
│ Assignment ID: xyz-789                      │
│ Status: Active 🟢                          │
│ Created: 20 Feb 2026 by Admin John         │
│                                             │
│ ┌─ Teacher ─────────────────────────────┐  │
│ │ Name: Mr. Rajesh Kumar                │  │
│ │ Email: rajesh@example.com             │  │
│ │ Phone: +1 234 567 8900                │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Student ─────────────────────────────┐  │
│ │ Name: Jane Doe                        │  │
│ │ Standard: 10th Grade (CBSE)           │  │
│ │ Parent: John Doe                      │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Assignment Details ──────────────────┐  │
│ │ Subjects: Math, Physics               │  │
│ │ Start Date: 20 Feb 2026               │  │
│ │ End Date: Ongoing                     │  │
│ │ Notes: Focus on board exam prep       │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Lecture Statistics ──────────────────┐  │
│ │ Total Lectures: 8                     │  │
│ │ Upcoming: 3                           │  │
│ │ Completed: 4                          │  │
│ │ Cancelled: 1                          │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Recent Lectures ─────────────────────┐  │
│ │ • Math - 25 Feb 4:00 PM (Scheduled)   │  │
│ │ • Physics - 22 Feb 5:00 PM (Complete) │  │
│ │ • Math - 20 Feb 4:00 PM (Complete)    │  │
│ │ [View All Lectures]                   │  │
│ └───────────────────────────────────────┘  │
│                                             │
│ ┌─ Actions ─────────────────────────────┐  │
│ │ [Pause Assignment]                    │  │
│ │ [End Assignment]                      │  │
│ │ [Edit Notes]                          │  │
│ │ [Close]                               │  │
│ └───────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

---

### 8. Rejection Dialog

**Triggered by**: "Reject" button on request

**Purpose**: Provide reason for rejection

```
┌────────────────────────────────────────────┐
│ Reject Lecture Request        [X]           │
├────────────────────────────────────────────┤
│                                             │
│ Request by: John Doe                        │
│ Student: Jane Doe                           │
│ Subjects: Math, Physics                     │
│                                             │
│ Rejection Reason: *                         │
│ ┌─────────────────────────────────────────┐│
│ │ [Dropdown with common reasons]          ││
│ │ • No teachers available for subjects    ││
│ │ • Student age not suitable              ││
│ │ • Duplicate request                     ││
│ │ • Incomplete information                ││
│ │ • Other (specify below)                 ││
│ └─────────────────────────────────────────┘│
│                                             │
│ Additional Details:                         │
│ ┌─────────────────────────────────────────┐│
│ │                                         ││
│ │                                         ││
│ │                                         ││
│ └─────────────────────────────────────────┘│
│                                             │
│ ⚠️  Parent will be notified of rejection    │
│                                             │
│ [Cancel]  [Confirm Rejection]               │
└────────────────────────────────────────────┘
```

**On Submit**:
```typescript
PATCH /rest/v1/lecture_requests?id=eq.{request_id}
Body: {
  status: 'rejected',
  rejection_reason: 'No teachers available for subjects. Please try again in 2 weeks.'
}
```

---

## 🔐 Admin Authentication & Authorization

### Admin User Setup

**Supabase Setup**:
1. Create `admins` table:
```sql
CREATE TABLE IF NOT EXISTS public.admins (
  uid TEXT NOT NULL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  first_name TEXT,
  last_name TEXT,
  role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT admins_uid_fkey FOREIGN KEY (uid) REFERENCES public.users(uid)
);

-- Enable RLS
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- Admin can read own data
CREATE POLICY "Admins can view own data" ON public.admins
  FOR SELECT USING (auth.uid() = uid);
```

2. Add `is_admin` flag to users table or use role-based checks

### RLS Policies for Admin Operations

Admin needs elevated permissions to manage lecture requests and assignments:

```sql
-- Admin can view all lecture requests
CREATE POLICY "Admins can view all lecture requests" ON public.lecture_requests
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.admins WHERE uid = auth.uid())
  );

-- Admin can update lecture requests
CREATE POLICY "Admins can update lecture requests" ON public.lecture_requests
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.admins WHERE uid = auth.uid())
  );

-- Admin can create teacher-student assignments
CREATE POLICY "Admins can create assignments" ON public.teacher_student_assignments
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.admins WHERE uid = auth.uid())
  );

-- Admin can view all assignments
CREATE POLICY "Admins can view all assignments" ON public.teacher_student_assignments
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.admins WHERE uid = auth.uid())
  );

-- Admin can update assignments
CREATE POLICY "Admins can update assignments" ON public.teacher_student_assignments
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.admins WHERE uid = auth.uid())
  );

-- Admin can view teacher availability
CREATE POLICY "Admins can view teacher availability" ON public.teacher_availability
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.admins WHERE uid = auth.uid())
  );
```

---

## 🛠️ Technical Stack Recommendations

### Frontend Options

#### Option 1: Next.js Admin Dashboard (Recommended)
**Pros**:
- Fast development with React
- Server-side rendering
- Built-in API routes
- Great with Supabase
- TypeScript support

**Libraries**:
- `@supabase/supabase-js` - Supabase client
- `@tanstack/react-query` - Data fetching
- `shadcn/ui` or `Ant Design` - UI components
- `react-hook-form` + `zod` - Form validation
- `date-fns` or `dayjs` - Date manipulation

#### Option 2: Vue.js + Nuxt Admin Dashboard
**Similar benefits to Next.js but with Vue ecosystem**

#### Option 3: Flutter Web Admin Dashboard
**Pros**:
- Same codebase as mobile apps
- Consistent UI
**Cons**:
- Larger bundle size
- SEO limitations

### Backend
- **Supabase** (already configured)
  - PostgreSQL database
  - Row Level Security
  - Realtime subscriptions (optional for live updates)
  - Edge Functions (for complex logic)

---

## 📡 API Integration Examples

### Supabase JavaScript Client Setup

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

### Get Pending Requests

```typescript
const { data: requests, error } = await supabase
  .from('lecture_requests')
  .select(`
    *,
    parents:parent_uid (
      first_name,
      last_name,
      email
    ),
    students:student_id (
      first_name,
      last_name,
      standard,
      board,
      medium
    )
  `)
  .eq('status', 'pending')
  .order('priority_level', { ascending: false })
  .order('created_at', { ascending: false })
```

### Approve Request

```typescript
const { error } = await supabase
  .from('lecture_requests')
  .update({ status: 'approved' })
  .eq('id', requestId)
```

### Reject Request

```typescript
const { error } = await supabase
  .from('lecture_requests')
  .update({ 
    status: 'rejected',
    rejection_reason: 'No teachers available for requested subjects'
  })
  .eq('id', requestId)
```

### Find Suitable Teachers

```typescript
const { data: teachers, error } = await supabase
  .from('teachers')
  .select(`
    *,
    teacher_availability (
      available_days,
      time_slots,
      subjects_offered,
      is_active
    )
  `)
  .eq('verified', true)
  .eq('teacher_availability.is_active', true)
  .contains('teacher_availability.subjects_offered', requestedSubjects)
```

### Create Assignment

```typescript
const { data: assignment, error } = await supabase
  .from('teacher_student_assignments')
  .insert({
    lecture_request_id: requestId,
    teacher_uid: teacherUid,
    student_id: studentId,
    subjects: ['Math', 'Physics'],
    assigned_by: adminUid,
    assignment_status: 'active',
    start_date: '2026-02-20',
    end_date: null,
    notes: 'Focus on board exam preparation'
  })
  .select()
  .single()

// Update request status
if (!error) {
  await supabase
    .from('lecture_requests')
    .update({ status: 'assigned' })
    .eq('id', requestId)
}
```

### Get Assignment with Details

```typescript
const { data: assignment, error } = await supabase
  .from('teacher_student_assignments')
  .select(`
    *,
    teachers:teacher_uid (
      first_name,
      last_name,
      email,
      phone_number
    ),
    students:student_id (
      first_name,
      last_name,
      standard,
      board
    ),
    lecture_requests:lecture_request_id (
      preferred_time_slots,
      frequency
    ),
    lectures (
      id,
      subject,
      scheduled_date,
      scheduled_time,
      status
    )
  `)
  .eq('id', assignmentId)
  .single()
```

### Update Assignment Status

```typescript
// Pause assignment
const { error } = await supabase
  .from('teacher_student_assignments')
  .update({ assignment_status: 'paused' })
  .eq('id', assignmentId)

// End assignment
const { error } = await supabase
  .from('teacher_student_assignments')
  .update({ 
    assignment_status: 'completed',
    end_date: new Date().toISOString().split('T')[0]
  })
  .eq('id', assignmentId)
```

---

## 🔔 Notifications (Future Enhancement)

### Email Notifications

**Send to Parents**:
- Request approved
- Request rejected (with reason)
- Teacher assigned
- Assignment ended/cancelled

**Send to Teachers**:
- New student assigned
- Assignment paused/resumed
- Assignment ended

### Implementation Options:
1. **Supabase Edge Functions** + Email service (SendGrid, Resend, AWS SES)
2. **Trigger-based** (PostgreSQL triggers → webhook → email)
3. **Manual** from admin dashboard

---

## 📊 Reports & Analytics (Future)

### Admin Reports Page

**Metrics to Track**:
- Request volume over time
- Average time to assign teacher
- Rejection reasons breakdown
- Teacher workload distribution
- Subject demand analysis
- Peak request times

**Visualizations**:
- Line charts for trends
- Pie charts for distributions
- Tables for detailed data

---

## 🧪 Testing Checklist for Admin Dashboard

### Lecture Requests
- [ ] View all pending requests
- [ ] Filter by status
- [ ] Search requests
- [ ] View request details
- [ ] Approve request
- [ ] Reject request with reason
- [ ] Verify parent sees rejection reason

### Teacher Assignment
- [ ] Open teacher selection after approval
- [ ] Search teachers by subject
- [ ] View teacher availability
- [ ] Select teacher
- [ ] Fill assignment form
- [ ] Create assignment
- [ ] Verify request status changes to 'assigned'
- [ ] Verify teacher can now create lectures

### Assignment Management
- [ ] View all assignments
- [ ] Filter by status
- [ ] View assignment details
- [ ] Pause active assignment
- [ ] Resume paused assignment
- [ ] End assignment
- [ ] Verify teacher can't create lectures for paused/ended assignments

### Edge Cases
- [ ] No suitable teachers available → proper messaging
- [ ] Duplicate request handling
- [ ] Invalid date ranges
- [ ] Assign teacher to multiple students
- [ ] Student with multiple teachers (different subjects)

---

## 🚀 Deployment

### Environment Variables

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_key # Admin-only operations
```

### Deployment Platforms
- **Vercel** (recommended for Next.js)
- **Netlify**
- **AWS Amplify**
- **Self-hosted** (Docker)

---

## 📞 Support & Maintenance

### Admin Training Required
1. How to review requests
2. How to find suitable teachers
3. How to create assignments
4. How to handle rejections
5. How to monitor system health

### Monitoring
- Track failed assignments
- Monitor teacher response times
- Watch for unassigned approved requests
- Alert on high rejection rates

---

## 🎓 Best Practices

1. **Always provide rejection reasons** - Helps parents understand
2. **Match teacher availability with request** - Check time slots
3. **Consider teacher workload** - Don't overload teachers
4. **Document assignment notes** - Helps future reference
5. **Regular audits** - Check for stale pending requests
6. **Communication** - Keep parents and teachers informed

---

## 📚 Additional Resources

- [Supabase Docs](https://supabase.com/docs)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Next.js Docs](https://nextjs.org/docs)
- [shadcn/ui Components](https://ui.shadcn.com/)

---

## 📝 Next Steps for Admin Dashboard

1. **Setup Project**:
   - Initialize Next.js project
   - Install Supabase client
   - Setup environment variables
   - Configure authentication

2. **Implement Core Pages**:
   - Dashboard overview
   - Lecture requests management
   - Teacher selection & assignment
   - Assignments management

3. **Add Admin Users**:
   - Create admins table
   - Setup admin authentication
   - Configure RLS policies

4. **Test Workflow**:
   - Parent creates request → Admin reviews → Assigns teacher → Teacher creates lectures

5. **Deploy**:
   - Deploy to Vercel/Netlify
   - Configure production environment
   - Train admin users

---

This admin dashboard will complete the lecture management system and enable the full workflow from request to assignment to lecture delivery!
