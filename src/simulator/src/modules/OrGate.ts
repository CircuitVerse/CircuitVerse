import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import { simulationArea } from '../simulationArea';
import { correctWidth, bezierCurveTo, moveTo } from '../canvasApi';
import { changeInputSize } from '../modules';
import { gateGenerateVerilog } from '../utils';

import { colors } from '../themer/themer';

export default class OrGate extends CircuitElement {
    private inp: Node[];
    private inputSize: number;
    private output1: Node;

    constructor(
        x: number,
        y: number,
        scope: any = globalScope,
        dir: string = 'RIGHT',
        inputs: number = 2,
        bitWidth: number = 1
    ) {
        super(x, y, scope, dir, bitWidth);
        this.rectangleObject = false;
        this.setDimensions(15, 20);
        this.inp = [];
        this.inputSize = inputs;
        if (inputs % 2 === 1) {
            for (let i = Math.floor(inputs / 2) - 1; i >= 0; i--) {
                const a = new Node(-10, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            let a = new Node(-10, 0, 0, this);
            this.inp.push(a);
            for (let i = 0; i < Math.floor(inputs / 2); i++) {
                a = new Node(-10, 10 * (i + 1), 0, this);
                this.inp.push(a);
            }
        } else {
            for (let i = inputs / 2 - 1; i >= 0; i--) {
                const a = new Node(-10, -10 * (i + 1), 0, this);
                this.inp.push(a);
            }
            for (let i = 0; i < inputs / 2; i++) {
                const a = new Node(-10, 10 * (i + 1), 0, this);
                this.inp.push(a);
            }
        }
        this.output1 = new Node(20, 0, 1, this);
    }

    // Resolve output values based on inp
    resolve() {
        let result = this.inp[0].value || 0;
        if (this.isResolvable() === false) {
            return;
        }
        for (let i = 1; i < this.inputSize; i++) {
            result |= this.inp[i].value || 0;
        }
        this.output1.value = result >>> 0;
        simulationArea.simulationQueue.add(this.output1);
    }

    customDraw() {
        var ctx = simulationArea.context;
        if (ctx) {
            ctx.strokeStyle = colors['stroke'];
            ctx.lineWidth = correctWidth(3);

            const xx = this.x;
            const yy = this.y;
            ctx.beginPath();
            ctx.fillStyle = colors['fill'];

            moveTo(ctx, -10, -20, xx, yy, this.direction, true);
            bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
            bezierCurveTo(
                0 + 15,
                0 + 10,
                0,
                0 + 20,
                -10,
                +20,
                xx,
                yy,
                this.direction
            );
            bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
            ctx.closePath();
            if (
                (this.hover && !simulationArea.shiftDown) ||
                simulationArea.lastSelected === this ||
                simulationArea.multipleObjectSelections.includes(this)
            ) {
                ctx.fillStyle = colors['hover_select'];
            }
            ctx.fill();
            ctx.stroke();
        }
    }

    customSave(): object {
        const data = {
            constructorParamaters: [
                this.direction,
                this.inputSize,
                this.bitWidth,
            ],
            nodes: {
                inp: this.inp.map(findNode),
                output1: findNode(this.output1),
            },
        };
        return data;
    }

    generateVerilog(): string {
        return gateGenerateVerilog.call(this, '|');
    }
}

OrGate.prototype.tooltipText =
    'Or Gate ToolTip : Implements logical disjunction';

OrGate.prototype.changeInputSize = changeInputSize;

OrGate.prototype.alwaysResolve = true;

OrGate.prototype.verilogType = 'or';
OrGate.prototype.helplink =
    'https://docs.circuitverse.org/#/chapter4/4gates?id=or-gate';
OrGate.prototype.objectType = 'OrGate';