import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo,
} from '../canvasApi';

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
export default class Arrow extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT') {
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
        const ctx = simulationArea.context;
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.strokeStyle = 'red';
        ctx.fillStyle = 'white';

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
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
    }
}

/**
 * @memberof Arrow
 * Help Tip
 * @type {string}
 * @category modules
 */
Arrow.prototype.tooltipText = 'Arrow ToolTip : Arrow Selected.';
Arrow.prototype.propagationDelayFixed = true;
Arrow.prototype.helplink = 'https://docs.circuitverse.org/#/annotation?id=arrow';
Arrow.prototype.objectType = 'Arrow';
