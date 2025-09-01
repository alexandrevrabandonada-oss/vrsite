import InstagramFeed from '@/components/InstagramFeed';

export const metadata = {
  title: 'Instagram (preview) • VR Abandonada',
  description: 'Prévia do feed do Instagram renderizada no site.',
};

export default async function Page() {
  return (
    <main className="max-w-6xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-2">Instagram (preview)</h1>
      <p className="text-sm text-neutral-600 mb-6">
        Esta página serve apenas para testar o componente. Em produção você pode importar <code>InstagramFeed</code> em qualquer lugar.
      </p>
      <InstagramFeed limit={9} />
    </main>
  );
}
