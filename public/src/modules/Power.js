import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, arc,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * Power
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
export default class Power extends CircuitElement {
    constructor(x, y, scope = globalScope, bitWidth = 1) {
        super(x, y, scope, 'RIGHT', bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Power'].push(this);
        */
        this.directionFixed = true;
        this.rectangleObject = false;
        this.setDimensions(10, 10);
        this.output1 = new Node(0, 10, 1, this);
    }

    /**
     * @memberof Power
     * resolve output values based on inputData
     */
    resolve() {
        this.output1.value = ~0 >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof Power
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
     * @memberof Power
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.strokeStyle = ('rgba(0,0,0,1)');
        ctx.lineWidth = correctWidth(3);
        ctx.fillStyle = 'green';
        moveTo(ctx, 0, -10, xx, yy, this.direction);
        lineTo(ctx, -10, 0, xx, yy, this.direction);
        lineTo(ctx, 10, 0, xx, yy, this.direction);
        lineTo(ctx, 0, -10, xx, yy, this.direction);
        ctx.closePath();
        ctx.stroke();
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        moveTo(ctx, 0, 0, xx, yy, this.direction);
        lineTo(ctx, 0, 10, xx, yy, this.direction);
        ctx.stroke();
    }
}

/**
 * @memberof Power
 * Help Tip
 * @type {string}
 * @category modules
 */
Power.prototype.tooltipText = 'Power: All bits are High(1).';

/**
 * @memberof Power
 * Help URL
 * @type {string}
 * @category modules
 */
Power.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=power';

/**
 * @memberof Power
 * @type {number}
 * @category modules
 */
Power.prototype.propagationDelay = 0;

function getNextPosition(x = 0, scope = globalScope) {
    let possibleY = 20;
    const done = {};
    for (let i = 0; i < scope.Input.length; i++) {
        if (scope.Input[i].layoutProperties.x === x) { done[scope.Input[i].layoutProperties.y] = 1; }
    }
    for (let i = 0; i < scope.Output.length; i++) {
        if (scope.Output[i].layoutProperties.x === x) { done[scope.Output[i].layoutProperties.y] = 1; }
    }
    while (done[possibleY] || done[possibleY + 10] || done[possibleY - 10]) { possibleY += 10; }
    const height = possibleY + 20;
    if (height > scope.layout.height) {
        const oldHeight = scope.layout.height;
        scope.layout.height = height;
        for (let i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].layoutProperties.y === oldHeight) { scope.Input[i].layoutProperties.y = scope.layout.height; }
        }
        for (let i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].layoutProperties.y === oldHeight) { scope.Output[i].layoutProperties.y = scope.layout.height; }
        }
    }
    return possibleY;
}
Power.prototype.objectType = 'Power';
