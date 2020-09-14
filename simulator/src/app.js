import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap/js/dist/util';
import 'bootstrap/js/dist/alert'
import 'bootstrap/js/dist/button'
import 'bootstrap/js/dist/carousel'
import 'bootstrap/js/dist/collapse'
import 'bootstrap/js/dist/dropdown'
import 'bootstrap/js/dist/modal'
// import 'bootstrap/js/dist/popover'
import 'bootstrap/js/dist/scrollspy'

import 'bootstrap/js/dist/tab.js'
import 'bootstrap/js/dist/toast.js'

// import 'bootstrap/js/dist/tooltip.js'
import { keyBinder } from './hotkey_binder/keyBinder';

document.addEventListener('DOMContentLoaded', () => {
    setup();
    keyBinder();
});

window.Array = Array;
