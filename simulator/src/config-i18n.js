// initialize banana-i18n constructor
const banana = new Banana();
// set locale
banana.setLocale(window.locale);
//  constant locale holding value of banana.locale
const { locale } = banana;
// fallback language
const finalFallback = "en";
// loading  fallback language en.json by default into object
const messages = {
    [finalFallback]: require(`./i18n/${finalFallback}.json`),
};
// loading json file into object for current locale (if present)
try {
    messages[locale] = require(`./i18n/${locale}.json`);
} catch (err) {
    // if failed to load, object with default language is loaded
}
banana.load(messages);
export default banana;
