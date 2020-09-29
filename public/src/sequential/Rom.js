import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, rect2, fillText3,
} from '../canvasApi';
/**
 * @class
 * Rom
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {Array=} data - bit width per node.
 * @category sequential
 */
import { colors } from '../themer/themer';
export default class Rom extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ) {
        super(x, y, scope, 'RIGHT', 1);
        /*
        this.scope['Rom'].push(this);
        */
        this.fixedBitWidth = true;
        this.directionFixed = true;
        this.rectangleObject = false;
        this.setDimensions(80, 50);
        this.memAddr = new Node(-80, 0, 0, this, 4, 'Address');
        this.en = new Node(0, 50, 0, this, 1, 'Enable');
        this.dataOut = new Node(80, 0, 1, this, 8, 'DataOut');
        this.data = data || prompt('Enter data').split(' ').map((lambda) => parseInt(lambda, 16));
        // console.log(this.data);
    }

    /**
     * @memberof Rom
     * Checks if the element is resolvable
     * @return {boolean}
     */
    isResolvable() {
        if ((this.en.value === 1 || this.en.connections.length === 0) && this.memAddr.value !== undefined) return true;
        return false;
    }

    /**
     * @memberof Rom
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.data],
            nodes: {
                memAddr: findNode(this.memAddr),
                dataOut: findNode(this.dataOut),
                en: findNode(this.en),
            },

        };
        return data;
    }

    /**
     * @memberof Rom
     * function to find position of the index of part of rom selected.
     * @return {number}
     */
    findPos() {
        const i = Math.floor((simulationArea.mouseX - this.x + 35) / 20);
        const j = Math.floor((simulationArea.mouseY - this.y + 35) / 16);
        if (i < 0 || j < 0 || i > 3 || j > 3) return undefined;
        return j * 4 + i;
    }

    /**
     * @memberof Rom
     * listener function to set selected index
     * @return {number}
     */
    click() { // toggle
        this.selectedIndex = this.findPos();
    }

    /**
     * @memberof Rom
     * to take input in rom
     * @return {number}
     */
    keyDown(key) {
        if (key === 'Backspace') this.delete();
        if (this.selectedIndex === undefined) return;
        key = key.toLowerCase();
        if (!~'1234567890abcdef'.indexOf(key)) return;

        this.data[this.selectedIndex] = (this.data[this.selectedIndex] * 16 + parseInt(key, 16)) % 256;
    }

    /**
     * @memberof Rom
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        const hoverIndex = this.findPos();
        ctx.strokeStyle = colors['stroke'];
        ctx.fillStyle = (colors['fill']);
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, [this.direction, 'RIGHT'][+this.directionFixed]);
        if (hoverIndex === undefined && ((!simulationArea.shiftDown && this.hover) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this))) ctx.fillStyle = colors["hover_select"];
        ctx.fill();
        ctx.stroke();
        ctx.strokeStyle = 'black';
        ctx.fillStyle = '#fafafa';
        ctx.lineWidth = correctWidth(1);
        ctx.beginPath();
        for (let i = 0; i < 16; i += 4) {
            for (let j = i; j < i + 4; j++) {
                rect2(ctx, (j % 4) * 20, i * 4, 20, 16, xx - 35, yy - 35);
            }
        }
        ctx.fill();
        ctx.stroke();
        if (hoverIndex !== undefined) {
            ctx.beginPath();
            ctx.fillStyle = 'yellow';
            rect2(ctx, (hoverIndex % 4) * 20, Math.floor(hoverIndex / 4) * 16, 20, 16, xx - 35, yy - 35);
            ctx.fill();
            ctx.stroke();
        }
        if (this.selectedIndex !== undefined) {
            ctx.beginPath();
            ctx.fillStyle = 'lightgreen';
            rect2(ctx, (this.selectedIndex % 4) * 20, Math.floor(this.selectedIndex / 4) * 16, 20, 16, xx - 35, yy - 35);
            ctx.fill();
            ctx.stroke();
        }
        if (this.memAddr.value !== undefined) {
            ctx.beginPath();
            ctx.fillStyle = colors['input_text'];
            rect2(ctx, (this.memAddr.value % 4) * 20, Math.floor(this.memAddr.value / 4) * 16, 20, 16, xx - 35, yy - 35);
            ctx.fill();
            ctx.stroke();
        }

        ctx.beginPath();
        ctx.fillStyle = 'Black';
        fillText3(ctx, 'A', -65, 5, xx, yy, 16, 'Georgia', 'right');
        fillText3(ctx, 'D', 75, 5, xx, yy, 16, 'Georgia', 'right');
        fillText3(ctx, 'En', 5, 47, xx, yy, 16, 'Georgia', 'right');
        ctx.fill();

        ctx.beginPath();
        ctx.fillStyle = 'Black';
        for (let i = 0; i < 16; i += 4) {
            for (let j = i; j < i + 4; j++) {
                let s = this.data[j].toString(16);
                if (s.length < 2) s = `0${s}`;
                fillText3(ctx, s, (j % 4) * 20, i * 4, xx - 35 + 10, yy - 35 + 12, 14, 'Georgia', 'center');
            }
        }
        ctx.fill();

        ctx.beginPath();
        ctx.fillStyle = 'Black';
        for (let i = 0; i < 16; i += 4) {
            let s = i.toString(16);
            if (s.length < 2) s = `0${s}`;
            fillText3(ctx, s, 0, i * 4, xx - 40, yy - 35 + 12, 14, 'Georgia', 'right');
        }
        ctx.fill();
    }

    /**
     * @memberof Rom
     * resolve output values based on inputData
     */
    resolve() {
        if (this.isResolvable() === false) {
            return;
        }
        this.dataOut.value = this.data[this.memAddr.value];
        simulationArea.simulationQueue.add(this.dataOut);
    }
}

/**
 * @memberof Rom
 * Help Tip
 * @type {string}
 * @category sequential
 */
Rom.prototype.tooltipText = 'Read-only memory';
Rom.prototype.helplink = 'https://docs.circuitverse.org/#/memoryElements?id=rom';
Rom.prototype.objectType = 'Rom';
