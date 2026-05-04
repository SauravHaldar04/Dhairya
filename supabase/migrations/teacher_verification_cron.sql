-- ============================================================
-- Teacher Verification Notification Cron Job
-- ============================================================
-- Triggers Edge Function to send FCM notifications for verification updates

-- Enable pg_cron extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create a lightweight queue table for verification notifications
CREATE TABLE IF NOT EXISTS teacher_verification_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_uid text NOT NULL REFERENCES teachers(uid),
  status text NOT NULL CHECK (status IN ('approved', 'rejected')),
  reason text,
  fcm_triggered boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  triggered_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_teacher_verification_notif_trigger
  ON teacher_verification_notifications(fcm_triggered)
  WHERE fcm_triggered = false;

-- Cron job: push pending verification notifications every 2 minutes
SELECT cron.schedule(
  'send-teacher-verification-fcm',
  '*/2 * * * *',
  $$
  WITH pending AS (
    SELECT id, teacher_uid, status, reason
    FROM teacher_verification_notifications
    WHERE fcm_triggered = false
    ORDER BY created_at ASC
    LIMIT 10
  ), sent AS (
    SELECT
      p.id,
      net.http_post(
        url:='https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-teacher-verification-notification',
        headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
        body:=jsonb_build_object(
          'teacherId', p.teacher_uid,
          'status', p.status,
          'reason', p.reason
        )
      ) AS request_id
    FROM pending p
  )
  UPDATE teacher_verification_notifications t
  SET fcm_triggered = true, triggered_at = now()
  WHERE t.id IN (SELECT id FROM sent);
  $$
);

-- Optional cleanup (30 days)
SELECT cron.schedule(
  'cleanup-teacher-verification-notifs',
  '0 3 * * *',
  $$
  DELETE FROM teacher_verification_notifications
  WHERE fcm_triggered = true
  AND created_at < now() - interval '30 days';
  $$
);
