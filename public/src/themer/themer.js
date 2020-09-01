import { dots } from '../canvasApi';
import themeOptions from "./themes";
import themeCardSvg from "./themeCardSvg";

const getCanvasColors = () => {
  let colors = {};
  colors["hover_select"] = getComputedStyle(document.documentElement).getPropertyValue('--hover-and-sel');
  colors["fill"] = getComputedStyle(document.documentElement).getPropertyValue('--fill');
  colors["mini_fill"] = getComputedStyle(document.documentElement).getPropertyValue('--mini-map');
  colors["mini_stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--mini-map-stroke');
  colors["stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--stroke');
  colors["stroke_alt"] = getComputedStyle(document.documentElement).getPropertyValue('--secondary-stroke');
  colors["input_text"] = getComputedStyle(document.documentElement).getPropertyValue('--input-text');
  colors["color_wire_draw"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-draw');
  colors["color_wire_con"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-cnt');
  colors["color_wire_pow"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-pow');
  colors["color_wire_sel"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-sel');
  colors["color_wire_lose"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-lose');
  colors["color_wire"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-norm');
  colors["text"] = getComputedStyle(document.documentElement).getPropertyValue('--text');
  colors["node"] = getComputedStyle(document.documentElement).getPropertyValue('--node');
  colors["node_norm"] = getComputedStyle(document.documentElement).getPropertyValue('--node-norm');
  colors["splitter"] = getComputedStyle(document.documentElement).getPropertyValue('--splitter');
  colors["out_rect"] = getComputedStyle(document.documentElement).getPropertyValue('--output-rect');
  colors["canvas_stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--canvas-stroke');
  colors["canvas_fill"] = getComputedStyle(document.documentElement).getPropertyValue('--canvas-fill');
  return colors;
}

export let colors = getCanvasColors();

function updateThemeForStyle(themeName) {
    const selectedTheme = themeOptions[themeName];
    const html = document.getElementsByTagName('html')[0];
    Object.keys(selectedTheme).forEach((property, i) => {
        html.style.setProperty(property, selectedTheme[property]);
    });
    colors = getCanvasColors();
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