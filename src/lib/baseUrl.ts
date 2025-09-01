export function getBaseUrl() {
  // Node/Server (Vercel)
  if (typeof window === "undefined") {
    const env = process.env.NEXT_PUBLIC_SITE_URL || process.env.VERCEL_URL;
    if (env) {
      const url = env.startsWith("http") ? env : `https://${env}`;
      return url.replace(/\/+$/, "");
    }
    return "http://localhost:3000";
  }
  // Browser
  return window.location.origin;
}
