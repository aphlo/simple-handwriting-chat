'use client';

import Link from 'next/link';
import { useDictionary } from './DictionaryProvider';

export default function Footer() {
  const { dict, lang } = useDictionary();
  const year = new Date().getFullYear();

  return (
    <footer className="bg-gray-50 border-t border-gray-100 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center">
        <div className="mb-4 md:mb-0">
          <span className="text-gray-500 text-sm">{dict.footer.copyright.replace('{{year}}', String(year))}</span>
        </div>
        <div className="flex space-x-6">
          <Link href={`/${lang}/terms`} className="text-gray-500 hover:text-primary-700 text-sm transition-colors">
            {dict.footer.terms}
          </Link>
          <Link href={`/${lang}/privacy`} className="text-gray-500 hover:text-primary-700 text-sm transition-colors">
            {dict.footer.privacy}
          </Link>
        </div>
      </div>
    </footer>
  );
}
