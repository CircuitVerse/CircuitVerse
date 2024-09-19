/// <reference types="vitest" />
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'url'
import vueI18n from '@intlify/vite-plugin-vue-i18n'

// https://github.com/vuetifyjs/vuetify-loader/tree/next/packages/vite-plugin
import vuetify from 'vite-plugin-vuetify'

const proxyUrl: string = 'http://localhost:3000'

// https://vitejs.dev/config/
export default defineConfig(() => ({
    plugins: [
        vue(),
        vuetify({ autoImport: true }),
        vueI18n({
            // if you want to use Vue I18n Legacy API, you need to set `compositionOnly: false`
            // compositionOnly: false,

            // you need to set i18n resource including paths !
            include: fileURLToPath(
                new URL('./src/locales/**', import.meta.url)
            ),
        }),
    ],
    resolve: {
        alias: {
            '#': fileURLToPath(new URL('./src', import.meta.url)),
            '@': fileURLToPath(new URL('./src/components', import.meta.url)),
        },
    },
    base: process.env.VITE_BASE_URL,
    build: {
        outDir: './public/output',
        assetsDir: 'assets',
        chunkSizeWarningLimit: 2000,
        rollupOptions: {
            output: {
                manualChunks(id) {
                    if (id.includes('node_modules')) {
                        return id.toString().split('node_modules/')[1].split('/')[0].toString();
                    }
                }
            }
        }
    },
    test:{
        globals: true,
        environment: 'jsdom',
        server: {
            deps: {
                inline: ['vuetify'],
            },
        },
        setupFiles: './src/simulator/spec/vitestSetup.ts',
    },
    server: {
        port: 4000,
        proxy: {
            // ...(process.env.NODE_ENV === 'development' && {
            '^/(?!(simulatorvue)).*': {
                target: proxyUrl,
                changeOrigin: true,
                headers: {
                    origin: proxyUrl,
                },
            },
            // }),
        },
        host: true
    },
}))