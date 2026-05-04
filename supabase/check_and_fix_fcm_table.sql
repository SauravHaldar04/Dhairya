-- Check if user_fcm_tokens table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'user_fcm_tokens'
) AS table_exists;

-- If table doesn't exist, create it:
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, fcm_token)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_active ON user_fcm_tokens(is_active) WHERE is_active = true;

-- Enable RLS
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Users can view own tokens" ON user_fcm_tokens;
DROP POLICY IF EXISTS "Users can insert own tokens" ON user_fcm_tokens;
DROP POLICY IF EXISTS "Users can update own tokens" ON user_fcm_tokens;
DROP POLICY IF EXISTS "Users can delete own tokens" ON user_fcm_tokens;

-- Create policies
CREATE POLICY "Users can view own tokens"
  ON user_fcm_tokens FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own tokens"
  ON user_fcm_tokens FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own tokens"
  ON user_fcm_tokens FOR UPDATE
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own tokens"
  ON user_fcm_tokens FOR DELETE
  USING (auth.uid()::text = user_id);

-- Grant permissions
GRANT ALL ON user_fcm_tokens TO authenticated;
GRANT SELECT ON user_fcm_tokens TO anon;

-- Verify the table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_fcm_tokens'
ORDER BY ordinal_position;
