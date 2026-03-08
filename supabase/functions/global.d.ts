// TypeScript declaration file to suppress VS Code errors in Deno Edge Functions
// These functions run on Deno runtime, not Node.js
// The "errors" shown in VS Code are false positives

declare namespace Deno {
  export namespace env {
    export function get(key: string): string | undefined;
  }
}

declare module "https://deno.land/std@0.168.0/http/server.ts" {
  export function serve(handler: (req: Request) => Promise<Response> | Response): void;
}

declare module "https://esm.sh/@supabase/supabase-js@2" {
  export function createClient(url: string, key: string): any;
}

declare module "https://esm.sh/firebase-admin@12.0.0/app" {
  export function initializeApp(config: any): any;
  export function cert(config: any): any;
  export function getApps(): any[];
}

declare module "https://esm.sh/firebase-admin@12.0.0/messaging" {
  export function getMessaging(): any;
}
