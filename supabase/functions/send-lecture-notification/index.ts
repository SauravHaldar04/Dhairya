/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse, getAccessToken, sendFcmMessage } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface NotificationRequest {
  notificationId: string
  userId?: string
  lectureId?: string
  templateId?: string
  title: string
  body: string
  data?: Record<string, string>
}

serve(async (req: Request) => {
  const corsRes = handleCors(req)
  if (corsRes) return corsRes

  try {
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      return jsonResponse({ error: 'Request body is empty' }, 400)
    }

    let parsed: NotificationRequest
    try {
      parsed = JSON.parse(bodyText) as NotificationRequest
    } catch {
      return jsonResponse({ error: 'Invalid JSON in request body' }, 400)
    }

    const { notificationId, userId, lectureId, templateId, title, body, data } = parsed

    if (!notificationId) {
      return jsonResponse({ error: 'notificationId is required' }, 400)
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Determine userId from lectureId or templateId if not provided
    let targetUserId = userId
    if (!targetUserId && lectureId) {
      const { data: lecture } = await supabase
        .from('lectures')
        .select('student_id')
        .eq('id', lectureId)
        .single()
      targetUserId = lecture?.student_id
    } else if (!targetUserId && templateId) {
      const { data: template } = await supabase
        .from('recurring_lecture_templates')
        .select('student_id')
        .eq('id', templateId)
        .single()
      targetUserId = template?.student_id
    }

    if (!targetUserId) {
      return jsonResponse({ error: 'Could not determine userId' }, 400)
    }

    // Fetch user's FCM tokens
    const { data: tokens, error: tokensError } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .eq('user_id', targetUserId)
      .eq('is_active', true)

    if (tokensError || !tokens || tokens.length === 0) {
      console.log(`No active FCM tokens found for user ${targetUserId}`)
      
      await supabase
        .from('lecture_notifications')
        .update({
          is_sent: false,
          error_message: 'No active FCM tokens found',
          updated_at: new Date().toISOString(),
        })
        .eq('id', notificationId)

      return jsonResponse({ success: false, error: 'No active FCM tokens' })
    }

    const accessToken = await getAccessToken()
    const results = []

    for (const row of tokens) {
      try {
        await sendFcmMessage(
          accessToken,
          row.fcm_token,
          title,
          body,
          {
            notificationId: notificationId,
            lectureId: lectureId || '',
            templateId: templateId || '',
            ...data,
          },
        )
        results.push({ token: row.fcm_token, success: true })
      } catch (err: any) {
        console.error(`Failed to send to token ${row.fcm_token}:`, err.message)
        results.push({ token: row.fcm_token, success: false, error: err.message })
        
        if (err.message?.includes('INVALID_ARGUMENT') || err.message?.includes('UNREGISTERED')) {
          await supabase
            .from('user_fcm_tokens')
            .update({ is_active: false })
            .eq('fcm_token', row.fcm_token)
        }
      }
    }

    const successfulSends = results.filter(r => r.success)

    await supabase
      .from('lecture_notifications')
      .update({
        is_sent: successfulSends.length > 0,
        sent_at: successfulSends.length > 0 ? new Date().toISOString() : null,
        error_message: successfulSends.length === 0 ? 'All sends failed' : null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', notificationId)

    return jsonResponse({
      success: true,
      sentCount: successfulSends.length,
      totalTokens: tokens.length,
      results: results,
    })

  } catch (error: any) {
    console.error('Error in send-lecture-notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
