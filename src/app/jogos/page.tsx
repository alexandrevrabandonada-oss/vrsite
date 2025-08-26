import Link from 'next/link'

const jogos = [
  { slug: 'exemplo', title: 'Jogo Exemplo (HTML5/Pygame via pygbag)', desc: 'Demonstração' },
]

export default function JogosPage() {
  return (
    <section className="space-y-4">
      <h1>Jogos</h1>
      <div className="grid sm:grid-cols-2 gap-4">
        {jogos.map(j => (
          <div key={j.slug} className="card">
            <h2 className="text-xl">{j.title}</h2>
            <p className="opacity-80">{j.desc}</p>
            <Link href={`/jogos/${j.slug}`} className="inline-block mt-2 underline">Abrir</Link>
          </div>
        ))}
      </div>
    </section>
  )
}
