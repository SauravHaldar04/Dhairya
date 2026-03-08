/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { initializeApp, cert, getApps } from "https://esm.sh/firebase-admin@12.0.0/app"
import { getMessaging } from "https://esm.sh/firebase-admin@12.0.0/messaging"

// Firebase Admin SDK initialization
const firebaseConfig = {
  projectId: Deno.env.get('FIREBASE_PROJECT_ID'),
  clientEmail: Deno.env.get('FIREBASE_CLIENT_EMAIL'),
  privateKey: Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
}

if (getApps().length === 0) {
  initializeApp({
    credential: cert(firebaseConfig as any),
  })
}

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface RequestReceivedNotification {
  requestId: string
  adminUserId: string
}

serve(async (req: Request) => {
  try {
    const { requestId, adminUserId }: RequestReceivedNotification = await req.json()

    if (!requestId || !adminUserId) {
      return new Response(
        JSON.stringify({ error: 'requestId and adminUserId are required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Fetch lecture request details
    const { data: lectureRequest, error: requestError } = await supabase
      .from('lecture_requests')
      .select(`
        id,
        subject,
        student:students(id, full_name, grade),
        parent:parents(id, full_name)
      `)
      .eq('id', requestId)
      .single()

    if (requestError || !lectureRequest) {
      return new Response(
        JSON.stringify({ error: 'Lecture request not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Fetch admin's FCM tokens
    const { data: tokens, error: tokensError } = await supabase
      .from('user_fcm_tokens')
      .select('token')
      .eq('user_id', adminUserId)
      .eq('is_active', true)

    if (tokensError || !tokens || tokens.length === 0) {
      console.log(`No active FCM tokens found for admin ${adminUserId}`)
      return new Response(
        JSON.stringify({ success: false, error: 'No active FCM tokens' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Store in-app notification
    const { data: inAppNotif, error: notifError } = await supabase
      .from('in_app_notifications')
      .insert({
        user_id: adminUserId,
        type: 'LECTURE_REQUEST_RECEIVED',
        title: 'New Lecture Request',
        body: `${lectureRequest.parent?.full_name} requested a ${lectureRequest.subject} lecture for ${lectureRequest.student?.full_name}`,
        related_id: requestId,
        is_read: false,
        created_at: new Date().toISOString(),
      })
      .select('id')
      .single()

    if (notifError) {
      console.error('Error storing in-app notification:', notifError)
    }

    // Send push notifications
    const messaging = getMessaging()
    const results = []

    for (const tokenRecord of tokens) {
      try {
        const message = {
          token: tokenRecord.token,
          notification: {
            title: 'New Lecture Request',
            body: `${lectureRequest.parent?.full_name} requested a ${lectureRequest.subject} lecture`,
          },
          data: {
            requestId: requestId,
            notificationType: 'LECTURE_REQUEST_RECEIVED',
            inAppNotificationId: inAppNotif?.id || '',
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
        console.error(`Failed to send to token:`, error)
        results.push({ token: tokenRecord.token, success: false, error: error.message })

        // Mark invalid tokens as inactive
        if (error.code === 'messaging/invalid-registration-token' || 
            error.code === 'messaging/registration-token-not-registered') {
          await supabase
            .from('user_fcm_tokens')
            .update({ is_active: false })
            .eq('token', tokenRecord.token)
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        sentCount: results.filter(r => r.success).length,
        totalTokens: tokens.length,
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('Error in send-request-received-notification:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
