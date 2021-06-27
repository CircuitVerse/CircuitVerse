// intialize banana-i18n constructor
const banana = new Banana({ finalFallback: 'en' });
// set locale
banana.setLocale(window.locale);
// setup fetch api with async/await to load json files
async function fetchJson() {
    const response = await fetch(`i18n/${banana.locale}.json`, {
        headers: {
            Accept: 'application/json',
            'Cache-Control': 'no-cache',
        },
    });
    const json = await response.json();
    return json;
}
// instantiate banana-i18n with translations and currnet locale
fetchJson().then((messages) => {
    banana.load(messages, banana.locale);
});
