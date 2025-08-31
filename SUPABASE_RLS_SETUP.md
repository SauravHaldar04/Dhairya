# Supabase Storage Row Level Security (RLS) Configuration Guide

## The Problem
You're getting a `StorageException: new row violates row-level security policy` error because Supabase Storage buckets have Row Level Security (RLS) enabled by default, but no policies are configured to allow file operations.

## Quick Fix (For Development)

### Option 1: Disable RLS (Not Recommended for Production)
1. Go to your Supabase Dashboard
2. Navigate to **Authentication** > **Policies**
3. Find the `storage.objects` table
4. Temporarily disable RLS (click the toggle)

### Option 2: Configure RLS Policies (Recommended)

#### Step 1: Go to Storage Policies
1. Open your Supabase Dashboard: `https://supabase.com/dashboard/projects`
2. Select your project
3. Navigate to **Storage** > **Policies**

#### Step 2: Create Upload Policy
Create a new policy for **INSERT** operations:

```sql
-- Policy Name: "Allow authenticated users to upload files"
-- Table: storage.objects
-- Operation: INSERT
-- Policy Definition:
(auth.role() = 'authenticated')
```

#### Step 3: Create Read Policy
Create a new policy for **SELECT** operations:

```sql
-- Policy Name: "Allow everyone to read files" 
-- Table: storage.objects
-- Operation: SELECT
-- Policy Definition:
true
```

#### Step 4: Create Update Policy (Optional)
Create a new policy for **UPDATE** operations:

```sql
-- Policy Name: "Allow authenticated users to update their files"
-- Table: storage.objects
-- Operation: UPDATE  
-- Policy Definition:
(auth.role() = 'authenticated')
```

#### Step 5: Create Delete Policy (Optional)
Create a new policy for **DELETE** operations:

```sql
-- Policy Name: "Allow authenticated users to delete their files"
-- Table: storage.objects
-- Operation: DELETE
-- Policy Definition:
(auth.role() = 'authenticated')
```

## Advanced Policies (User-Specific Access)

If you want users to only access their own files, use these policies instead:

### Upload Policy (User-Specific)
```sql
-- Policy Name: "Users can upload to their own folder"
-- Operation: INSERT
-- Policy Definition:
(auth.role() = 'authenticated' AND bucket_id = 'your-bucket-name' AND (storage.foldername(name))[1] = auth.uid()::text)
```

### Read Policy (User-Specific)
```sql
-- Policy Name: "Users can read their own files"  
-- Operation: SELECT
-- Policy Definition:
(bucket_id = 'your-bucket-name' AND (storage.foldername(name))[1] = auth.uid()::text)
```

## Bucket-Specific Policies

For each bucket (`user-files`, `profile-pictures`, `documents`), you can create specific policies:

### Profile Pictures Bucket
```sql
-- Allow authenticated users to upload profile pictures
(auth.role() = 'authenticated' AND bucket_id = 'profile-pictures')
```

### Documents Bucket
```sql
-- Allow authenticated users to upload documents
(auth.role() = 'authenticated' AND bucket_id = 'documents')
```

### User Files Bucket
```sql
-- Allow authenticated users to upload general files
(auth.role() = 'authenticated' AND bucket_id = 'user-files')
```

## Testing Your Policies

After creating the policies, test them by:

1. **Run your Flutter app**
2. **Attempt a file upload**
3. **Check the logs** - you should see success messages instead of RLS errors

## Troubleshooting

### Still getting RLS errors?
1. **Check if policies are enabled**: Policies should have a green toggle
2. **Verify policy syntax**: Make sure there are no syntax errors
3. **Check authentication**: Ensure your user is properly authenticated
4. **Review bucket names**: Verify bucket names match your configuration

### Authentication Issues?
Make sure your user is authenticated before attempting uploads:
```dart
final user = Supabase.instance.client.auth.currentUser;
if (user == null) {
  // User needs to log in first
}
```

### Bucket Doesn't Exist?
The app will automatically create buckets, but you can manually create them:
1. Go to **Storage** > **Buckets**
2. Click **New Bucket**
3. Set bucket name (e.g., `profile-pictures`)
4. Enable **Public bucket** if you want public access
5. Set file size limits and allowed file types

## Security Best Practices

1. **Use specific policies**: Don't use overly permissive policies like `true` for write operations
2. **Authenticate users**: Always require authentication for upload/delete operations
3. **Validate file types**: Set allowed MIME types in bucket configuration
4. **Set file size limits**: Prevent abuse by setting reasonable file size limits
5. **Monitor usage**: Regularly check your Supabase dashboard for unusual activity

## Quick Reference Commands

### Enable RLS on storage.objects
```sql
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
```

### Disable RLS (Development Only)
```sql
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

### Check existing policies
```sql
SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';
```

## Next Steps

1. **Fix the RLS policies** using the steps above
2. **Test file uploads** in your Flutter app
3. **Monitor the logs** to ensure everything works correctly
4. **Consider implementing user-specific folders** for better security

Once you've configured the policies, your Supabase storage should work perfectly with your Flutter app!
