import { createI18n } from 'vue-i18n'
import en from './en.json'
import hi from './hi.json'
import bn from './bn.json'

export const i18n = createI18n({
    legacy: false,
    locale: 'en',
    fallbackLocale: 'en',
    globalInjection: true,
    // messages
    messages: {
        en,
        hi,
        bn,
    },
})


export const availableLocale: Array<{
    title: string
    value: string
}> = [
    { title: 'English', value: 'en' },
    { title: 'Hindi', value: 'hi' },
]

export default i18n
