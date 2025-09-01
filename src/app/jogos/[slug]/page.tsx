type Props = { params: { slug: string } };

export default function JogoPage({ params }: Props) {
  const { slug } = params;
  return (
    <section className="space-y-4">
      <h1>Jogo: {slug}</h1>
      <div className="card">
        <div className="relative w-full aspect-video">
          <iframe
            src={`/games/${slug}/index.html`}
            className="w-full h-[70vh] rounded-xl"
            allowFullScreen
          />
        </div>
        <p className="mt-2 text-sm opacity-80">
          Dica: use o botão de tela cheia do jogo ou do navegador.
        </p>
      </div>
    </section>
  );
}
