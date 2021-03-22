import { colorToRGBA, validColor } from './canvasApi';

/**
 * Class for managing the color property of a CircuitElement
 * @param {string} initialColor - initial color value
 */
export default class ColorProperty {
    constructor(initialColor) {
        this.color = initialColor;
        this.actualColor = colorToRGBA(this.color);
    }

    /**
     * Change value of the color property
     * @param {string} newColor - new color value
     * @return {string} updated color value
     */
    changeColor(newColor) {
        if (validColor(newColor)) {
            this.color = newColor;
            this.actualColor = colorToRGBA(this.color);
        }
        return this.color;
    }

    /**
     * Get rgba value with custom alpha value
     * @param {number} alpha - alpha value of returned color
     * @return {string} rgba value of color
     */
    getRGBA(alpha = 0.8) {
        return `rgba(${this.actualColor[0]},${this.actualColor[1]},${this.actualColor[2]},${alpha})`;
    }

    /**
     * Creates a mutable color property object
     * @param {string} onChange - name of function triggered when property changed  
     * @return {JSON} color object as mutable property
     */
    static createMutableColorProp(onChange) {
        return {
            color: {
                name: "Color: ",
                type: "text",
                func: onChange,
            },
        };
    }
}
