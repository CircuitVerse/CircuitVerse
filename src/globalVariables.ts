/*global ...*/
/*eslint no-undef: "error"*/

declare const window: any

import jQuery from 'jquery'
window.$ = window.jQuery = jQuery

window.isUserLoggedIn = false
window.logixProjectId = undefined

window.restrictedElements = []
window.globalScope = undefined
window.lightMode = false // To be deprecated
window.projectId = undefined
window.id = undefined
window.loading = false // Flag - all assets are loaded

window.embed = false

window.width = undefined
window.height = undefined
window.DPR = window.devicePixelRatio || 1 // devicePixelRatio, 2 for retina displays, 1 for low resolution displays
