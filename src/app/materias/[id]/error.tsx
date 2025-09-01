"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main className="mx-auto max-w-2xl px-4 py-16 text-center">
      <h1 className="text-2xl font-bold">Erro ao carregar a matéria</h1>
      <p className="mt-2 text-neutral-500">
        {error?.message ? `Detalhe: ${error.message}` : "Tente novamente."}
      </p>
      <button
        onClick={() => reset()}
        className="mt-6 rounded-lg border px-4 py-2 hover:bg-neutral-50 dark:hover:bg-neutral-900"
      >
        Tentar novamente
      </button>
    </main>
  );
}
