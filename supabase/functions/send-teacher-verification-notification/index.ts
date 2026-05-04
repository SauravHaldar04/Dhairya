/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse, getAccessToken, sendFcmMessage } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface TeacherVerificationNotification {
  teacherId: string
  status: 'approved' | 'rejected'
  reason?: string
}

serve(async (req: Request) => {
  const corsRes = handleCors(req)
  if (corsRes) return corsRes

  try {
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      return jsonResponse({ error: 'Request body is empty' }, 400)
    }

    let payload: TeacherVerificationNotification
    try {
      payload = JSON.parse(bodyText) as TeacherVerificationNotification
    } catch {
      return jsonResponse({ error: 'Invalid JSON in request body' }, 400)
    }

    const { teacherId, status, reason } = payload
    if (!teacherId || !status) {
      return jsonResponse({ error: 'teacherId and status are required' }, 400)
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const title = status === 'approved'
      ? 'Profile Verified! ✅'
      : 'Verification Update'

    const message = status === 'approved'
      ? 'Your profile has been verified by the admin. You can now access all features.'
      : `Your profile verification has been declined. Reason: ${reason || 'Please contact admin for more details'}`

    const { data: tokens, error: tokensError } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .eq('user_id', teacherId)
      .eq('is_active', true)

    const { data: inAppNotif } = await supabase
      .from('user_notifications')
      .insert({
        user_id:           teacherId,
        notification_type: status === 'approved' ? 'teacher_verified' : 'teacher_rejected',
        title,
        message,
        is_read:           false,
      })
      .select('id')
      .single()

    if (!tokensError && tokens && tokens.length > 0) {
      const accessToken = await getAccessToken()
      const results = []

      for (const row of tokens) {
        try {
          await sendFcmMessage(
            accessToken,
            row.fcm_token,
            title,
            message,
            {
              notificationType:    status === 'approved' ? 'teacher_verified' : 'teacher_rejected',
              inAppNotificationId: inAppNotif?.id ?? '',
            },
          )
          results.push({ token: row.fcm_token, success: true })
        } catch (err: any) {
          console.error('FCM send failed:', err.message)
          results.push({ token: row.fcm_token, success: false, error: err.message })

          if (err.message?.includes('INVALID_ARGUMENT') || err.message?.includes('UNREGISTERED')) {
            await supabase
              .from('user_fcm_tokens')
              .update({ is_active: false })
              .eq('fcm_token', row.fcm_token)
          }
        }
      }

      return jsonResponse({
        success: true,
        pushed: results.filter(r => r.success).length,
        total: tokens.length,
        inAppCreated: !!inAppNotif,
      })
    }

    return jsonResponse({
      success: true,
      pushed: 0,
      inAppCreated: !!inAppNotif,
      message: 'No active FCM tokens, but in-app notification created',
    })

  } catch (error: any) {
    console.error('Error in send-teacher-verification-notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
