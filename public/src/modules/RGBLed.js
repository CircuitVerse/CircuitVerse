import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, arc,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * RGBLed
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @category modules
 */
export default class RGBLed extends CircuitElement {
    constructor(x, y, scope = globalScope) {
        // Calling base class constructor
        super(x, y, scope, 'UP', 8);
        /* this is done in this.baseSetup() now
        this.scope['RGBLed'].push(this);
        */
        this.rectangleObject = false;
        this.inp = [];
        this.setDimensions(10, 10);
        this.inp1 = new Node(-40, -10, 0, this, 8);
        this.inp2 = new Node(-40, 0, 0, this, 8);
        this.inp3 = new Node(-40, 10, 0, this, 8);
        this.inp.push(this.inp1);
        this.inp.push(this.inp2);
        this.inp.push(this.inp3);
        this.directionFixed = true;
        this.fixedBitWidth = true;
    }

    /**
     * @memberof RGBLed
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            nodes: {
                inp1: findNode(this.inp1),
                inp2: findNode(this.inp2),
                inp3: findNode(this.inp3),
            },
        };
        return data;
    }

    /**
     * @memberof RGBLed
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;

        const xx = this.x;
        const yy = this.y;

        ctx.strokeStyle = 'green';
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        moveTo(ctx, -20, 0, xx, yy, this.direction);
        lineTo(ctx, -40, 0, xx, yy, this.direction);
        ctx.stroke();

        ctx.strokeStyle = 'red';
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        moveTo(ctx, -20, -10, xx, yy, this.direction);
        lineTo(ctx, -40, -10, xx, yy, this.direction);
        ctx.stroke();

        ctx.strokeStyle = 'blue';
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        moveTo(ctx, -20, 10, xx, yy, this.direction);
        lineTo(ctx, -40, 10, xx, yy, this.direction);
        ctx.stroke();

        const a = this.inp1.value;
        const b = this.inp2.value;
        const c = this.inp3.value;
        ctx.strokeStyle = '#d3d4d5';
        ctx.fillStyle = [`rgba(${a}, ${b}, ${c}, 0.8)`, 'rgba(227, 228, 229, 0.8)'][((a === undefined || b === undefined || c === undefined)) + 0];
        // ctx.fillStyle = ["rgba(200, 200, 200, 0.3)","rgba(227, 228, 229, 0.8)"][((a === undefined || b === undefined || c === undefined) || (a === 0 && b === 0 && c === 0)) + 0];
        ctx.lineWidth = correctWidth(1);

        ctx.beginPath();

        moveTo(ctx, -18, -11, xx, yy, this.direction);
        lineTo(ctx, 0, -11, xx, yy, this.direction);
        arc(ctx, 0, 0, 11, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
        lineTo(ctx, -18, 11, xx, yy, this.direction);
        lineTo(ctx, -21, 15, xx, yy, this.direction);
        arc(ctx, 0, 0, Math.sqrt(666), ((Math.PI / 2) + Math.acos(15 / Math.sqrt(666))), ((-Math.PI / 2) - Math.asin(21 / Math.sqrt(666))), xx, yy, this.direction);
        lineTo(ctx, -18, -11, xx, yy, this.direction);
        ctx.stroke();
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
    }
}

/**
 * @memberof RGBLed
 * Help Tip
 * @type {string}
 * @category modules
 */
RGBLed.prototype.tooltipText = 'RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE.';

/**
 * @memberof RGBLed
 * Help URL
 * @type {string}
 * @category modules
 */
RGBLed.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=rgb-led';
RGBLed.prototype.objectType = 'RGBLed';
