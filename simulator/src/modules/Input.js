/* eslint-disable no-unused-expressions */
import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, oppositeDirection, fillText,
} from '../canvasApi';
import { getNextPosition } from '../modules';
import { generateId } from '../utils';
/**
 * @class
 * Input
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {Object=} layoutProperties - x,y and id
 * @category modules
 */
import { colors } from '../themer/themer';


function bin2dec(binString) {
    return parseInt(binString, 2);
}

function dec2bin(dec, bitWidth = undefined) {
    // only for positive nos
    var bin = (dec).toString(2);
    if (bitWidth == undefined) return bin;
    return '0'.repeat(bitWidth - bin.length) + bin;
}


export default class Input extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, layoutProperties) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Input'].push(this);
        */
        if (layoutProperties) { this.layoutProperties = layoutProperties; } else {
            this.layoutProperties = {};
            this.layoutProperties.x = 0;
            this.layoutProperties.y = getNextPosition(0, scope);
            this.layoutProperties.id = generateId();
        }

        // Call base class constructor
        this.state = 0;
        this.orientationFixed = false;
        this.state = bin2dec(this.state); // in integer format
        this.output1 = new Node(this.bitWidth * 10, 0, 1, this);
        this.wasClicked = false;
        this.directionFixed = true;
        this.setWidth(this.bitWidth * 10);
        this.rectangleObject = true; // Trying to make use of base class draw
        console.log(this);
    }

    /**
     * @memberof Input
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            nodes: {
                output1: findNode(this.output1),
            },
            values: {
                state: this.state,
            },
            constructorParamaters: [this.direction, this.bitWidth, this.layoutProperties],
        };
        return data;
    }

    /**
     * @memberof Input
     * resolve output values based on inputData
     */
    resolve() {
        this.output1.value = this.state;
        simulationArea.simulationQueue.add(this.output1);
    }

    // Check if override is necessary!!

    /**
     * @memberof Input
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        if (bitWidth < 1) return;
        const diffBitWidth = bitWidth - this.bitWidth;
        this.bitWidth = bitWidth; // ||parseInt(prompt("Enter bitWidth"),10);
        this.setWidth(this.bitWidth * 10);
        this.state = 0;
        this.output1.bitWidth = bitWidth;
        if (this.direction === 'RIGHT') {
            this.x -= 10 * diffBitWidth;
            this.output1.x = 10 * this.bitWidth;
            this.output1.leftx = 10 * this.bitWidth;
        } else if (this.direction === 'LEFT') {
            this.x += 10 * diffBitWidth;
            this.output1.x = -10 * this.bitWidth;
            this.output1.leftx = 10 * this.bitWidth;
        }
    }

    /**
     * @memberof Input
     * listener function to set selected index
     */
    click() { // toggle
        let pos = this.findPos();
        if (pos === 0) pos = 1; // minor correction
        if (pos < 1 || pos > this.bitWidth) return;
        this.state = ((this.state >>> 0) ^ (1 << (this.bitWidth - pos))) >>> 0;
    }

    /**
     * @memberof Input
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        ctx.beginPath();
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = colors['input_text'];
        ctx.textAlign = 'center';
        const bin = dec2bin(this.state, this.bitWidth);
        for (let k = 0; k < this.bitWidth; k++) { fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5); }
        ctx.fill();
    }

    /**
     * @memberof Input
     * function to change direction of input
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

    /**
     * @memberof Input
     * function to find position of mouse click
     */
    findPos() {
        return Math.round((simulationArea.mouseX - this.x + 10 * this.bitWidth) / 20.0);
    }
}

/**
 * @memberof Input
 * Help Tip
 * @type {string}
 * @category modules
 */
Input.prototype.tooltipText = 'Input ToolTip: Toggle the individual bits by clicking on them.';

/**
 * @memberof Input
 * Help URL
 * @type {string}
 * @category modules
 */
Input.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=input';

/**
 * @memberof Input
 * @type {number}
 * @category modules
 */
Input.prototype.propagationDelay = 0;
Input.prototype.objectType = 'Input';
