import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, arc } from "../canvasApi";
import { changeInputSize } from "../modules";
/**
 * @class
 * Arrow
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @category modules
 */
import { colors } from "../themer/themer";

export default class Arrow extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = "RIGHT") {
        super(x, y, scope, dir, 8);
        /* this is done in this.baseSetup() now
        this.scope['Arrow'].push(this);
        */
        this.rectangleObject = false;
        this.fixedBitWidth = true;
        this.setDimensions(30, 20);
    }

    /**
     * @memberof Arrow
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction],
        };
        return data;
    }

    /**
     * @memberof Arrow
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.strokeStyle = colors["stroke_alt"];
        ctx.fillStyle = colors["fill"];

        ctx.beginPath();

        moveTo(ctx, -30, -3, xx, yy, this.direction);
        lineTo(ctx, 10, -3, xx, yy, this.direction);
        lineTo(ctx, 10, -15, xx, yy, this.direction);
        lineTo(ctx, 30, 0, xx, yy, this.direction);
        lineTo(ctx, 10, 15, xx, yy, this.direction);
        lineTo(ctx, 10, 3, xx, yy, this.direction);
        lineTo(ctx, -30, 3, xx, yy, this.direction);
        ctx.closePath();
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
 * @memberof Arrow
 * Help Tip
 * @type {string}
 * @category modules
 */
Arrow.prototype.tooltipText = "Arrow ToolTip : Arrow Selected.";
Arrow.prototype.propagationDelayFixed = true;
Arrow.prototype.helplink =
    "https://docs.circuitverse.org/#/annotation?id=arrow";
Arrow.prototype.objectType = "Arrow";
