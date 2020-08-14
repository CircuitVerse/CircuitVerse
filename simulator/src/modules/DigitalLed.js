import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, arc, colorToRGBA } from "../canvasApi";
import { changeInputSize } from "../modules";
/**
 * @class
 * DigitalLed
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} color - color of led
 * @category modules
 */
import { colors } from "../themer/themer";

export default class DigitalLed extends CircuitElement {
    constructor(x, y, scope = globalScope, color = "Red") {
        // Calling base class constructor

        super(x, y, scope, "UP", 1);
        /* this is done in this.baseSetup() now
        this.scope['DigitalLed'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(10, 20);
        this.inp1 = new Node(-40, 0, 0, this, 1);
        this.directionFixed = true;
        this.fixedBitWidth = true;
        this.color = color;
        const temp = colorToRGBA(this.color);
        this.actualColor = `rgba(${temp[0]},${temp[1]},${temp[2]},${0.8})`;
    }

    /**
     * @memberof DigitalLed
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.color],
            nodes: {
                inp1: findNode(this.inp1),
            },
        };
        return data;
    }

    /**
     * @memberof DigitalLed
     * function to change color of the led
     */
    changeColor(value) {
        if (validColor(value)) {
            this.color = value;
            const temp = colorToRGBA(this.color);
            this.actualColor = `rgba(${temp[0]},${temp[1]},${temp[2]},${0.8})`;
        }
    }

    /**
     * @memberof DigitalLed
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;

        const xx = this.x;
        const yy = this.y;

        ctx.strokeStyle = "#e3e4e5";
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        moveTo(ctx, -20, 0, xx, yy, this.direction);
        lineTo(ctx, -40, 0, xx, yy, this.direction);
        ctx.stroke();

        ctx.strokeStyle = "#d3d4d5";
        ctx.fillStyle = ["rgba(227,228,229,0.8)", this.actualColor][
            this.inp1.value || 0
        ];
        ctx.lineWidth = correctWidth(1);

        ctx.beginPath();

        moveTo(ctx, -15, -9, xx, yy, this.direction);
        lineTo(ctx, 0, -9, xx, yy, this.direction);
        arc(ctx, 0, 0, 9, -Math.PI / 2, Math.PI / 2, xx, yy, this.direction);
        lineTo(ctx, -15, 9, xx, yy, this.direction);
        lineTo(ctx, -18, 12, xx, yy, this.direction);
        arc(
            ctx,
            0,
            0,
            Math.sqrt(468),
            Math.PI / 2 + Math.acos(12 / Math.sqrt(468)),
            -Math.PI / 2 - Math.asin(18 / Math.sqrt(468)),
            xx,
            yy,
            this.direction
        );
        lineTo(ctx, -15, -9, xx, yy, this.direction);
        ctx.stroke();
        if (
            (this.hover && !simulationArea.shiftDown) ||
            simulationArea.lastSelected === this ||
            simulationArea.multipleObjectSelections.contains(this)
        )
            ctx.fillStyle = colors["hover_select"];
        ctx.fill();
    }
}

/**
 * @memberof DigitalLed
 * Help Tip
 * @type {string}
 * @category modules
 */
DigitalLed.prototype.tooltipText =
    "Digital Led ToolTip: Digital LED glows high when input is High(1).";

/**
 * @memberof DigitalLed
 * Help URL
 * @type {string}
 * @category modules
 */
DigitalLed.prototype.helplink =
    "https://docs.circuitverse.org/#/outputs?id=digital-led";

/**
 * @memberof DigitalLed
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
DigitalLed.prototype.mutableProperties = {
    color: {
        name: "Color: ",
        type: "text",
        func: "changeColor",
    },
};
DigitalLed.prototype.objectType = "DigitalLed";
