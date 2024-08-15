import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, fillText } from '../canvasApi';
import {removeDuplicateComponent, generateHeaderVhdlEntity, generatePortsIO, generateSTDType, generateFooterEntity, generateSpacings, generateArchitetureHeader, generateLogicdlatch} from '../helperVHDL'
/**
 * @class
 * Dlatch
 * D latch has 2 input nodes:
 * clock, data input.
 * Difference between this and D - FlipFlop is
 * that Flip flop must have a clock.
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 * @category sequential
 */
import { colors } from '../themer/themer';
import { scopeList } from '../circuit';
export default class Dlatch extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
        super(x, y, scope, dir, bitWidth);
        /*
        this.scope['Dlatch'].push(this);
        */
        this.directionFixed = true;
        this.setDimensions(20, 20);
        this.rectangleObject = true;
        this.clockInp = new Node(-20, +10, 0, this, 1, 'Clock');
        this.dInp = new Node(-20, -10, 0, this, this.bitWidth, 'D');
        this.qOutput = new Node(20, -10, 1, this, this.bitWidth, 'Q');
        this.qInvOutput = new Node(20, 10, 1, this, this.bitWidth, 'Q Inverse');
        // this.reset = new Node(10, 20, 0, this, 1, "Asynchronous Reset");
        // this.preset = new Node(0, 20, 0, this, this.bitWidth, "Preset");
        // this.en = new Node(-10, 20, 0, this, 1, "Enable");
        this.state = 0;
        this.prevClockState = 0;
        this.wasClicked = false;
    }

    /**
     * Idea: shoould be D FF?
     */
    isResolvable() {
        if (this.clockInp.value != undefined && this.dInp.value != undefined) return true;
        return false;
    }

    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.dInp.bitWidth = bitWidth;
        this.qOutput.bitWidth = bitWidth;
        this.qInvOutput.bitWidth = bitWidth;
        // this.preset.bitWidth = bitWidth;
    }

    /**
     * @memberof Dlatch
     * when the clock input is high we update the state
     * qOutput is set to the state
     */
    resolve() {
        if (this.clockInp.value == 1 && this.dInp.value != undefined) {
            this.state = this.dInp.value;
        }

        if (this.qOutput.value != this.state) {
            this.qOutput.value = this.state;
            this.qInvOutput.value = this.flipBits(this.state);
            simulationArea.simulationQueue.add(this.qOutput);
            simulationArea.simulationQueue.add(this.qInvOutput);
        }

        this.setOutputsUpstream(true);
    }

    customSave() {
        var data = {
            nodes: {
                clockInp: findNode(this.clockInp),
                dInp: findNode(this.dInp),
                qOutput: findNode(this.qOutput),
                qInvOutput: findNode(this.qInvOutput),
                // reset: findNode(this.reset),
                // preset: findNode(this.preset),
                // en: findNode(this.en),
            },
            constructorParamaters: [this.direction, this.bitWidth],

        };
        return data;
    }

    customDraw() {
        var ctx = simulationArea.context;        
        ctx.strokeStyle = (colors['stroke']);
        ctx.fillStyle = colors['fill'];
        ctx.beginPath();
        ctx.lineWidth = correctWidth(3);
        var xx = this.x;
        var yy = this.y;
        // rect(ctx, xx - 20, yy - 20, 40, 40);
        moveTo(ctx, -20, 5, xx, yy, this.direction);
        lineTo(ctx, -15, 10, xx, yy, this.direction);
        lineTo(ctx, -20, 15, xx, yy, this.direction);
        // if ((this.b.hover&&!simulationArea.shiftDown)|| simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.font = '20px Raleway';
        ctx.fillStyle = colors['input_text'];
        ctx.textAlign = 'center';
        fillText(ctx, this.state.toString(16), xx, yy + 5);
        ctx.fill();
    }

    static moduleVHDL() {
        let output = "\n";
        const dlatch = Object.values(scopeList)[0].Dlatch
        let dlatchComponent = []

        for(var i = 0; i < dlatch.length; i++){
            dlatchComponent = [...dlatchComponent, {
                header: generateHeaderVhdlEntity('Dlatch', `bit${dlatch[i].bitWidth}`),
                portsin: generatePortsIO('in0', 0),
                stdin: generateSTDType('IN', dlatch[i].bitWidth) + ';\n',
                portsclock: generatePortsIO('clock', 0),
                stdclock: generateSTDType('IN', 1) + ';\n',
                portsout: generatePortsIO('q', 1),
                stdout: generateSTDType('OUT', dlatch[i].bitWidth) + '\n',
                footer: generateFooterEntity(),
                architeture: generateArchitetureHeader('Dlatch', `bit${dlatch[i].bitWidth}`),
                openProcess: `${generateSpacings(4)}PROCESS(in0, clock)\n${generateSpacings(6)}BEGIN\n${generateSpacings(8)}`,
                logic: generateLogicdlatch(),
                endprocess: `${generateSpacings(8)}END IF;\n${generateSpacings(4)}END PROCESS;`,
                end: `\nEND ARCHITECTURE;\n`,
                identificator: `bit${dlatch[i].bitWidth}`,
            }]
        }
        const dlatchFiltered = removeDuplicateComponent(dlatchComponent)
        dlatchFiltered.forEach(el => output += el.header + el.portsin + el.stdin + el.portsclock + el.stdclock + el.portsout + el.stdout + el.footer + el.architeture + el.openProcess + el.logic + el.endprocess + el.end)
        return output
    }
}

Dlatch.prototype.tooltipText = 'D Latch : Single input Flip flop or D FlipFlop';
Dlatch.prototype.helplink = 'https://docs.circuitverse.org/#/chapter4/6sequentialelements?id=d-latch';

Dlatch.prototype.objectType = 'Dlatch';
