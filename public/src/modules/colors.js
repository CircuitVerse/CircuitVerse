// const colors = {
//     "hover_select": hover_select,
// }

const getColors = () => {
    let colors = {};
    colors["hover_select"] = getComputedStyle(document.documentElement).getPropertyValue('--hover-and-sel');
    colors["fill"] = getComputedStyle(document.documentElement).getPropertyValue('--fill');
    colors["stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--stroke');
    return colors;
}

export default getColors;