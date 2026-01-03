-- Migration: Add Teacher Verification System
-- Date: 2025-12-30
-- Description: Adds verification fields to teachers table for admin approval workflow

-- Add verification columns to teachers table
ALTER TABLE teachers
ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'approved', 'rejected')),
ADD COLUMN IF NOT EXISTS verification_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS verified_by TEXT REFERENCES users(uid),
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Create indexes for faster queries on verification status
CREATE INDEX IF NOT EXISTS idx_teachers_verification_status ON teachers(verification_status);
CREATE INDEX IF NOT EXISTS idx_teachers_verified ON teachers(verified);

-- Add comments for documentation
COMMENT ON COLUMN teachers.verified IS 'Boolean flag indicating if teacher is verified by admin';
COMMENT ON COLUMN teachers.verification_status IS 'Current verification status: pending, approved, or rejected';
COMMENT ON COLUMN teachers.verification_date IS 'Timestamp when teacher was verified/rejected';
COMMENT ON COLUMN teachers.verified_by IS 'UID of admin who verified the teacher';
COMMENT ON COLUMN teachers.rejection_reason IS 'Reason provided if teacher application was rejected';

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Only admins can verify teachers" ON teachers;
DROP POLICY IF EXISTS "Teachers can view own verification status" ON teachers;
DROP POLICY IF EXISTS "Admins can view all teachers" ON teachers;

-- Policy: Only admins can update verification fields
CREATE POLICY "Only admins can verify teachers"
ON teachers
FOR UPDATE
USING (
  auth.uid() IN (
    SELECT uid FROM users WHERE user_type = 'admin'
  )
)
WITH CHECK (
  auth.uid() IN (
    SELECT uid FROM users WHERE user_type = 'admin'
  )
);

-- Policy: Teachers can view their own verification status
CREATE POLICY "Teachers can view own verification status"
ON teachers
FOR SELECT
USING (auth.uid() = uid);

-- Policy: Admins can view all teachers
CREATE POLICY "Admins can view all teachers"
ON teachers
FOR SELECT
USING (
  auth.uid() IN (
    SELECT uid FROM users WHERE user_type = 'admin'
  )
);

-- Optional: Set existing teachers as verified (grandfather clause)
-- Uncomment the line below if you want to automatically approve existing teachers
-- UPDATE teachers SET verified = TRUE, verification_status = 'approved', verification_date = NOW() WHERE verified IS NULL OR verified = FALSE;
