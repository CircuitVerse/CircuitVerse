import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, arc,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * Ground
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class Ground extends CircuitElement {
    constructor(x, y, scope = globalScope, bitWidth = 1) {
        super(x, y, scope, 'RIGHT', bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Ground'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(10, 10);
        this.directionFixed = true;
        this.output1 = new Node(0, -10, 1, this);
    }

    /**
     * @memberof Ground
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
            constructorParamaters: [this.direction, this.bitWidth],
        };
        return data;
    }

    /**
     * @memberof Ground
     * resolve output values based on inputData
     */
    resolve() {
        this.output1.value = 0;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof Ground
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            nodes: {
                output1: findNode(this.output1),
            },
            constructorParamaters: [this.bitWidth],
        };
        return data;
    }

    /**
     * @memberof Ground
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;

        ctx.beginPath();
        ctx.strokeStyle = ['black', 'brown'][((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) + 0];
        ctx.lineWidth = correctWidth(3);

        const xx = this.x;
        const yy = this.y;

        moveTo(ctx, 0, -10, xx, yy, this.direction);
        lineTo(ctx, 0, 0, xx, yy, this.direction);
        moveTo(ctx, -10, 0, xx, yy, this.direction);
        lineTo(ctx, 10, 0, xx, yy, this.direction);
        moveTo(ctx, -6, 5, xx, yy, this.direction);
        lineTo(ctx, 6, 5, xx, yy, this.direction);
        moveTo(ctx, -2.5, 10, xx, yy, this.direction);
        lineTo(ctx, 2.5, 10, xx, yy, this.direction);
        ctx.stroke();
    }
}

/**
 * @memberof Ground
 * Help Tip
 * @type {string}
 * @category modules
 */
Ground.prototype.tooltipText = 'Ground: All bits are Low(0).';

/**
 * @memberof Ground
 * Help URL
 * @type {string}
 * @category modules
 */
Ground.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=ground';

/**
 * @memberof Ground
 * @type {number}
 * @category modules
 */
Ground.prototype.propagationDelay = 0;
Ground.prototype.objectType = 'Ground';
