import CircuitElement from '../circuitElement';
import Node, { findNode, dec2bin } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, rect, fillText } from '../canvasApi';
/**
 * @class
 * PriorityEncoder
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class PriorityEncoder extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['PriorityEncoder'].push(this);
        */
        this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10);
        this.inputSize = 1 << this.bitWidth;

        this.yOff = 1;
        if (this.bitWidth <= 3) {
            this.yOff = 2;
        }

        this.setDimensions(20, this.yOff * 5 * (this.inputSize));
        this.directionFixed = true;
        this.rectangleObject = false;

        this.inp1 = [];
        for (let i = 0; i < this.inputSize; i++) {
            const a = new Node(-10, +this.yOff * 10 * (i - this.inputSize / 2) + 10, 0, this, 1);
            this.inp1.push(a);
        }

        this.output1 = [];
        for (let i = 0; i < this.bitWidth; i++) {
            const a = new Node(30, +2 * 10 * (i - this.bitWidth / 2) + 10, 1, this, 1);
            this.output1.push(a);
        }

        this.enable = new Node(10, 20 + this.inp1[this.inputSize - 1].y, 1, this, 1);
    }

    /**
     * @memberof PriorityEncoder
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {

            nodes: {
                inp1: this.inp1.map(findNode),
                output1: this.output1.map(findNode),
                enable: findNode(this.enable),
            },
            constructorParamaters: [this.direction, this.bitWidth],
        };
        return data;
    }

    /**
     * @memberof PriorityEncoder
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        if (bitWidth === undefined || bitWidth < 1 || bitWidth > 32) return;
        if (this.bitWidth === bitWidth) return;

        this.bitWidth = bitWidth;
        const obj = new PriorityEncoder(this.x, this.y, this.scope, this.direction, this.bitWidth);
        this.inputSize = 1 << bitWidth;

        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    }

    /**
     * @memberof PriorityEncoder
     * resolve output values based on inputData
     */
    resolve() {
        let out = 0;
        let temp = 0;
        for (let i = this.inputSize - 1; i >= 0; i--) {
            if (this.inp1[i].value === 1) {
                out = dec2bin(i);
                break;
            }
        }
        temp = out;

        if (out.length !== undefined) {
            this.enable.value = 1;
        } else {
            this.enable.value = 0;
        }
        simulationArea.simulationQueue.add(this.enable);

        if (temp.length === undefined) {
            temp = '0';
            for (let i = 0; i < this.bitWidth - 1; i++) {
                temp = `0${temp}`;
            }
        }

        if (temp.length !== this.bitWidth) {
            for (let i = temp.length; i < this.bitWidth; i++) {
                temp = `0${temp}`;
            }
        }

        for (let i = this.bitWidth - 1; i >= 0; i--) {
            this.output1[this.bitWidth - 1 - i].value = Number(temp[i]);
            simulationArea.simulationQueue.add(this.output1[this.bitWidth - 1 - i]);
        }
    }

    /**
     * @memberof PriorityEncoder
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'white';
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        if (this.bitWidth <= 3) { rect(ctx, xx - 10, yy - 10 - this.yOff * 5 * (this.inputSize), 40, 20 * (this.inputSize + 1)); } else { rect(ctx, xx - 10, yy - 10 - this.yOff * 5 * (this.inputSize), 40, 10 * (this.inputSize + 3)); }
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.fillStyle = 'black';
        ctx.textAlign = 'center';
        for (let i = 0; i < this.inputSize; i++) {
            fillText(ctx, String(i), xx, yy + this.inp1[i].y + 2, 10);
        }
        for (let i = 0; i < this.bitWidth; i++) {
            fillText(ctx, String(i), xx + this.output1[0].x - 10, yy + this.output1[i].y + 2, 10);
        }
        fillText(ctx, 'EN', xx + this.enable.x, yy + this.enable.y - 5, 10);
        ctx.fill();
    }
}

/**
 * @memberof PriorityEncoder
 * Help Tip
 * @type {string}
 * @category modules
 */
PriorityEncoder.prototype.tooltipText = 'Priority Encoder ToolTip : Compresses binary inputs into a smaller number of outputs.';
PriorityEncoder.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=priority-encoder';
PriorityEncoder.prototype.objectType = 'PriorityEncoder';
