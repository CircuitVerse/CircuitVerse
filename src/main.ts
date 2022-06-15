import { createApp } from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'
import router from './router/index'
import { createPinia } from 'pinia'
import { loadFonts } from './plugins/webfontloader'
import i18n from './locales/i18n'

import 'bootstrap'
import jQuery from 'jquery'
declare const window: any
window.$ = window.jQuery = jQuery
import Array from './simulator/src/arrayHelpers.js'
window.Array = Array

import './simulator/src/css/main.stylesheet.css'
import '../node_modules/bootstrap/scss/bootstrap.scss'
import './assets/color_theme.scss'
import './assets/simulator.scss'
import './assets/tutorials.scss'

window.restrictedElements = [];

loadFonts()

createApp(App)
    .use(vuetify)
    .use(router)
    .use(createPinia())
    .use(i18n)
    .mount('#app')
