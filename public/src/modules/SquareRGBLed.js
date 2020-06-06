import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, rect2,
} from '../canvasApi';

/**
 * @class
 * SquareRGBLed
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} pinLength - pins per node.
 * @category modules
 */
export default class SquareRGBLed extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'UP', pinLength = 1) {
        super(x, y, scope, dir, 8);
        /* this is done in this.baseSetup() now
        this.scope['SquareRGBLed'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 15);
        this.pinLength = pinLength === undefined ? 1 : pinLength;
        const nodeX = -10 - 10 * pinLength;
        this.inp1 = new Node(nodeX, -10, 0, this, 8, 'R');
        this.inp2 = new Node(nodeX, 0, 0, this, 8, 'G');
        this.inp3 = new Node(nodeX, 10, 0, this, 8, 'B');
        this.inp = [this.inp1, this.inp2, this.inp3];
        this.labelDirection = 'UP';
        this.fixedBitWidth = true;

        // eslint-disable-next-line no-shadow
        this.changePinLength = function (pinLength) {
            if (pinLength === undefined) return;
            pinLength = parseInt(pinLength, 10);
            if (pinLength < 0 || pinLength > 1000) return;

            // Calculate the new position of the LED, so the nodes will stay in the same place.
            const diff = 10 * (pinLength - this.pinLength);
            // eslint-disable-next-line no-nested-ternary
            const diffX = this.direction === 'LEFT' ? -diff : this.direction === 'RIGHT' ? diff : 0;
            // eslint-disable-next-line no-nested-ternary
            const diffY = this.direction === 'UP' ? -diff : this.direction === 'DOWN' ? diff : 0;

            // Build a new LED with the new values; preserve label properties too.
            const obj = new SquareRGBLed(this.x + diffX, this.y + diffY, this.scope, this.direction, pinLength);
            obj.label = this.label;
            obj.labelDirection = this.labelDirection;

            this.cleanDelete();
            simulationArea.lastSelected = obj;
            return obj;
        };

        this.mutableProperties = {
            pinLength: {
                name: 'Pin Length',
                type: 'number',
                max: '1000',
                min: '0',
                func: 'changePinLength',
            },
        };
    }

    /**
     * @memberof SquareRGBLed
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.pinLength],
            nodes: {
                inp1: findNode(this.inp1),
                inp2: findNode(this.inp2),
                inp3: findNode(this.inp3),
            },
        };
        return data;
    }

    /**
     * @memberof SquareRGBLed
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        const r = this.inp1.value;
        const g = this.inp2.value;
        const b = this.inp3.value;

        const colors = ['rgb(174,20,20)', 'rgb(40,174,40)', 'rgb(0,100,255)'];
        for (let i = 0; i < 3; i++) {
            const x = -10 - 10 * this.pinLength;
            const y = i * 10 - 10;
            ctx.lineWidth = correctWidth(3);

            // A gray line, which makes it easy on the eyes when the pin length is large
            ctx.beginPath();
            ctx.lineCap = 'butt';
            ctx.strokeStyle = 'rgb(227, 228, 229)';
            moveTo(ctx, -15, y, xx, yy, this.direction);
            lineTo(ctx, x + 10, y, xx, yy, this.direction);
            ctx.stroke();

            // A colored line, so people know which pin does what.
            ctx.lineCap = 'round';
            ctx.beginPath();
            ctx.strokeStyle = colors[i];
            moveTo(ctx, x + 10, y, xx, yy, this.direction);
            lineTo(ctx, x, y, xx, yy, this.direction);
            ctx.stroke();
        }

        ctx.strokeStyle = '#d3d4d5';
        ctx.fillStyle = (r === undefined && g === undefined && b === undefined) ? 'rgb(227, 228, 229)' : `rgb(${r || 0}, ${g || 0}, ${b || 0})`;
        ctx.lineWidth = correctWidth(1);
        ctx.beginPath();
        rect2(ctx, -15, -15, 30, 30, xx, yy, this.direction);
        ctx.stroke();

        if ((this.hover && !simulationArea.shiftDown)
            || simulationArea.lastSelected === this
            || simulationArea.multipleObjectSelections.contains(this)) {
            ctx.fillStyle = 'rgba(255, 255, 32)';
        }

        ctx.fill();
    }
}

/**
 * @memberof SquareRGBLed
 * Help Tip
 * @type {string}
 * @category modules
 */
SquareRGBLed.prototype.tooltipText = 'Square RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE.';

/**
 * @memberof SquareRGBLed
 * Help URL
 * @type {string}
 * @category modules
 */
SquareRGBLed.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=square-rgb-led';
SquareRGBLed.prototype.objectType = 'SquareRGBLed';
