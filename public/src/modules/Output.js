import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, fillText, rect2, oppositeDirection,
} from '../canvasApi';
import { getNextPosition } from '../modules';
import { generateId } from '../utils';


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
 * Output
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputLength - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class Output extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'LEFT', bitWidth = 1, layoutProperties) {
        // Calling base class constructor
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Output'].push(this);
        */
        if (layoutProperties) { this.layoutProperties = layoutProperties; } else {
            this.layoutProperties = {};
            this.layoutProperties.x = scope.layout.width;
            this.layoutProperties.y = getNextPosition(scope.layout.width, scope);
            this.layoutProperties.id = generateId();
        }

        this.rectangleObject = false;
        this.directionFixed = true;
        this.orientationFixed = false;
        this.setDimensions(this.bitWidth * 10, 10);
        this.inp1 = new Node(this.bitWidth * 10, 0, 0, this);
    }

    /**
     * @memberof Output
     * function to generate verilog for output
     * @return {string}
     */
    generateVerilog() {
        return `assign ${this.label} = ${this.inp1.verilogLabel};`;
    }

    /**
     * @memberof Output
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            nodes: {
                inp1: findNode(this.inp1),
            },
            constructorParamaters: [this.direction, this.bitWidth, this.layoutProperties],
        };
        return data;
    }

    /**
     * @memberof Output
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        if (bitWidth < 1) return;
        const diffBitWidth = bitWidth - this.bitWidth;
        this.state = undefined;
        this.inp1.bitWidth = bitWidth;
        this.bitWidth = bitWidth;
        this.setWidth(10 * this.bitWidth);

        if (this.direction === 'RIGHT') {
            this.x -= 10 * diffBitWidth;
            this.inp1.x = 10 * this.bitWidth;
            this.inp1.leftx = 10 * this.bitWidth;
        } else if (this.direction === 'LEFT') {
            this.x += 10 * diffBitWidth;
            this.inp1.x = -10 * this.bitWidth;
            this.inp1.leftx = 10 * this.bitWidth;
        }
    }

    /**
     * @memberof Output
     * function to draw element
     */
    customDraw() {
        this.state = this.inp1.value;
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = ['blue', 'red'][+(this.inp1.value === undefined)];
        ctx.fillStyle = 'white';
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;

        rect2(ctx, -10 * this.bitWidth, -10, 20 * this.bitWidth, 20, xx, yy, 'RIGHT');
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }

        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.font = '20px Georgia';
        ctx.fillStyle = 'green';
        ctx.textAlign = 'center';
        let bin;
        if (this.state === undefined) { bin = 'x'.repeat(this.bitWidth); } else { bin = dec2bin(this.state, this.bitWidth); }

        for (let k = 0; k < this.bitWidth; k++) { fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5); }
        ctx.fill();
    }

    /**
     * @memberof Output
     * function to change direction of Output
     * @param {string} dir - new direction
     */
    newDirection(dir) {
        if (dir === this.direction) return;
        this.direction = dir;
        this.inp1.refresh();
        if (dir === 'RIGHT' || dir === 'LEFT') {
            this.inp1.leftx = 10 * this.bitWidth;
            this.inp1.lefty = 0;
        } else {
            this.inp1.leftx = 10; // 10*this.bitWidth;
            this.inp1.lefty = 0;
        }

        this.inp1.refresh();
        this.labelDirection = oppositeDirection[this.direction];
    }
}

/**
 * @memberof Output
 * Help Tip
 * @type {string}
 * @category modules
 */
Output.prototype.tooltipText = 'Output ToolTip: Simple output element showing output in binary.';

/**
 * @memberof Output
 * Help URL
 * @type {string}
 * @category modules
 */
Output.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=output';

/**
 * @memberof Output
 * @type {number}
 * @category modules
 */
Output.prototype.propagationDelay = 0;
Output.prototype.objectType = 'Output';
