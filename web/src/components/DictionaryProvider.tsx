'use client';

import { createContext, type ReactNode, useContext } from 'react';
import type { Locale } from '@/i18n/config';
import type { Dictionary } from '@/i18n/dictionaries';

type DictionaryContextType = {
  dict: Dictionary;
  lang: Locale;
};

const DictionaryContext = createContext<DictionaryContextType | null>(null);

export function DictionaryProvider({
  children,
  dictionary,
  lang,
}: {
  children: ReactNode;
  dictionary: Dictionary;
  lang: Locale;
}) {
  return <DictionaryContext.Provider value={{ dict: dictionary, lang }}>{children}</DictionaryContext.Provider>;
}

export function useDictionary() {
  const context = useContext(DictionaryContext);
  if (!context) {
    throw new Error('useDictionary must be used within a DictionaryProvider');
  }
  return context;
}
