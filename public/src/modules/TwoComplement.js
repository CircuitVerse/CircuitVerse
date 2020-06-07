import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, arc,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * TwoComplement
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class TwoComplement extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['TwoComplement'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 15);
        this.inp1 = new Node(-10, 0, 0, this, this.bitWidth, 'input stream');
        this.output1 = new Node(20, 0, 1, this, this.bitWidth, "2's complement");
    }

    /**
     * @memberof TwoComplement
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                output1: findNode(this.output1),
                inp1: findNode(this.inp1),
            },
        };
        return data;
    }

    /**
     * @memberof TwoComplement
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        let output = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        output += 1;
        this.output1.value = ((output) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof TwoComplement
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.strokeStyle = 'black';
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = 'black';
        fillText(ctx, "2'", xx, yy, 10);
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.beginPath();
        drawCircle2(ctx, 5, 0, 15, xx, yy, this.direction);
        ctx.stroke();
    }
}

/**
 * @memberof TwoComplement
 * Help Tip
 * @type {string}
 * @category modules
 */
TwoComplement.prototype.tooltipText = "Two's Complement Tooltip : Calculates the two's complement";
TwoComplement.prototype.objectType = 'TwoComplement';
