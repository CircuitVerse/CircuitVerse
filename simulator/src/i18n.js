import Banana from 'banana-i18n';

const banana = new Banana();
banana.setLocale('ur');

const finalFallback = 'en';
const messages = {
    [finalFallback]: require('./i18n/en.json'),
};

try {
    messages.ur = require('./i18n/ur.json');
} catch (err) {
    // Silent error handling
}

banana.load(messages);
window.banana = banana;

export default banana;