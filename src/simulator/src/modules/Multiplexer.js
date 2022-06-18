import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, fillText } from "../canvasApi";
import { changeInputSize } from "../modules";
/**
 * @class
 * Multiplexer
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

export default class Multiplexer extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = "RIGHT",
        bitWidth = 1,
        controlSignalSize = 1
    ) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Multiplexer'].push(this);
        */
        this.controlSignalSize =
            controlSignalSize ||
            parseInt(prompt("Enter control signal bitWidth"), 10);
        this.inputSize = 1 << this.controlSignalSize;
        this.xOff = 0;
        this.yOff = 1;
        if (this.controlSignalSize === 1) {
            this.xOff = 10;
        }
        if (this.controlSignalSize <= 3) {
            this.yOff = 2;
        }
        this.setDimensions(20 - this.xOff, this.yOff * 5 * this.inputSize);
        this.rectangleObject = false;
        this.inp = [];
        for (let i = 0; i < this.inputSize; i++) {
            const a = new Node(
                -20 + this.xOff,
                +this.yOff * 10 * (i - this.inputSize / 2) + 10,
                0,
                this
            );
            this.inp.push(a);
        }
        this.output1 = new Node(20 - this.xOff, 0, 1, this);
        this.controlSignalInput = new Node(
            0,
            this.yOff * 10 * (this.inputSize / 2 - 1) + this.xOff + 10,
            0,
            this,
            this.controlSignalSize,
            "Control Signal"
        );
    }

    /**
     * @memberof Multiplexer
     * function to change control signal of the element
     */
    changeControlSignalSize(size) {
        if (size === undefined || size < 1 || size > 32) return;
        if (this.controlSignalSize === size) return;
        const obj = new Multiplexer(
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
    }

    /**
     * @memberof Multiplexer
     * function to change bitwidth of the element
     * @param {number} bitWidth - bitwidth
     */
    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        for (let i = 0; i < this.inputSize; i++) {
            this.inp[i].bitWidth = bitWidth;
        }
        this.output1.bitWidth = bitWidth;
    }

    /**
     * @memberof Multiplexer
     * @type {boolean}
     */
    isResolvable() {
        if (
            this.controlSignalInput.value !== undefined &&
            this.inp[this.controlSignalInput.value].value !== undefined
        )
            return true;
        return false;
    }

    /**
     * @memberof Multiplexer
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
                inp: this.inp.map(findNode),
                output1: findNode(this.output1),
                controlSignalInput: findNode(this.controlSignalInput),
            },
        };
        return data;
    }

    /**
     * @memberof Multiplexer
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        this.output1.value = this.inp[this.controlSignalInput.value].value;
        simulationArea.simulationQueue.add(this.output1);
    }

    /**
     * @memberof Multiplexer
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
            this.yOff * 10 * (this.inputSize / 2 - 1) + 10 + 0.5 * this.xOff,
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            0,
            this.yOff * 5 * (this.inputSize - 1) + this.xOff,
            xx,
            yy,
            this.direction
        );
        ctx.stroke();

        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        ctx.strokeStyle = colors["stroke"];

        ctx.fillStyle = colors["fill"];
        moveTo(
            ctx,
            -20 + this.xOff,
            -this.yOff * 10 * (this.inputSize / 2),
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            -20 + this.xOff,
            20 + this.yOff * 10 * (this.inputSize / 2 - 1),
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            20 - this.xOff,
            +this.yOff * 10 * (this.inputSize / 2 - 1) + this.xOff,
            xx,
            yy,
            this.direction
        );
        lineTo(
            ctx,
            20 - this.xOff,
            -this.yOff * 10 * (this.inputSize / 2) - this.xOff + 20,
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
        // ctx.lineWidth = correctWidth(2);
        ctx.fillStyle = "black";
        ctx.textAlign = "center";
        for (let i = 0; i < this.inputSize; i++) {
            if (this.direction === "RIGHT")
                fillText(
                    ctx,
                    String(i),
                    xx + this.inp[i].x + 7,
                    yy + this.inp[i].y + 2,
                    10
                );
            else if (this.direction === "LEFT")
                fillText(
                    ctx,
                    String(i),
                    xx + this.inp[i].x - 7,
                    yy + this.inp[i].y + 2,
                    10
                );
            else if (this.direction === "UP")
                fillText(
                    ctx,
                    String(i),
                    xx + this.inp[i].x,
                    yy + this.inp[i].y - 4,
                    10
                );
            else
                fillText(
                    ctx,
                    String(i),
                    xx + this.inp[i].x,
                    yy + this.inp[i].y + 10,
                    10
                );
        }
        ctx.fill();
    }

    verilogBaseType() {
        return this.verilogName() + this.inp.length;
    }

    //this code to generate Verilog
    generateVerilog() {
        Multiplexer.selSizes.add(this.controlSignalSize);
        return CircuitElement.prototype.generateVerilog.call(this);
    }

    //generate the needed modules
    static moduleVerilog() {
        var output = "";

        for (var size of Multiplexer.selSizes) {
            var numInput = 1 << size;
            var inpString = "";
            for (var j = 0; j < numInput; j++) {
                inpString += `in${j}, `;
            }
            output += `\nmodule Multiplexer${numInput}(out, ${inpString}sel);\n`;

            output += "  parameter WIDTH = 1;\n";
            output += "  output reg [WIDTH-1:0] out;\n";

            output += "  input [WIDTH-1:0] "
            for (var j = 0; j < numInput-1; j++) {
                output += `in${j}, `;
            }
            output += "in" + (numInput-1) + ";\n";

            output += `  input [${size-1}:0] sel;\n`;
            output += "  \n";

            output += "  always @ (*)\n";
            output += "    case (sel)\n";
            for (var j = 0; j < numInput; j++) {
                output += `      ${j} : out = in${j};\n`;
            }
            output += "    endcase\n";
            output += "endmodule\n";
            output += "\n";
        }

        return output;
    }
    //reset the sized before Verilog generation
    static resetVerilog() {
        Multiplexer.selSizes = new Set();
    }
}

/**
 * @memberof Multiplexer
 * Help Tip
 * @type {string}
 * @category modules
 */
Multiplexer.prototype.tooltipText =
    "Multiplexer ToolTip : Multiple inputs and a single line output.";
Multiplexer.prototype.helplink =
    "https://docs.circuitverse.org/#/decodersandplexers?id=multiplexer";

/**
 * @memberof Multiplexer
 * multable properties of element
 * @type {JSON}
 * @category modules
 */
Multiplexer.prototype.mutableProperties = {
    controlSignalSize: {
        name: "Control Signal Size",
        type: "number",
        max: "10",
        min: "1",
        func: "changeControlSignalSize",
    },
};
Multiplexer.prototype.objectType = "Multiplexer";
