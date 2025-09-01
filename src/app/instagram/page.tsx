import InstagramFeed from "@/components/InstagramFeed";

export const metadata = {
  title: "Instagram (preview) • VR Abandonada",
  description: "Pré-visualização do feed do Instagram no site.",
};

export default function Page() {
  return (
    <main className="container space-y-6">
      <h1>Instagram (preview)</h1>
      <p>
        Esta página serve apenas para testar o componente. Em produção você pode
        importar <code>InstagramFeed</code> em qualquer lugar.
      </p>
      <InstagramFeed limit={9} />
    </main>
  );
}
