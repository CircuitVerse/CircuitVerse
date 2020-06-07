import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, rect2, fillText, oppositeDirection,
} from '../canvasApi';


function bin2dec(binString) {
    return parseInt(binString, 2);
}

function dec2bin(dec, bitWidth = undefined) {
    // only for positive nos
    const bin = (dec).toString(2);
    if (bitWidth == undefined) return bin;
    return '0'.repeat(bitWidth - bin.length) + bin;
}

/**
 * @class
 * ConstantVal
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {string=} state - The state of element
 * @category modules
 */
export default class ConstantVal extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, state = '0') {
        // state = state || prompt('Enter value');
        super(x, y, scope, dir, state.length);
        /* this is done in this.baseSetup() now
            this.scope['ConstantVal'].push(this);
        */
        this.state = state;
        this.setDimensions(10 * this.state.length, 10);
        this.bitWidth = bitWidth || this.state.length;
        this.directionFixed = true;
        this.orientationFixed = false;
        this.rectangleObject = false;

        this.output1 = new Node(this.bitWidth * 10, 0, 1, this);
        this.wasClicked = false;
        this.label = '';
    }

    generateVerilog() {
        return `localparam [${this.bitWidth - 1}:0] ${this.verilogLabel}=${this.bitWidth}b'${this.state};`;
    }

    /**
     * @memberof ConstantVal
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            nodes: {
                output1: findNode(this.output1),
            },
            constructorParamaters: [this.direction, this.bitWidth, this.state],
        };
        return data;
    }

    /**
     * @memberof ConstantVal
     * resolve output values based on inputData
     */
    resolve() {
        this.output1.value = bin2dec(this.state);
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof ConstantVal
     * updates state using a prompt when dbl clicked
     */
    dblclick() {
        this.state = prompt('Re enter the value') || '0';
        this.newBitWidth(this.state.toString().length);
        // console.log(this.state, this.bitWidth);
    }

    /**
     * @memberof ConstantVal
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        if (bitWidth > this.state.length) this.state = '0'.repeat(bitWidth - this.state.length) + this.state;
        else if (bitWidth < this.state.length) this.state = this.state.slice(this.bitWidth - bitWidth);
        this.bitWidth = bitWidth; // ||parseInt(prompt("Enter bitWidth"),10);
        this.output1.bitWidth = bitWidth;
        this.setDimensions(10 * this.bitWidth, 10);
        if (this.direction === 'RIGHT') {
            this.output1.x = 10 * this.bitWidth;
            this.output1.leftx = 10 * this.bitWidth;
        } else if (this.direction === 'LEFT') {
            this.output1.x = -10 * this.bitWidth;
            this.output1.leftx = 10 * this.bitWidth;
        }
    }

    /**
     * @memberof ConstantVal
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = ('rgba(0,0,0,1)');
        ctx.fillStyle = 'white';
        ctx.lineWidth = correctWidth(1);
        const xx = this.x;
        const yy = this.y;

        rect2(ctx, -10 * this.bitWidth, -10, 20 * this.bitWidth, 20, xx, yy, 'RIGHT');
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.fillStyle = 'green';
        ctx.textAlign = 'center';
        const bin = this.state; // dec2bin(this.state,this.bitWidth);
        for (let k = 0; k < this.bitWidth; k++) { fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5); }
        ctx.fill();
    }

    /**
     * @memberof ConstantVal
     * function to change direction of ConstantVal
     * @param {string} dir - new direction
     */
    newDirection(dir) {
        if (dir === this.direction) return;
        this.direction = dir;
        this.output1.refresh();
        if (dir === 'RIGHT' || dir === 'LEFT') {
            this.output1.leftx = 10 * this.bitWidth;
            this.output1.lefty = 0;
        } else {
            this.output1.leftx = 10; // 10*this.bitWidth;
            this.output1.lefty = 0;
        }

        this.output1.refresh();
        this.labelDirection = oppositeDirection[this.direction];
    }
}

/**
 * @memberof ConstantVal
 * Help Tip
 * @type {string}
 * @category modules
 */
ConstantVal.prototype.tooltipText = 'Constant ToolTip: Bits are fixed. Double click element to change the bits.';

/**
 * @memberof ConstantVal
 * Help URL
 * @type {string}
 * @category modules
 */
ConstantVal.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=constantval';

/**
 * @memberof ConstantVal
 * @type {number}
 * @category modules
 */
ConstantVal.prototype.propagationDelay = 0;
ConstantVal.prototype.objectType = 'ConstantVal';
