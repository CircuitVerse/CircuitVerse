import { dots } from '../canvasApi';

const themeOptions = [
    {
        "--primary": "#0F111A", //header bg, panels bg
        "--text-primary": "#FFF", //normal state text
        "--text-secondary": "#000", //text state on hover, on drop down menu , context menu
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

        "--node":"",
        "--stroke":"",
        "--fill":"",
        "--hover-and-sel":"",
        "--wire-draw":"",
        "--wire-cnt":"",
        "--wire-pow":"",
        "--wire-sel":"",
        "--wire-lose":"",
        "--mini-map":"",
        "--mini-map-stroke":"",
        "--input-text":"",
        "--secondary-stroke":"",

        name: "nightSky",
    },
];

// document.getElementById('backgroundArea').getContext('2d').strokeStyle

//metadata.json , upto max 3rd level
const themes = [
    {
        name: "default", //theme name
        "--border-all": "#fff", //border color all
        navbar: {
            "--bg-primary-nav": "#557493", //nav-bar bg color
            "--text-primary-nav": "#557493", //project title font color
            "--text-seconday-nav": "#557493", //menu font color
            "--text-alternate-nav": "#ffffff", // text-color on hover
            dropdown: {
                "--text-primary-drop": "#557493", //dropdown font color
                "--text-alternate-drop": "#557493", //dropdown font color on hover
            },
        },
        sideMenu: {
            "--bg-primary-side": "#557493", //side menu bg color
            "--text-primary-side": "#557493", //heading text font color of side menu
            circuitElements: {
                "--bg-primary-circuit": "#557493", //circuit elements options bg color
                "--bg-secondary-circuit": "#557493", //circuit elements option dropdown bg color
                "--text-primary-circuit": "#557493", //circuit elements option font color
            },
            properties: {
                //config
            },
        },
        propertyMenu: {
            //config
        },
        canvas: {
            "--bg-primary-canvas": "#557493", //canvas bg-color
            "--primary-canvas": "#557493", //canvas grid-color
        },
    },
    {
        name: "Retro", //theme name
        "--border-all": "#fff", //border color all
        navbar: {
            "--bg-primary-nav": "#557493", //nav-bar bg color
            "--text-primary-nav": "#557493", //project title font color
            "--text-seconday-nav": "#557493", //menu font color
            "--text-alternate-nav": "#ffffff", // text-color on hover
            dropdown: {
                "--text-primary-drop": "#557493", //dropdown font color
                "--text-alternate-drop": "#557493", //dropdown font color on hover
            },
        },
        sideMenu: {
            "--bg-primary-side": "#557493", //side menu bg color
            "--text-primary-side": "#557493", //heading text font color of side menu
            circuitElements: {
                "--bg-primary-circuit": "#557493", //circuit elements options bg color
                "--bg-secondary-circuit": "#557493", //circuit elements option dropdown bg color
                "--text-primary-circuit": "#557493", //circuit elements option font color
            },
            properties: {
                //config
            },
        },
        propertyMenu: {
            //config
        },
        canvas: {
            "--bg-primary-canvas": "#557493", //canvas bg-color
            "--primary-canvas": "#557493", //canvas grid-color
        },
    },
];

function updateThemeForStyle(themeName) {
    const selectedTheme = themeOptions.find(
        (t) => t.name.toLowerCase() === themeName.toLowerCase()
    );
    const html = document.getElementsByTagName("html")[0];
    Object.keys(selectedTheme).forEach((property, i) => {
        if (property === "name") return;
        html.style.setProperty(property, selectedTheme[property]);
    });

}

export default updateThemeForStyle;
