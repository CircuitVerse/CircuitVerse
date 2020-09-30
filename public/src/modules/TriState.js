import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, arc } from "../canvasApi";
import { changeInputSize } from "../modules";
/**
 * @class
 * TriState
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @category modules
 */
import { colors } from "../themer/themer";

export default class TriState extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['TriState'].push(this);
        */
        this.rectangleObject = false;
        this.setDimensions(15, 15);

        this.inp1 = new Node(-10, 0, 0, this);
        this.output1 = new Node(20, 0, 1, this);
        this.state = new Node(0, 0, 0, this, 1, "Enable");
    }

    // TriState.prototype.propagationDelay=10000;

    /**
     * @memberof TriState
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                output1: findNode(this.output1),
                inp1: findNode(this.inp1),
                state: findNode(this.state),
            },
        };
        return data;
    }

    /**
     * @memberof TriState
     * function to change bitwidth of the element
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        this.inp1.bitWidth = bitWidth;
        this.output1.bitWidth = bitWidth;
        this.bitWidth = bitWidth;
    }

    /**
     * @memberof TriState
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }

        if (this.state.value === 1) {
            if (this.output1.value !== this.inp1.value) {
                this.output1.value = this.inp1.value; // >>>0)<<(32-this.bitWidth))>>>(32-this.bitWidth);
                simulationArea.simulationQueue.add(this.output1);
            }
            simulationArea.contentionPending.clean(this);
        } else if (
            this.output1.value !== undefined &&
            !simulationArea.contentionPending.contains(this)
        ) {
            this.output1.value = undefined;
            simulationArea.simulationQueue.add(this.output1);
        }
        simulationArea.contentionPending.clean(this);
    }

    /**
     * @memberof TriState
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        ctx.strokeStyle = colors["stroke"];
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
 * @memberof TriState
 * Help Tip
 * @type {string}
 * @category modules
 */
TriState.prototype.tooltipText =
    "TriState ToolTip : Effectively removes the output from the circuit.";
TriState.prototype.helplink =
    "https://docs.circuitverse.org/#/miscellaneous?id=tri-state-buffer";
TriState.prototype.objectType = "TriState";
