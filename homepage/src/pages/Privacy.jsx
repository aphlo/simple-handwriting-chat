import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import Footer from '../components/Footer';
import Header from '../components/Header';

export default function Privacy() {
  const { t } = useTranslation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <div className="min-h-screen bg-white">
      <Header />
      <main className="pt-24 pb-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-8">{t('privacy.title')}</h1>
          <div className="prose prose-teal max-w-none text-gray-600 whitespace-pre-wrap">{t('privacy.content')}</div>
        </div>
      </main>
      <Footer />
    </div>
  );
}
