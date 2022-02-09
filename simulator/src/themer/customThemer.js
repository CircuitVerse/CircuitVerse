import { dots } from '../canvasApi';
import themeOptions from './themes';
import updateThemeForStyle from './themer';
import { CreateAbstraction } from './customThemeAbstraction';

/**
 *
 */
var customTheme = CreateAbstraction(themeOptions['Custom Theme']);

const updateBG = () => dots(true, false, true);

/**
 * Generates Custom theme card HTML
 * return Html Element Theme card html (properties_container)
 */
const getCustomThemeCard = () => {
    var propertiesContainer = document.createElement('form');
    const keys = Object.keys(customTheme);
    keys.forEach((key) => {
        const property = document.createElement('div');
        const newPropertyLabel = document.createElement('label');
        newPropertyLabel.textContent = `${key} (${customTheme[key].description})`;
        newPropertyLabel.setAttribute('for', key);
        const newPropertyInput = document.createElement('input');
        newPropertyInput.setAttribute('type', 'color');
        newPropertyInput.setAttribute('name', key);
        newPropertyInput.setAttribute('value', customTheme[key].color);
        newPropertyInput.classList.add('customColorInput');
        property.append(newPropertyLabel);
        property.append(newPropertyInput);
        propertiesContainer.append(property);
    });
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('id', 'downloadThemeFile');
    downloadAnchor.setAttribute('style', 'display:none');
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
    $('.customColorInput').on('input', (e) => {
        customTheme[e.target.name].color = e.target.value;
        customTheme[e.target.name].ref.forEach((property) => {
            themeOptions['Custom Theme'][property] = e.target.value;
        });
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
    *  */
    function receivedText(e) {
        const lines = JSON.parse(e.target.result);
        customTheme = CreateAbstraction(lines);
        themeOptions['Custom Theme'] = lines;
        // preview theme
        updateThemeForStyle('Custom Theme');
        updateBG();
        // update colors in dialog box
        $('#CustomColorThemesDialog').empty();
        $('#CustomColorThemesDialog').append(getCustomThemeCard());
    }

    /**
     * Add listener for file input
     * Read imported JSON file
     */
    $('#importThemeFile').on('change', (event) => {
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
