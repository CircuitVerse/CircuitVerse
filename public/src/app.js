import Driver from 'driver.js';
import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
// import tutorials from './tutorials';



document.addEventListener('DOMContentLoaded', () => {
    setup();

    const panelHighlight = new Driver();
    $('.panelHeader').one('click', (e) => {
        panelHighlight.highlight({
            element: '#guide_1',
            showButtons: false,
            popover: {
                title: 'Here are the elements',
                description: 'Select any element by clicking on it & then click anywhere on the grid to place the element.',
                position: 'right',
                offset: $($(e.target).next()).height() + $(e.target).offset().top - 45,
            }
        })
    })
    $('.icon').click(() => {
        panelHighlight.reset(true);
    });
});

window.Array = Array;
