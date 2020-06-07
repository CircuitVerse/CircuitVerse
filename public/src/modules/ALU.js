/* eslint-disable no-bitwise */
import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, fillText4,
} from '../canvasApi';

/**
 * @class
 * ALU
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class ALU extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        // //console.log("HIT");
        // //console.log(x,y,scope,dir,bitWidth,controlSignalSize);
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['ALU'].push(this);
        */
        this.message = 'ALU';

        this.setDimensions(30, 40);
        this.rectangleObject = false;

        this.inp1 = new Node(-30, -30, 0, this, this.bitwidth, 'A');
        this.inp2 = new Node(-30, 30, 0, this, this.bitwidth, 'B');

        this.controlSignalInput = new Node(-10, -40, 0, this, 3, 'Ctrl');
        this.carryOut = new Node(-10, 40, 1, this, 1, 'Cout');
        this.output = new Node(30, 0, 1, this, this.bitwidth, 'Out');
    }

    /**
     * @memberof ALU
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.inp1.bitWidth = bitWidth;
        this.inp2.bitWidth = bitWidth;
        this.output.bitWidth = bitWidth;
    }

    /**
     * @memberof ALU
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                inp1: findNode(this.inp1),
                inp2: findNode(this.inp2),
                output: findNode(this.output),
                carryOut: findNode(this.carryOut),
                controlSignalInput: findNode(this.controlSignalInput),
            },
        };
        return data;
    }

    /**
     * @memberof ALU
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'white';
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        moveTo(ctx, 30, 10, xx, yy, this.direction);
        lineTo(ctx, 30, -10, xx, yy, this.direction);
        lineTo(ctx, 10, -40, xx, yy, this.direction);
        lineTo(ctx, -30, -40, xx, yy, this.direction);
        lineTo(ctx, -30, -20, xx, yy, this.direction);
        lineTo(ctx, -20, -10, xx, yy, this.direction);
        lineTo(ctx, -20, 10, xx, yy, this.direction);
        lineTo(ctx, -30, 20, xx, yy, this.direction);
        lineTo(ctx, -30, 40, xx, yy, this.direction);
        lineTo(ctx, 10, 40, xx, yy, this.direction);
        lineTo(ctx, 30, 10, xx, yy, this.direction);
        ctx.closePath();
        ctx.stroke();

        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.fillStyle = 'Black';
        ctx.textAlign = 'center';

        fillText4(ctx, 'B', -23, 30, xx, yy, this.direction, 6);
        fillText4(ctx, 'A', -23, -30, xx, yy, this.direction, 6);
        fillText4(ctx, 'CTR', -10, -30, xx, yy, this.direction, 6);
        fillText4(ctx, 'Carry', -10, 30, xx, yy, this.direction, 6);
        fillText4(ctx, 'Ans', 20, 0, xx, yy, this.direction, 6);
        ctx.fill();
        ctx.beginPath();
        ctx.fillStyle = 'DarkGreen';
        fillText4(ctx, this.message, 0, 0, xx, yy, this.direction, 12);
        ctx.fill();
    }

    /**
     * @memberof ALU
     * resolve output values based on inputData
     */
    resolve() {
        if (this.controlSignalInput.value === 0) {
            this.output.value = ((this.inp1.value) & (this.inp2.value));
            simulationArea.simulationQueue.add(this.output);
            this.carryOut.value = 0;
            simulationArea.simulationQueue.add(this.carryOut);
            this.message = 'A&B';
        } else if (this.controlSignalInput.value === 1) {
            this.output.value = ((this.inp1.value) | (this.inp2.value));

            simulationArea.simulationQueue.add(this.output);
            this.carryOut.value = 0;
            simulationArea.simulationQueue.add(this.carryOut);
            this.message = 'A|B';
        } else if (this.controlSignalInput.value === 2) {
            const sum = this.inp1.value + this.inp2.value;
            this.output.value = ((sum) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
            this.carryOut.value = +((sum >>> (this.bitWidth)) !== 0);
            simulationArea.simulationQueue.add(this.carryOut);
            simulationArea.simulationQueue.add(this.output);
            this.message = 'A+B';
        } else if (this.controlSignalInput.value === 3) {
            this.message = 'ALU';
        } else if (this.controlSignalInput.value === 4) {
            this.message = 'A&~B';
            this.output.value = ((this.inp1.value) & this.flipBits(this.inp2.value));
            simulationArea.simulationQueue.add(this.output);
            this.carryOut.value = 0;
            simulationArea.simulationQueue.add(this.carryOut);
        } else if (this.controlSignalInput.value === 5) {
            this.message = 'A|~B';
            this.output.value = ((this.inp1.value) | this.flipBits(this.inp2.value));
            simulationArea.simulationQueue.add(this.output);
            this.carryOut.value = 0;
            simulationArea.simulationQueue.add(this.carryOut);
        } else if (this.controlSignalInput.value === 6) {
            this.message = 'A-B';
            this.output.value = ((this.inp1.value - this.inp2.value) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
            simulationArea.simulationQueue.add(this.output);
            this.carryOut.value = 0;
            simulationArea.simulationQueue.add(this.carryOut);
        } else if (this.controlSignalInput.value === 7) {
            this.message = 'A<B';
            if (this.inp1.value < this.inp2.value) { this.output.value = 1; } else { this.output.value = 0; }
            simulationArea.simulationQueue.add(this.output);
            this.carryOut.value = 0;
            simulationArea.simulationQueue.add(this.carryOut);
        }
    }
}

/**
 * @memberof ALU
 * Help Tip
 * @type {string}
 * @category modules
 */
ALU.prototype.tooltipText = 'ALU ToolTip: 0: A&B, 1:A|B, 2:A+B, 4:A&~B, 5:A|~B, 6:A-B, 7:SLT ';

/**
 * @memberof ALU
 * Help URL
 * @type {string}
 * @category modules
 */
ALU.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=alu';
ALU.prototype.objectType = 'ALU';
