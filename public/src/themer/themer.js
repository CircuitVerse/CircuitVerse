import { dots } from '../canvasApi';
import getColors from '../modules/colors';

const themeOptions = [
    {
        "--primary": "#454545",
        "--text-primary": "#fff",
        "--text-secondary": "#000",
        "--br-primary": "#fff",
        "--bg-primary-moz": "#454545e6",
        "--bg-primary-chr": "#454545b3",
        "--bg-tabs": "#8b8b8b",
        "--bg-icons": "#7d7d7d",
        "--bg-text": "#cacaca",
        "--bg-secondary": "#bbbbbb",
        "--canvas-stroke": "#eee",
        "--canvas-fill": "white",
        "--bg-toogle": "#42b983",
        "--bg-toogle-darken": "#3ca877",
        "--btn-danger": "#dc5656",
        "--btn-danger-darken": "#b03662",
        "--disable": "#6c8b93",
        "--qp-br-tl": "#333333",
        "--qp-br-rd": "#535353",
        "--qp-box-shadow-1": "#3b3b3b",
        "--qp-box-shadow-2": "#4f4f4f",
        "--btn-dg-hov": "#ddd",
        "--btn-dg-hov-text": "#000",
        "--node": "green",
        "--stroke": "black",
        "--fill": "white",
        "--hover-and-sel": "rgba(255, 255, 32, 0.8)",
        "--wire-draw": "black",
        "--wire-cnt": "green",
        "--wire-pow": "lightgreen",
        "--wire-sel": "blue",
        "--wire-lose": "red",
        "--mini-map": "green",
        "--mini-map-stroke": "darkgreen",
        "--input-text": "green",
        "--secondary-stroke": "red",
        "--text": "black",
        "--wire-norm": "black",
        "--node-norm": "green",
        "--splitter": "black",
        "--output-rect": "blue",
        name: "Default Theme",
    },
    {
        "--primary": "#0F111A", //header bg, panels bg
        "--text-primary": "#FFF", //normal state text
        "--text-secondary": "white", //text state on hover, on drop down menu , context menu
        "--br-primary": "#665627", //panel border, tabbar circuit border
        "--bg-primary-moz": "#0f111ae6", //dialog bg
        "--bg-primary-chr": "#0f111ab3", //dialog bg
        "--bg-tabs": "#727d8d", //tabs bar primary bg,
        "--bg-icons": "#4d647a", //ce icon bg
        "--bg-text": "#727d8d", //drop down, content menu, text bg on hover
        "--bg-secondary": "#536c84", //border color input button,
        "--canvas-fill": "#1B2C33", //canvas bg
        "--canvas-stroke": "#6A7980", //canvas stroke
        "--bg-toogle": "#48a69d",
        "--bg-toogle-darken": "#3f9189",
        "--btn-danger": "#c33c6c",
        "--btn-danger-darken": "#b03662",
        "--qp-br-tl": "#282d46", //more ligthen than qp box shadow 1
        "--qp-br-rd": "#1d2132",
        "--qp-box-shadow-1": "#1d2132", //lil lighten base
        "--qp-box-shadow-2": "#0a0b11", //lil darken base
        "--btn-dg-hov": "#48a69d",
        "--btn-dg-hov-text": "#fff",

        "--node": "#285963",
        "--stroke": "#277F7C",
        "--fill": "#DEFFFE",
        "--hover-and-sel": "#E3B924",
        "--wire-draw": "#262626",
        "--wire-cnt": "#3B7F58",
        "--wire-pow": "#75FFB0",
        "--wire-sel": "#208CC9",
        "--wire-lose": "#BF0426",
        "--mini-map": "#3B7F58",
        "--mini-map-stroke": "#607F6E",
        "--input-text": "#3B7F58",
        "--output-rect": "#0487D9",
        "--secondary-stroke": "#BF0426",
        "--text": "#E9FBF8",
        "--wire-norm": "#277F7C",
        "--node-norm": "#FFC231",
        "--splitter": "#0284A8",
        name: "nightSky",
    },
];

// document.getElementById('backgroundArea').getContext('2d').strokeStyle

//metadata.json , upto max 3rd level
// const themes = [
//     {
//         name: "default", //theme name
//         "--border-all": "#fff", //border color all
//         navbar: {
//             "--bg-primary-nav": "#557493", //nav-bar bg color
//             "--text-primary-nav": "#557493", //project title font color
//             "--text-seconday-nav": "#557493", //menu font color
//             "--text-alternate-nav": "#ffffff", // text-color on hover
//             dropdown: {
//                 "--text-primary-drop": "#557493", //dropdown font color
//                 "--text-alternate-drop": "#557493", //dropdown font color on hover
//             },
//         },
//         sideMenu: {
//             "--bg-primary-side": "#557493", //side menu bg color
//             "--text-primary-side": "#557493", //heading text font color of side menu
//             circuitElements: {
//                 "--bg-primary-circuit": "#557493", //circuit elements options bg color
//                 "--bg-secondary-circuit": "#557493", //circuit elements option dropdown bg color
//                 "--text-primary-circuit": "#557493", //circuit elements option font color
//             },
//             properties: {
//                 //config
//             },
//         },
//         propertyMenu: {
//             //config
//         },
//         canvas: {
//             "--bg-primary-canvas": "#557493", //canvas bg-color
//             "--primary-canvas": "#557493", //canvas grid-color
//         },
//     },
//     {
//         name: "Retro", //theme name
//         "--border-all": "#fff", //border color all
//         navbar: {
//             "--bg-primary-nav": "#557493", //nav-bar bg color
//             "--text-primary-nav": "#557493", //project title font color
//             "--text-seconday-nav": "#557493", //menu font color
//             "--text-alternate-nav": "#ffffff", // text-color on hover
//             dropdown: {
//                 "--text-primary-drop": "#557493", //dropdown font color
//                 "--text-alternate-drop": "#557493", //dropdown font color on hover
//             },
//         },
//         sideMenu: {
//             "--bg-primary-side": "#557493", //side menu bg color
//             "--text-primary-side": "#557493", //heading text font color of side menu
//             circuitElements: {
//                 "--bg-primary-circuit": "#557493", //circuit elements options bg color
//                 "--bg-secondary-circuit": "#557493", //circuit elements option dropdown bg color
//                 "--text-primary-circuit": "#557493", //circuit elements option font color
//             },
//             properties: {
//                 //config
//             },
//         },
//         propertyMenu: {
//             //config
//         },
//         canvas: {
//             "--bg-primary-canvas": "#557493", //canvas bg-color
//             "--primary-canvas": "#557493", //canvas grid-color
//         },
//     },
// ];

function updateThemeForStyle(themeName) {
    const selectedTheme = themeOptions.find(
        (t) => t.name.toLowerCase() === themeName.toLowerCase()
    );
    const html = document.getElementsByTagName('html')[0];
    Object.keys(selectedTheme).forEach((property, i) => {
        if (property === 'name') return;
        html.style.setProperty(property, selectedTheme[property]);
    });
}

export default updateThemeForStyle;

export const colorThemes = () => {
    const selectedTheme = localStorage.getItem('theme');
    $('#colorThemesDialog').empty();
    themeOptions.forEach(theme => {
        if (theme.name === selectedTheme) {
            $('#colorThemesDialog').append(`
            <div class="theme selected set">${theme.name}</div> 
            `)
        } else {
            $('#colorThemesDialog').append(`
            <div class="theme">${theme.name}</div> 
            `)
        }
    })

    $('#colorThemesDialog').dialog({
        draggable: false,
        resizable: false,
        close() {
            updateThemeForStyle(localStorage.getItem('theme'));
            hackCanvas();
        },
        buttons: [{
            text: "Apply Theme",
            click() {
                localStorage.setItem('theme', $('.selected').text());
                $('.set').removeClass('set');
                $('.selected').addClass('set');
                $(this).dialog('close');
            }
        }]
    });
    $('#colorThemesDialog').focus()
    $('.ui-dialog[aria-describedby="colorThemesDialog"]').click(() => $('#colorThemesDialog').focus()) //hack for losing focus

    $('#colorThemesDialog').click((e) => {
        $('.selected').removeClass('selected');
        $(e.target).addClass('selected');
        updateThemeForStyle($('.selected').text());
        hackCanvas();
    });


    $('#colorThemesDialog').keydown((e) => {
        if (e.which === 40 && $('.selected').next().length) {
            $('.selected').next().addClass('selected')
            $($('.selected')[0]).removeClass('selected')
            updateThemeForStyle($('.selected').text());
            hackCanvas();
        } else if (e.which === 38 && $('.selected').prev().length) {
            $('.selected').prev().addClass('selected')
            $($('.selected')[1]).removeClass('selected')
            updateThemeForStyle($('.selected').text());
            hackCanvas();
        }
        if (e.which === 13) {
            localStorage.setItem("theme", $('.selected').text());
            $('.set').removeClass('set');
            $('.selected').addClass('set');
            // $('.ui-dialog').find('button:first').trigger('click');
        }
        if (e.which === 27) {
            updateThemeForStyle(localStorage.getItem('theme'));
            hackCanvas();
            // $('.ui-dialog').find('button:first').trigger('click');
        }
    });
}

const hackCanvas = () => {
    globalScope.scale -= 0.0000000000001; //hack
    dots();
}

(() => {
    if (!localStorage.getItem('theme')) localStorage.setItem('theme', 'Default Theme');
    updateThemeForStyle(localStorage.getItem('theme'));
})();
