export default function Page() {
  return (
    <main className="min-h-screen p-8 bg-gray-50 dark:bg-neutral-900">
      <div className="max-w-4xl mx-auto space-y-6">
        <h1 className="text-3xl font-bold text-center text-gray-900 dark:text-gray-100">
          Últimas do Instagram
        </h1>
        <p className="text-center text-gray-600 dark:text-gray-300">
          Bem-vindo ao site VR Abandonada. Use a busca para encontrar conteúdos por tema.
        </p>
        <div className="flex justify-center">
          <a
            href="/search"
            className="inline-block px-4 py-2 rounded-lg border shadow-sm hover:shadow transition"
          >
            Ir para a Busca
          </a>
        </div>
      </div>
    </main>
  )
}
