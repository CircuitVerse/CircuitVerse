import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';

document.addEventListener('DOMContentLoaded', () => {
    setup();
});

window.Array = Array;
