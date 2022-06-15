import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, fillText3 } from '../canvasApi';
/**
 * @class
 * Keyboard
 * KeyBoard - We can give 3 inputs: clock, enable and available.
 * An output of 7 bits is given out when clockInp = 1.
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 * @category sequential
 */
import { colors } from '../themer/themer';
export default class Keyboard extends CircuitElement {
    constructor(x, y, scope = globalScope, bufferSize = 32) {
        super(x, y, scope, 'RIGHT', 1);
        /*
        this.scope['Keyboard'].push(this);
        */
        this.directionFixed = true;
        this.fixedBitWidth = true;

        this.bufferSize = bufferSize || parseInt(prompt('Enter buffer size:'));
        this.elementWidth = Math.max(80, Math.ceil(this.bufferSize / 2) * 20);
        this.elementHeight = 40; // Math.max(40,Math.ceil(this.rows*15/20)*20);
        this.setWidth(this.elementWidth / 2);
        this.setHeight(this.elementHeight / 2);

        this.clockInp = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 10, 0, this, 1, 'Clock');
        this.asciiOutput = new Node(30, this.elementHeight / 2, 1, this, 7, 'Ascii Output');
        this.available = new Node(10, this.elementHeight / 2, 1, this, 1, 'Available');
        this.reset = new Node(-10, this.elementHeight / 2, 0, this, 1, 'Reset');
        this.en = new Node(-30, this.elementHeight / 2, 0, this, 1, 'Enable');
        this.prevClockState = 0;
        this.buffer = '';
        this.bufferOutValue = undefined;
    }

    /**
     * @memberof Keyboard
     * this funcion sets the size of maximum input that can
     * be given to the keyboard at once before it starts sending data.
     */
    changeBufferSize(size) {
        if (size == undefined || size < 20 || size > 100) return;
        if (this.bufferSize == size) return;
        var obj = new Keyboard(this.x, this.y, this.scope, size);
        this.delete();
        simulationArea.lastSelected = obj;
        return obj;
    }

    /**
     * @memberof Keyboard
     * Adds the keyy pressed to the buffer
     */
    keyDown(key) {
        if (key.length != 1) return;
        this.buffer += key;
        if (this.buffer.length > this.bufferSize) { this.buffer = this.buffer.slice(1); }
    }

    /**
     * @memberof Keyboard
     * not resolvable if enable = 0 or clock is undefined
     */
    isResolvable() {
        if (this.reset.value == 1) return true;
        if (this.en.value == 0 || (this.en.connections.length && this.en.value == undefined)) return false;
        else if (this.clockInp.value == undefined) return false;
        return true;
    }

    /**
     * @memberof Keyboard
     * Whenever clock is enabled (1) then one charecter
     * from the buffer is converted to ascii and transmitted 
     * through the output nodes.
     */
    resolve() {
        if (this.reset.value == 1) {
            this.buffer = '';
            return;
        }
        if (this.en.value == 0) {
            return;
        }

        if (this.available.value != 0) {
            this.available.value = 0; // this.bufferOutValue;
            simulationArea.simulationQueue.add(this.available);
        }

        if (this.clockInp.value == this.prevClockState) {
            if (this.clockInp.value == 0) {
                if (this.buffer.length) {
                    this.bufferOutValue = this.buffer[0].charCodeAt(0);
                } else {
                    this.bufferOutValue = undefined;
                }
            }
        } else if (this.clockInp.value != undefined) {
            if (this.clockInp.value == 1 && this.buffer.length) {
                if (this.bufferOutValue == this.buffer[0].charCodeAt(0)) { // WHY IS THIS REQUIRED ??
                    this.buffer = this.buffer.slice(1);
                }
            } else if (this.buffer.length) {
                this.bufferOutValue = this.buffer[0].charCodeAt(0);
            } else {
                this.bufferOutValue = undefined;
            }
            this.prevClockState = this.clockInp.value;
        }

        if (this.asciiOutput.value != this.bufferOutValue) {
            this.asciiOutput.value = this.bufferOutValue;
            simulationArea.simulationQueue.add(this.asciiOutput);
        }

        if (this.bufferOutValue !== undefined && this.available.value != 1) {
            this.available.value = 1; // this.bufferOutValue;
            simulationArea.simulationQueue.add(this.available);
        }
    }

    customSave() {
        var data = {
            nodes: {
                clockInp: findNode(this.clockInp),
                asciiOutput: findNode(this.asciiOutput),
                available: findNode(this.available),
                reset: findNode(this.reset),
                en: findNode(this.en),
            },
            constructorParamaters: [this.bufferSize],
        };
        return data;
    }

    customDraw() {
        var ctx = simulationArea.context;
        //        
        ctx.strokeStyle = (colors['stroke']);
        ctx.fillStyle = (colors['fill']);
        ctx.beginPath();
        ctx.lineWidth = correctWidth(3);
        var xx = this.x;
        var yy = this.y;
        moveTo(ctx, -this.elementWidth / 2, this.elementHeight / 2 - 15, xx, yy, this.direction);
        lineTo(ctx, 5 - this.elementWidth / 2, this.elementHeight / 2 - 10, xx, yy, this.direction);
        lineTo(ctx, -this.elementWidth / 2, this.elementHeight / 2 - 5, xx, yy, this.direction);

        ctx.stroke();

        ctx.beginPath();
        ctx.fillStyle = colors['input_text'];
        ctx.textAlign = 'center';
        var lineData = this.buffer + ' '.repeat(this.bufferSize - this.buffer.length);
        fillText3(ctx, lineData, 0, +5, xx, yy, 15, 'Courier New', 'center');
        ctx.fill();
    }
}

Keyboard.prototype.tooltipText = 'Keyboard';
Keyboard.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=keyboard';

Keyboard.prototype.mutableProperties = {
    'bufferSize': {
        name: 'Buffer Size',
        type: 'number',
        max: '100',
        min: '20',
        func: 'changeBufferSize',
    },
};

Keyboard.prototype.objectType = 'Keyboard';
