import { dots } from '../canvasApi';
import themeOptions from './themes';
import updateThemeForStyle from './themer';
import abstraction from './customThemeHelper';

const updateBG = () => dots(true, false, true);

/**
 * Generates Custom theme card HTML
 * @return {HTML Element} Theme card html (properties_container)
 */
const getCustomThemeCard = () => {
    var propertiesContainer = document.createElement('form');
    const keys = Object.keys(abstraction);
    keys.forEach((key) => {
        const property = document.createElement('div');
        const newPropertyLabel = document.createElement('label');
        newPropertyLabel.textContent = key;
        newPropertyLabel.setAttribute('for', key);
        const newPropertyInput = document.createElement('input');
        newPropertyInput.setAttribute('type', 'color');
        newPropertyInput.setAttribute('name', key);
        newPropertyInput.setAttribute('value', abstraction[key]['color']);
        property.append(newPropertyLabel);
        property.append(newPropertyInput);
        propertiesContainer.append(property);
    });
    const fileInput = document.createElement('input');
    fileInput.setAttribute('name', 'themeFile');
    fileInput.setAttribute('type', 'file');
    fileInput.setAttribute('id', 'importThemeFile');
    fileInput.setAttribute('style', 'display:none');
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('id', 'downloadThemeFile');
    downloadAnchor.setAttribute('style', 'display:none');
    propertiesContainer.appendChild(fileInput);
    propertiesContainer.appendChild(downloadAnchor);
    return propertiesContainer;
};

/**
* Create Custom Color Themes Dialog
*/
export const CustomColorThemes = () => {
    $('#CustomColorThemesDialog').empty();
    $('#CustomColorThemesDialog').append(getCustomThemeCard());
    $('#CustomColorThemesDialog').dialog({
        resizable: false,
        close() {
            themeOptions['Custom Theme'] = JSON.parse(localStorage.getItem('Custom Theme')) || themeOptions['Default Theme']; // hack for closing dialog box without saving
            // Rollback to previous theme
            updateThemeForStyle(localStorage.getItem('theme'));
            updateBG();
        },
        buttons: [{
            text: 'Apply Theme',
            click() {
                // update theme to Custom Theme
                localStorage.setItem('theme', 'Custom Theme');
                // add Custom theme to custom theme object
                localStorage.setItem('Custom Theme', JSON.stringify(themeOptions['Custom Theme']));
                $('.set').removeClass('set');
                $('.selected').addClass('set');
                $(this).dialog('close');
            },
        }, {
            text: 'Import Theme',
            click() {
                $('#importThemeFile').click();
            },
        }, {
            text: 'Export Theme',
            click() {
                const dlAnchorElem = document.getElementById('downloadThemeFile');
                dlAnchorElem.setAttribute('href', `data:text/json;charset=utf-8,${encodeURIComponent(JSON.stringify(themeOptions['Custom Theme']))}`);
                dlAnchorElem.setAttribute('download', 'CV_CustomTheme.json');
                dlAnchorElem.click();
            },
        }],
    });

    $('#CustomColorThemesDialog').focus();

    /**
     * To preview the changes
     */
    $('#CustomColorThemesDialog input').on('input', (e) => {
        abstraction[e.target.name]['color'] = e.target.value;
        abstraction[e.target.name]['linked'].forEach((property) => themeOptions['Custom Theme'][property] = e.target.value);
        updateThemeForStyle('Custom Theme');
        updateBG();
    });

    // hack for updating current theme to the saved custom theme
    setTimeout(() => {
        updateThemeForStyle('Custom Theme');
        updateBG();
    }, 50);

    /**
    * Read JSON file and
    * set Custom theme to the Content of the JSON file
    * @return call CustomColorThemes function
    *  */
    function receivedText(e) {
        const lines = e.target.result;
        themeOptions['Custom Theme'] = JSON.parse(lines);
        localStorage.setItem('Custom Theme', lines);
        $('#CustomColorThemesDialog').dialog('close');
        return CustomColorThemes();
    }

    /**
     * Add listener for file input
     * Read imported JSON file
     */
    $('#importThemeFile').on('input', (event) => {
        var File = event.target.files[0];
        if (File !== null && File.name.split('.')[1] === 'json') {
            var fr = new FileReader();
            fr.onload = receivedText;
            fr.readAsText(File);
        } else {
            alert('File Not Supported !');
        }
    });
};
