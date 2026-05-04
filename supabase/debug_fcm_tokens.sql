-- Debugging queries for FCM token registration

-- 1. Check if user_fcm_tokens table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'user_fcm_tokens'
) AS table_exists;

-- 2. Check table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_fcm_tokens'
ORDER BY ordinal_position;

-- 3. View all FCM tokens (latest first)
SELECT 
  id,
  user_id,
  LEFT(fcm_token, 30) || '...' AS token_preview,
  device_type,
  is_active,
  created_at,
  updated_at
FROM user_fcm_tokens
ORDER BY created_at DESC;

-- 4. Count tokens per user
SELECT 
  u.email,
  u.role,
  COUNT(f.id) AS token_count,
  COUNT(CASE WHEN f.is_active THEN 1 END) AS active_tokens
FROM auth.users u
LEFT JOIN user_fcm_tokens f ON u.id::text = f.user_id
GROUP BY u.email, u.role
ORDER BY u.role, u.email;

-- 5. Check for users without tokens
SELECT 
  u.id,
  u.email,
  u.role,
  u.created_at
FROM auth.users u
LEFT JOIN user_fcm_tokens f ON u.id::text = f.user_id
WHERE f.id IS NULL
ORDER BY u.created_at DESC;

-- 6. View RLS policies on the table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'user_fcm_tokens';

-- 7. Delete all inactive tokens (cleanup)
-- Uncomment to run:
-- DELETE FROM user_fcm_tokens WHERE is_active = false;

-- 8. Get token count by device type
SELECT 
  device_type,
  COUNT(*) AS count,
  COUNT(CASE WHEN is_active THEN 1 END) AS active_count
FROM user_fcm_tokens
GROUP BY device_type;
