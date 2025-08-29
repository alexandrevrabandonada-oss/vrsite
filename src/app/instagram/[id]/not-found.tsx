import Link from 'next/link';

export default function NotFoundPost() {
  return (
    <main className="container mx-auto max-w-3xl p-6">
      <h1 className="text-xl font-semibold">Post não encontrado</h1>
      <p className="mt-2 text-neutral-600 dark:text-neutral-300">
        O conteúdo pode ter sido removido ou o link está incorreto.
      </p>
      <Link href="/instagram" className="mt-4 inline-block text-blue-600 hover:underline">
        ← Voltar ao feed
      </Link>
    </main>
  );
}
