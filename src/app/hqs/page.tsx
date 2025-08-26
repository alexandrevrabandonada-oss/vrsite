import Link from 'next/link'

const series = [
  { id: 'serie-exemplo', title: 'Série Exemplo', caps: [{ id: 'cap-1', pages: 3 }] }
]

export default function HQsPage() {
  return (
    <section className="space-y-4">
      <h1>HQs / Mangás</h1>
      <div className="grid sm:grid-cols-2 gap-4">
        {series.map(s => (
          <div key={s.id} className="card">
            <h2 className="text-xl">{s.title}</h2>
            <ul className="list-disc ml-6">
              {s.caps.map(c => (
                <li key={c.id}>
                  <Link href={`/hqs/${s.id}/${c.id}`}>Capítulo {c.id.replace('cap-','')}</Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
    </section>
  )
}
