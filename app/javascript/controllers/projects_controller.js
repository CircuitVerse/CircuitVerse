/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';

var flag = false;

export default class extends Controller {
    // eslint-disable-next-line class-methods-use-this
    copy() {
        const textarea = document.getElementById('result');
        var x = document.querySelector('.projectshow-embed-text-confirmation');
        textarea.select();
        document.execCommand('copy');
        x.style.display = 'block';
    }

    showEmbedLink() {
        const clockTimeEnable = document.querySelector('#checkbox-clock-time').checked;
        const displayTitle = document.querySelector('#checkbox-display-title').checked;
        const fullscreen = document.querySelector('#checkbox-fullscreen').checked;
        const zoomInOut = document.querySelector('#checkbox-zoom-in-out').checked;
        const theme = document.querySelector('#theme').value;
        const url = `${document.querySelector('#url').value}?theme=${theme}&display_title=${displayTitle}&clock_time=${clockTimeEnable}&fullscreen=${fullscreen}&zoom_in_out=${zoomInOut}`;
        let height = document.querySelector('#height').value;
        if (height === '') height = 500;
        let width = document.querySelector('#width').value;
        if (width === '') width = 500;
        const borderPr = document.querySelector('#border_px').value;
        const borderStyle = document.querySelector('#border_style').value;
        const borderColor = document.querySelector('#border_color').value;
        const markup = `<iframe src="${url}" style="border-width:${borderPr}; border-style: ${borderStyle}; border-color:${borderColor};" name="myiframe" id="projectPreview" scrolling="no" frameborder="1" marginheight="0px" marginwidth="0px" height="${height}" width="${width}" allowFullScreen></iframe>`;
        document.querySelector('#result').innerText = markup;
        this.copy();
    }
}
