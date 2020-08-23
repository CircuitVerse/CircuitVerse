import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { fillText } from '../canvasApi';
import { changeInputSize } from '../modules';
/**
 * @class
 * Stepper
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bitwidth of element
 * @category modules
 */
import { colors } from '../themer/themer';

export default class Stepper extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 8) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Stepper'].push(this);
        */
        this.setDimensions(20, 20);

        this.output1 = new Node(20, 0, 1, this, bitWidth);
        this.state = 0;
    }

    /**
     * @memberof Stepper
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        var data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                output1: findNode(this.output1),
            },
            values: {
                state: this.state,
            },
        };
        return data;
    }

    /**
     * @memberof Stepper
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        ctx.beginPath();
        ctx.font = '20px Georgia';
        ctx.fillStyle = colors['input_text'];
        ctx.textAlign = 'center';
        fillText(ctx, this.state.toString(16), this.x, this.y + 5);
        ctx.fill();
    }

    /**
     * @memberof Stepper
     * resolve output values based on inputData
     */
    resolve() {
        this.state = Math.min(this.state, (1 << this.bitWidth) - 1);
        this.output1.value = this.state;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * Listener function for increasing value of state
     * @memberof Stepper
     * @param {string} key - the key pressed
     */
    keyDown2(key) {
        // console.log(key);
        if (this.state < (1 << this.bitWidth) && (key === '+' || key === '=')) this.state++;
        if (this.state > 0 && (key === '_' || key === '-')) this.state--;
    }
}

/**
 * @memberof Stepper
 * Help Tip
 * @type {string}
 * @category modules
 */
Stepper.prototype.tooltipText = 'Stepper ToolTip: Increase/Decrease value by selecting the stepper and using +/- keys.';

/**
 * @memberof Stepper
 * Help URL
 * @type {string}
 * @category modules
 */
Stepper.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=stepper';
Stepper.prototype.objectType = 'Stepper';
