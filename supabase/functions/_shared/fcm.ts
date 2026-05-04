/**
 * Shared FCM HTTP v1 REST API helpers for Supabase Edge Functions.
 * Uses only Deno built-ins — no firebase-admin, no extra npm deps.
 */

// ─── CORS ────────────────────────────────────────────────────────────────────

export const corsHeaders = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/** Call at the top of every handler: returns a 200 preflight response for OPTIONS */
export function handleCors(req: Request): Response | null {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }
  return null
}

/** Wrap every JSON response with CORS headers */
export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}


const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID')!
export const FCM_ENDPOINT = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '')
  const binary = atob(b64)
  const buf = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) buf[i] = binary.charCodeAt(i)
  return buf.buffer
}

function toBase64Url(buf: ArrayBuffer): string {
  const bytes = new Uint8Array(buf)
  let binary = ''
  for (const b of bytes) binary += String.fromCharCode(b)
  return btoa(binary).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
}

function objToBase64Url(obj: object): string {
  return btoa(JSON.stringify(obj))
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
}

/**
 * Obtains a short-lived Google OAuth2 access token via the service account
 * JWT bearer flow. Each call makes one HTTPS request to Google.
 */
export async function getAccessToken(): Promise<string> {
  const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')!
  const privateKey  = Deno.env.get('FIREBASE_PRIVATE_KEY')!.replace(/\\n/g, '\n')
  const scope       = 'https://www.googleapis.com/auth/firebase.messaging'
  const now         = Math.floor(Date.now() / 1000)

  const header  = { alg: 'RS256', typ: 'JWT' }
  const payload = {
    iss: clientEmail,
    sub: clientEmail,
    aud: 'https://oauth2.googleapis.com/token',
    scope,
    iat: now,
    exp: now + 3600,
  }

  const signingInput = `${objToBase64Url(header)}.${objToBase64Url(payload)}`

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    pemToArrayBuffer(privateKey),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  )

  const jwt = `${signingInput}.${toBase64Url(signature)}`

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  })

  const json = await res.json()
  if (!json.access_token) throw new Error(`Failed to get access token: ${JSON.stringify(json)}`)
  return json.access_token
}

export interface FcmSendResult {
  token: string
  success: boolean
  error?: string
}

/**
 * Sends a single FCM push notification via the HTTP v1 API.
 * Throws on HTTP-level errors so callers can catch and deactivate bad tokens.
 */
export async function sendFcmMessage(
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  const res = await fetch(FCM_ENDPOINT, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title, body },
        data,
        android: {
          priority: 'high',
          notification: { sound: 'default', click_action: 'FLUTTER_NOTIFICATION_CLICK' },
        },
        apns: {
          payload: { aps: { sound: 'default', badge: 1 } },
        },
      },
    }),
  })

  if (!res.ok) {
    const err = await res.json()
    const msg = err?.error?.message ?? err?.error?.status ?? `HTTP ${res.status}`
    throw new Error(msg)
  }
}

/** Returns true if the FCM error indicates an invalid/expired token */
export function isInvalidTokenError(message: string): boolean {
  return (
    message.includes('INVALID_ARGUMENT') ||
    message.includes('UNREGISTERED') ||
    message.includes('invalid-registration-token') ||
    message.includes('registration-token-not-registered')
  )
}

/**
 * Sends push to all active tokens for a user.
 * Automatically deactivates stale tokens.
 * Returns summary counts.
 */
export async function pushToUser(
  supabase: any,
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<{ pushed: number; total: number }> {
  const { data: tokens } = await supabase
    .from('user_fcm_tokens')
    .select('fcm_token')
    .eq('user_id', userId)
    .eq('is_active', true)

  if (!tokens || tokens.length === 0) return { pushed: 0, total: 0 }

  const accessToken = await getAccessToken()
  let pushed = 0

  for (const row of tokens) {
    try {
      await sendFcmMessage(accessToken, row.fcm_token, title, body, data)
      pushed++
    } catch (err: any) {
      console.error(`FCM push to ${userId} failed:`, err.message)
      if (isInvalidTokenError(err.message)) {
        await supabase
          .from('user_fcm_tokens')
          .update({ is_active: false })
          .eq('fcm_token', row.fcm_token)
      }
    }
  }

  return { pushed, total: tokens.length }
}
