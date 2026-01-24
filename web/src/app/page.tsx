'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function RootPage() {
  const router = useRouter();

  useEffect(() => {
    const userLang = navigator.language;
    const targetLang = userLang.startsWith('ja') ? 'ja' : 'en';
    router.replace(`/${targetLang}`);
  }, [router]);

  return (
    <html lang="en">
      <body>
        <div className="min-h-screen flex items-center justify-center">
          <div className="animate-pulse text-gray-500">Loading...</div>
        </div>
      </body>
    </html>
  );
}
