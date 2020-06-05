/**
 * Helper function to show prompt to save image
 * Options - resolution, image type, view
 * @param {Scope=} scope - useless though
 * @category data
 */
import { generateImage } from './save';

/**
 * Function called to generate a prompt to save an image
 * @category data
 * @param {Scope=} - circuit whose image we want
 * @exports createSaveAsImgPrompt
 */
export default function createSaveAsImgPrompt(scope = globalScope) {
    $('#saveImageDialog').dialog({
        width: 'auto',
        buttons: [{
            text: 'Render Circuit Image',
            click() {
                generateImage($('input[name=imgType]:checked').val(), $('input[name=view]:checked').val(), $('input[name=transparent]:checked').val(), $('input[name=resolution]:checked').val());
                $(this).dialog('close');
            },
        }],

    });
    $('input[name=imgType]').change(() => {
        $('input[name=resolution]').prop('disabled', false);
        $('input[name=transparent]').prop('disabled', false);
        const imgType = $('input[name=imgType]:checked').val();
        if (imgType === 'svg') {
            $('input[name=resolution][value=1]').click();
            $('input[name=view][value="full"]').click();
            $('input[name=resolution]').prop('disabled', true);
            $('input[name=view]').prop('disabled', true);
        } else if (imgType !== 'png') {
            $('input[name=transparent]').attr('checked', false);
            $('input[name=transparent]').prop('disabled', true);
            $('input[name=view]').prop('disabled', false);
        } else {
            $('input[name=view]').prop('disabled', false);
        }
    });
}
