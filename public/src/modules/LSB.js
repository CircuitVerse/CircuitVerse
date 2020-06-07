import CircuitElement from '../circuitElement';
import Node, { findNode, dec2bin } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, rect, fillText } from '../canvasApi';
/**
 * @class
 * LSB
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class LSB extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['LSB'].push(this);
        */
        this.leftDimensionX = 10;
        this.rightDimensionX = 20;
        this.setHeight(30);
        this.directionFixed = true;
        this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10);
        this.rectangleObject = false;
        this.inputSize = 1 << this.bitWidth;

        this.inp1 = new Node(-10, 0, 0, this, this.inputSize);
        this.output1 = new Node(20, 0, 1, this, this.bitWidth);
        this.enable = new Node(20, 20, 1, this, 1);
    }

    /**
     * @memberof LSB
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {

            nodes: {
                inp1: findNode(this.inp1),
                output1: findNode(this.output1),
                enable: findNode(this.enable),
            },
            constructorParamaters: [this.direction, this.bitWidth],
        };
        return data;
    }

    /**
     * @memberof LSB
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        // this.inputSize = 1 << bitWidth
        this.inputSize = bitWidth;
        this.inp1.bitWidth = this.inputSize;
        this.bitWidth = bitWidth;
        this.output1.bitWidth = bitWidth;
    }

    /**
     * @memberof LSB
     * resolve output values based on inputData
     */
    resolve() {
        const inp = dec2bin(this.inp1.value);
        let out = 0;
        for (let i = inp.length - 1; i >= 0; i--) {
            if (inp[i] === 1) {
                out = inp.length - 1 - i;
                break;
            }
        }
        this.output1.value = out;
        simulationArea.simulationQueue.add(this.output1);
        if (inp !== 0) {
            this.enable.value = 1;
        } else {
            this.enable.value = 0;
        }
        simulationArea.simulationQueue.add(this.enable);
    }

    /**
     * @memberof LSB
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
        rect(ctx, xx - 10, yy - 30, 30, 60);
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.fillStyle = 'black';
        ctx.textAlign = 'center';
        fillText(ctx, 'LSB', xx + 6, yy - 12, 10);
        fillText(ctx, 'EN', xx + this.enable.x - 12, yy + this.enable.y + 3, 8);
        ctx.fill();

        ctx.beginPath();
        ctx.fillStyle = 'green';
        ctx.textAlign = 'center';
        if (this.output1.value !== undefined) {
            fillText(ctx, this.output1.value, xx + 5, yy + 14, 13);
        }
        ctx.stroke();
        ctx.fill();
    }
}

/**
 * @memberof LSB
 * Help Tip
 * @type {string}
 * @category modules
 */
LSB.prototype.tooltipText = 'LSB ToolTip : The least significant bit or the low-order bit.';
LSB.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=least-significant-bit-lsb-detector';
LSB.prototype.objectType = 'LSB';
