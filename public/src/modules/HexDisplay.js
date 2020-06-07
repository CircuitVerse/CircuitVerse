import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, arc,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * HexDisplay
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @category modules
 */
export default class HexDisplay extends CircuitElement {
    constructor(x, y, scope = globalScope) {
        super(x, y, scope, 'RIGHT', 4);
        /* this is done in this.baseSetup() now
        this.scope['HexDisplay'].push(this);
        */
        this.directionFixed = true;
        this.fixedBitWidth = true;
        this.setDimensions(30, 50);
        this.inp = new Node(0, -50, 0, this, 4);
        this.direction = 'RIGHT';
    }

    /**
     * @memberof HexDisplay
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {

            nodes: {
                inp: findNode(this.inp),
            },

        };
        return data;
    }

    /**
     * @memberof HexDisplay
     * function to draw element
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
     * @memberof HexDisplay
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;

        const xx = this.x;
        const yy = this.y;

        ctx.strokeStyle = 'black';
        ctx.lineWidth = correctWidth(3);
        let a = 0; let b = 0; let c = 0; let d = 0; let e = 0; let f = 0; let
            g = 0;
        switch (this.inp.value) {
        case 0:
            a = b = c = d = e = f = 1;
            break;
        case 1:
            b = c = 1;
            break;
        case 2:
            a = b = g = e = d = 1;
            break;
        case 3:
            a = b = g = c = d = 1;
            break;
        case 4:
            f = g = b = c = 1;
            break;
        case 5:
            a = f = g = c = d = 1;
            break;
        case 6:
            a = f = g = e = c = d = 1;
            break;
        case 7:
            a = b = c = 1;
            break;
        case 8:
            a = b = c = d = e = g = f = 1;
            break;
        case 9:
            a = f = g = b = c = 1;
            break;
        case 0xA:
            a = f = b = c = g = e = 1;
            break;
        case 0xB:
            f = e = g = c = d = 1;
            break;
        case 0xC:
            a = f = e = d = 1;
            break;
        case 0xD:
            b = c = g = e = d = 1;
            break;
        case 0xE:
            a = f = g = e = d = 1;
            break;
        case 0xF:
            a = f = g = e = 1;
            break;
        default:
        }
        this.customDrawSegment(18, -3, 18, -38, ['lightgrey', 'red'][b]);
        this.customDrawSegment(18, 3, 18, 38, ['lightgrey', 'red'][c]);
        this.customDrawSegment(-18, -3, -18, -38, ['lightgrey', 'red'][f]);
        this.customDrawSegment(-18, 3, -18, 38, ['lightgrey', 'red'][e]);
        this.customDrawSegment(-17, -38, 17, -38, ['lightgrey', 'red'][a]);
        this.customDrawSegment(-17, 0, 17, 0, ['lightgrey', 'red'][g]);
        this.customDrawSegment(-15, 38, 17, 38, ['lightgrey', 'red'][d]);
    }
}

/**
 * @memberof HexDisplay
 * Help Tip
 * @type {string}
 * @category modules
 */
HexDisplay.prototype.tooltipText = 'Hex Display ToolTip: Inputs a 4 Bit Hex number and displays it.';

/**
 * @memberof HexDisplay
 * Help URL
 * @type {string}
 * @category modules
 */
HexDisplay.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=hex-display';
HexDisplay.prototype.objectType = 'HexDisplay';
