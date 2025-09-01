import Link from "next/link";

const artigos = [
  {
    slug: "artigo-exemplo",
    title: "Artigo Exemplo",
    autores: "Você",
    ano: 2025,
  },
];

export default function ArtigosPage() {
  return (
    <section className="space-y-4">
      <h1>Artigos Científicos</h1>
      <div className="grid gap-4">
        {artigos.map((a) => (
          <div key={a.slug} className="card">
            <h2 className="text-xl">{a.title}</h2>
            <p className="opacity-80">
              {a.autores} — {a.ano}
            </p>
            <Link href={`/artigos/${a.slug}`} className="underline">
              Ler online
            </Link>
          </div>
        ))}
      </div>
    </section>
  );
}
