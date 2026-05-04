/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { pushToUser } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req: Request) => {
  try {
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const now      = new Date().toISOString()

    // Fetch unsent notifications whose scheduled time has passed
    const { data: pending, error: fetchError } = await supabase
      .from('lecture_notifications')
      .select('id, lecture_id, template_id, notification_type, scheduled_for')
      .eq('is_sent', false)
      .lte('scheduled_for', now)
      .order('scheduled_for', { ascending: true })
      .limit(50)

    if (fetchError) throw new Error(`Failed to fetch notifications: ${fetchError.message}`)
    if (!pending || pending.length === 0) {
      return new Response(
        JSON.stringify({ success: true, processed: 0 }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      )
    }

    console.log(`Processing ${pending.length} pending notifications`)

    const results = []
    for (const notif of pending) {
      try {
        let title    = 'Lecture Reminder'
        let body     = 'Your lecture is starting soon'
        let userId: string | null = null

        if (notif.lecture_id) {
          const { data: lecture } = await supabase
            .from('lectures')
            .select('subject, scheduled_time, student_id')
            .eq('id', notif.lecture_id)
            .single()

          if (lecture) {
            userId = lecture.student_id
            const time = lecture.scheduled_time ?? ''
            title = `${lecture.subject} Lecture`
            body  = `Your ${lecture.subject} lecture starts at ${time}`
          }
        } else if (notif.template_id) {
          const { data: template } = await supabase
            .from('recurring_lecture_templates')
            .select('subject, scheduled_time, student_id')
            .eq('id', notif.template_id)
            .single()

          if (template) {
            userId = template.student_id
            const time = template.scheduled_time?.start ?? template.scheduled_time ?? ''
            title = `${template.subject} Lecture`
            body  = `Your ${template.subject} lecture starts at ${time}`
          }
        }

        if (!userId) {
          console.warn(`Could not resolve userId for notification ${notif.id}`)
          results.push({ id: notif.id, success: false, error: 'No userId resolved' })
          continue
        }

        const { pushed } = await pushToUser(
          supabase,
          userId,
          title,
          body,
          {
            notificationId: notif.id,
            lectureId:      notif.lecture_id  ?? '',
            templateId:     notif.template_id ?? '',
            type:           notif.notification_type,
            scheduledFor:   notif.scheduled_for,
          },
        )

        // Mark as sent
        await supabase
          .from('lecture_notifications')
          .update({
            is_sent:    pushed > 0,
            sent_at:    pushed > 0 ? new Date().toISOString() : null,
            error_message: pushed === 0 ? 'No active tokens' : null,
            updated_at: new Date().toISOString(),
          })
          .eq('id', notif.id)

        results.push({ id: notif.id, success: pushed > 0 })
      } catch (err: any) {
        console.error(`Error processing notification ${notif.id}:`, err)
        await supabase
          .from('lecture_notifications')
          .update({ error_message: err.message, updated_at: new Date().toISOString() })
          .eq('id', notif.id)
        results.push({ id: notif.id, success: false, error: err.message })
      }
    }

    const successCount = results.filter(r => r.success).length
    return new Response(
      JSON.stringify({ success: true, processed: results.length, successful: successCount, failed: results.length - successCount }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )

  } catch (error: any) {
    console.error('Error in process-pending-notifications:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    )
  }
})
