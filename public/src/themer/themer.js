import { dots } from '../canvasApi';
import themeOptions from "./themes";
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

const themeSvgPre = `<svg id='`;
const themeIcon = `' xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="202.9" height="106" viewBox="0 0 202.9 106">
<defs>
  <clipPath id="clip">
    <use xlink:href="#fill"/>
  </clipPath>
  <clipPath id="clip-2">
    <use xlink:href="#fill-2"/>
  </clipPath>
  <clipPath id="clip-3">
    <use xlink:href="#fill-3"/>
  </clipPath>
</defs>
<g id="Default" transform="translate(-542 -149.868)">
  <rect class='svgGridBG' id="Rectangle_1592" data-name="Rectangle 1592" width="202" height="106" transform="translate(542.45 149.868)" fill="#f2f2f2"/>
  <line class='svgGrid' id="Line_78" data-name="Line 78" y1="105.737" transform="translate(554.145 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_79" data-name="Line 79" y1="105.737" transform="translate(565.576 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_80" data-name="Line 80" y1="105.737" transform="translate(577.007 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_81" data-name="Line 81" y1="105.737" transform="translate(588.438 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_82" data-name="Line 82" y1="105.737" transform="translate(599.87 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_83" data-name="Line 83" y1="105.737" transform="translate(611.3 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_84" data-name="Line 84" y1="105.737" transform="translate(622.732 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_85" data-name="Line 85" y1="105.737" transform="translate(635.591 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_86" data-name="Line 86" y1="105.737" transform="translate(647.022 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_87" data-name="Line 87" y1="105.737" transform="translate(658.453 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_88" data-name="Line 88" y1="105.737" transform="translate(669.884 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_89" data-name="Line 89" y1="105.737" transform="translate(681.315 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_90" data-name="Line 90" y1="105.737" transform="translate(692.746 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_91" data-name="Line 91" y1="105.737" transform="translate(704.177 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_92" data-name="Line 92" y1="105.737" transform="translate(715.608 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_93" data-name="Line 93" y1="105.737" transform="translate(727.039 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_94" data-name="Line 94" y1="105.737" transform="translate(738.47 150)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_95" data-name="Line 95" x2="202.9" transform="translate(542 172.148)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_96" data-name="Line 96" x2="202.9" transform="translate(542 183.579)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_97" data-name="Line 97" x2="202.9" transform="translate(542 195.01)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_98" data-name="Line 98" x2="202.9" transform="translate(542 206.441)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_99" data-name="Line 99" x2="202.9" transform="translate(542 217.872)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_100" data-name="Line 100" x2="202.9" transform="translate(542 229.303)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_101" data-name="Line 101" x2="202.9" transform="translate(542 240.734)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <line class='svgGrid' id="Line_102" data-name="Line 102" x2="202.9" transform="translate(542 252.165)" fill="none" stroke="#707070" stroke-width="0.1" opacity="1"/>
  <rect class='svgPanel' id="Rectangle_1589" data-name="Rectangle 1589" width="47" height="73" rx="4" transform="translate(552.45 172.868)" fill="#40393e"/>
  <path class='svgNav' id="Rectangle_1599" data-name="Rectangle 1599" d="M0,0H202a0,0,0,0,1,0,0V6a3,3,0,0,1-3,3H3A3,3,0,0,1,0,6V0A0,0,0,0,1,0,0Z" transform="translate(542.45 153.868)" fill="#bbb"/>
  <rect class='svgPanel' id="Rectangle_1593" data-name="Rectangle 1593" width="47" height="64" rx="4" transform="translate(689.45 172.868)" fill="#40393e"/>
  <rect class='svgHeader' id="Rectangle_1598" data-name="Rectangle 1598" width="202" height="7" transform="translate(542.45 149.868)" fill="#40393e"/>
  <g  id="Rectangle_1594" data-name="Rectangle 1594" transform="translate(559.45 183.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="24" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="23" height="2" fill="none"/>
  </g>
  <g  id="Rectangle_1601" data-name="Rectangle 1601" transform="translate(694.45 182.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="36" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="35" height="2" fill="none"/>
  </g>
  <g id="Rectangle_1602" data-name="Rectangle 1602" transform="translate(694.45 199.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="36" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="35" height="2" fill="none"/>
  </g>
  <g id="Rectangle_1604" data-name="Rectangle 1604" transform="translate(694.45 216.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="36" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="35" height="2" fill="none"/>
  </g>
  <g id="Rectangle_1600" data-name="Rectangle 1600" transform="translate(694.89 178.578)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect id="fill" width="12.86" height="0.714" stroke="none"/>
    <path d="M0,0.21443802118301392h12.859884262084961M12.359884262084961,0v0.7144380211830139M12.859884262084961,0.5h-12.859884262084961M0.5,0.7144380211830139v-0.7144380211830139" fill="none" clip-path="url(#clip)"/>
  </g>
  <g id="Rectangle_1606" data-name="Rectangle 1606" transform="translate(630.59 152.858)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="27.149" height="2.143" stroke="none"/>
    <rect x="0.5" y="0.5" width="26.149" height="1.143" fill="none"/>
  </g>
  <g id="Rectangle_1603" data-name="Rectangle 1603" transform="translate(694.89 195.724)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect id="fill-2" width="12.86" height="0.714" stroke="none"/>
    <path d="M0,0.21443802118301392h12.859884262084961M12.359884262084961,0v0.7144380211830139M12.859884262084961,0.5h-12.859884262084961M0.5,0.7144380211830139v-0.7144380211830139" fill="none" clip-path="url(#clip-2)"/>
  </g>
  <g id="Rectangle_1605" data-name="Rectangle 1605" transform="translate(694.89 212.871)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect id="fill-3" width="12.86" height="0.714" stroke="none"/>
    <path d="M0,0.21443802118301392h12.859884262084961M12.359884262084961,0v0.7144380211830139M12.859884262084961,0.5h-12.859884262084961M0.5,0.7144380211830139v-0.7144380211830139" fill="none" clip-path="url(#clip-3)"/>
  </g>
  <g id="Rectangle_1595" data-name="Rectangle 1595" transform="translate(559.45 198.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="24" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="23" height="2" fill="none"/>
  </g>
  <g id="Rectangle_1596" data-name="Rectangle 1596" transform="translate(559.45 212.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="24" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="23" height="2" fill="none"/>
  </g>
  <g id="Rectangle_1597" data-name="Rectangle 1597" transform="translate(559.45 226.868)" fill="#f5f5f5" class='svgText' stroke="#bbb" stroke-width="1">
    <rect width="24" height="3" stroke="none"/>
    <rect x="0.5" y="0.5" width="23" height="2" fill="none"/>
  </g>
  <g class='' id="chevron-down" transform="translate(587.949 185.477)">
    <path class='SvgChev' id="chevron-down-2" data-name="chevron-down" d="M6,9l1.881,1.881L9.762,9" transform="translate(-6 -9)" fill="none" stroke="#bbb" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
  </g>
  <g id="chevron-down-3" data-name="chevron-down" transform="translate(587.949 199.766)">
    <path class='SvgChev' id="chevron-down-4" data-name="chevron-down" d="M6,9l1.881,1.881L9.762,9" transform="translate(-6 -9)" fill="none" stroke="#bbb" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
  </g>
  <g id="chevron-down-5" data-name="chevron-down" transform="translate(587.949 214.055)">
    <path class='SvgChev' id="chevron-down-6" data-name="chevron-down" d="M6,9l1.881,1.881L9.762,9" transform="translate(-6 -9)" fill="none" stroke="#bbb" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
  </g>
  <g id="chevron-down-7" data-name="chevron-down" transform="translate(587.949 228.343)">
    <path class='SvgChev' id="chevron-down-8" data-name="chevron-down" d="M6,9l1.881,1.881L9.762,9" transform="translate(-6 -9)" fill="none" stroke="#bbb" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
  </g>
</g>
</svg>
`

export const colorThemes = () => {
    const selectedTheme = localStorage.getItem('theme');
    $('#colorThemesDialog').empty();
    const themes = Object.keys(themeOptions);
    themes.forEach((theme) => {
        if (theme === selectedTheme) {
            $('#colorThemesDialog').append(`
            <div id="theme" class="theme selected set"><div class='themeSel'></div><span>${themeSvgPre}${theme.replace(' ', '')}Svg${themeIcon}</span><span id='themeNameBox' class='themeNameBox'><input type='radio' value='${theme}' name='theme' id='${theme.replace(' ', '')}'><label for='${theme.replace(' ', '')}'>${theme}</label></span></div>
            `)
        } else {
            $('#colorThemesDialog').append(`
            <div class="theme"><div class='themeSel'></div><span>${themeSvgPre}${theme.replace(/[^a-zA-Z0-9]/g, '')}Svg${themeIcon}</span><span id='themeNameBox' class='themeNameBox'><input type='radio' id='${theme.replace(' ', '')}' value='${theme}' name='theme'><label for='${theme.replace(' ', '')}'>${theme}</label></span></div>
            `)
        }
    })

    $('.selected label').click();
    $('#colorThemesDialog').dialog({
        resizable: false,
        close() {
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
        $(e.target.parentElement).addClass('selected');
        e.target.nextSibling.nextSibling.children[0].click();
        updateThemeForStyle(e.target.nextSibling.nextSibling.children.theme.value);
        updateBG();
    })
}

const updateBG = () => dots(true, false, true);

(() => {
    if (!localStorage.getItem('theme')) localStorage.setItem('theme', 'Default Theme');
    updateThemeForStyle(localStorage.getItem('theme'));
})();