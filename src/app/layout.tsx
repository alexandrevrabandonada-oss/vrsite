import type { Metadata } from "next";
import "./globals.css";
import InstagramFeed from "@/components/InstagramFeed";
export const metadata: Metadata = {
  title: "VR Abandonada",
  description: "Site oficial do projeto VR Abandonada com feed do Instagram.",
};import AppHeader from '@/components/AppHeader'\n{
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      {" "}
      <body>
      <AppHeader />
        {" "}
        <header className="border-b sticky top-0 bg-white/70 dark:bg-neutral-950/70 backdrop-blur z-50">
          {" "}
          <nav className="max-w-4xl mx-auto flex gap-6 p-4 text-sm">
            {" "}
            <a href="/" className="hover:underline">
              Início
            </a>{" "}
            <a href="/instagram" className="hover:underline">
              Instagram
            </a>{" "}
          </nav>{" "}
        </header>{" "}
        <main className="max-w-4xl mx-auto p-4">{children}</main>{" "}
        <footer className="border-t mt-10 py-6 text-center text-sm text-neutral-500">
          {" "}
          © {new Date().getFullYear()} VR Abandonada. Todos os direitos
          reservados.{" "}
        </footer>{" "}
      </body>{" "}
    </html>
  );
}
