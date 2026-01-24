import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { DictionaryProvider } from '@/components/DictionaryProvider';
import { isValidLocale, type Locale, locales } from '@/i18n/config';
import { getDictionary } from '@/i18n/dictionaries';

type Props = {
  children: React.ReactNode;
  params: Promise<{ lang: string }>;
};

export async function generateStaticParams() {
  return locales.map(lang => ({ lang }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { lang } = await params;
  if (!isValidLocale(lang)) return {};

  const dict = getDictionary(lang);
  return {
    title: dict.app.title,
    description: dict.app.subtitle,
  };
}

export default async function LangLayout({ children, params }: Props) {
  const { lang } = await params;

  if (!isValidLocale(lang)) {
    notFound();
  }

  const dict = getDictionary(lang as Locale);

  return (
    <html lang={lang}>
      <body>
        <DictionaryProvider dictionary={dict} lang={lang as Locale}>
          {children}
        </DictionaryProvider>
      </body>
    </html>
  );
}
