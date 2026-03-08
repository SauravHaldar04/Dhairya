# 🚀 Quick Start Guide

## ⚡ Immediate Next Steps (30 minutes total)

### 1️⃣ Create Your .env File (5 minutes)

```bash
# Copy the template
Copy-Item .env.example .env

# Then edit .env with your real credentials
notepad .env
```

Fill in these values:
```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_KEY
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXX
FIREBASE_APP_ID=1:123456789:web:abcdef
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=your-project-id
```

**Where to get these:**
- Supabase: https://app.supabase.com/project/YOUR_PROJECT/settings/api
- Firebase: Console → Project Settings → Your apps

### 2️⃣ Test the App (2 minutes)

```bash
flutter run
```

You should see:
```
✅ Environment variables loaded successfully
✅ All environment variables validated successfully
```

### 3️⃣ Deploy Supabase Edge Functions (15 minutes)

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link your project
supabase link --project-ref YOUR_PROJECT_REF

# Set Firebase secrets
supabase secrets set FIREBASE_PROJECT_ID="your-id"
supabase secrets set FIREBASE_CLIENT_EMAIL="your-email@iam.gserviceaccount.com"
supabase secrets set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_KEY\n-----END PRIVATE KEY-----"

# Deploy functions (existing)
supabase functions deploy send-lecture-notification
supabase functions deploy process-pending-notifications

# Deploy functions (new - for lecture requests)
supabase functions deploy send-teacher-interest-notification
supabase functions deploy send-parent-approval-notification
supabase functions deploy send-teacher-assignment-notification
supabase functions deploy send-request-received-notification
```

### 4️⃣ Setup Cron Job (5 minutes)

1. Open: Supabase Dashboard → SQL Editor
2. Paste: Content from `supabase/migrations/cron_jobs.sql`
3. Replace:
   - `YOUR_PROJECT_REF` → Your actual project ref
   - `YOUR_SERVICE_ROLE_KEY` → From API settings
4. Execute SQL

### 4️⃣-B Setup New Lecture Request System (Optional - only if implementing admin features)

1. **Run SQL migrations:**
   ```bash
   # In Supabase SQL Editor, run these migrations:
   supabase/migrations/lecture_requests_system.sql
   ```
   
2. **Configure new Edge Functions:**
   - Update `supabase/functions/send-teacher-interest-notification/index.ts` with:
     - Your email service details (for teacher interest emails)
     - FCM topic subscriptions for teachers
   
   - Update `supabase/functions/send-parent-approval-notification/index.ts` with:
     - Parent notification templates
     - Email/push preferences

3. **Enable admin operations** in your app:
   - Set `ENABLE_ADMIN_FEATURES=true` in `.env`
   - Admin users will see lecture request approval interface

### 5️⃣ Verify Everything Works (3 minutes)

```bash
# Check functions deployed
supabase functions list

# Check cron job scheduled
# In Supabase SQL Editor:
SELECT * FROM cron.job WHERE jobname = 'process-pending-notifications';

# View function logs
supabase functions logs process-pending-notifications --follow
```

---

## 📚 Detailed Documentation

- **IMPLEMENTATION_COMPLETE.md** - What was implemented + what you need to do
- **SUPABASE_SETUP.md** - Complete Supabase CLI guide with troubleshooting
- **PHASE_5_NOTIFICATIONS_SETUP.md** - Push notifications setup guide
- **APPLICATION_ARCHITECTURE_PLAN.md** - Complete lecture request system architecture
- **ADMIN_LECTURES_IMPLEMENTATION_PLAN.md** - Step-by-step admin feature implementation
- **ADMIN_QUICK_START.md** - Admin-specific feature workflows and code examples
- **NOTIFICATION_FLOW_ADMIN.md** - Detailed notification architecture for admin operations

---

## 🔒 Security Reminders

**✅ SAFE to commit:**
- Code files (*.dart, *.ts)
- .env.example (template only)
- Documentation (*.md)
- SQL migrations

**❌ NEVER commit:**
- .env (actual credentials)
- serviceAccountKey.json
- Any file with API keys

**Before every commit:**
```bash
git status
git diff
```

If you see `.env` or credentials, DON'T commit!

---

## 🆘 Problems?

### App won't start - "Missing environment variable"
- Create `.env` file from `.env.example`
- Fill in all values
- Run: `flutter clean && flutter pub get`

### Edge Functions not working
- Check: `supabase secrets list`
- Logs: `supabase functions logs FUNCTION_NAME`
- Redeploy: `supabase functions deploy FUNCTION_NAME`

### Notifications not sending
1. Check FCM token registered: Query `user_fcm_tokens` table
2. Check notifications scheduled: Query `lecture_notifications` table
3. Check cron running: `SELECT * FROM cron.job_run_details`
4. Check function logs: `supabase functions logs`

---

## ✅ Implementation Status

- ✅ Phase 1: Foundation Layer (Entities, Models, Calculator)
- ✅ Phase 2: Data Layer (Datasource, Repository)
- ✅ Phase 3: Use Cases (6 use cases)
- ✅ Phase 4: BLoC Layer (Events, States, Handlers)
- ✅ Phase 5: Push Notifications (Edge Functions, FCM Service)
- ✅ Phase 6: Authentication & Landing Page UI
- ✅ Phase 7: Lecture Request System Architecture (Design Complete)
- ⏳ Phase 8: Admin Lecture Request Features (In Progress)
  - ⏳ Edge Functions deployment (4 new functions)
  - ⏳ SQL migrations (new tables)
  - ⏳ Admin BLoC implementation
  - ⏳ Admin UI pages
- ⏳ Phase 9: Teacher & Parent Notifications
- ⏳ Phase 10: Testing & Verification

---

## 🎯 What This Achieves

**Before:** 
- 150+ database rows per recurring lecture
- Local notifications (don't work when app closed)
- Hardcoded credentials in code

**After:**
- 1 template row → unlimited virtual instances
- Server-side push notifications (always work)
- Secure environment variables
- 99% storage reduction
- Production-ready architecture

---

**Need Help?** Read IMPLEMENTATION_COMPLETE.md for step-by-step instructions!
