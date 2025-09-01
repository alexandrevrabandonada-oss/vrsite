import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'VR Abandonada',
  description: 'Site oficial do projeto VR Abandonada com feed do Instagram e busca.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  )
}
