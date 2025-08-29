import { Metadata } from 'next';

type Props = {
  params: { id: string };
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const id = params.id;
  const apiUrl = `${process.env.NEXT_PUBLIC_SITE_URL || ''}/api/instagram?t=${process.env.IG_LONG_LIVED_TOKEN}&id=${process.env.IG_USER_ID}`;

  try {
    const res = await fetch(apiUrl);
    const data = await res.json();
    const item = data.data.find((i: any) => i.id === id);
    if (item) {
      return {
        title: item.caption || 'Post do Instagram',
        description: item.caption || 'Veja este post no Instagram',
        openGraph: {
          images: [item.media_url],
        },
      };
    }
  } catch (e) {
    console.error(e);
  }

  return { title: 'Instagram Post' };
}

export default async function InstagramPostPage({ params }: Props) {
  const id = params.id;
  const apiUrl = `${process.env.NEXT_PUBLIC_SITE_URL || ''}/api/instagram?t=${process.env.IG_LONG_LIVED_TOKEN}&id=${process.env.IG_USER_ID}`;
  const res = await fetch(apiUrl, { cache: 'no-store' });
  const data = await res.json();
  const item = data.data.find((i: any) => i.id === id);

  if (!item) {
    return <div>Post não encontrado.</div>;
  }

  return (
    <main className="max-w-2xl mx-auto p-4">
      <h1 className="text-xl font-bold mb-4">{item.caption || 'Post do Instagram'}</h1>
      <img src={item.media_url} alt={item.caption || 'Post'} className="rounded-lg" />
      <p className="mt-2 text-gray-600">{item.timestamp}</p>
      <a href={item.permalink} target="_blank" rel="noopener noreferrer" className="text-blue-500 underline">
        Ver no Instagram
      </a>
    </main>
  );
}
