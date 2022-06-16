declare const window: any

import jQuery from 'jquery'
window.$ = window.jQuery = jQuery

import Array from './simulator/src/arrayHelpers.js'
window.Array = Array

window.restrictedElements = []
window.globalScope = undefined
window.lightMode = false // To be deprecated
window.projectId = undefined
window.id = undefined
window.loading = false // Flag - all assets are loaded
