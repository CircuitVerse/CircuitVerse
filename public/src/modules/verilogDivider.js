/* eslint-disable no-bitwise */
import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';

/**
 * @class
 * verilogDivider
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node. modules
 * @category modules
 */
export default class verilogDivider extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, outputBitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['verilogDivider'].push(this);
        */
        this.setDimensions(20, 20);
        this.outputBitWidth = outputBitWidth;
        this.inpA = new Node(-20, -10, 0, this, this.bitWidth, 'A');
        this.inpB = new Node(-20, 0, 0, this, this.bitWidth, 'B');
        this.quotient = new Node(20, 0, 1, this, this.outputBitWidth, 'Quotient');
        this.remainder = new Node(20, 0, 1, this, this.outputBitWidth, 'Remainder');
    }

    /**
     * @memberof verilogDivider
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth, this.outputBitWidth],
            nodes: {
                inpA: findNode(this.inpA),
                inpB: findNode(this.inpB),
                quotient: findNode(this.quotient),
                remainder: findNode(this.remainder)
            },
        };
        return data;
    }

    /**
     * @memberof verilogDivider
     * Checks if the element is resolvable
     * @return {boolean}
     */
    isResolvable() {
        return this.inpA.value !== undefined && this.inpB.value !== undefined;
    }

    /**
     * @memberof verilogDivider
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.inpA.bitWidth = bitWidth;
        this.inpB.bitWidth = bitWidth;
        this.quotient.bitWidth = bitWidth;
        this.remainder.bitWidth = bitWidth;
    }

    /**
     * @memberof verilogDivider
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        const quotient = this.inpA.value / this.inpB.value;
        const remainder = this.inpA.value % this.inpB.value;
        this.remainder.value = ((remainder) << (32 - this.outputBitWidth)) >>> (32 - this.outputBitWidth);
        this.quotient.value = ((quotient) << (32 - this.outputBitWidth)) >>> (32 - this.outputBitWidth);
        simulationArea.simulationQueue.add(this.quotient);
        simulationArea.simulationQueue.add(this.remainder);
    }
}

/**
 * @memberof verilogDivider
 * Help Tip
 * @type {string}
 * @category modules
 */
verilogDivider.prototype.tooltipText = 'verilogDivider ToolTip : Performs addition of numbers.';
verilogDivider.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=verilogDivider';
verilogDivider.prototype.objectType = 'verilogDivider';
