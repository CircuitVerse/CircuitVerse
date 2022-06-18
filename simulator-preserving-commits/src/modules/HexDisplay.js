import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, lineTo, moveTo, arc, rect2, validColor, colorToRGBA } from "../canvasApi";
import { changeInputSize } from "../modules";
/**
 * @class
 * HexDisplay
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @category modules
 */
import { colors } from "../themer/themer";

export default class HexDisplay extends CircuitElement {
    constructor(x, y, scope = globalScope, color = "Red") {
        super(x, y, scope, "RIGHT", 4);
        /* this is done in this.baseSetup() now
        this.scope['HexDisplay'].push(this);
        */
        this.directionFixed = true;
        this.fixedBitWidth = true;
        this.setDimensions(30, 50);
        this.inp = new Node(0, -50, 0, this, 4);
        this.direction = "RIGHT";
        this.color = color;
        this.actualColor = color;
    }

    /**
     * @memberof HexDisplay
     * fn to change the color of HexDisplay
     * @return {JSON}
     */
    changeColor(value) {
        if (validColor(value)) {
            if (value.trim() === "") {
                this.color = "Red";
                this.actualColor = "rgba(255, 0, 0, 1)";
            } else {
                this.color = value;
                const temp = colorToRGBA(value);
                this.actualColor = `rgba(${temp[0]},${temp[1]},${temp[2]}, ${temp[3]})`;
            }
        }
    }

    /**
     * @memberof HexDisplay
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.color],
            nodes: {
                inp: findNode(this.inp),
            },
        };
        return data;
    }

    /**
     * @memberof HexDisplay
     * function to draw element
     */
    customDrawSegment(x1, y1, x2, y2, color) {
        if (color === undefined) color = "lightgrey";
        var ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = correctWidth(5);
        const xx = this.x;
        const yy = this.y;

        moveTo(ctx, x1, y1, xx, yy, this.direction);
        lineTo(ctx, x2, y2, xx, yy, this.direction);
        ctx.closePath();
        ctx.stroke();
    }

    /**
     * @memberof HexDisplay
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;

        const xx = this.x;
        const yy = this.y;

        ctx.strokeStyle = colors["stroke"];
        ctx.lineWidth = correctWidth(3);

        let a = 0,
            b = 0,
            c = 0,
            d = 0,
            e = 0,
            f = 0,
            g = 0;
        switch (this.inp.value) {
            case 0:
                a = b = c = d = e = f = 1;
                break;
            case 1:
                b = c = 1;
                break;
            case 2:
                a = b = g = e = d = 1;
                break;
            case 3:
                a = b = g = c = d = 1;
                break;
            case 4:
                f = g = b = c = 1;
                break;
            case 5:
                a = f = g = c = d = 1;
                break;
            case 6:
                a = f = g = e = c = d = 1;
                break;
            case 7:
                a = b = c = 1;
                break;
            case 8:
                a = b = c = d = e = g = f = 1;
                break;
            case 9:
                a = f = g = b = c = 1;
                break;
            case 0xa:
                a = f = b = c = g = e = 1;
                break;
            case 0xb:
                f = e = g = c = d = 1;
                break;
            case 0xc:
                a = f = e = d = 1;
                break;
            case 0xd:
                b = c = g = e = d = 1;
                break;
            case 0xe:
                a = f = g = e = d = 1;
                break;
            case 0xf:
                a = f = g = e = 1;
                break;
            default:
        }
        this.customDrawSegment(18, -3, 18, -38, ["lightgrey", this.actualColor][b]);
        this.customDrawSegment(18, 3, 18, 38, ["lightgrey", this.actualColor][c]);
        this.customDrawSegment(-18, -3, -18, -38, ["lightgrey", this.actualColor][f]);
        this.customDrawSegment(-18, 3, -18, 38, ["lightgrey", this.actualColor][e]);
        this.customDrawSegment(-17, -38, 17, -38, ["lightgrey", this.actualColor][a]);
        this.customDrawSegment(-17, 0, 17, 0, ["lightgrey", this.actualColor][g]);
        this.customDrawSegment(-15, 38, 17, 38, ["lightgrey", this.actualColor][d]);
    }

    subcircuitDrawSegment(x1, y1, x2, y2, color, xxSegment, yySegment) {
        if (color == undefined) color = "lightgrey";
        var ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = correctWidth(3);
        var xx = xxSegment;
        var yy = yySegment;

        moveTo(ctx, x1, y1, xx, yy, this.direction);
        lineTo(ctx, x2, y2, xx, yy, this.direction);
        ctx.closePath();
        ctx.stroke();
    }
    // Draws the element in the subcircuit. Used in layout mode
    subcircuitDraw(xOffset = 0, yOffset = 0) {
        var ctx = simulationArea.context;

        var xx = this.subcircuitMetadata.x + xOffset;
        var yy = this.subcircuitMetadata.y + yOffset;

        ctx.strokeStyle = "black";
        ctx.lineWidth = correctWidth(3);
        let a = 0,
            b = 0,
            c = 0,
            d = 0,
            e = 0,
            f = 0,
            g = 0;

        switch (this.inp.value) {
            case 0:
                a = b = c = d = e = f = 1;
                break;
            case 1:
                b = c = 1;
                break;
            case 2:
                a = b = g = e = d = 1;
                break;
            case 3:
                a = b = g = c = d = 1;
                break;
            case 4:
                f = g = b = c = 1;
                break;
            case 5:
                a = f = g = c = d = 1;
                break;
            case 6:
                a = f = g = e = c = d = 1;
                break;
            case 7:
                a = b = c = 1;
                break;
            case 8:
                a = b = c = d = e = g = f = 1;
                break;
            case 9:
                a = f = g = b = c = 1;
                break;
            case 0xA:
                a = f = b = c = g = e = 1;
                break;
            case 0xB:
                f = e = g = c = d = 1;
                break;
            case 0xC:
                a = f = e = d = 1;
                break;
            case 0xD:
                b = c = g = e = d = 1;
                break;
            case 0xE:
                a = f = g = e = d = 1;
                break;
            case 0xF:
                a = f = g = e = 1;
                break;
            default:

        }
        this.subcircuitDrawSegment(10, -20, 10, -38, ["lightgrey", this.actualColor][b],xx, yy);
        this.subcircuitDrawSegment(10, -17, 10, 1, ["lightgrey", this.actualColor][c],xx, yy);
        this.subcircuitDrawSegment(-10, -20, -10, -38, ["lightgrey", this.actualColor][f],xx, yy);
        this.subcircuitDrawSegment(-10, -17, -10, 1, ["lightgrey", this.actualColor][e],xx, yy);
        this.subcircuitDrawSegment(-8, -38, 8, -38, ["lightgrey", this.actualColor][a],xx, yy);
        this.subcircuitDrawSegment(-8, -18, 8, -18, ["lightgrey", this.actualColor][g],xx, yy);
        this.subcircuitDrawSegment(-8, 1, 8, 1, ["lightgrey", this.actualColor][d],xx, yy);

        ctx.beginPath();
        ctx.strokeStyle = "black";
        ctx.lineWidth = correctWidth(1);
        rect2(ctx, -15, -42, 33, 51, xx, yy, this.direction);
        ctx.stroke();

        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) {
            ctx.fillStyle = "rgba(255, 255, 32,0.6)";
            ctx.fill();
        } 
    }
    generateVerilog() {
        return `
      always @ (*)
        $display("HexDisplay:${this.verilogLabel}=%d", ${this.inp.verilogLabel});`;
    }
}

/**
 * @memberof HexDisplay
 * Help Tip
 * @type {string}
 * @category modules
 */
HexDisplay.prototype.tooltipText =
    "Hex Display ToolTip: Inputs a 4 Bit Hex number and displays it.";

/**
 * @memberof HexDisplay
 * Help URL
 * @type {string}
 * @category modules
 */
HexDisplay.prototype.helplink =
    "https://docs.circuitverse.org/#/outputs?id=hex-display";
HexDisplay.prototype.objectType = "HexDisplay";
HexDisplay.prototype.canShowInSubcircuit = true;
HexDisplay.prototype.layoutProperties = {
    rightDimensionX : 20,
    leftDimensionX : 15,
    upDimensionY : 42,
    downDimensionY: 10
}

/**
 * @memberof HexDisplay
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
HexDisplay.prototype.mutableProperties = {
    color: {
        name: "Color: ",
        type: "text",
        func: "changeColor",
    },
};
