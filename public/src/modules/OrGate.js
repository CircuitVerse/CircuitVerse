import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, bezierCurveTo, moveTo, arc2,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * OrGate
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputs - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class OrGate extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
        // Calling base class constructor
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['OrGate'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 20);
        // Inherit base class prototype
        this.inp = [];
        this.inputSize = inputs;
        if (inputs % 2 === 1) {
            for (let i = Math.floor(inputs / 2) - 1; i >= 0; i--) {
                const a = new Node(-10, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            let a = new Node(-10, 0, 0, this);
            this.inp.push(a);
            for (let i = 0; i < Math.floor(inputs / 2); i++) {
                a = new Node(-10, 10 * (i + 1), 0, this);
                this.inp.push(a);
            }
        } else {
            for (let i = inputs / 2 - 1; i >= 0; i--) {
                const a = new Node(-10, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            for (let i = 0; i < inputs / 2; i++) {
                const a = new Node(-10, 10 * (i + 1), 0, this);
                this.inp.push(a);
            }
        }
        this.output1 = new Node(20, 0, 1, this);
    }

    /**
     * @memberof OrGate
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
     * @memberof OrGate
     * resolve output values based on inputData
     */
    resolve() {
        let result = this.inp[0].value || 0;
        if (this.isResolvable() === false) {
            return;
        }
        for (let i = 1; i < this.inputSize; i++) result |= (this.inp[i].value || 0);
        this.output1.value = result;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof OrGate
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
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();
    }
}

/**
 * @memberof OrGate
 * Help Tip
 * @type {string}
 * @category modules
 */
OrGate.prototype.tooltipText = 'Or Gate Tooltip : Implements logical disjunction';

/**
 * @memberof OrGate
 * function to change input nodes of the element
 * @category modules
 */
OrGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof SevenSegDisplay
 * @type {boolean}
 * @category modules
 */
OrGate.prototype.alwaysResolve = true;

/**
 * @memberof SevenSegDisplay
 * @type {string}
 * @category modules
 */
OrGate.prototype.verilogType = 'or';
OrGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=or-gate';
OrGate.prototype.objectType = 'OrGate';
