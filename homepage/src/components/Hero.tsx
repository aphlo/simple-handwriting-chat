import { useTranslation } from 'react-i18next';

export default function Hero() {
  const { t } = useTranslation();

  return (
    <section className="pt-32 pb-16 md:pt-48 md:pb-32 bg-gradient-to-br from-primary-50 to-white overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="lg:grid lg:grid-cols-12 lg:gap-8 items-center">
          <div className="sm:text-center md:max-w-2xl md:mx-auto lg:col-span-6 lg:text-left">
            <h1 className="text-4xl tracking-tight font-extrabold text-gray-900 sm:text-5xl md:text-6xl lg:text-5xl xl:text-6xl">
              <span className="block xl:inline">{t('app.title')}</span>
            </h1>
            <p className="mt-3 text-base text-gray-500 sm:mt-5 sm:text-lg sm:max-w-xl sm:mx-auto md:mt-5 md:text-xl lg:mx-0 font-handwriting text-primary-700">
              {t('app.subtitle')}
            </p>
            <div className="mt-8 sm:max-w-lg sm:mx-auto sm:text-center lg:text-left lg:mx-0 flex flex-row flex-wrap gap-4">
              <a href="#" className="inline-block transition-transform hover:scale-105">
                <img
                  src="/Download_on_the_App_Store_Badge_JP_RGB_blk_100317.svg"
                  alt="Download on the App Store"
                  className="h-12 w-auto"
                />
              </a>
              <a href="#" className="inline-block transition-transform hover:scale-105">
                <img
                  src="/GetItOnGooglePlay_Badge_Web_color_Japanese.svg"
                  alt="Get it on Google Play"
                  className="h-12 w-auto"
                />
              </a>
            </div>
          </div>
          <div className="mt-12 relative sm:max-w-lg sm:mx-auto lg:mt-0 lg:max-w-none lg:mx-0 lg:col-span-6 lg:flex lg:items-center">
            <div className="relative mx-auto w-full rounded-lg shadow-lg lg:max-w-md">
              {/* Placeholder for App Screenshot */}
              <div className="relative block w-full bg-white rounded-lg overflow-hidden focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 aspect-[9/16] border-8 border-gray-800 shadow-2xl flex items-center justify-center bg-gray-100">
                <span className="text-gray-400 font-handwriting text-2xl">App Screenshot</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
