import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import Footer from '../components/Footer';
import Header from '../components/Header';

const SECTION_KEYS = [
  'intro',
  'applicability',
  'prohibited',
  'suspension',
  'restriction',
  'change',
  'termsChange',
  'assignment',
  'disclaimer',
  'governingLaw',
];

export default function Terms() {
  const { t } = useTranslation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const appName = t('app.title');

  return (
    <div className="min-h-screen bg-white">
      <Header />
      <main className="pt-24 pb-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-8">{t('marketing.terms.title')}</h1>
          <div className="space-y-8 text-gray-600 leading-relaxed">
            {SECTION_KEYS.map(key => (
              <Section
                key={key}
                sectionData={t(`marketing.terms.sections.${key}`, { returnObjects: true, name: appName })}
              />
            ))}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}

function Section({ sectionData }) {
  if (!sectionData) return null;
  const { title, body, list, bodyAfter } = sectionData;

  return (
    <section>
      <h2 className="text-xl font-semibold text-gray-900 mb-3">{title}</h2>
      {body && <p className="mb-3 whitespace-pre-wrap">{body}</p>}
      {list && Array.isArray(list) && (
        <ul className="list-disc pl-5 mb-3 space-y-1">
          {list.map((item, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: Static list
            <li key={index}>{item}</li>
          ))}
        </ul>
      )}
      {bodyAfter && <p className="mt-3 whitespace-pre-wrap">{bodyAfter}</p>}
    </section>
  );
}
