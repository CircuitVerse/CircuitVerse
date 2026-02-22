import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
})

/*
  NOTE FOR CONTRIBUTORS:
  This file configures Vite for the frontend build pipeline.
  It may appear unused because it is not directly imported
  in application code, but it is consumed by the build tooling
  (Vite CLI / Rails integration / dev server).
 
  There have been recent discussions about refactoring this file:
  - Some issues report it being messy
  - Some mention dev server breakage
 
  Please be cautious before modifying or removing this file,
  as it is part of the project’s build infrastructure.
 
  If you are investigating cleanup, check related issues:
  - Search: "vite.config.ts" in Issues
 */
