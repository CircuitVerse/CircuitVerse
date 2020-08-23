import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, fillText } from '../canvasApi';
import { colors } from '../themer/themer';
/**
 * @class
 * DflipFlop
 * D flip flop has 5 input nodes:
 * clock, data input, preset, reset ,enable.
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 * @category sequential
 */
export default class DflipFlop extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /*
        this.scope['DflipFlop'].push(this);
        */
        this.directionFixed = true;
        this.setDimensions(20, 20);
        this.rectangleObject = true;
        this.clockInp = new Node(-20, +10, 0, this, 1, 'Clock');
        this.dInp = new Node(-20, -10, 0, this, this.bitWidth, 'D');
        this.qOutput = new Node(20, -10, 1, this, this.bitWidth, 'Q');
        this.qInvOutput = new Node(20, 10, 1, this, this.bitWidth, 'Q Inverse');
        this.reset = new Node(10, 20, 0, this, 1, 'Asynchronous Reset');
        this.preset = new Node(0, 20, 0, this, this.bitWidth, 'Preset');
        this.en = new Node(-10, 20, 0, this, 1, 'Enable');
        this.masterState = 0;
        this.slaveState = 0;
        this.prevClockState = 0;

        this.wasClicked = false;
    }

    /**
     * WIP always resolvable?
     */
    isResolvable() {
        return true;
        // if (this.reset.value == 1) return true;
        // if (this.clockInp.value != undefined && this.dInp.value != undefined) return true;
        // return false;
    }

    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.dInp.bitWidth = bitWidth;
        this.qOutput.bitWidth = bitWidth;
        this.qInvOutput.bitWidth = bitWidth;
        this.preset.bitWidth = bitWidth;
    }

    /**
     * @memberof DflipFlop
     * On the leading edge of the clock signal (LOW-to-HIGH) the first stage,
     * the “master” latches the input condition at D, while the output stage is deactivated.
     * On the trailing edge of the clock signal (HIGH-to-LOW) the second “slave” stage is
     * now activated, latching on to the output from the first master circuit.
     * Then the output stage appears to be triggered on the negative edge of the clock pulse.
     * This fuction sets the value for the node qOutput based on the previous state
     * and input of the clock. We flip the bits to find qInvOutput
     */
    resolve() {
        if (this.reset.value == 1) {
            this.masterState = this.slaveState = (this.preset.value || 0);
        } else if (this.en.value == 0) {
            this.prevClockState = this.clockInp.value;
        } else if (this.en.value == 1 || this.en.connections.length == 0) { // if(this.en.value==1) // Creating Infinite Loop, WHY ??
            if (this.clockInp.value == this.prevClockState) {
                if (this.clockInp.value == 0 && this.dInp.value != undefined) {
                    this.masterState = this.dInp.value;
                }
            } else if (this.clockInp.value != undefined) {
                if (this.clockInp.value == 1) {
                    this.slaveState = this.masterState;
                } else if (this.clockInp.value == 0 && this.dInp.value != undefined) {
                    this.masterState = this.dInp.value;
                }
                this.prevClockState = this.clockInp.value;
            }
        }

        if (this.qOutput.value != this.slaveState) {
            this.qOutput.value = this.slaveState;
            this.qInvOutput.value = this.flipBits(this.slaveState);
            simulationArea.simulationQueue.add(this.qOutput);
            simulationArea.simulationQueue.add(this.qInvOutput);
        }
    }

    customSave() {
        var data = {
            nodes: {
                clockInp: findNode(this.clockInp),
                dInp: findNode(this.dInp),
                qOutput: findNode(this.qOutput),
                qInvOutput: findNode(this.qInvOutput),
                reset: findNode(this.reset),
                preset: findNode(this.preset),
                en: findNode(this.en),
            },
            constructorParamaters: [this.direction, this.bitWidth],

        };
        return data;
    }

    customDraw() {
        var ctx = simulationArea.context;
        //        
        ctx.strokeStyle = (colors['stroke']);
        ctx.fillStyle = colors['fill'];
        ctx.beginPath();
        ctx.lineWidth = correctWidth(3);
        var xx = this.x;
        var yy = this.y;
        // rect(ctx, xx - 20, yy - 20, 40, 40);
        moveTo(ctx, -20, 5, xx, yy, this.direction);
        lineTo(ctx, -15, 10, xx, yy, this.direction);
        lineTo(ctx, -20, 15, xx, yy, this.direction);
        // if ((this.b.hover&&!simulationArea.shiftDown)|| simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.font = '20px Georgia';
        ctx.fillStyle = colors['input_text'];
        ctx.textAlign = 'center';
        fillText(ctx, this.slaveState.toString(16), xx, yy + 5);
        ctx.fill();
    }
}

DflipFlop.prototype.tooltipText = 'D FlipFlop ToolTip : Introduces delay in timing circuit.';
DflipFlop.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=d-flip-flop';

DflipFlop.prototype.objectType = 'DflipFlop';
