import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  const m = pathname.match(/^\/(post|posts|materias)\/([^\/]+)\/?$/i)
  if (m) {
    const id = m[2]
    const url = req.nextUrl.clone()
    url.pathname = `/instagram/${id}`
    return NextResponse.rewrite(url)
  }
  return NextResponse.next()
}

// opcional: definir em quais rotas roda (global por padrão)
export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
