import Banana from 'banana-i18n';

const banana = new Banana();
banana.setLocale("ar");
console.log("Forced Locale:", banana.getLocale());

const finalFallback = "en";
const messages = {
    [finalFallback]: require(`./i18n/${finalFallback}.json`),
};

try {
    messages["ar"] = require(`./i18n/ar.json`);
    messages["ur"] = require(`./i18n/ur.json`);
    messages["he"] = require(`./i18n/he.json`);
} catch (err) {
    console.error("Failed to load locale JSON files:", err);
}

banana.load(messages);
window.banana = banana;

export default banana;
