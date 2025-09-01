export function getBaseUrl() {
  if (typeof window !== "undefined") return window.location.origin;

  const vercelUrl =
    process.env.NEXT_PUBLIC_SITE_URL ||
    process.env.VERCEL_URL ||
    process.env.NEXT_PUBLIC_VERCEL_URL;

  if (vercelUrl) {
    if (/^https?:\/\//i.test(vercelUrl)) return vercelUrl;
    return `https://${vercelUrl}`;
  }
  return "http://localhost:3000";
}
