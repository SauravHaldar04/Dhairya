-- Verify and create user_fcm_tokens table if needed
-- This table stores FCM tokens for push notifications

-- Create table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_type TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, fcm_token)
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id 
  ON user_fcm_tokens(user_id);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_active 
  ON user_fcm_tokens(is_active) 
  WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own tokens
CREATE POLICY IF NOT EXISTS "Users can view own tokens"
  ON user_fcm_tokens
  FOR SELECT
  USING (auth.uid()::text = user_id);

-- Policy: Users can insert their own tokens
CREATE POLICY IF NOT EXISTS "Users can insert own tokens"
  ON user_fcm_tokens
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

-- Policy: Users can update their own tokens
CREATE POLICY IF NOT EXISTS "Users can update own tokens"
  ON user_fcm_tokens
  FOR UPDATE
  USING (auth.uid()::text = user_id);

-- Policy: Users can delete their own tokens
CREATE POLICY IF NOT EXISTS "Users can delete own tokens"
  ON user_fcm_tokens
  FOR DELETE
  USING (auth.uid()::text = user_id);

-- Grant permissions
GRANT ALL ON user_fcm_tokens TO authenticated;
GRANT SELECT ON user_fcm_tokens TO anon;
