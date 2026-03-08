# ============================================================
# SUPABASE SETUP INSTRUCTIONS
# ============================================================

## Prerequisites
- Supabase account (https://supabase.com)
- Firebase project with service account
- Supabase CLI installed

## Step 1: Install Supabase CLI

```bash
# Windows (PowerShell)
npm install -g supabase

# Verify installation
supabase --version
```

## Step 2: Login to Supabase

```bash
supabase login
```

This will open your browser to authenticate.

## Step 3: Link Your Project

```bash
cd "c:\Flutter projects\Dhairya"
supabase link --project-ref YOUR_PROJECT_REF
```

Get YOUR_PROJECT_REF from your Supabase dashboard URL:
`https://app.supabase.com/project/YOUR_PROJECT_REF`

## Step 4: Set Supabase Secrets (for Edge Functions)

**IMPORTANT:** Never commit these values to Git!

```bash
# Set Firebase credentials for Edge Functions
supabase secrets set FIREBASE_PROJECT_ID="your-firebase-project-id"
supabase secrets set FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
supabase secrets set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"

# Verify secrets are set (values will be hidden)
supabase secrets list
```

To get Firebase credentials:
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download JSON file
4. Extract: `project_id`, `client_email`, `private_key`

## Step 5: Deploy Edge Functions

```bash
# Deploy individual functions
supabase functions deploy send-lecture-notification
supabase functions deploy process-pending-notifications

# Or deploy all at once
supabase functions deploy

# View deployment logs
supabase functions logs send-lecture-notification --follow
```

## Step 6: Setup pg_cron Job

1. Open Supabase Dashboard → SQL Editor
2. Copy content from `supabase/migrations/cron_jobs.sql`
3. Replace placeholders:
   - `YOUR_PROJECT_REF` → Your project reference
   - `YOUR_SERVICE_ROLE_KEY` → From Project Settings → API → service_role key
4. Execute the SQL

Verify cron is running:
```sql
SELECT * FROM cron.job WHERE jobname = 'process-pending-notifications';
```

## Step 7: Test Edge Functions

```bash
# Test locally (requires Docker)
supabase start
supabase functions serve

# Test deployed function
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-lecture-notification' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"notificationId": "test-id", "userId": "test-user", "title": "Test", "body": "Testing"}'
```

## Troubleshooting

### "Function not found"
- Ensure deployment succeeded: `supabase functions list`
- Check function logs: `supabase functions logs FUNCTION_NAME`

### "Missing environment variable"
- Verify secrets are set: `supabase secrets list`
- Re-set the secret: `supabase secrets set KEY=value`

### "Authentication failed"
- Re-login: `supabase logout && supabase login`
- Re-link project: `supabase link --project-ref YOUR_REF`

### Cron job not running
- Check if pg_cron is enabled: `SELECT * FROM pg_extension WHERE extname = 'pg_cron'`
- View job history: `SELECT * FROM cron.job_run_details ORDER BY start_time DESC`

## Monitoring

```bash
# View function logs
supabase functions logs send-lecture-notification --follow
supabase functions logs process-pending-notifications --follow

# View database logs
supabase logs db --follow
```

## Security Checklist

- ✅ Never commit `.env` files
- ✅ Never commit Firebase service account JSON
- ✅ Use `supabase secrets` for Edge Function credentials
- ✅ Use environment variables in Flutter app
- ✅ Restrict Firebase service account permissions
- ✅ Enable Supabase RLS (Row Level Security)
- ✅ Use HTTPS only in production
