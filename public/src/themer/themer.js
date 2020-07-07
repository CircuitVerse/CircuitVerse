const themeOptions = [
    {
        "--primary": "#0F111A",
        "--text-primary": "#FFF",
        "--text-secondary": "#000",
        "--br-primary": "#665627",
        "--bg-primary-moz": "#0f111ae6", 
        "--bg-primary-chr": "#0f111ab3",
        "--bg-tabs": "#8b8b8b",
        "--bg-icons": "#2f3550",
        "--bg-text": "#49527a",
        "--bg-secondary": "#40486b",
        name: "nightSky"
    },
];

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
        if (property == "name") return;
        html.style.setProperty(property, selectedTheme[property]);
    });
}

export default updateThemeForStyle;