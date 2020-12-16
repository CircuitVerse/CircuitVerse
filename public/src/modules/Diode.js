import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, arc } from '../canvasApi';
import { changeInputSize } from '../modules';
import { colors } from '../themer/themer';
import { gateGenerateVerilog } from '../utils';


export default class Diode extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = "RIGHT",
        inputLength = 1,
        bitWidth = 1, 
        DiodeFlag = 0 
    ) {

		super(x, y, scope, dir, bitWidth);

        this.DiodeFlag = DiodeFlag; 
        this.fixedBitWidth = true ; 
		this.rectangleObject = false;
        this.setDimensions(15, 15) ;
        this.inp1 = new Node(-10, 0, 0, this);
        this.output1 = new Node(20, 0, 1, this);

    }


    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                output1: findNode(this.output1),
                inp1: findNode(this.inp1),
            },
        };
        return data;
    }

    isResolvable() {
        return true;
    }

    resolve() {
        this.DiodeFlag = 1 ; 

        if (this.inp1.value === 0) {
            this.state = undefined;
        }

        if (this.inp1.value === 1) {
            this.state = this.inp1.value;
        }

        this.output1.value = this.state;
        simulationArea.simulationQueue.add(this.output1);
    }


    customDraw() {
   		var ctx = simulationArea.context;
        ctx.strokeStyle = colors["stroke"];
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = "black";
        moveTo(ctx, -7, -10, xx, yy, this.direction);
        lineTo(ctx, 15, 0, xx, yy, this.direction);
        lineTo(ctx, -7, 10, xx, yy, this.direction);
        ctx.closePath();
        if (
            (this.hover && !simulationArea.shiftDown) ||
            simulationArea.lastSelected === this ||
            simulationArea.multipleObjectSelections.contains(this)
        )
            ctx.fillStyle = colors["hover_select"];
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        moveTo(ctx , 15 , 10 , xx , yy , this.direction); 
        lineTo(ctx, 15 , -10, xx , yy , this.direction);
        ctx.stroke();
    }

    generateVerilog() {
        return "assign " + this.output1.verilogLabel + " = " + this.inp1.verilogLabel + ";"
    }
}

export function getDiodeFlag() {
        return this.DiodeFlag ; 
    }

/**
 * @memberof Buffer
 * Help Tip
 * @type {string}
 * @category modules
 */
Diode.prototype.tooltipText =
    "Diode ToolTip : Isolate the input from the output.";
Diode.prototype.objectType = "Diode";

