import { dots } from '../canvasApi';
import themeOptions from "./themes";
import themeCardSvg from "./themeCardSvg";
import getColors from '../modules/colors';

export let colors = getColors();

function updateThemeForStyle(themeName) {
    const selectedTheme = themeOptions[themeName];
    const html = document.getElementsByTagName('html')[0];
    Object.keys(selectedTheme).forEach((property, i) => {
        html.style.setProperty(property, selectedTheme[property]);
    });
    colors = getColors();
}

export default updateThemeForStyle;

const getSvg = (themeName) => {
  const colors = themeOptions[themeName];
  let svgIcon = $(themeCardSvg);

  // Dynamically set the colors according to the theme
  $(".svgText", svgIcon).attr('fill', colors['--text-panel']);

  $(".svgNav", svgIcon).attr('fill', colors['--bg-tab']);
  $(".svgNav", svgIcon).attr('stroke', colors['--br-primary']);

  $(".svgGridBG", svgIcon).attr('fill', colors['--canvas-fill']);
  $(".svgGrid", svgIcon).attr('fill', colors['--canvas-stroke']);

  $(".svgPanel", svgIcon).attr('fill', colors['--primary']);
  $(".svgPanel", svgIcon).attr('stroke', colors['--br-primary']);

  $(".svgChev", svgIcon).attr('stroke', colors['--br-secondary']);

  $(".svgHeader", svgIcon).attr('fill', colors['--primary']);

  return svgIcon.prop('outerHTML');
};

export const getThemeCard = (themeName, selected) => {
  let themeId = themeName.replace(' ', '');
  let selectedClass = selected ? 'selected set' : '';
  // themeSel is the hit area
  return `
            <div id="theme" class="theme ${selectedClass}">
              <div class='themeSel'></div>
              <span>${getSvg(themeName)}</span>
              <span id='themeNameBox' class='themeNameBox'>
                <input type='radio' id='${themeId}' value='${themeName}' name='theme'>
                <label for='${themeId}'>${themeName}</label>
              </span>
            </div>
            `
}

export const colorThemes = () => {
    const selectedTheme = localStorage.getItem('theme');
    $('#colorThemesDialog').empty();
    const themes = Object.keys(themeOptions);
    themes.forEach((theme) => {
      if(theme === selectedTheme) {
        $('#colorThemesDialog').append(getThemeCard(theme, true));
      }
      else {
        $('#colorThemesDialog').append(getThemeCard(theme, false));
      }
    })

    $('.selected label').click();
    $('#colorThemesDialog').dialog({
        resizable: false,
        close() {
            // Rollback to previous theme
            updateThemeForStyle(localStorage.getItem('theme'));
            updateBG();
        },
        buttons: [{
            text: "Apply Theme",
            click() {
                localStorage.setItem('theme', $('.selected label').text());
                $('.set').removeClass('set');
                $('.selected').addClass('set');
                $(this).dialog('close');
            }
        }]
    });

    $('#colorThemesDialog').focus();
    $('.ui-dialog[aria-describedby="colorThemesDialog"]').click(() => $('#colorThemesDialog').focus()) //hack for losing focus

    $('.themeSel').on('mousedown', (e) => {
        e.preventDefault();
        $('.selected').removeClass('selected');
        let themeCard = $(e.target.parentElement);
        themeCard.addClass('selected');
        // Extract radio button
        var radioButton = themeCard.find('input[type=radio]');
        radioButton.click(); // Mark as selected
        updateThemeForStyle(themeCard.find('label').text()); // Extract theme name and set
        updateBG();
    })
}

const updateBG = () => dots(true, false, true);

(() => {
    if (!localStorage.getItem('theme')) localStorage.setItem('theme', 'Default Theme');
    updateThemeForStyle(localStorage.getItem('theme'));
})();