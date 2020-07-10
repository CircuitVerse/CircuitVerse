// const colors = {
//     "hover_select": hover_select,
// }

const getColors = () => {
    const colors = {};
    colors["hover_select"] = getComputedStyle(document.documentElement).getPropertyValue('--hover-and-sel');
    colors["fill"] = getComputedStyle(document.documentElement).getPropertyValue('--fill');
    colors["mini_fill"] = getComputedStyle(document.documentElement).getPropertyValue('--mini-map');
    colors["mini_stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--mini-map-stroke');
    colors["stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--stroke');
    colors["stroke_alt"] = getComputedStyle(document.documentElement).getPropertyValue('--secondary-stroke');
    colors["input_text"] = getComputedStyle(document.documentElement).getPropertyValue('--input-text');
    colors["wire_draw"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-draw');
    colors["wire_con"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-cnt');
    colors["wire_pow"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-pow');
    colors["wire_sel"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-sel');
    colors["wire_lose"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-lose');
    colors["wire"] = getComputedStyle(document.documentElement).getPropertyValue('--wire-norm');
    colors["text"] = getComputedStyle(document.documentElement).getPropertyValue('--text');
    colors["node"] = getComputedStyle(document.documentElement).getPropertyValue('--node');
    colors["node_norm"] = getComputedStyle(document.documentElement).getPropertyValue('--node-norm');
    colors["splitter"] = getComputedStyle(document.documentElement).getPropertyValue('--splitter');
    colors["out_rect"] = getComputedStyle(document.documentElement).getPropertyValue('--output-rect');
    colors["canvas_stroke"] = getComputedStyle(document.documentElement).getPropertyValue('--canvas-stroke');
    colors["canvas_fill"] = getComputedStyle(document.documentElement).getPropertyValue('--canvas-fill');
    return colors;
}

export default getColors;