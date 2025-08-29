// src/app/instagram/page.tsx
import InstagramFeed from "@/components/InstagramFeed";

export const metadata = {
  title: "Instagram — preview",
};

export default function Page() {
  return (
    <main className="max-w-5xl mx-auto p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Instagram (preview)</h1>
      <p className="text-sm opacity-80">
        Esta página serve apenas para testar o componente. Em produção você
        pode importar <code>InstagramFeed</code> em qualquer lugar.
      </p>
      {/* Exibe 12 itens */}
      {/* @ts-expect-error Async Server Component */}
      <InstagramFeed limit={12} />
    </main>
  );
}
