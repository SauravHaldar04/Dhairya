/// <reference path="../global.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse, pushToUser } from '../_shared/fcm.ts'

const supabaseUrl        = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface TeacherAssignmentNotification {
  assignmentId: string
  teacherId:    string
  parentId:     string
}

serve(async (req: Request) => {
  const corsRes = handleCors(req)
  if (corsRes) return corsRes

  try {
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      return jsonResponse({ error: 'Request body is empty' }, 400)
    }

    let assignmentId: string, teacherId: string, parentId: string
    try {
      const parsed  = JSON.parse(bodyText) as TeacherAssignmentNotification
      assignmentId  = parsed.assignmentId
      teacherId     = parsed.teacherId
      parentId      = parsed.parentId
    } catch {
      return jsonResponse({ error: 'Invalid JSON in request body' }, 400)
    }

    if (!assignmentId) {
      return jsonResponse({ error: 'assignmentId is required' }, 400)
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { data: assignment, error: assignmentError } = await supabase
      .from('teacher_student_assignments')
      .select(`
        id, subjects,
        teachers!teacher_student_assignments_teacher_uid_fkey(first_name, last_name),
        students!teacher_student_assignments_student_id_fkey(first_name, last_name, standard)
      `)
      .eq('id', assignmentId)
      .single()

    if (assignmentError || !assignment) {
      return jsonResponse({ error: 'Assignment not found' }, 404)
    }

    const teacherName = `${assignment.teachers?.first_name ?? ''} ${assignment.teachers?.last_name ?? ''}`.trim()
    const studentName = `${assignment.students?.first_name ?? ''} ${assignment.students?.last_name ?? ''}`.trim()
    const grade       = assignment.students?.standard ?? ''
    const subjects    = Array.isArray(assignment.subjects)
      ? assignment.subjects.join(', ')
      : assignment.subjects ?? 'assigned subject'

    const results: { role: string; pushed: number; total: number }[] = []

    // ── Notify teacher ──────────────────────────────────────────────────
    if (teacherId) {
      await supabase.from('user_notifications').insert({
        user_id:               teacherId,
        notification_type:     'TEACHER_ASSIGNED',
        title:                 'New Teaching Assignment',
        message:               `You have been assigned to teach ${subjects}${grade ? ` (Grade ${grade})` : ''} for ${studentName}`,
        related_assignment_id: assignmentId,
        is_read:               false,
      })

      const r = await pushToUser(
        supabase, teacherId,
        'Teaching Assignment Confirmed',
        `You are now teaching ${subjects} for ${studentName}`,
        { assignmentId, notificationType: 'TEACHER_ASSIGNED' },
      )
      results.push({ role: 'teacher', ...r })
    }

    // ── Notify parent ───────────────────────────────────────────────────
    if (parentId) {
      await supabase.from('user_notifications').insert({
        user_id:               parentId,
        notification_type:     'TEACHER_ASSIGNED',
        title:                 'Teacher Assigned',
        message:               `${teacherName} has been assigned to teach ${subjects} to ${studentName}`,
        related_assignment_id: assignmentId,
        is_read:               false,
      })

      const r = await pushToUser(
        supabase, parentId,
        'Teacher Assigned ✓',
        `${teacherName} will teach ${subjects} to ${studentName}`,
        { assignmentId, teacherName, notificationType: 'TEACHER_ASSIGNED' },
      )
      results.push({ role: 'parent', ...r })
    }

    return jsonResponse({ success: true, results })

  } catch (error: any) {
    console.error('Error in send-teacher-assignment-notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
