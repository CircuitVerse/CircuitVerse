import { Controller } from 'stimulus';

export default class extends Controller {
    handleMainCheckbox() {
        $('#advance-embed').change((e) => {
            e.preventDefault();
            var radio = $(e.currentTarget);

            if (radio.is(':checked')) {
                $('.advance-embed-option').css('display', 'block');
            } else {
                $('.advance-embed-option').css('display', 'none');
            }
        });
        $('#advance-embed').trigger('change');
    }

    connect() {
        this.handleMainCheckbox();
    }

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
        const theme = document.querySelector("#theme").value;
        const url = `${document.querySelector('#url').value}?theme=${theme}&display-title=${displayTitle}&clock-time=${clockTimeEnable}&fullscreen=${fullscreen}&zoom-in-out=${zoomInOut}`;
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
