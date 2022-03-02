import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, fillText2,
} from '../canvasApi';
import { colors } from '../themer/themer';


function extractBits(num, start, end) {
    return (num << (32 - end)) >>> (32 - (end - start + 1));
}

/**
 * @class
 * Splitter
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} bitWidthSplit - number of input nodes
 * @category modules
 */
export default class Splitter extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = 'RIGHT',
        bitWidth = undefined,
        bitWidthSplit = undefined,
    ) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Splitter'].push(this);
        */
        this.rectangleObject = false;

        this.bitWidthSplit = bitWidthSplit || (prompt('Enter bitWidth Split') || `${'1 '.repeat((this.bitWidth || 1) - 1)}1`).split(' ').filter((lambda) => lambda !== '').map((lambda) => parseInt(lambda, 10) || 1);
        this.splitCount = this.bitWidthSplit.length;

        this.setDimensions(10, (this.splitCount - 1) * 10 + 10);
        this.yOffset = (this.splitCount / 2 - 1) * 20;

        this.inp1 = new Node(-10, 10 + this.yOffset, 0, this, this.bitWidth);

        this.outputs = [];
        // this.prevOutValues=new Array(this.splitCount)
        for (let i = 0; i < this.splitCount; i++) { this.outputs.push(new Node(20, i * 20 - this.yOffset - 20, 0, this, this.bitWidthSplit[i])); }

        this.prevInpValue = undefined;
    }

    /**
     * @memberof Splitter
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {

            constructorParamaters: [this.direction, this.bitWidth, this.bitWidthSplit],
            nodes: {
                outputs: this.outputs.map(findNode),
                inp1: findNode(this.inp1),
            },
        };
        return data;
    }

    /**
     * @memberof Splitter
     * fn to remove proporgation delay.
     * @return {JSON}
     */
    removePropagation() {
        if (this.inp1.value === undefined) {
            let i = 0;
            for (i = 0; i < this.outputs.length; i++) { // False Hit
                if (this.outputs[i].value === undefined) return;
            }
            for (i = 0; i < this.outputs.length; i++) {
                if (this.outputs[i].value !== undefined) {
                    this.outputs[i].value = undefined;
                    simulationArea.simulationQueue.add(this.outputs[i]);
                }
            }
        } else if (this.inp1.value !== undefined) {
            this.inp1.value = undefined;
            simulationArea.simulationQueue.add(this.inp1);
        }
        this.prevInpValue = undefined;
    }

    /**
     * @memberof Splitter
     * Checks if the element is resolvable
     * @return {boolean}
     */
    isResolvable() {
        let resolvable = false;
        if (this.inp1.value !== this.prevInpValue) {
            if (this.inp1.value !== undefined) return true;
            return false;
        }
        let i;
        for (i = 0; i < this.splitCount; i++) { if (this.outputs[i].value === undefined) break; }
        if (i === this.splitCount) resolvable = true;
        return resolvable;
    }

    /**
     * @memberof Splitter
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        if (this.inp1.value !== undefined && this.inp1.value !== this.prevInpValue) {
            let bitCount = 1;
            for (let i = 0; i < this.splitCount; i++) {
                const bitSplitValue = extractBits(this.inp1.value, bitCount, bitCount + this.bitWidthSplit[i] - 1);
                if (this.outputs[i].value !== bitSplitValue) {
                    if (this.outputs[i].value !== bitSplitValue) {
                        this.outputs[i].value = bitSplitValue;
                        simulationArea.simulationQueue.add(this.outputs[i]);
                    }
                }
                bitCount += this.bitWidthSplit[i];
            }
        } else {
            let n = 0;
            for (let i = this.splitCount - 1; i >= 0; i--) {
                n <<= this.bitWidthSplit[i];
                n += this.outputs[i].value;
            }
            if (this.inp1.value !== (n >>> 0)) {
                this.inp1.value = (n >>> 0);
                simulationArea.simulationQueue.add(this.inp1);
            }
            // else if (this.inp1.value !== n) {
            //     console.log("CONTENTION");
            // }
        }
        this.prevInpValue = this.inp1.value;
    }

    /**
     * @memberof Splitter
     * fn to reset values of splitter
     */
    reset() {
        this.prevInpValue = undefined;
    }

    /**
     * @memberof Splitter
     * fn to process verilog of the element
     * @return {JSON}
     */
    processVerilog() {
        // console.log(this.inp1.verilogLabel +":"+ this.outputs[0].verilogLabel);
        if (this.inp1.verilogLabel !== '' && this.outputs[0].verilogLabel === '') {
            let bitCount = 0;
            for (let i = 0; i < this.splitCount; i++) {
                // let bitSplitValue = extractBits(this.inp1.value, bitCount, bitCount + this.bitWidthSplit[i] - 1);
                if (this.bitWidthSplit[i] > 1) { const label = `${this.inp1.verilogLabel}[ ${bitCount + this.bitWidthSplit[i] - 1}:${bitCount}]`; } else { const label = `${this.inp1.verilogLabel}[${bitCount}]`; }
                if (this.outputs[i].verilogLabel !== label) {
                    this.outputs[i].verilogLabel = label;
                    this.scope.stack.push(this.outputs[i]);
                }
                bitCount += this.bitWidthSplit[i];
            }
        } else if (this.inp1.verilogLabel === '' && this.outputs[0].verilogLabel !== '') {
            const label = `{${this.outputs.map((x) => x.verilogLabel).join(',')}}`;
            // console.log("HIT",label)
            if (this.inp1.verilogLabel !== label) {
                this.inp1.verilogLabel = label;
                this.scope.stack.push(this.inp1);
            }
        }
    }

    /**
     * @memberof Splitter
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        //        
        ctx.strokeStyle = [colors['splitter'], 'brown'][((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) + 0];
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        moveTo(ctx, -10, 10 + this.yOffset, xx, yy, this.direction);
        lineTo(ctx, 0, 0 + this.yOffset, xx, yy, this.direction);
        lineTo(ctx, 0, -20 * (this.splitCount - 1) + this.yOffset, xx, yy, this.direction);
        let bitCount = 0;
        for (let i = this.splitCount - 1; i >= 0; i--) {
            moveTo(ctx, 0, -20 * i + this.yOffset, xx, yy, this.direction);
            lineTo(ctx, 20, -20 * i + this.yOffset, xx, yy, this.direction);
        }
        ctx.stroke();
        ctx.beginPath();
        ctx.fillStyle = colors['text'];
        for (let i = this.splitCount - 1; i >= 0; i--) {
            var splitLabel;
            if (this.bitWidthSplit[this.splitCount - i - 1] == 1)
                splitLabel = `${bitCount}`;
            else
                splitLabel = `${bitCount}:${bitCount + this.bitWidthSplit[this.splitCount - i - 1] - 1}`;

            fillText2(ctx, splitLabel, 16, -20 * i + this.yOffset + 10, xx, yy, this.direction);
            bitCount += this.bitWidthSplit[this.splitCount - i - 1];
        }
        ctx.fill();
    }

    processVerilog() {
        // Combiner
        if (this.inp1.verilogLabel == "") {
            this.isSplitter = false;
            this.inp1.verilogLabel = this.verilogLabel + "_cmb";
            if (!this.scope.verilogWireList[this.bitWidth].contains(this.inp1.verilogLabel))
                this.scope.verilogWireList[this.bitWidth].push(this.inp1.verilogLabel);
            this.scope.stack.push(this.inp1);
            return;
        }

        // Splitter
        this.isSplitter = true;
        for (var j = 0; j < this.outputs.length; j++) {
            var bitCount = 0;
            var inpLabel = this.inp1.verilogLabel;
            // Already Split Regex
            var re = /^(.*)\[(\d*):(\d*)\]$/;
            if (re.test(inpLabel)) {
                var matches = inpLabel.match(re);
                inpLabel = matches[1];
                bitCount = parseInt(matches[3]);
            }
            for (var i = 0; i < this.splitCount; i++) {
                if (this.bitWidthSplit[i] > 1)
                    var label = inpLabel + '[' + (bitCount + this.bitWidthSplit[i] - 1) + ":" + bitCount + "]";
                else
                    var label = inpLabel + '[' + bitCount + "]";
                if (this.outputs[i].verilogLabel != label) {
                    this.outputs[i].verilogLabel = label;
                    this.scope.stack.push(this.outputs[i]);
                }
                bitCount += this.bitWidthSplit[i];
            }
        }
    }
    //added to generate Splitter INPUTS
    generateVerilog() {
        var res = "";
        if (!this.isSplitter) {
            res += "assign " + this.inp1.verilogLabel + " = {";
            for (var i = this.outputs.length - 1; i > 0; i--)
                res += this.outputs[i].verilogLabel + ",";
            res += this.outputs[0].verilogLabel + "};";
        }
        return res;
    }
}

/**
 * @memberof Splitter
 * Help Tip
 * @type {string}
 * @category modules
 */
Splitter.prototype.tooltipText = 'Splitter ToolTip: Split multiBit Input into smaller bitwidths or vice versa.';

/**
 * @memberof Splitter
 * Help URL
 * @type {string}
 * @category modules
 */
Splitter.prototype.helplink = 'https://docs.circuitverse.org/#/splitter';
Splitter.prototype.objectType = 'Splitter';
