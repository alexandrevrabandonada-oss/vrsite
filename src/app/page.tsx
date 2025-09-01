﻿import HomeSearchBar from '@/components/HomeSearchBar'
import InstagramFeed from "@/components/InstagramFeed";

export default function Page() {
  return (
    <HomeSearchBar />
<main className="min-h-screen p-8 bg-gray-50 dark:bg-neutral-900">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-6 text-center text-gray-900 dark:text-gray-100">
          Ãšltimas do Instagram
        </h1>
        <InstagramFeed />
      </div>
    </main>
  );
}

export {};
