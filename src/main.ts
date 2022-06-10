import { createApp } from "vue";
import App from "./App.vue";
import vuetify from "./plugins/vuetify";
import router from "./router/index";
import { createPinia } from "pinia";
import { loadFonts } from "./plugins/webfontloader";
import i18n from "./locales/i18n";

loadFonts();

createApp(App)
    .use(vuetify)
    .use(router)
    .use(createPinia())
    .use(i18n)
    .mount("#app");
