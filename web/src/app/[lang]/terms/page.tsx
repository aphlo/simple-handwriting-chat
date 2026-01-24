'use client';

import { useEffect } from 'react';
import { useDictionary } from '@/components/DictionaryProvider';
import Footer from '@/components/Footer';
import Header from '@/components/Header';

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
] as const;

type SectionKey = (typeof SECTION_KEYS)[number];

interface SectionData {
  title: string;
  body?: string;
  list?: string[];
  bodyAfter?: string;
}

export default function TermsPage() {
  const { dict } = useDictionary();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const appName = dict.app.title;

  return (
    <div className="min-h-screen bg-white">
      <Header />
      <main className="pt-24 pb-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-8">{dict.marketing.terms.title}</h1>
          <div className="space-y-8 text-gray-600 leading-relaxed">
            {SECTION_KEYS.map(key => {
              const sectionData = dict.marketing.terms.sections[key as SectionKey] as SectionData;
              // Replace {name} placeholder with app name
              const processedData = {
                ...sectionData,
                body: sectionData.body?.replace('{name}', appName),
              };
              return <Section key={key} sectionData={processedData} />;
            })}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}

function Section({ sectionData }: { sectionData: SectionData }) {
  if (!sectionData) return null;
  const { title, body, list, bodyAfter } = sectionData;

  return (
    <section>
      <h2 className="text-xl font-semibold text-gray-900 mb-3">{title}</h2>
      {body && <p className="mb-3 whitespace-pre-wrap">{body}</p>}
      {list && Array.isArray(list) && (
        <ul className="list-disc pl-5 mb-3 space-y-1">
          {list.map((item, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: Static list that never reorders
            <li key={index}>{item}</li>
          ))}
        </ul>
      )}
      {bodyAfter && <p className="mt-3 whitespace-pre-wrap">{bodyAfter}</p>}
    </section>
  );
}
