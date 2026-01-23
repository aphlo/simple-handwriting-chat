import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function LanguageRedirect() {
  const navigate = useNavigate();

  useEffect(() => {
    const userLang = navigator.language;
    const targetLang = userLang.startsWith('ja') ? 'ja' : 'en';
    navigate(`/${targetLang}`, { replace: true });
  }, [navigate]);

  return null;
}
