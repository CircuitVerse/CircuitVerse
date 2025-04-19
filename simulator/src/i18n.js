import Banana from 'banana-i18n';

const banana = new Banana();
banana.setLocale('en');

const finalFallback = 'en';
const messages = {
    [finalFallback]: require('./i18n/en.json'),
};

try {
    messages.ar = require(`./i18n/ar.json`);
    messages.he = require('./i18n/he.json');
    messages.ur = require('./i18n/ur.json');
} catch (err) {
    
}

banana.load(messages);
window.banana = banana;

export default banana;