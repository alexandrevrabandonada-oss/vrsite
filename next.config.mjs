// @ts-check

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      // Instagram CDNs (images & thumbnails)
      { protocol: 'https', hostname: 'scontent.cdninstagram.com' },
      { protocol: 'https', hostname: '*.cdninstagram.com' },
      { protocol: 'https', hostname: 'scontent-*.cdninstagram.com' },
      { protocol: 'https', hostname: 'scontent-*.xx.fbcdn.net' },
      // Instagram fallbacks (rare cases)
      { protocol: 'https', hostname: 'instagram.*' },
      { protocol: 'https', hostname: '*.fbcdn.net' },
    ],
    formats: ['image/avif', 'image/webp'],
  },
};

export default nextConfig;
