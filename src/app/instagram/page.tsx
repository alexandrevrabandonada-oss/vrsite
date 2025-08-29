// srimport Iimport InstagramFeed from "@/components/InstagramFeed";

export default function InstagramPage() {
  return (
    <main className="container mx-auto px-4 py-10 space-y-6">
      <h1 className="text-3xl font-semibold">Instagram (preview)</h1>
      <p className="text-muted-foreground">
        Esta página serve apenas para testar o componente. Em produção você pode
        importar <code>InstagramFeed</code> em qualquer lugar.
      </p>

      {/* Exibe 12 itens */}
      <InstagramFeed limit={12} />
    </main>
  );
}
