import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, arc } from "../canvasApi";
import { changeInputSize } from "../modules";
/**
 * @class
 * Buffer
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
import { colors } from "../themer/themer";

export default class Buffer extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Buffer'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 15);
        this.state = 0;
        this.preState = 0;
        this.inp1 = new Node(-10, 0, 0, this);
        this.reset = new Node(0, 0, 0, this, 1, "reset");
        this.output1 = new Node(20, 0, 1, this);
    }

    /**
     * @memberof Buffer
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                output1: findNode(this.output1),
                inp1: findNode(this.inp1),
                reset: findNode(this.reset),
            },
        };
        return data;
    }

    /**
     * @memberof Buffer
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.inp1.bitWidth = bitWidth;
        this.output1.bitWidth = bitWidth;
        this.bitWidth = bitWidth;
    }

    /**
     * @memberof Buffer
     * Checks if the element is resolvable
     * @return {boolean}
     */
    isResolvable() {
        return true;
    }

    /**
     * @memberof Buffer
     * resolve output values based on inputData
     */
    resolve() {
        if (this.reset.value === 1) {
            this.state = this.preState;
        }
        if (this.inp1.value !== undefined) {
            this.state = this.inp1.value;
        }

        this.output1.value = this.state;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof Buffer
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        ctx.strokeStyle = colors["stroke_alt"];
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = colors["fill"];
        moveTo(ctx, -10, -15, xx, yy, this.direction);
        lineTo(ctx, 20, 0, xx, yy, this.direction);
        lineTo(ctx, -10, 15, xx, yy, this.direction);
        ctx.closePath();
        if (
            (this.hover && !simulationArea.shiftDown) ||
            simulationArea.lastSelected === this ||
            simulationArea.multipleObjectSelections.contains(this)
        )
            ctx.fillStyle = colors["hover_select"];
        ctx.fill();
        ctx.stroke();
    }
}

/**
 * @memberof Buffer
 * Help Tip
 * @type {string}
 * @category modules
 */
Buffer.prototype.tooltipText =
    "Buffer ToolTip : Isolate the input from the output.";
Buffer.prototype.helplink =
    "https://docs.circuitverse.org/#/miscellaneous?id=buffer";
Buffer.prototype.objectType = "Buffer";
