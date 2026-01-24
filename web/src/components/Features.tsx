'use client';

import { PenTool, Share2, ShieldCheck } from 'lucide-react';
import { useDictionary } from './DictionaryProvider';

export default function Features() {
  const { dict } = useDictionary();

  const features = [
    {
      name: dict.features.mirror.title,
      description: dict.features.mirror.desc,
      icon: Share2,
    },
    {
      name: dict.features.simple.title,
      description: dict.features.simple.desc,
      icon: PenTool,
    },
    {
      name: dict.features.private.title,
      description: dict.features.private.desc,
      icon: ShieldCheck,
    },
  ];

  return (
    <div className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 gap-12 lg:grid-cols-3 lg:gap-8">
          {features.map(feature => (
            <div key={feature.name} className="flex flex-col items-center text-center">
              <div className="flex items-center justify-center h-16 w-16 rounded-full bg-primary-100 text-primary-600 mb-6">
                <feature.icon className="h-8 w-8" aria-hidden="true" />
              </div>
              <h3 className="text-xl font-medium text-gray-900 mb-2 font-handwriting text-2xl">{feature.name}</h3>
              <p className="mt-2 text-base text-gray-500 max-w-xs mx-auto">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
