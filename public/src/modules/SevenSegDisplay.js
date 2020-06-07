import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, rect,
} from '../canvasApi';

/**
 * @class
 * SevenSegDisplay
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @category modules
 */
export default class SevenSegDisplay extends CircuitElement {
    constructor(x, y, scope = globalScope) {
        super(x, y, scope, 'RIGHT', 1);
        /* this is done in this.baseSetup() now
        this.scope['SevenSegDisplay'].push(this);
        */
        this.fixedBitWidth = true;
        this.directionFixed = true;
        this.setDimensions(30, 50);

        this.g = new Node(-20, -50, 0, this);
        this.f = new Node(-10, -50, 0, this);
        this.a = new Node(+10, -50, 0, this);
        this.b = new Node(+20, -50, 0, this);
        this.e = new Node(-20, +50, 0, this);
        this.d = new Node(-10, +50, 0, this);
        this.c = new Node(+10, +50, 0, this);
        this.dot = new Node(+20, +50, 0, this);
        this.direction = 'RIGHT';
    }

    /**
     * @memberof SevenSegDisplay
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {

            nodes: {
                g: findNode(this.g),
                f: findNode(this.f),
                a: findNode(this.a),
                b: findNode(this.b),
                d: findNode(this.d),
                e: findNode(this.e),
                c: findNode(this.c),
                dot: findNode(this.dot),
            },
        };
        return data;
    }

    /**
     * @memberof SevenSegDisplay
     * helper function to create save Json Data of object
     */
    customDrawSegment(x1, y1, x2, y2, color) {
        if (color === undefined) color = 'lightgrey';
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = correctWidth(5);
        const xx = this.x;
        const yy = this.y;
        moveTo(ctx, x1, y1, xx, yy, this.direction);
        lineTo(ctx, x2, y2, xx, yy, this.direction);
        ctx.closePath();
        ctx.stroke();
    }

    /**
     * @memberof SevenSegDisplay
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        this.customDrawSegment(18, -3, 18, -38, ['lightgrey', 'red'][this.b.value]);
        this.customDrawSegment(18, 3, 18, 38, ['lightgrey', 'red'][this.c.value]);
        this.customDrawSegment(-18, -3, -18, -38, ['lightgrey', 'red'][this.f.value]);
        this.customDrawSegment(-18, 3, -18, 38, ['lightgrey', 'red'][this.e.value]);
        this.customDrawSegment(-17, -38, 17, -38, ['lightgrey', 'red'][this.a.value]);
        this.customDrawSegment(-17, 0, 17, 0, ['lightgrey', 'red'][this.g.value]);
        this.customDrawSegment(-15, 38, 17, 38, ['lightgrey', 'red'][this.d.value]);
        ctx.beginPath();
        const dotColor = ['lightgrey', 'red'][this.dot.value] || 'lightgrey';
        ctx.strokeStyle = dotColor;
        rect(ctx, xx + 22, yy + 42, 2, 2);
        ctx.stroke();
    }
}

/**
 * @memberof SevenSegDisplay
 * Help Tip
 * @type {string}
 * @category modules
 */
SevenSegDisplay.prototype.tooltipText = 'Seven Display ToolTip: Consists of 7+1 single bit inputs.';

/**
 * @memberof SevenSegDisplay
 * Help URL
 * @type {string}
 * @category modules
 */
SevenSegDisplay.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=seven-segment-display';
SevenSegDisplay.prototype.objectType = 'SevenSegDisplay';
