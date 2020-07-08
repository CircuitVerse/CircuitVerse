// const colors = {
//     "hover_select": hover_select,
// }

const getColors = () => {
    let colors = {};
    colors["hover_select"] = getComputedStyle(document.documentElement).getPropertyValue('--hover-and-sel');
    return colors;
}

export default getColors;