// src/app/layout.tsx
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Volta Redonda",
  description: "Site com posts do Instagram, jogos, HQs e artigos.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      <body>
        <header className="border-b sticky top-0 bg-white/70 dark:bg-neutral-950/70 backdrop-blur z-50">
          <nav className="max-w-6xl mx-auto px-4 py-3 flex items-center gap-6">
            <a href="/" className="font-semibold">Volta Redonda</a>
            <a href="/instagram" className="hover:underline">Instagram</a>
            <a href="/jogos" className="hover:underline">Jogos</a>
            <a href="/hqs" className="hover:underline">HQs</a>
            <a href="/artigos" className="hover:underline">Artigos</a>
          </nav>
        </header>
        <main className="min-h-screen">{children}</main>
      </body>
    </html>
  );
}
