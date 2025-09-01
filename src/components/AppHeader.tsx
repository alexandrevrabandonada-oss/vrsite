export default function AppHeader() {
  return (
    <header className="w-full border-b bg-white/80 backdrop-blur">
      <div className="max-w-5xl mx-auto px-4 py-3 flex items-center justify-between">
        <a href="/" className="font-semibold">VR Abandonada</a>
        <nav className="flex items-center gap-4 text-sm">
          <a href="/search" className="hover:underline">Pesquisar</a>
        </nav>
      </div>
    </header>
  )
}
