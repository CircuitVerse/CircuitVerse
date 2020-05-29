import $ from 'jquery';

import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
import undo from './data/undo';

window.$ = $;
window.jQuery = $;

document.addEventListener('DOMContentLoaded', () => {
    setup();
});
window.undo = undo;
window.Array = Array;
