import Banana from 'banana-i18n';

// Statically import all JSON files to avoid dynamic require() or glob issues
import ar from './i18n/ar.json';
import bn from './i18n/bn.json';
import de from './i18n/de.json';
import en from './i18n/en.json';
import es from './i18n/es.json';
import fr from './i18n/fr.json';
import hi from './i18n/hi.json';
import ja from './i18n/ja.json';
import kn from './i18n/kn.json';
import ko from './i18n/ko.json';
import ml from './i18n/ml.json';
import mr from './i18n/mr.json';
import ne from './i18n/ne.json';
import pt from './i18n/pt.json';
import ta from './i18n/ta.json';
import te from './i18n/te.json';
import tr from './i18n/tr.json';
import ur from './i18n/ur.json';
import zh from './i18n/zh.json';

const messages = {
    ar, bn, de, en, es, fr, hi, ja, kn, ko, ml, mr, ne, pt, ta, te, tr, ur, zh
};

const banana = new Banana();
banana.setLocale(window.locale || 'en');
banana.load(messages);

window.banana = banana;
export default banana;
