import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, drawCircle2,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * NotGate
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class NotGate extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['NotGate'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 15);

        this.inp1 = new Node(-10, 0, 0, this);
        this.output1 = new Node(20, 0, 1, this);
    }

    /**
     * @memberof NotGate
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
     * @memberof NotGate
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        this.output1.value = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof NotGate
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.strokeStyle = 'black';
        ctx.lineWidth = correctWidth(3);

        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = 'white';
        moveTo(ctx, -10, -10, xx, yy, this.direction);
        lineTo(ctx, 10, 0, xx, yy, this.direction);
        lineTo(ctx, -10, 10, xx, yy, this.direction);
        ctx.closePath();
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        drawCircle2(ctx, 15, 0, 5, xx, yy, this.direction);
        ctx.stroke();
    }
}

/**
 * @memberof NotGate
 * Help Tip
 * @type {string}
 * @category modules
 */
NotGate.prototype.tooltipText = 'Not Gate Tooltip : Inverts the input digital signal.';
NotGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=not-gate';
NotGate.prototype.objectType = 'NotGate';
