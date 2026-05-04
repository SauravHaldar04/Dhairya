/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse, pushToUser } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface ParentApprovalNotification {
  requestId: string
  parentId:  string
}

serve(async (req: Request) => {
  const corsRes = handleCors(req)
  if (corsRes) return corsRes

  try {
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      return jsonResponse({ error: 'Request body is empty' }, 400)
    }

    let requestId: string, parentId: string
    try {
      const parsed = JSON.parse(bodyText) as ParentApprovalNotification
      requestId = parsed.requestId
      parentId  = parsed.parentId
    } catch {
      return jsonResponse({ error: 'Invalid JSON in request body' }, 400)
    }

    if (!requestId || !parentId) {
      return jsonResponse({ error: 'requestId and parentId are required' }, 400)
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { data: lectureRequest, error: requestError } = await supabase
      .from('lecture_requests')
      .select('id, subjects, students!lecture_requests_student_id_fkey(first_name, last_name)')
      .eq('id', requestId)
      .single()

    if (requestError || !lectureRequest) {
      return jsonResponse({ error: 'Lecture request not found' }, 404)
    }

    const studentName = `${lectureRequest.students?.first_name ?? ''} ${lectureRequest.students?.last_name ?? ''}`.trim()
    const subjects    = Array.isArray(lectureRequest.subjects)
      ? lectureRequest.subjects.join(', ')
      : lectureRequest.subjects ?? 'your requested subject'

    await supabase
      .from('user_notifications')
      .insert({
        user_id:                    parentId,
        notification_type:          'LECTURE_REQUEST_APPROVED',
        title:                      'Lecture Request Approved',
        message:                    `Your request for ${subjects} for ${studentName} has been approved. A teacher will be assigned shortly.`,
        related_lecture_request_id: requestId,
        is_read:                    false,
      })

    const { pushed, total } = await pushToUser(
      supabase, parentId,
      'Lecture Request Approved ✓',
      `Your ${subjects} request for ${studentName} has been approved!`,
      { requestId, notificationType: 'LECTURE_REQUEST_APPROVED' },
    )

    return jsonResponse({ success: true, pushed, total })

  } catch (error: any) {
    console.error('Error in send-parent-approval-notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
