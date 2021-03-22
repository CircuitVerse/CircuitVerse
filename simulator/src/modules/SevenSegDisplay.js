import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, rect, rect2 } from '../canvasApi';
import ColorProperty from "../colorProperty";

/**
 * @class
 * SevenSegDisplay
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} color - color of display elements
 * @category modules
 */
export default class SevenSegDisplay extends CircuitElement {
    constructor(x, y, scope = globalScope, color = "Red") {
        super(x, y, scope, 'RIGHT', 1);
        /* this is done in this.baseSetup() now
        this.scope['SevenSegDisplay'].push(this);
        */
        this.fixedBitWidth = true;
        this.directionFixed = true;
        this.setDimensions(30, 50);

        this.g = new Node(-20, -50, 0, this);
        this.f = new Node(-10, -50, 0, this);
        this.a = new Node(+10, -50, 0, this);
        this.b = new Node(+20, -50, 0, this);
        this.e = new Node(-20, +50, 0, this);
        this.d = new Node(-10, +50, 0, this);
        this.c = new Node(+10, +50, 0, this);
        this.dot = new Node(+20, +50, 0, this);
        this.direction = 'RIGHT';  
        this.colorProp = new ColorProperty(color);
        this.color = this.colorProp.color;
    }

    /**
     * @memberof SevenSegDisplay
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.color],    
            nodes: {
                g: findNode(this.g),
                f: findNode(this.f),
                a: findNode(this.a),
                b: findNode(this.b),
                d: findNode(this.d),
                e: findNode(this.e),
                c: findNode(this.c),
                dot: findNode(this.dot),
            },
        };
        return data;
    }

    /**
     * @memberof SevenSegDisplay
     * function to change color of the led
     */
    changeColor(value) {
        this.color = this.colorProp.changeColor(value);
    }

    /**
     * @memberof SevenSegDisplay
     * helper function to create save Json Data of object
     */
    customDrawSegment(x1, y1, x2, y2, color) {
        if (color === undefined) color = 'lightgrey';
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
     * @memberof SevenSegDisplay
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        this.customDrawSegment(18, -3, 18, -38, ['lightgrey', this.colorProp.getRGBA()][this.b.value]);
        this.customDrawSegment(18, 3, 18, 38, ['lightgrey', this.colorProp.getRGBA()][this.c.value]);
        this.customDrawSegment(-18, -3, -18, -38, ['lightgrey', this.colorProp.getRGBA()][this.f.value]);
        this.customDrawSegment(-18, 3, -18, 38, ['lightgrey', this.colorProp.getRGBA()][this.e.value]);
        this.customDrawSegment(-17, -38, 17, -38, ['lightgrey', this.colorProp.getRGBA()][this.a.value]);
        this.customDrawSegment(-17, 0, 17, 0, ['lightgrey', this.colorProp.getRGBA()][this.g.value]);
        this.customDrawSegment(-15, 38, 17, 38, ['lightgrey', this.colorProp.getRGBA()][this.d.value]);
        ctx.beginPath();
        const dotColor = ['lightgrey', this.colorProp.getRGBA()][this.dot.value] || 'lightgrey';
        ctx.strokeStyle = dotColor;
        rect(ctx, xx + 22, yy + 42, 2, 2);
        ctx.stroke();
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

    // Draws the element in the subcuircuit. Used in layout mode
    subcircuitDraw(xOffset = 0, yOffset = 0) {
        var ctx = simulationArea.context;

        var xx = this.subcircuitMetadata.x + xOffset;
        var yy = this.subcircuitMetadata.y + yOffset;

        this.subcircuitDrawSegment(10, -20, 10, -38, ["lightgrey", this.colorProp.getRGBA()][this.b.value], xx, yy);
        this.subcircuitDrawSegment(10, -17, 10, 1, ["lightgrey", this.colorProp.getRGBA()][this.c.value], xx, yy);
        this.subcircuitDrawSegment(-10, -20, -10, -38, ["lightgrey", this.colorProp.getRGBA()][this.f.value], xx, yy);
        this.subcircuitDrawSegment(-10, -17, -10, 1, ["lightgrey", this.colorProp.getRGBA()][this.e.value], xx, yy);
        this.subcircuitDrawSegment(-8, -38, 8, -38, ["lightgrey", this.colorProp.getRGBA()][this.a.value], xx, yy);
        this.subcircuitDrawSegment(-8, -18, 8, -18, ["lightgrey", this.colorProp.getRGBA()][this.g.value], xx, yy);
        this.subcircuitDrawSegment(-8, 1, 8, 1, ["lightgrey", this.colorProp.getRGBA()][this.d.value], xx, yy);

        ctx.beginPath();
        var dotColor = ["lightgrey", this.colorProp.getRGBA()][this.dot.value] || "lightgrey"
        ctx.strokeStyle = dotColor;
        rect(ctx, xx + 13, yy + 5, 1, 1);
        ctx.stroke();

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
    generateVerilog(){
        return `
      always @ (*)
        $display("SevenSegDisplay:${this.verilogLabel}.abcdefg. = %b%b%b%b%b%b%b%b}",
                 ${this.a.verilogLabel}, ${this.b.verilogLabel}, ${this.c.verilogLabel}, ${this.d.verilogLabel}, ${this.e.verilogLabel}, ${this.f.verilogLabel}, ${this.g.verilogLabel}, ${this.dot.verilogLabel});`;
    }
}

/**
 * @memberof SevenSegDisplay
 * Help Tip
 * @type {string}
 * @category modules
 */
SevenSegDisplay.prototype.tooltipText = 'Seven Display ToolTip: Consists of 7+1 single bit inputs.';

/**
 * @memberof SevenSegDisplay
 * Help URL
 * @type {string}
 * @category modules
 */
SevenSegDisplay.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=seven-segment-display';
/**
 * @memberof SevenSegDisplay
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
SevenSegDisplay.prototype.mutableProperties = ColorProperty.createMutableColorProp("changeColor");
SevenSegDisplay.prototype.objectType = 'SevenSegDisplay';
SevenSegDisplay.prototype.canShowInSubcircuit = true;
SevenSegDisplay.prototype.layoutProperties = {
    rightDimensionX : 20,
    leftDimensionX : 15,
    upDimensionY : 42,
    downDimensionY: 10
}
