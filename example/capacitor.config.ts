import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.audiodrm',
  appName: 'example',
  webDir: 'dist/example',
  server: {
    androidScheme: 'https'
  }
};

export default config;
