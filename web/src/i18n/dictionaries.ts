import en from '../locales/en.json';
import ja from '../locales/ja.json';
import type { Locale } from './config';

const dictionaries = {
  en,
  ja,
} as const;

export type Dictionary = typeof en;

export function getDictionary(locale: Locale): Dictionary {
  return dictionaries[locale];
}
