import Banana from 'banana-i18n';

const banana = new Banana();
banana.setLocale(window.locale);
const { locale } = banana;
const finalFallback = 'en';


const RTL_LANGUAGES = ["ar", "he", "ur",];

const messages = {
    [finalFallback]: require(./i18n/${finalFallback}.json),
};

try {
    messages[locale] = require(./i18n/${locale}.json);
} catch (err) {
    
}

banana.load(messages);


function applyRTL() {
    if (RTL_LANGUAGES.includes(locale)) {
        document.documentElement.setAttribute("dir", "rtl");
        document.documentElement.setAttribute("lang", locale);
        document.body.classList.add("rtl");
    } else {
        document.documentElement.setAttribute("dir", "ltr");
        document.body.classList.remove("rtl");
    }
}


applyRTL();

export default banana;
