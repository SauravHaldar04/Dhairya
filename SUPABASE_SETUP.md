# Supabase Storage Setup Instructions

## Prerequisites
1. Create a Supabase account at https://supabase.com
2. Create a new project

## Setup Steps

### 1. Get Supabase Credentials
1. Go to your Supabase project dashboard
2. Navigate to Settings > API
3. Copy the following values:
   - Project URL (e.g., https://abcdefghijklmnop.supabase.co)
   - Public anon key

### 2. Update Secrets File
Edit `lib/core/config/secrets.dart`:

```dart
class Secrets {
  // Replace with your actual Supabase values
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // Storage bucket names
  static const String userFilesBucket = 'user-files';
  static const String profilePicturesBucket = 'profile-pictures';
  static const String documentsBucket = 'documents';
  
  // Switch this to true when ready to use Supabase
  static const bool useSupabaseStorage = false;
}
```

### 3. Setup Storage Buckets in Supabase Dashboard
1. Go to Storage in your Supabase dashboard
2. Create the following buckets:
   - `user-files` (public)
   - `profile-pictures` (public)
   - `documents` (public)

### 4. Configure Storage Policies
For each bucket, add these RLS policies:

**Allow public uploads:**
```sql
CREATE POLICY "Allow public uploads" ON storage.objects 
FOR INSERT WITH CHECK (true);
```

**Allow public downloads:**
```sql
CREATE POLICY "Allow public downloads" ON storage.objects 
FOR SELECT USING (true);
```

**Allow authenticated deletes:**
```sql
CREATE POLICY "Allow authenticated deletes" ON storage.objects 
FOR DELETE USING (auth.role() = 'authenticated');
```

### 5. Test the Implementation
1. Keep `useSupabaseStorage = false` initially
2. Test file uploads with Firebase Storage (current)
3. Switch to `useSupabaseStorage = true` when ready
4. Test uploads with Supabase Storage

### 6. Install Dependencies
Run in your project directory:
```bash
flutter pub get
```

## Migration Strategy
1. **Phase 1**: Keep Firebase as primary, Supabase as secondary
2. **Phase 2**: Test Supabase with non-critical uploads
3. **Phase 3**: Switch to Supabase completely
4. **Phase 4**: Optionally remove Firebase dependencies

## Troubleshooting
- Make sure bucket names match between code and Supabase dashboard
- Check RLS policies are properly configured
- Verify API keys are correct
- Check file size limits (currently set to 50MB)

## File Organization
```
Storage Structure:
├── user-files/
│   ├── profile-pictures/
│   ├── documents/
│   └── resumes/
├── profile-pictures/
│   ├── teachers/
│   ├── parents/
│   └── students/
└── documents/
    ├── resumes/
    └── certificates/
```
