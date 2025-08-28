import './globals.css'
import type { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Volta Redonda — Site',
  description: 'Início (Instagram), Jogos, HQs, Artigos',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body>
        <header className="border-b sticky top-0 bg-white/70 dark:bg-neutral-950/70 backdrop-blur z-50">
          <nav <a href="/instagram" className="hover:underline">Instagram</a>
            <Link href="/" className="font-bold no-underline">VR</Link>
            <ul className="flex gap-4 text-sm">
              <li><Link href="/jogos" className="no-underline">Jogos</Link></li>
              <li><Link href="/hqs" className="no-underline">HQs</Link></li>
              <li><Link href="/artigos" className="no-underline">Artigos</Link></li>
            </ul>
          </nav>
        </header>
        <main className="container py-6">
          {children}
        </main>
        <footer className="border-t mt-12">
          <div className="container py-6 text-sm opacity-70">
            © {(new Date()).getFullYear()} • Volta Redonda — feito com Next.js
          </div>
        </footer>
      </body>
    </html>
  )
}
