import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const resources = {
  en: {
    translation: {
      app: {
        title: 'Simple Handwriting Chat',
        subtitle: 'Chat with handwritten messages. Simple, personal, and fun.',
        download: 'Download Now',
      },
      features: {
        mirror: {
          title: 'Mirror Drawing',
          desc: 'Draw to your friend like a mirror. Face-to-face creativity.',
        },
        simple: {
          title: 'Simple Design',
          desc: 'No clutter. Just you and your handwriting.',
        },
        private: {
          title: 'Private & Secure',
          desc: 'Messages are encrypted and ephemeral.',
        },
      },
      footer: {
        terms: 'Terms of Service',
        privacy: 'Privacy Policy',
        copyright: '© {{year}} Simple Handwriting Chat. All rights reserved.',
      },
      terms: {
        title: 'Terms of Service',
        content: 'Welcome to Simple Handwriting Chat. By using our app, you agree to these terms...',
      },
      privacy: {
        title: 'Privacy Policy',
        content: 'Your privacy is important to us. We collect minimal data...',
      },
    },
  },
  ja: {
    translation: {
      app: {
        title: 'シンプル手書きチャット',
        subtitle: '手描きのメッセージで会話しよう。シンプルで、パーソナルで、楽しい。',
        download: '今すぐダウンロード',
      },
      features: {
        mirror: {
          title: 'ミラー描画',
          desc: '鏡のように相手に向かって描こう。対面のような創造性。',
        },
        simple: {
          title: 'シンプルデザイン',
          desc: '余計なものはありません。あなたと手書き文字だけ。',
        },
        private: {
          title: 'プライベート＆セキュア',
          desc: 'メッセージは暗号化され、一時的です。',
        },
      },
      footer: {
        terms: '利用規約',
        privacy: 'プライバシーポリシー',
        copyright: '© {{year}} Simple Handwriting Chat. All rights reserved.',
      },
      terms: {
        title: '利用規約',
        content: 'シンプル手書きチャットへようこそ。アプリを使用することで、以下の規約に同意したものとみなされます...',
      },
      privacy: {
        title: 'プライバシーポリシー',
        content: '私たちはあなたのプライバシーを尊重します。最小限のデータのみを収集します...',
      },
    },
  },
};

i18n.use(initReactI18next).init({
  resources,
  lng: 'en',
  fallbackLng: 'en',
  interpolation: {
    escapeValue: false,
  },
});

export default i18n;
