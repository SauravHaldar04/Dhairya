/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { initializeApp, cert, getApps } from "https://esm.sh/firebase-admin@12.0.0/app"
import { getMessaging } from "https://esm.sh/firebase-admin@12.0.0/messaging"

// Firebase Admin SDK initialization
// Store your Firebase service account JSON in Supabase secrets
const firebaseConfig = {
  projectId: Deno.env.get('FIREBASE_PROJECT_ID'),
  clientEmail: Deno.env.get('FIREBASE_CLIENT_EMAIL'),
  privateKey: Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
}

// Initialize Firebase Admin (only once)
if (getApps().length === 0) {
  initializeApp({
    credential: cert(firebaseConfig as any),
  })
}

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
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
  try {
    // Parse request
    const { notificationId, userId, lectureId, templateId, title, body, data }: NotificationRequest = await req.json()

    if (!notificationId) {
      return new Response(
        JSON.stringify({ error: 'notificationId is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client
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
      return new Response(
        JSON.stringify({ error: 'Could not determine userId' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Fetch user's FCM tokens
    const { data: tokens, error: tokensError } = await supabase
      .from('user_fcm_tokens')
      .select('token')
      .eq('user_id', targetUserId)
      .eq('is_active', true)

    if (tokensError || !tokens || tokens.length === 0) {
      console.log(`No active FCM tokens found for user ${targetUserId}`)
      
      // Update notification as failed
      await supabase
        .from('lecture_notifications')
        .update({
          is_sent: false,
          error_message: 'No active FCM tokens found',
          updated_at: new Date().toISOString(),
        })
        .eq('id', notificationId)

      return new Response(
        JSON.stringify({ success: false, error: 'No active FCM tokens' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Send notification to all user's devices
    const messaging = getMessaging()
    const results = []

    for (const tokenRecord of tokens) {
      try {
        const message = {
          token: tokenRecord.token,
          notification: {
            title: title,
            body: body,
          },
          data: {
            notificationId: notificationId,
            lectureId: lectureId || '',
            templateId: templateId || '',
            ...data,
          },
          android: {
            priority: 'high' as const,
            notification: {
              sound: 'default',
              clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
              },
            },
          },
        }

        const response = await messaging.send(message)
        results.push({ token: tokenRecord.token, success: true, messageId: response })
      } catch (error: any) {
        console.error(`Failed to send to token ${tokenRecord.token}:`, error)
        results.push({ token: tokenRecord.token, success: false, error: error.message })
        
        // If token is invalid, mark it as inactive
        if (error.code === 'messaging/invalid-registration-token' || 
            error.code === 'messaging/registration-token-not-registered') {
          await supabase
            .from('user_fcm_tokens')
            .update({ is_active: false })
            .eq('token', tokenRecord.token)
        }
      }
    }

    // Update notification record
    const successfulSends = results.filter(r => r.success)
    const fcmMessageId = successfulSends[0]?.messageId || null

    await supabase
      .from('lecture_notifications')
      .update({
        is_sent: successfulSends.length > 0,
        sent_at: successfulSends.length > 0 ? new Date().toISOString() : null,
        fcm_message_id: fcmMessageId,
        error_message: successfulSends.length === 0 ? 'All sends failed' : null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', notificationId)

    return new Response(
      JSON.stringify({
        success: true,
        sentCount: successfulSends.length,
        totalTokens: tokens.length,
        results: results,
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('Error in send-lecture-notification:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
