import '@/index.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Simple Handwriting Chat',
  description: 'Chat with handwritten messages. Simple, personal, and fun.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return children;
}
