/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse, pushToUser } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface RequestReceivedNotification {
  requestId:   string
  adminUserId: string
}

serve(async (req: Request) => {
  const corsRes = handleCors(req)
  if (corsRes) return corsRes

  try {
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      return jsonResponse({ error: 'Request body is empty' }, 400)
    }

    let requestId: string, adminUserId: string
    try {
      const parsed = JSON.parse(bodyText) as RequestReceivedNotification
      requestId   = parsed.requestId
      adminUserId = parsed.adminUserId
    } catch {
      return jsonResponse({ error: 'Invalid JSON in request body' }, 400)
    }

    if (!requestId || !adminUserId) {
      return jsonResponse({ error: 'requestId and adminUserId are required' }, 400)
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { data: lectureRequest, error: requestError } = await supabase
      .from('lecture_requests')
      .select(`
        id, subjects,
        parents!lecture_requests_parent_uid_fkey(first_name, last_name),
        students!lecture_requests_student_id_fkey(first_name, last_name)
      `)
      .eq('id', requestId)
      .single()

    if (requestError || !lectureRequest) {
      return jsonResponse({ error: 'Lecture request not found' }, 404)
    }

    const parentName  = `${lectureRequest.parents?.first_name ?? ''} ${lectureRequest.parents?.last_name ?? ''}`.trim()
    const studentName = `${lectureRequest.students?.first_name ?? ''} ${lectureRequest.students?.last_name ?? ''}`.trim()
    const subjects    = Array.isArray(lectureRequest.subjects)
      ? lectureRequest.subjects.join(', ')
      : lectureRequest.subjects ?? 'a subject'

    await supabase
      .from('user_notifications')
      .insert({
        user_id:                    adminUserId,
        notification_type:          'LECTURE_REQUEST_RECEIVED',
        title:                      'New Lecture Request',
        message:                    `${parentName} requested ${subjects} for ${studentName}`,
        related_lecture_request_id: requestId,
        is_read:                    false,
      })

    const { pushed, total } = await pushToUser(
      supabase, adminUserId,
      'New Lecture Request',
      `${parentName} requested ${subjects} for ${studentName}`,
      { requestId, notificationType: 'LECTURE_REQUEST_RECEIVED' },
    )

    return jsonResponse({ success: true, pushed, total })

  } catch (error: any) {
    console.error('Error in send-request-received-notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
