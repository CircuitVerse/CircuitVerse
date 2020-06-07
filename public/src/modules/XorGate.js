import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, bezierCurveTo, moveTo, arc2,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * XorGate
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputs - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class XorGate extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['XorGate'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 20);

        this.inp = [];
        this.inputSize = inputs;

        if (inputs % 2 === 1) {
            for (let i = 0; i < inputs / 2 - 1; i++) {
                const a = new Node(-20, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            let a = new Node(-20, 0, 0, this);
            this.inp.push(a);
            for (let i = inputs / 2 + 1; i < inputs; i++) {
                a = new Node(-20, 10 * (i + 1 - inputs / 2 - 1), 0, this);
                this.inp.push(a);
            }
        } else {
            for (let i = 0; i < inputs / 2; i++) {
                const a = new Node(-20, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            for (let i = inputs / 2; i < inputs; i++) {
                const a = new Node(-20, 10 * (i + 1 - inputs / 2), 0, this);
                this.inp.push(a);
            }
        }
        this.output1 = new Node(20, 0, 1, this);
    }

    /**
     * @memberof XorGate
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        // //console.log(this.scope.allNodes);
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
     * @memberof XorGate
     * resolve output values based on inputData
     */
    resolve() {
        let result = this.inp[0].value || 0;
        if (this.isResolvable() === false) {
            return;
        }
        for (let i = 1; i < this.inputSize; i++) result ^= (this.inp[i].value || 0);

        this.output1.value = result;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof XorGate
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
        // arc(ctx, 0, 0, -20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
        ctx.closePath();
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        arc2(ctx, -35, 0, 25, 1.70 * (Math.PI), 0.30 * (Math.PI), xx, yy, this.direction);
        ctx.stroke();
    }
}

/**
 * @memberof XorGate
 * Help Tip
 * @type {string}
 * @category modules
 */
XorGate.prototype.tooltipText = 'Xor Gate Tooltip : Implements an exclusive OR.';

/**
 * @memberof XorGate
 * @type {boolean}
 * @category modules
 */
XorGate.prototype.alwaysResolve = true;

/**
 * @memberof XorGate
 * function to change input nodes of the element
 * @category modules
 */
XorGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof XorGate
 * @type {string}
 * @category modules
 */
XorGate.prototype.verilogType = 'xor';
XorGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=xor-gate';
XorGate.prototype.objectType = 'XorGate';
