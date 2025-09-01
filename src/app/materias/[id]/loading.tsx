export default function Loading() {
  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <div className="animate-pulse space-y-4">
        <div className="h-8 w-2/3 rounded bg-neutral-200 dark:bg-neutral-800" />
        <div className="h-4 w-1/2 rounded bg-neutral-200 dark:bg-neutral-800" />
        <div className="h-[320px] w-full rounded bg-neutral-200 dark:bg-neutral-800" />
        <div className="h-4 w-full rounded bg-neutral-200 dark:bg-neutral-800" />
        <div className="h-4 w-5/6 rounded bg-neutral-200 dark:bg-neutral-800" />
      </div>
    </main>
  );
}