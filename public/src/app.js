import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
import tutorials from './tutorials';

document.addEventListener('DOMContentLoaded', () => {
    setup();
    tutorials.start();
});

window.Array = Array;
