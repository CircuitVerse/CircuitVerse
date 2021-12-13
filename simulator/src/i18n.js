import Banana from 'banana-i18n';

const banana = new Banana();
banana.setLocale(window.locale);
const { locale } = banana;
const finalFallback = 'en';
// object with default language preloaded
const messages = {
    [finalFallback]: require(`./i18n/${finalFallback}.json`),
};
try {
    messages[locale] = require(`./i18n/${locale}.json`);
} catch (err) {
    // If Asynchronous loading for current locale failed, load default locale
}
banana.load(messages);
export default banana;
