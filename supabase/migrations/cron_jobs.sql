-- ============================================================
-- SUPABASE CRON JOB SETUP
-- ============================================================
-- This SQL sets up a pg_cron job to process pending notifications every minute

-- Enable pg_cron extension (if not already enabled)
-- Run this in Supabase SQL Editor
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create cron job to process pending notifications every minute
SELECT cron.schedule(
  'process-pending-notifications', -- job name
  '* * * * *',                      -- cron expression (every minute)
  $$
  SELECT
    net.http_post(
      url:='https://YOUR_PROJECT_REF.supabase.co/functions/v1/process-pending-notifications',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
      body:='{}'::jsonb
    ) as request_id;
  $$
);

-- View all cron jobs
SELECT * FROM cron.job;

-- View cron job history/logs
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- Unschedule a job (if needed)
-- SELECT cron.unschedule('process-pending-notifications');

-- ============================================================
-- NOTIFICATION CLEANUP JOB (Optional - runs daily at 2 AM)
-- ============================================================
-- Deletes old sent notifications older than 30 days
SELECT cron.schedule(
  'cleanup-old-notifications',
  '0 2 * * *', -- 2 AM daily
  $$
  DELETE FROM lecture_notifications
  WHERE is_sent = true
  AND sent_at < NOW() - INTERVAL '30 days';
  $$
);
