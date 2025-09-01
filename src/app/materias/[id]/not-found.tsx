export default function NotFound() {
  return (
    <main className="mx-auto max-w-2xl px-4 py-16 text-center">
      <h1 className="text-2xl font-bold">Matéria não encontrada</h1>
      <p className="mt-2 text-neutral-500">
        Talvez o post tenha sido removido ou o link está incorreto.
      </p>
      <a href="/instagram" className="mt-6 inline-block underline">
        Voltar para o feed
      </a>
    </main>
  );
}