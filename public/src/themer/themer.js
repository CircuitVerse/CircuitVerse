const themeOptions = [
    {
        "--bg-primary": "#181818",
        "--bg-secondary": "#282828",
        "--primary": "#1db954",
        "--text-alternate": "#666666",
        "--text-primary": "#ffffff",
        "--text-secondary": "#b3b3b3",
        name: "default",
    },
    {
        "--bg-primary": "#1e352f",
        "--bg-secondary": "#335145",
        "--primary": "#828c51",
        "--text-alternate": "#a6c36f",
        "--text-primary": "#ffffff",
        "--text-secondary": "#beef9e",
        name: "Jungle",
    },
    {
        "--bg-primary": "#00293c",
        "--bg-secondary": "#257985",
        "--primary": "#ff4447",
        "--text-alternate": "#5ea8a7",
        "--text-primary": "#ffffff",
        "--text-secondary": "#f0eff0",
        name: "Summit",
    },
    {
        "--bg-primary": "#a8b0b8",
        "--bg-secondary": "#b8d0d0",
        "--primary": "#f89070",
        "--text-alternate": "#703858",
        "--text-primary": "#ffffff",
        "--text-secondary": "#f8e0a0",
        name: "Casino",
    },
    {
        "--bg-primary": "#515365",
        "--bg-secondary": "#8badaa",
        "--primary": "#cecbb4",
        "--text-alternate": "#ffffff",
        "--text-primary": "#d27f65",
        "--text-secondary": "#5d8198",
        name: "Seastar",
    },
    {
        "--bg-primary": "#5b6678",
        "--bg-secondary": "#7d899a",
        "--primary": "#ffb8b8",
        "--text-alternate": "#ffffff",
        "--text-primary": "#ffebd2",
        "--text-secondary": "#b5b7b4",
        name: "Jurassic",
    },
    {
        "--bg-primary": "#634e4e",
        "--bg-secondary": "#986464",
        "--primary": "#80b5bd",
        "--text-alternate": "#ffffff",
        "--text-primary": "#eabebe",
        "--text-secondary": "#eee2e2",
        name: "Beachfront",
    },
    {
        "--bg-primary": "#d6ae7c",
        "--bg-secondary": "#a9978b",
        "--primary": "#464776",
        "--text-alternate": "#ffffff",
        "--text-primary": "#d8dbb2",
        "--text-secondary": "#a2a5b4",
        name: "Salamander",
    },
    {
        "--bg-primary": "#557493",
        "--bg-secondary": "#a9c391",
        "--primary": "#ffd2da",
        "--text-alternate": "#ffffff",
        "--text-primary": "#f2f2f2",
        "--text-secondary": "#eeeeee",
        name: "Retro",
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