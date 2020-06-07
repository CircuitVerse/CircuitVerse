import CircuitElement from '../circuitElement';
import Node, { findNode, extractBits } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, rect, fillText } from '../canvasApi';
/**
 * @class
 * BitSelector
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} selectorBitWidth - 1 by default
 * @category modules
 */
export default class BitSelector extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = 'RIGHT',
        bitWidth = 2,
        selectorBitWidth = 1,
    ) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['BitSelector'].push(this);
        */
        this.setDimensions(20, 20);
        this.selectorBitWidth = selectorBitWidth || parseInt(prompt('Enter Selector bitWidth'), 10);
        this.rectangleObject = false;
        this.inp1 = new Node(-20, 0, 0, this, this.bitWidth, 'Input');
        this.output1 = new Node(20, 0, 1, this, 1, 'Output');
        this.bitSelectorInp = new Node(0, 20, 0, this, this.selectorBitWidth, 'Bit Selector');
    }

    /**
     * @memberof BitSelector
     * Function to change selector Bitwidth
     * @param {size}
     */
    changeSelectorBitWidth(size) {
        if (size === undefined || size < 1 || size > 32) return;
        this.selectorBitWidth = size;
        this.bitSelectorInp.bitWidth = size;
    }

    /**
     * @memberof BitSelector
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {

            nodes: {
                inp1: findNode(this.inp1),
                output1: findNode(this.output1),
                bitSelectorInp: findNode(this.bitSelectorInp),
            },
            constructorParamaters: [this.direction, this.bitWidth, this.selectorBitWidth],
        };
        return data;
    }

    /**
     * @memberof BitSelector
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.inp1.bitWidth = bitWidth;
        this.bitWidth = bitWidth;
    }

    /**
     * @memberof BitSelector
     * resolve output values based on inputData
     */
    resolve() {
        this.output1.value = extractBits(this.inp1.value, this.bitSelectorInp.value + 1, this.bitSelectorInp.value + 1); // (this.inp1.value^(1<<this.bitSelectorInp.value))==(1<<this.bitSelectorInp.value);
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof BitSelector
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = ['blue', 'red'][(this.state === undefined) + 0];
        ctx.fillStyle = 'white';
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        rect(ctx, xx - 20, yy - 20, 40, 40);
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.font = '20px Georgia';
        ctx.fillStyle = 'green';
        ctx.textAlign = 'center';
        let bit;
        if (this.bitSelectorInp.value === undefined) { bit = 'x'; } else { bit = this.bitSelectorInp.value; }

        fillText(ctx, bit, xx, yy + 5);
        ctx.fill();
    }
}

/**
 * @memberof BitSelector
 * Help Tip
 * @type {string}
 * @category modules
 */
BitSelector.prototype.tooltipText = 'BitSelector ToolTip : Divides input bits into several equal-sized groups.';
BitSelector.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=bit-selector';

/**
 * @memberof BitSelector
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
BitSelector.prototype.mutableProperties = {
    selectorBitWidth: {
        name: 'Selector Bit Width: ',
        type: 'number',
        max: '32',
        min: '1',
        func: 'changeSelectorBitWidth',
    },
};
BitSelector.prototype.objectType = 'BitSelector';
