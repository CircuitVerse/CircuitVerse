import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, fillText } from "../canvasApi";
/**
 * @class
 * Demultiplexer
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} controlSignalSize - 1 by default
 * @category modules
 */
import { colors } from "../themer/themer";

export default class Demultiplexer extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = "LEFT",
        bitWidth = 1,
        controlSignalSize = 1
    ) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Demultiplexer'].push(this);
        */
        this.controlSignalSize =
            controlSignalSize ||
            parseInt(prompt("Enter control signal bitWidth"), 10);
        this.outputsize = 1 << this.controlSignalSize;
        this.xOff = 0;
        this.yOff = 1;
        if (this.controlSignalSize === 1) {
            this.xOff = 10;
        }
        if (this.controlSignalSize <= 3) {
            this.yOff = 2;
        }

        this.changeControlSignalSize = function (size) {
            if (size === undefined || size < 1 || size > 32) return;
            if (this.controlSignalSize === size) return;
            const obj = new Demultiplexer(
                this.x,
                this.y,
                this.scope,
                this.direction,
                this.bitWidth,
                size
            );
            this.cleanDelete();
            simulationArea.lastSelected = obj;
            return obj;
        };
        this.mutableProperties = {
            controlSignalSize: {
                name: "Control Signal Size",
                type: "number",
                max: "32",
                min: "1",
                func: "changeControlSignalSize",
            },
        };
        // eslint-disable-next-line no-shadow
        this.newBitWidth = function (bitWidth) {
            this.bitWidth = bitWidth;
            for (let i = 0; i < this.outputsize; i++) {
                this.output1[i].bitWidth = bitWidth;
            }
            this.input.bitWidth = bitWidth;
        };

        this.setDimensions(20 - this.xOff, this.yOff * 5 * this.outputsize);
        this.rectangleObject = false;
        this.input = new Node(20 - this.xOff, 0, 0, this);

        this.output1 = [];
        for (let i = 0; i < this.outputsize; i++) {
            const a = new Node(
                -20 + this.xOff,
                +this.yOff * 10 * (i - this.outputsize / 2) + 10,
                1,
                this
            );
            this.output1.push(a);
        }

        this.controlSignalInput = new Node(
            0,
            this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff + 10,
            0,
            this,
            this.controlSignalSize,
            "Control Signal"
        );
    }

    /**
     * @memberof Demultiplexer
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [
                this.direction,
                this.bitWidth,
                this.controlSignalSize,
            ],
            nodes: {
                output1: this.output1.map(findNode),
                input: findNode(this.input),
                controlSignalInput: findNode(this.controlSignalInput),
            },
        };
        return data;
    }

    /**
     * @memberof Demultiplexer
     * resolve output values based on inputData
     */
    resolve() {
        for (let i = 0; i < this.output1.length; i++) {
            this.output1[i].value = 0;
        }

        this.output1[this.controlSignalInput.value].value = this.input.value;

        for (let i = 0; i < this.output1.length; i++) {
            simulationArea.simulationQueue.add(this.output1[i]);
        }
    }

    /**
     * @memberof Demultiplexer
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;

        const xx = this.x;
        const yy = this.y;

        ctx.beginPath();
        moveTo(
            ctx,
            0,
            this.yOff * 10 * (this.outputsize / 2 - 1) + 10 + 0.5 * this.xOff,
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            0,
            this.yOff * 5 * (this.outputsize - 1) + this.xOff,
            xx,
            yy,
            this.direction
        );
        ctx.stroke();

        ctx.beginPath();
        ctx.strokeStyle = colors["stroke"];
        ctx.lineWidth = correctWidth(4);
        ctx.fillStyle = colors["fill"];
        moveTo(
            ctx,
            -20 + this.xOff,
            -this.yOff * 10 * (this.outputsize / 2),
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            -20 + this.xOff,
            20 + this.yOff * 10 * (this.outputsize / 2 - 1),
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            20 - this.xOff,
            +this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff,
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            20 - this.xOff,
            -this.yOff * 10 * (this.outputsize / 2) - this.xOff + 20,
            xx,
            yy,
            this.direction
        );
        ctx.closePath();
        if (
            (this.hover && !simulationArea.shiftDown) ||
            simulationArea.lastSelected === this ||
            simulationArea.multipleObjectSelections.contains(this)
        ) {
            ctx.fillStyle = colors["hover_select"];
        }
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.fillStyle = "black";
        ctx.textAlign = "center";
        // [xFill,yFill] = rotate(xx + this.output1[i].x - 7, yy + this.output1[i].y + 2);
        // //console.log([xFill,yFill])
        for (let i = 0; i < this.outputsize; i++) {
            if (this.direction === "LEFT")
                fillText(
                    ctx,
                    String(i),
                    xx + this.output1[i].x - 7,
                    yy + this.output1[i].y + 2,
                    10
                );
            else if (this.direction === "RIGHT")
                fillText(
                    ctx,
                    String(i),
                    xx + this.output1[i].x + 7,
                    yy + this.output1[i].y + 2,
                    10
                );
            else if (this.direction === "UP")
                fillText(
                    ctx,
                    String(i),
                    xx + this.output1[i].x,
                    yy + this.output1[i].y - 5,
                    10
                );
            else
                fillText(
                    ctx,
                    String(i),
                    xx + this.output1[i].x,
                    yy + this.output1[i].y + 10,
                    10
                );
        }
        ctx.fill();
    }
}

/**
 * @memberof Demultiplexer
 * Help Tip
 * @type {string}
 * @category modules
 */
Demultiplexer.prototype.tooltipText =
    "DeMultiplexer ToolTip : Multiple outputs and a single line input.";
Demultiplexer.prototype.helplink =
    "https://docs.circuitverse.org/#/decodersandplexers?id=demultiplexer";
Demultiplexer.prototype.objectType = "Demultiplexer";
