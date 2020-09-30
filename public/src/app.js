import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
import { keyBinder } from './hotkey_binder/keyBinder';

document.addEventListener('DOMContentLoaded', () => {
    setup();
    keyBinder();
});

window.Array = Array;
