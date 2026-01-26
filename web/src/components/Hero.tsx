'use client';

import Image from 'next/image';
import { useDictionary } from './DictionaryProvider';

export default function Hero() {
  const { dict, lang } = useDictionary();
  const badgeLang = lang === 'ja' ? 'ja' : 'en';

  return (
    <section className="pt-32 pb-16 md:pt-48 md:pb-32 bg-gradient-to-br from-primary-50 to-white overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="lg:grid lg:grid-cols-12 lg:gap-8 items-center">
          <div className="sm:text-center md:max-w-2xl md:mx-auto lg:col-span-6 lg:text-left">
            <h1 className="text-4xl tracking-tight font-extrabold text-gray-900 sm:text-5xl md:text-6xl lg:text-5xl xl:text-6xl">
              <span className="block xl:inline">{dict.app.title}</span>
            </h1>
            <p className="mt-3 text-base text-gray-500 sm:mt-5 sm:text-lg sm:max-w-xl sm:mx-auto md:mt-5 md:text-xl lg:mx-0 font-handwriting text-primary-700">
              {dict.app.subtitle}
            </p>
            <div className="mt-8 sm:max-w-lg sm:mx-auto sm:text-center lg:text-left lg:mx-0 flex flex-row flex-wrap gap-4">
              <a
                href="https://apps.apple.com/us/app/simple-handwriting-chat/id6758146611"
                className="inline-block transition-transform hover:scale-105"
              >
                <Image src={`/apple/${badgeLang}.svg`} alt={dict.hero.appStoreAlt} width={135} height={48} />
              </a>
              <a
                href="https://play.google.com/store/apps/details?id=com.aphlo.simplehandwritingchat"
                className="inline-block transition-transform hover:scale-105"
              >
                <Image src={`/google/${badgeLang}.svg`} alt={dict.hero.googlePlayAlt} width={162} height={48} />
              </a>
            </div>
          </div>
          <div className="mt-12 relative sm:max-w-lg sm:mx-auto lg:mt-0 lg:max-w-none lg:mx-0 lg:col-span-6 lg:flex lg:items-center">
            <div className="relative mx-auto w-full lg:max-w-md">
              <Image
                src="/screen_shot.png"
                alt="App Screenshot"
                width={400}
                height={800}
                className="w-full h-auto rounded-3xl shadow-2xl"
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
