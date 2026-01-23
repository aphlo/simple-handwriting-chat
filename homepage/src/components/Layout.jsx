import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Outlet, useNavigate, useParams } from 'react-router-dom';

export default function Layout() {
  const { lang } = useParams();
  const { i18n, t } = useTranslation();
  const navigate = useNavigate();

  useEffect(() => {
    const validLangs = ['en', 'ja'];
    if (lang && validLangs.includes(lang)) {
      if (i18n.language !== lang) {
        i18n.changeLanguage(lang);
      }
    } else {
      // If invalid lang or no lang (though routing should catch no lang), redirect to default (en)
      navigate('/en', { replace: true });
    }
  }, [lang, i18n, navigate]);

  useEffect(() => {
    document.title = t('app.title');
    const metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription) {
      metaDescription.setAttribute('content', t('app.subtitle'));
    }
  }, [t]);

  return <Outlet />;
}
