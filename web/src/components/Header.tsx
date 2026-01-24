'use client';

import { Globe } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useDictionary } from './DictionaryProvider';

export default function Header() {
  const { dict, lang } = useDictionary();
  const pathname = usePathname();

  const toggleLanguage = () => {
    const newLang = lang === 'en' ? 'ja' : 'en';
    const newPath = pathname.replace(`/${lang}`, `/${newLang}`);
    window.location.href = newPath;
  };

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex-shrink-0 flex items-center">
            <Link href={`/${lang}`} className="text-2xl font-bold text-gray-900 font-handwriting">
              {dict.app.title}
            </Link>
          </div>
          <div className="hidden md:flex items-center space-x-8">
            <Link href={`/${lang}/terms`} className="text-gray-600 hover:text-primary-700 transition-colors">
              {dict.footer.terms}
            </Link>
            <Link href={`/${lang}/privacy`} className="text-gray-600 hover:text-primary-700 transition-colors">
              {dict.footer.privacy}
            </Link>
            <button
              type="button"
              onClick={toggleLanguage}
              className="flex items-center space-x-1 text-gray-600 hover:text-primary-700 transition-colors"
            >
              <Globe className="w-5 h-5" />
              <span className="text-sm font-medium">{lang.toUpperCase()}</span>
            </button>
          </div>
          <div className="md:hidden flex items-center">
            <button
              type="button"
              onClick={toggleLanguage}
              className="p-2 rounded-md text-gray-600 hover:text-primary-700"
            >
              <Globe className="w-6 h-6" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
