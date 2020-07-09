// const colors = {
//     "hover_select": hover_select,
// }

const getColors = () => {
    const colors = {};
    colors["hover_select"] = getComputedStyle(document.documentElement).getPropertyValue('--hover-and-sel');
    colors["fill"] = getComputedStyle(document.documentElement).getPropertyValue('--fill');
    colors["stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--stroke');
    colors["stroke_alt"] = getComputedStyle(document.documentElement).getPropertyValue('--secondary-stroke');
    colors["input_text"] = getComputedStyle(document.documentElement).getPropertyValue('--input-text');
    colors["wire_con"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-cnt');
    colors["wire_pow"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-pow');
    return colors;
}

export default getColors;