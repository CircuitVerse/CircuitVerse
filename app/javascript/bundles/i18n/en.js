import I18n from 'i18n-js';
I18n.translations || (I18n.translations = {});
I18n.translations["en"] = I18n.extend((I18n.translations["en"] || {}), {
  "simulator": {
    "agc": "english",
    "hello": "Hello world"
  }
});
