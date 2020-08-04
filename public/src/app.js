import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
import { tutorialWrapper } from './tutorials';



document.addEventListener('DOMContentLoaded', () => {
    setup();
    tutorialWrapper();
});

window.Array = Array;
