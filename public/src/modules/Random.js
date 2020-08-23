import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { fillText, lineTo, moveTo } from '../canvasApi';
/**
 * @class
 * Random
 * Random is used to generate random value.
 * It has 2 input node:
 * clock and max random output value
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 * @category modules
 */
import { colors } from '../themer/themer';

export default class Random extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Random'].push(this);
        */
        this.directionFixed = true;
        this.setDimensions(20, 20);
        this.rectangleObject = true;
        this.currentRandomNo = 0;
        this.clockInp = new Node(-20, +10, 0, this, 1, 'Clock');
        this.maxValue = new Node(-20, -10, 0, this, this.bitWidth, 'MaxValue');
        this.output = new Node(20, -10, 1, this, this.bitWidth, 'RandomValue');
        this.prevClockState = 0;
        this.wasClicked = false;
    }

    /**
     * @memberof Random
     * return true if clock is connected and if maxValue is set or unconnected.
     */
    isResolvable() {
        if (this.clockInp.value != undefined && (this.maxValue.value != undefined || this.maxValue.connections.length == 0)) { return true; }
        return false;
    }

    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.maxValue.bitWidth = bitWidth;
        this.output.bitWidth = bitWidth;
    }

    /**
     * @memberof Random
     * Edge triggered when the clock state changes a
     * Random number is generated less then the maxValue.
     */
    resolve() {
        // console.log("HIT")
        var maxValue = this.maxValue.connections.length ? this.maxValue.value + 1 : (2 << (this.bitWidth - 1));
        if (this.clockInp.value != undefined) {
            if (this.clockInp.value != this.prevClockState) {
                if (this.clockInp.value == 1) {
                    this.currentRandomNo = Math.floor(Math.random() * maxValue);
                }
                this.prevClockState = this.clockInp.value;
            }
        }
        if (this.output.value != this.currentRandomNo) {
            this.output.value = this.currentRandomNo;
            simulationArea.simulationQueue.add(this.output);
        }
    }

    customSave() {
        var data = {
            nodes: {
                clockInp: findNode(this.clockInp),
                maxValue: findNode(this.maxValue),
                output: findNode(this.output),
            },
            constructorParamaters: [this.direction, this.bitWidth],

        };
        return data;
    }

    customDraw() {
        var ctx = simulationArea.context;
        //        
        ctx.fillStyle = colors['fill'];
        ctx.strokeStyle = colors['stroke'];
        ctx.beginPath();
        var xx = this.x;
        var yy = this.y;
        ctx.font = '20px Georgia';
        ctx.fillStyle = colors['input_text'];
        ctx.textAlign = 'center';
        fillText(ctx, this.currentRandomNo.toString(10), this.x, this.y + 5);
        ctx.fill();
        ctx.beginPath();
        moveTo(ctx, -20, 5, xx, yy, this.direction);
        lineTo(ctx, -15, 10, xx, yy, this.direction);
        lineTo(ctx, -20, 15, xx, yy, this.direction);
        ctx.stroke();
    }
}

Random.prototype.tooltipText = 'Random ToolTip : Random Selected.';

Random.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=random';

Random.prototype.objectType = 'Random';
