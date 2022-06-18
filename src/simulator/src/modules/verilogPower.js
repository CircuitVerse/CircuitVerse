/* eslint-disable no-bitwise */
import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';

/**
 * @class
 * verilogPower
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node. modules
 * @category modules
 */
export default class verilogPower extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, outputBitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['verilogPower'].push(this);
        */
        this.setDimensions(20, 20);
        this.outputBitWidth = outputBitWidth;
        this.inpA = new Node(-20, -10, 0, this, this.bitWidth, 'A');
        this.inpB = new Node(-20, 0, 0, this, this.bitWidth, 'B');
        this.answer = new Node(20, 0, 1, this, this.outputBitWidth, 'Answer');
    }

    /**
     * @memberof verilogPower
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth, this.outputBitWidth],
            nodes: {
                inpA: findNode(this.inpA),
                inpB: findNode(this.inpB),
                answer: findNode(this.answer),
            },
        };
        return data;
    }

    /**
     * @memberof verilogPower
     * Checks if the element is resolvable
     * @return {boolean}
     */
    isResolvable() {
        return this.inpA.value !== undefined && this.inpB.value !== undefined;
    }

    /**
     * @memberof verilogPower
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.inpA.bitWidth = bitWidth;
        this.inpB.bitWidth = bitWidth;
        this.answer.bitWidth = bitWidth;
    }

    /**
     * @memberof verilogPower
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        const answer = Math.pow(this.inpA.value, this.inpB.value);

        this.answer.value = ((answer) << (32 - this.outputBitWidth)) >>> (32 - this.outputBitWidth);
        simulationArea.simulationQueue.add(this.answer);
    }
}

/**
 * @memberof verilogPower
 * Help Tip
 * @type {string}
 * @category modules
 */
verilogPower.prototype.tooltipText = 'verilogPower ToolTip : Performs addition of numbers.';
verilogPower.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=verilogPower';
verilogPower.prototype.objectType = 'verilogPower';
