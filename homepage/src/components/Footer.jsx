import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

export default function Footer() {
  const { t } = useTranslation();
  const year = new Date().getFullYear();

  return (
    <footer className="bg-gray-50 border-t border-gray-100 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center">
        <div className="mb-4 md:mb-0">
          <span className="text-gray-500 text-sm">{t('footer.copyright', { year })}</span>
        </div>
        <div className="flex space-x-6">
          <Link to="/terms" className="text-gray-500 hover:text-primary-700 text-sm transition-colors">
            {t('footer.terms')}
          </Link>
          <Link to="/privacy" className="text-gray-500 hover:text-primary-700 text-sm transition-colors">
            {t('footer.privacy')}
          </Link>
        </div>
      </div>
    </footer>
  );
}
