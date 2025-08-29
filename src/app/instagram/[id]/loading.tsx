export default function LoadingPost() {
  return (
    <main className="container mx-auto max-w-3xl p-6">
      <div className="h-64 animate-pulse rounded-xl bg-neutral-200 dark:bg-neutral-800" />
      <div className="mt-4 h-4 w-3/4 animate-pulse rounded bg-neutral-200 dark:bg-neutral-800" />
      <div className="mt-2 h-4 w-1/2 animate-pulse rounded bg-neutral-200 dark:bg-neutral-800" />
    </main>
  );
}
