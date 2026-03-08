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

interface TeacherAssignmentNotification {
  assignmentId: string
  teacherId: string
  parentId: string
}

serve(async (req: Request) => {
  try {
    const { assignmentId, teacherId, parentId }: TeacherAssignmentNotification = await req.json()

    if (!assignmentId) {
      return new Response(
        JSON.stringify({ error: 'assignmentId is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Fetch assignment details
    const { data: assignment, error: assignmentError } = await supabase
      .from('teacher_student_assignments')
      .select(`
        id,
        request_id,
        lecture_requests!inner(
          id,
          subject,
          grade_level,
          student:students(id, full_name),
          parent:parents(id, full_name)
        ),
        teacher:teachers(id, full_name, specialization),
        assigned_dates,
        time_slots
      `)
      .eq('id', assignmentId)
      .single()

    if (assignmentError || !assignment) {
      return new Response(
        JSON.stringify({ error: 'Assignment not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const lectureRequest = assignment.lecture_requests
    const assignedDatesCount = (assignment.assigned_dates || []).length
    const timeSlotInfo = assignment.time_slots?.[0] || 'TBD'

    const results = []

    // Send notification to teacher if teacherId provided
    if (teacherId) {
      const { data: teacherTokens } = await supabase
        .from('user_fcm_tokens')
        .select('token')
        .eq('user_id', teacherId)
        .eq('is_active', true)

      if (teacherTokens && teacherTokens.length > 0) {
        // Store in-app notification for teacher
        await supabase
          .from('in_app_notifications')
          .insert({
            user_id: teacherId,
            type: 'TEACHER_ASSIGNED',
            title: 'New Teaching Assignment',
            body: `You have been assigned to teach ${lectureRequest.subject} (Grade ${lectureRequest.grade_level}) for ${lectureRequest.student?.full_name}`,
            related_id: assignmentId,
            is_read: false,
            created_at: new Date().toISOString(),
          })

        const messaging = getMessaging()
        for (const tokenRecord of teacherTokens) {
          try {
            const message = {
              token: tokenRecord.token,
              notification: {
                title: 'Teaching Assignment Confirmed',
                body: `You are now teaching ${lectureRequest.subject} for ${lectureRequest.student?.full_name}`,
              },
              data: {
                assignmentId: assignmentId,
                requestId: lectureRequest.id,
                notificationType: 'TEACHER_ASSIGNED',
                datesCount: assignedDatesCount.toString(),
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
            results.push({ userId: teacherId, role: 'teacher', success: true, messageId: response })
          } catch (error: any) {
            console.error(`Failed to send teacher notification:`, error)
            results.push({ userId: teacherId, role: 'teacher', success: false, error: error.message })

            if (error.code === 'messaging/invalid-registration-token' || 
                error.code === 'messaging/registration-token-not-registered') {
              await supabase
                .from('user_fcm_tokens')
                .update({ is_active: false })
                .eq('token', tokenRecord.token)
            }
          }
        }
      }
    }

    // Send notification to parent if parentId provided
    if (parentId) {
      const { data: parentTokens } = await supabase
        .from('user_fcm_tokens')
        .select('token')
        .eq('user_id', parentId)
        .eq('is_active', true)

      if (parentTokens && parentTokens.length > 0) {
        // Store in-app notification for parent
        await supabase
          .from('in_app_notifications')
          .insert({
            user_id: parentId,
            type: 'TEACHER_ASSIGNED',
            title: 'Teacher Assigned',
            body: `A teacher has been assigned for your request. ${assignment.teacher?.full_name} will teach ${lectureRequest.subject} to ${lectureRequest.student?.full_name}`,
            related_id: assignmentId,
            is_read: false,
            created_at: new Date().toISOString(),
          })

        const messaging = getMessaging()
        for (const tokenRecord of parentTokens) {
          try {
            const message = {
              token: tokenRecord.token,
              notification: {
                title: 'Teacher Assigned ✓',
                body: `${assignment.teacher?.full_name} has been assigned to teach ${lectureRequest.subject}`,
              },
              data: {
                assignmentId: assignmentId,
                requestId: lectureRequest.id,
                notificationType: 'TEACHER_ASSIGNED',
                teacherName: assignment.teacher?.full_name || '',
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
            results.push({ userId: parentId, role: 'parent', success: true, messageId: response })
          } catch (error: any) {
            console.error(`Failed to send parent notification:`, error)
            results.push({ userId: parentId, role: 'parent', success: false, error: error.message })

            if (error.code === 'messaging/invalid-registration-token' || 
                error.code === 'messaging/registration-token-not-registered') {
              await supabase
                .from('user_fcm_tokens')
                .update({ is_active: false })
                .eq('token', tokenRecord.token)
            }
          }
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        sentCount: results.filter(r => r.success).length,
        totalNotifications: results.length,
        results: results,
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('Error in send-teacher-assignment-notification:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
