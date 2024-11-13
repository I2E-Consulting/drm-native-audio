import { registerPlugin } from '@capacitor/core';

import type { AudioDRMPlugin } from './definitions';

const AudioDRM = registerPlugin<AudioDRMPlugin>('AudioDRM', {
  web: () => import('./web').then(m => new m.AudioDRMWeb()),
});

export * from './definitions';
export { AudioDRM };
