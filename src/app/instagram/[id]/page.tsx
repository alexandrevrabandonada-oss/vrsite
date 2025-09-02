'use client'
import * as React from 'react'

function useQueryParam(name: string) {
  if (typeof window === 'undefined') return null
  const url = new URL(window.location.href)
  return url.searchParams.get(name)
}

type IgItem = {
  id: string
  media_url?: string
  permalink?: string
  caption?: string
  timestamp?: string
}

export default function InstagramClientDetail({ params }: any) {
  const id = String(params?.id || '')
  const debug = typeof window !== 'undefined' ? (new URL(window.location.href).searchParams.get('debug') === '1') : false
  const [state, setState] = React.useState<{loading:boolean, error:string|null, item:IgItem|null}>({
    loading: true, error: null, item: null
  })

  React.useEffect(() => {
    let cancelled = false
    const run = async () => {
      try {
        const res = await fetch(`/api/ig?id=${encodeURIComponent(id)}${debug ? '&debug=1&_dump=1' : ''}`, { cache: 'no-store' })
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const data = await res.json()
        const item: IgItem = data?.item || null
        if (!cancelled) setState({ loading: false, error: null, item })
      } catch (e:any) {
        if (!cancelled) setState({ loading: false, error: e?.message || String(e), item: null })
      }
    }
    run()
    return () => { cancelled = true }
  }, [id, debug])

  return (
    <main style={{padding:'24px'}}>
      <a href="/" style={{opacity:.7}}>&larr; Voltar</a>
      <h1 style={{margin:'12px 0'}}>Post do Instagram</h1>

      {state.loading && <p>Carregandoâ€¦</p>}
      {state.error && (
        <pre style={{background:'#111',color:'#fff',padding:'12px',borderRadius:'8px',overflow:'auto'}}>
{`Erro: ${state.error}\nID: ${id}`}
        </pre>
      )}

      {debug && !state.loading && (
        <details open style={{margin:'12px 0'}}>
          <summary>Debug</summary>
          <pre style={{background:'#111',color:'#fff',padding:'12px',borderRadius:'8px',overflow:'auto'}}>
{JSON.stringify({ id, item: state.item }, null, 2)}
          </pre>
        </details>
      )}

      {state.item && (
        <section style={{marginTop:'12px'}}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={state.item.media_url || '/og-default.png'}
            alt="post"
            onError={(e:any)=>{ e.currentTarget.src='/og-default.png' }}
            style={{maxWidth:'100%',border:'1px solid #ddd',borderRadius:'8px'}}
          />
          <p style={{marginTop:'8px',whiteSpace:'pre-wrap'}}>{state.item.caption || ''}</p>
          {state.item.permalink ? <p style={{marginTop:'8px'}}><a href={state.item.permalink} target="_blank" rel="noreferrer">Ver no Instagram</a></p> : null}
        </section>
      )}
    </main>
  )
}

