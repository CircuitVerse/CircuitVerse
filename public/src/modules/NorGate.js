import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, bezierCurveTo, moveTo, arc2, drawCircle2,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * NorGate
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputs - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class NorGate extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['NorGate'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 20);

        this.inp = [];
        this.inputSize = inputs;

        if (inputs % 2 === 1) {
            for (let i = 0; i < inputs / 2 - 1; i++) {
                const a = new Node(-10, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            let a = new Node(-10, 0, 0, this);
            this.inp.push(a);
            for (let i = inputs / 2 + 1; i < inputs; i++) {
                a = new Node(-10, 10 * (i + 1 - inputs / 2 - 1), 0, this);
                this.inp.push(a);
            }
        } else {
            for (let i = 0; i < inputs / 2; i++) {
                const a = new Node(-10, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            for (let i = inputs / 2; i < inputs; i++) {
                const a = new Node(-10, 10 * (i + 1 - inputs / 2), 0, this);
                this.inp.push(a);
            }
        }
        this.output1 = new Node(30, 0, 1, this);
    }

    /**
     * @memberof NorGate
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
            nodes: {
                inp: this.inp.map(findNode),
                output1: findNode(this.output1),
            },
        };
        return data;
    }

    /**
     * @memberof NorGate
     * resolve output values based on inputData
     */
    resolve() {
        let result = this.inp[0].value || 0;
        for (let i = 1; i < this.inputSize; i++) result |= (this.inp[i].value || 0);
        result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        this.output1.value = result;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof NorGate
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.strokeStyle = ('rgba(0,0,0,1)');
        ctx.lineWidth = correctWidth(3);

        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = 'white';

        moveTo(ctx, -10, -20, xx, yy, this.direction, true);
        bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
        bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
        bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
        ctx.closePath();
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.5)';
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
        ctx.stroke();
        // for debugging
    }
}

/**
 * @memberof NorGate
 * Help Tip
 * @type {string}
 * @category modules
 */
NorGate.prototype.tooltipText = 'Nor Gate ToolTip : Combination of OR gate and NOT gate.';

/**
 * @memberof NorGate
 * @type {boolean}
 * @category modules
 */
NorGate.prototype.alwaysResolve = true;


/**
 * @memberof SevenSegDisplay
 * function to change input nodes of the element
 * @category modules
 */
NorGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof SevenSegDisplay
 * @type {string}
 * @category modules
 */
NorGate.prototype.verilogType = 'nor';
NorGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=nor-gate';
NorGate.prototype.objectType = 'NorGate';
