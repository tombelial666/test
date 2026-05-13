import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';
import dts from 'vite-plugin-dts';
import * as path from 'path';

export default defineConfig({
  plugins: [
    solidPlugin(),
    dts({
      entryRoot: 'src',
      outDir: 'dist',
      include: ['src/entry-lib.ts'],
      rollupTypes: false,
      copyDtsFiles: false,
    }),
  ],
  build: {
    target: 'modules',
    lib: {
      entry: path.resolve(__dirname, 'src/index.tsx'),
      name: 'account-documents',
      fileName: (format) => `account-documents.${format}.js`,

    },
    minify: true
  },
  server: {
    port: 4200,
    host: true,
  },
  resolve: {
    alias: {
      'app': path.resolve('./src/'),
    }
  },
});
