import { Controller } from 'stimulus';

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
        const url = document.querySelector('#url').value;
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
