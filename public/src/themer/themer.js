import { dots } from '../canvasApi';
import getColors from '../modules/colors';

const themeOptions = [
    {
        "--primary": "#454545",
        "--text-lite": "#fff",
        "--text-dark": "#000",
        "--text-panel": "white",

        "--text-navbar": "white",
        "--bg-navbar":"#454545",
        "--qp-br-tl": "#333333",
        "--qp-br-rd": "#535353",
        "--qp-box-shadow-1": "#3b3b3b",
        "--qp-box-shadow-2": "#4f4f4f",


        "--bg-circuit": "#bbbbbb",
        "--br-circuit": "#454545",

        "--br-primary": "#fff",
        "--bg-primary-moz": "#454545e6",
        "--bg-primary-chr": "#454545b3",
        "--bg-tabs": "#8b8b8b",
        "--bg-icons": "#7d7d7d",
        "--bg-text": "#cacaca",
        "--bg-secondary": "#bbbbbb",
        "--canvas-stroke": "#eee",
        "--canvas-fill": "white",
        "--bg-toggle-btn-primary": "#42b983",
        "--primary-btn-hov": "#3ca877",
        "--btn-danger": "#dc5656",
        "--btn-danger-darken": "#b03662",
        "--disable": "#6c8b93",
        "--cus-btn-hov--bg": "#ddd",
        "--cus-btn-hov-text": "#000",
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
        "--text-lite": "#FFF", //normal state text
        "--text-dark": "white", //text state on hover, on drop down menu , context menu
        "--text-panel": "white",
        
        "--bg-navbar":"#0F111A",
        "--br-primary": "#665627", //panel border, tabbar circuit border
        "--br-circuit-cur": "#cccccc",
        "--bg-circuit": "#727d8d",
        "--bg-primary-moz": "#0f111ae6", //dialog bg
        "--bg-primary-chr": "#0f111ab3", //dialog bg
        "--bg-tabs": "#727d8d", //tabs bar primary bg,
        "--bg-icons": "#4d647a", //ce icon bg
        "--bg-text": "#727d8d", //drop down, content menu, text bg on hover
        "--bg-secondary": "#536c84", //border color input button,
        "--canvas-fill": "#1B2C33", //canvas bg
        "--canvas-stroke": "#6A7980", //canvas stroke
        "--bg-toggle-btn-primary": "#48a69d",
        "--primary-btn-hov": "#3f9189",
        "--btn-danger": "#c33c6c",
        "--btn-danger-darken": "#b03662",
        "--qp-br-tl": "#282d46", //more ligthen than qp box shadow 1
        "--qp-br-rd": "#1d2132",
        "--qp-box-shadow-1": "#1d2132", //lil lighten base
        "--qp-box-shadow-2": "#0a0b11", //lil darken base
        "--cus-btn-hov--bg": "#48a69d",
        "--cus-btn-hov-text": "#fff",

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
        name: "Night Sky",
    },
    {
        "--primary": "#EAEAEB", //header bg
        "--text-dark": "#6B6B6B", //normal state text
        "--text-lite": "white", //text state on hover, on drop down menu , context menu
        "--text-panel": "#6B6B6B",
        
        "--bg-navbar":"#6b6b6b",
        "--text-navbar": "white",
        "--qp-br-tl": "#969696", //more ligthen than qp box shadow 1
        "--qp-br-rd": "#545454",
        "--qp-box-shadow-1": "#747474", //lil lighten base .. top left shadow
        "--qp-box-shadow-2": "#5f5f5f", //lil darken base //down right shadow
        
        // "--bg-tabs": "#EAEAEB", //tabs bar primary bg,
        "--bg-tabs": "#D7D7D7", //tabs bar primary bg,
        "--br-circuit-cur": "#42B983",
        "--bg-circuit": "#A4A4A4",
        "--br-circuit": "#42B983", 

        "--br-primary": "#42B983", //panel border, tabbar circuit border

        "--context-text-hov": "#6B6B6B",
        "--context-text": "white",

        "--bg-primary-moz": "rgba(107, 107, 107, 0.904)", //dialog bg, navbar dropwdown //.9 opacity of nav
        "--bg-primary-chr": "rgba(107, 107, 107, 0.704)", //dialog bg navbar dropwdown // .7 opacity of nav

        "--bg-icons": "#DDDDDD", //ce icon bg

        "--bg-text": "#ddd", //drop down, content menu, text bg on hover

        "--bg-secondary": "#6B6B6B", //border color input button,

        "--bg-toggle-btn-primary": "#42B983",
        "--primary-btn-hov": "#66C89C",
        "--btn-danger": "#BF2424",
        "--btn-danger-darken": "#BF414C",
        "--cus-btn-hov--bg": "#42B983",
        "--cus-btn-hov-text": "#fff",
        
        "--canvas-fill": "white", //canvas bg
        "--canvas-stroke": "#BABABA", //canvas stroke
        "--node": "#42B983",
        "--stroke": "#6B6B6B",
        "--fill": "#EAEAEB",
        "--hover-and-sel": "#FFE99B", //yellow
        "--wire-draw": "#6B6B6B", //black
        "--wire-cnt": "#42B983", //
        "--wire-pow": "#52E539",
        "--wire-sel": "#0FB2F2",
        "--wire-lose": "#F10530",
        "--mini-map": "#42B983",
        "--mini-map-stroke": "#0FB2F2",
        "--input-text": "#42B983",
        "--output-rect": "#0487D9",
        "--secondary-stroke": "#F10530",
        "--text": "#454545",
        "--wire-norm": "#006839",
        "--node-norm": "#FFC231",
        "--splitter": "#00B462",
        name: "Lite-born Spring",
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
//             "--text-lite-nav": "#557493", //project title font color
//             "--text-seconday-nav": "#557493", //menu font color
//             "--text-alternate-nav": "#ffffff", // text-color on hover
//             dropdown: {
//                 "--text-lite-drop": "#557493", //dropdown font color
//                 "--text-alternate-drop": "#557493", //dropdown font color on hover
//             },
//         },
//         sideMenu: {
//             "--bg-primary-side": "#557493", //side menu bg color
//             "--text-lite-side": "#557493", //heading text font color of side menu
//             circuitElements: {
//                 "--bg-primary-circuit": "#557493", //circuit elements options bg color
//                 "--bg-secondary-circuit": "#557493", //circuit elements option dropdown bg color
//                 "--text-lite-circuit": "#557493", //circuit elements option font color
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
//             "--text-lite-nav": "#557493", //project title font color
//             "--text-seconday-nav": "#557493", //menu font color
//             "--text-alternate-nav": "#ffffff", // text-color on hover
//             dropdown: {
//                 "--text-lite-drop": "#557493", //dropdown font color
//                 "--text-alternate-drop": "#557493", //dropdown font color on hover
//             },
//         },
//         sideMenu: {
//             "--bg-primary-side": "#557493", //side menu bg color
//             "--text-lite-side": "#557493", //heading text font color of side menu
//             circuitElements: {
//                 "--bg-primary-circuit": "#557493", //circuit elements options bg color
//                 "--bg-secondary-circuit": "#557493", //circuit elements option dropdown bg color
//                 "--text-lite-circuit": "#557493", //circuit elements option font color
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
            $('.ui-dialog').find('button:first').trigger('click');
        }
        if (e.which === 27) {
            updateThemeForStyle(localStorage.getItem('theme'));
            hackCanvas();
            // $('.ui-dialog').find('button:first').trigger('click');
        }
    });
}

const hackCanvas = () => {
    // globalScope.scale -= 0.0000000000001; //hack
    dots(true, false, true);
}

(() => {
    if (!localStorage.getItem('theme')) localStorage.setItem('theme', 'Default Theme');
    updateThemeForStyle(localStorage.getItem('theme'));
})();
