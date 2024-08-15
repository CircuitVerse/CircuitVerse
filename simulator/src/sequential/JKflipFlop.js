import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, fillText } from '../canvasApi';
/**
 * @class
 * JKflipFlop
 * JK flip flop has 6 input nodes:
 * clock, J input, K input, preset, reset ,enable.
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 * @category sequential
 */
import { colors } from '../themer/themer';
import { scopeList } from '../circuit';
import { generateArchitetureHeaderTFlipFlop, generateFooterEntity, generateHeaderVhdlEntity, generateLogicJKFlipFlop, generatePortsIO, generateSpacings, generateSTDType, hasComponent, hasExtraPorts, removeDuplicateComponent } from '../helperVHDL';
export default class JKflipFlop extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT') {
        super(x, y, scope, dir, 1);
        /*
        this.scope['JKflipFlop'].push(this);
        */
        this.directionFixed = true;
        this.fixedBitWidth = true;
        this.setDimensions(20, 20);
        this.rectangleObject = true;
        this.J = new Node(-20, -10, 0, this, 1, 'J');
        this.K = new Node(-20, 0, 0, this, 1, 'K');
        this.clockInp = new Node(-20, 10, 0, this, 1, 'Clock');
        this.qOutput = new Node(20, -10, 1, this, 1, 'Q');
        this.qInvOutput = new Node(20, 10, 1, this, 1, 'Q Inverse');
        this.reset = new Node(10, 20, 0, this, 1, 'Asynchronous Reset');
        this.preset = new Node(0, 20, 0, this, 1, 'Preset');
        this.en = new Node(-10, 20, 0, this, 1, 'Enable');
        this.state = 0;
        this.slaveState = 0;
        this.masterState = 0;
        this.prevClockState = 0;

        // this.wasClicked = false;
    }

    /**
     * @memberof JKflipFlop
     * if none of the predefined nodes have been deleted it isresolvable
     */
    isResolvable() {
        if (this.reset.value == 1) return true;
        if (this.clockInp.value != undefined && this.J.value != undefined && this.K.value != undefined) return true;
        return false;
    }

    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.dInp.bitWidth = bitWidth;
        this.qOutput.bitWidth = bitWidth;
        this.qInvOutput.bitWidth = bitWidth;
        this.preset.bitWidth = bitWidth;
    }

    /**
     * @memberof JKflipFlop
     * Edge triggered master slave JK flip flop is resolved by
     * setting the slaveState = masterState when there is an edge
     * in the clock. masterState = this.J when no change in clock.
     */
    resolve() {
        if (this.reset.value == 1) {
            this.masterState = this.slaveState = this.preset.value || 0;
        } else if (this.en.value == 0) {
            this.prevClockState = this.clockInp.value;
        } else if (this.en.value == 1 || this.en.connections.length == 0) {
            if (this.clockInp.value == this.prevClockState) {
                if (this.clockInp.value == 0 && this.J.value != undefined && this.K.value != undefined) {
                    if (this.J.value && this.K.value) { this.masterState = 1 ^ this.slaveState; }
                    else if (this.J.value ^ this.K.value) { this.masterState = this.J.value; }
                }
            } else if (this.clockInp.value != undefined) {
                if (this.clockInp.value == 1) {
                    this.slaveState = this.masterState;
                } else if (this.clockInp.value == 0 && this.J.value != undefined && this.K.value != undefined) {
                    if (this.J.value && this.K.value) { this.masterState = 1 ^ this.slaveState; }
                    else if (this.J.value ^ this.K.value) { this.masterState = this.J.value; }
                }
                this.prevClockState = this.clockInp.value;
            }
        }

        if (this.qOutput.value != this.slaveState) {
            this.qOutput.value = this.slaveState;
            this.qInvOutput.value = this.flipBits(this.slaveState);
            simulationArea.simulationQueue.add(this.qOutput);
            simulationArea.simulationQueue.add(this.qInvOutput);
        }

        this.setOutputsUpstream(true);
    }

    customSave() {
        var data = {
            nodes: {
                J: findNode(this.J),
                K: findNode(this.K),
                clockInp: findNode(this.clockInp),
                qOutput: findNode(this.qOutput),
                qInvOutput: findNode(this.qInvOutput),
                reset: findNode(this.reset),
                preset: findNode(this.preset),
                en: findNode(this.en),
            },
            constructorParamaters: [this.direction],

        };
        return data;
    }

    customDraw() {
        var ctx = simulationArea.context;        
        ctx.strokeStyle = (colors['stroke']);
        ctx.fillStyle = (colors['fill']);
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
        fillText(ctx, this.slaveState.toString(16), xx, yy + 5);
        ctx.fill();
    }

    static moduleVHDL(){
        let output = "\n";
        const jkflipflop = Object.values(scopeList)[0].JKflipFlop
        let jkflipflopcomponent = []
        let enable = []
        let preset = []
        let reset = []

        for(var i = 0; i < jkflipflop.length; i++){
            enable = jkflipflop[i].en
            preset = jkflipflop[i].preset
            reset = jkflipflop[i].reset

            jkflipflopcomponent = [...jkflipflopcomponent, {
                header: generateHeaderVhdlEntity('JKFlipFlop', `bit${jkflipflop[i].bitWidth}`),
                JPort: generatePortsIO('J', 0),
                stdJ: generateSTDType('IN', jkflipflop[i].bitWidth) + ';\n',
                KPort: generatePortsIO('K', 0),
                stdK: generateSTDType('IN', jkflipflop[i].bitWidth) + ';\n',
                portsclock: generatePortsIO('clock', 0),
                stdclock: generateSTDType('IN', 1) + ';',
                
                portEnable: hasComponent(enable.connections) ? '\n' + generatePortsIO('enable', 0) : '',
                stdEnable: hasComponent(enable.connections) ? generateSTDType('IN', 1) + ';' : '',
                
                portPreset: hasComponent(preset.connections) ? '\n' + generatePortsIO('preset', 0) : '',
                stdPreset: hasComponent(preset.connections) ? generateSTDType('IN', 1) + ';' : '',
                
                portAReset: hasComponent(reset.connections) ? '\n' + generatePortsIO('reset', 0) : '',
                stdReset: hasComponent(reset.connections) ? generateSTDType('IN', 1) + ';' : '',
                
                portsout: '\n' + generatePortsIO('q', 1),
                stdout: generateSTDType('OUT', jkflipflop[i].bitWidth) + '\n',
                footer: generateFooterEntity(),
                architeture: generateArchitetureHeaderTFlipFlop('JKFlipFlop', `bit${jkflipflop[i].bitWidth}`),
                openProcess: `${generateSpacings(4)}PROCESS(J, K, clock${hasExtraPorts(enable.connections, preset.connections, reset.connections)})\n${generateSpacings(6)}BEGIN\n${generateSpacings(8)}`,
                logic: generateLogicJKFlipFlop(jkflipflop[i]),
                endprocess: `${generateSpacings(4)}END PROCESS;\n`,
                attr: `${generateSpacings(2)} q0 <= tmp;\n${generateSpacings(2)} q1 <= NOT tmp;\n`,
                end: `\nEND ARCHITECTURE;\n`,
                identificator: `bit${jkflipflop[i].bitWidth}`,
            }]
        }
        const jkflipflopFiltered = removeDuplicateComponent(jkflipflopcomponent)
        jkflipflopFiltered.forEach(el => output += el.header + el.JPort + el.stdJ + el.KPort + el.stdK + el.portsclock + el.stdclock + el.portEnable + el.stdEnable + el.portPreset + el.stdPreset + el.portAReset + el.stdReset + el.portsout + el.stdout + el.footer + el.architeture + el.openProcess + el.logic + el.endprocess + el.attr + el.end)
        return output
    }
}

JKflipFlop.prototype.tooltipText = 'JK FlipFlop ToolTip : gated SR flip-flop with the addition of a clock input.';

JKflipFlop.prototype.helplink = 'https://docs.circuitverse.org/#/chapter4/6sequentialelements?id=jk-flip-flop';

JKflipFlop.prototype.objectType = 'JKflipFlop';
