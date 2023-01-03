import { useActions } from './store/SimulatorStore/actions'
import { createApp } from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'
import router from './router/index'
import { createPinia } from 'pinia'
import { loadFonts } from './plugins/webfontloader'
import i18n from './locales/i18n'

import 'bootstrap'

import './globalVariables'

import './styles/css/main.stylesheet.css'
import '../node_modules/bootstrap/scss/bootstrap.scss'
import './styles/color_theme.scss'
import './styles/simulator.scss'
import './styles/tutorials.scss'

loadFonts()

createApp(App)
    .use(createPinia())
    .use(vuetify)
    .use(router)
    .use(i18n)
    .mount('#app')
