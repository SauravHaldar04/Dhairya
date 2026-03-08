/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req: Request) => {
  try {
    console.log('Processing pending notifications...')
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const now = new Date().toISOString()

    // Fetch pending notifications that should be sent now
    const { data: pendingNotifications, error: fetchError } = await supabase
      .from('lecture_notifications')
      .select(`
        id,
        lecture_id,
        template_id,
        notification_type,
        scheduled_for
      `)
      .eq('is_sent', false)
      .lte('scheduled_for', now)
      .order('scheduled_for', { ascending: true })
      .limit(50) // Process max 50 per run to avoid timeout

    if (fetchError) {
      throw new Error(`Failed to fetch notifications: ${fetchError.message}`)
    }

    if (!pendingNotifications || pendingNotifications.length === 0) {
      console.log('No pending notifications to process')
      return new Response(
        JSON.stringify({ success: true, processed: 0 }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Found ${pendingNotifications.length} pending notifications`)

    // Process each notification
    const results = []
    for (const notification of pendingNotifications) {
      try {
        // Fetch lecture/template details for notification content
        let title = 'Lecture Reminder'
        let body = 'Your lecture is starting soon'
        let lectureData: any = null

        if (notification.lecture_id) {
          const { data: lecture } = await supabase
            .from('lectures')
            .select('subject, scheduled_date, scheduled_time, student_id')
            .eq('id', notification.lecture_id)
            .single()
          
          lectureData = lecture
          if (lecture) {
            const timeStr = lecture.scheduled_time?.start || ''
            title = `${lecture.subject} Lecture`
            body = `Your ${lecture.subject} lecture starts at ${timeStr}`
          }
        } else if (notification.template_id) {
          const { data: template } = await supabase
            .from('recurring_lecture_templates')
            .select('subject, scheduled_time, student_id')
            .eq('id', notification.template_id)
            .single()
          
          lectureData = template
          if (template) {
            const timeStr = template.scheduled_time?.start || ''
            title = `${template.subject} Lecture`
            body = `Your ${template.subject} lecture starts at ${timeStr}`
          }
        }

        // Call send-lecture-notification function
        const sendResponse = await fetch(
          `${supabaseUrl}/functions/v1/send-lecture-notification`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${supabaseServiceKey}`,
            },
            body: JSON.stringify({
              notificationId: notification.id,
              userId: lectureData?.student_id,
              lectureId: notification.lecture_id,
              templateId: notification.template_id,
              title: title,
              body: body,
              data: {
                type: notification.notification_type,
                scheduledFor: notification.scheduled_for,
              },
            }),
          }
        )

        const sendResult = await sendResponse.json()
        results.push({
          notificationId: notification.id,
          success: sendResult.success,
          error: sendResult.error,
        })

        console.log(`Processed notification ${notification.id}: ${sendResult.success ? 'success' : 'failed'}`)
      } catch (error: any) {
        console.error(`Error processing notification ${notification.id}:`, error)
        results.push({
          notificationId: notification.id,
          success: false,
          error: error.message,
        })

        // Mark notification as failed
        await supabase
          .from('lecture_notifications')
          .update({
            error_message: error.message,
            updated_at: new Date().toISOString(),
          })
          .eq('id', notification.id)
      }
    }

    const successCount = results.filter(r => r.success).length
    console.log(`Processed ${results.length} notifications, ${successCount} successful`)

    return new Response(
      JSON.stringify({
        success: true,
        processed: results.length,
        successful: successCount,
        failed: results.length - successCount,
        details: results,
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('Error in process-pending-notifications:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
