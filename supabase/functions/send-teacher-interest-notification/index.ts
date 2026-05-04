/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse, getAccessToken, sendFcmMessage } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface TeacherInterestNotification {
  requestId: string
  teacherId: string
}

serve(async (req: Request) => {
  // Handle CORS preflight
  const corsRes = handleCors(req)
  if (corsRes) return corsRes

  try {
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      return jsonResponse({ error: 'Request body is empty' }, 400)
    }

    let requestId: string, teacherId: string
    try {
      const parsed = JSON.parse(bodyText) as TeacherInterestNotification
      requestId = parsed.requestId
      teacherId = parsed.teacherId
    } catch {
      return jsonResponse({ error: 'Invalid JSON in request body' }, 400)
    }

    if (!requestId || !teacherId) {
      return jsonResponse({ error: 'requestId and teacherId are required' }, 400)
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Fetch lecture request details
    const { data: lectureRequest, error: requestError } = await supabase
      .from('lecture_requests')
      .select('id, subjects, students!lecture_requests_student_id_fkey(first_name, last_name, standard)')
      .eq('id', requestId)
      .single()

    if (requestError || !lectureRequest) {
      return jsonResponse({ error: 'Lecture request not found' }, 404)
    }

    const studentName = `${lectureRequest.students?.first_name ?? ''} ${lectureRequest.students?.last_name ?? ''}`.trim()
    const subjects    = Array.isArray(lectureRequest.subjects)
      ? lectureRequest.subjects.join(', ')
      : lectureRequest.subjects ?? 'requested subject'
    const grade       = lectureRequest.students?.standard ?? ''

    // Fetch teacher's active FCM tokens
    const { data: tokens, error: tokensError } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .eq('user_id', teacherId)
      .eq('is_active', true)

    // Store in-app notification regardless of push status
    const { data: inAppNotif } = await supabase
      .from('user_notifications')
      .insert({
        user_id:                    teacherId,
        notification_type:          'TEACHER_INTEREST_REQUEST',
        title:                      'New Teaching Opportunity',
        message:                    `You are invited to teach ${subjects}${grade ? ` (Grade ${grade})` : ''} for ${studentName}`,
        related_lecture_request_id: requestId,
        is_read:                    false,
      })
      .select('id')
      .single()

    if (tokensError || !tokens || tokens.length === 0) {
      console.log(`No active FCM tokens for teacher ${teacherId}`)
      return jsonResponse({ success: true, pushed: 0, inAppCreated: !!inAppNotif })
    }

    const accessToken = await getAccessToken()
    const results = []

    for (const row of tokens) {
      try {
        await sendFcmMessage(
          accessToken,
          row.fcm_token,
          'New Teaching Opportunity',
          `You are invited to teach ${subjects} for ${studentName}`,
          {
            requestId,
            notificationType:    'TEACHER_INTEREST_REQUEST',
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

    return jsonResponse({ success: true, pushed: results.filter(r => r.success).length, total: tokens.length })

  } catch (error: any) {
    console.error('Error in send-teacher-interest-notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
