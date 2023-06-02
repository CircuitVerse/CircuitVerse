import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import  viteEnvCompatible  from 'vite-plugin-env-compatible';

export default defineConfig({
  plugins: [
    RubyPlugin(),
    viteEnvCompatible()
  ],
  css: {
    preprocessorOptions: {
      scss: {}
    }
  }
})
