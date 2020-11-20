/* eslint-disable no-bitwise */
import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';

/**
 * @class
 * verilogShiftLeft
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node. modules
 * @category modules
 */
export default class verilogShiftLeft extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, outputBitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['verilogShiftLeft'].push(this);
        */
        this.setDimensions(20, 20);
        this.outputBitWidth = outputBitWidth;
        this.inp1 = new Node(-20, -10, 0, this, this.bitWidth, 'Input');
        this.shiftInp = new Node(-20, 0, 0, this, this.bitWidth, 'ShiftInput');
        this.output1 = new Node(20, 0, 1, this, this.outputBitWidth, 'Output');
    }

    /**
     * @memberof verilogShiftLeft
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth, this.outputBitWidth],
            nodes: {
                inp1: findNode(this.inp1),
                shiftInp: findNode(this.shiftInp),
                output1: findNode(this.output1),
            },
        };
        return data;
    }

    /**
     * @memberof verilogShiftLeft
     * Checks if the element is resolvable
     * @return {boolean}
     */
    isResolvable() {
        return this.inp1.value !== undefined && this.shiftInp.value !== undefined;
    }

    /**
     * @memberof verilogShiftLeft
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.inp1.bitWidth = bitWidth;
        this.shiftInp.bitWidth = bitWidth;
        this.output1.bitWidth = bitWidth;
    }

    /**
     * @memberof verilogShiftLeft
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        const output1 = this.inp1.value << this.shiftInp.value;

        this.output1.value = ((output1) << (32 - this.outputBitWidth)) >>> (32 - this.outputBitWidth);
        simulationArea.simulationQueue.add(this.output1);
    }
}

/**
 * @memberof verilogShiftLeft
 * Help Tip
 * @type {string}
 * @category modules
 */
verilogShiftLeft.prototype.tooltipText = 'verilogShiftLeft ToolTip : Performs addition of numbers.';
verilogShiftLeft.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=verilogShiftLeft';
verilogShiftLeft.prototype.objectType = 'verilogShiftLeft';
