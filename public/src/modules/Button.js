import CircuitElement from '../circuitElement';
import { Node, findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, arc,
} from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * Button
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 */
export default class Button extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT') {
        super(x, y, scope, dir, 1);
        this.state = 0;
        this.output1 = new Node(30, 0, 1, this);
        this.wasClicked = false;
        this.rectangleObject = false;
        this.setDimensions(10, 10);
    }

    /**
     * @memberof Button
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
     * @memberof Button
     * resolve output values based on inputData
     */
    resolve() {
        if (this.wasClicked) {
            this.state = 1;
            this.output1.value = this.state;
        } else {
            this.state = 0;
            this.output1.value = this.state;
        }
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof Button
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        ctx.fillStyle = '#ddd';

        ctx.strokeStyle = '#353535';
        ctx.lineWidth = correctWidth(5);

        ctx.beginPath();

        moveTo(ctx, 10, 0, xx, yy, this.direction);
        lineTo(ctx, 30, 0, xx, yy, this.direction);
        ctx.stroke();

        ctx.beginPath();

        drawCircle2(ctx, 0, 0, 12, xx, yy, this.direction);
        ctx.stroke();

        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(232, 13, 13,0.6)'; }

        if (this.wasClicked) { ctx.fillStyle = 'rgba(232, 13, 13,0.8)'; }
        ctx.fill();
    }
}

/**
 * @memberof Button
 * Help Tip
 * @type {string}
 */
Button.prototype.tooltipText = 'Button ToolTip: High(1) when pressed and Low(0) when released.';

/**
 * @memberof Button
 * Help URL
 * @type {string}
 */
Button.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=button';

/**
 * @memberof Button
 * @type {number}
 */
Button.prototype.propagationDelay = 0;
