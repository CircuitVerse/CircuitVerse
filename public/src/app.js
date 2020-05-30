import $ from 'jquery';

import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';

window.$ = $;
window.jQuery = $;

document.addEventListener('DOMContentLoaded', () => {
    setup();
});

window.Array = Array;
