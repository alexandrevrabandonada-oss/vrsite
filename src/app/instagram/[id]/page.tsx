import { getIgItemById } from '@/lib/ig-data'
export const dynamic = 'force-dynamic'

function toBool(v:any){ return v===true || v==='1' || (Array.isArray(v) && v[0]==='1') }

export default async function InstagramDetailSafe({ params, searchParams }: any) {
  const id = String(params?.id || '')
  const debug = toBool(searchParams?.debug)
  let item:any = null
  let caught:any = null

  try {
    item = await getIgItemById(id)
  } catch (e:any) {
    caught = { message: String(e?.message || e), stack: String(e?.stack || '') }
  }

  if (!item && !debug) {
    // em modo "não debug", apenas um texto simples para não quebrar
    return <main style={{padding:'24px'}}><a href="/" style={{opacity:.7}}>&larr; Voltar</a><h1>Post não encontrado</h1><p>ID: <code>{id}</code></p></main>
  }

  return (
    <main style={{padding:'24px'}}>
      <a href="/" style={{opacity:.7}}>&larr; Voltar</a>
      <h1 style={{margin:'12px 0'}}>Instagram Detail (safe)</h1>
      {debug ? (
        <pre style={{background:'#111',color:'#fff',padding:'12px',borderRadius:'8px',overflow:'auto'}}>
{JSON.stringify({ id, item, error: caught }, null, 2)}
        </pre>
      ) : null}
      {item ? (
        <section style={{marginTop:'12px'}}>
          <img src={item.media_url || '/og-default.png'} alt="post" style={{maxWidth:'100%',border:'1px solid #ddd',borderRadius:'8px'}} onError={(e:any)=>{ e.currentTarget.src='/og-default.png' }}/>
          <p style={{marginTop:'8px',whiteSpace:'pre-wrap'}}>{item.caption || ''}</p>
          {item.permalink ? <p style={{marginTop:'8px'}}><a href={item.permalink} target="_blank" rel="noreferrer">Ver no Instagram</a></p> : null}
        </section>
      ) : null}
    </main>
  )
}
