import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, rect2, fillText,
} from '../canvasApi';
import plotArea from '../plotArea';
/**
 * @class
 * Flag
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {string} identifier - id
 * @category modules
 */
export default class Flag extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, identifier) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Flag'].push(this);
        */
        this.setWidth(60);
        this.setHeight(20);
        this.rectangleObject = false;
        this.directionFixed = true;
        this.orientationFixed = false;
        this.identifier = identifier || (`F${this.scope.Flag.length}`);
        this.plotValues = [];

        this.xSize = 10;

        this.inp1 = new Node(40, 0, 0, this);
    }

    /**
     * @memberof Flag
     * funtion to Set plot values
     * @type {string}
     */
    setPlotValue() {
        const time = plotArea.stopWatch.ElapsedMilliseconds;

        // //console.log("DEB:",time);
        if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] === time) { this.plotValues.pop(); }

        if (this.plotValues.length === 0) {
            this.plotValues.push([time, this.inp1.value]);
            return;
        }

        if (this.plotValues[this.plotValues.length - 1][1] === this.inp1.value) { return; }
        this.plotValues.push([time, this.inp1.value]);
    }

    /**
     * @memberof Flag
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth],
            nodes: {
                inp1: findNode(this.inp1),
            },
            values: {
                identifier: this.identifier,
            },
        };
        return data;
    }

    /**
     * @memberof Flag
     * set the flag id
     * @param {number} id - identifier for flag
     */
    setIdentifier(id = '') {
        if (id.length === 0) return;
        this.identifier = id;
        const len = this.identifier.length;
        if (len === 1) this.xSize = 20;
        else if (len > 1 && len < 4) this.xSize = 10;
        else this.xSize = 0;
    }

    /**
     * @memberof Flag
     * function to draw element
     */
    customDraw() {
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = 'grey';
        ctx.fillStyle = '#fcfcfc';
        ctx.lineWidth = correctWidth(1);
        const xx = this.x;
        const yy = this.y;

        rect2(ctx, -50 + this.xSize, -20, 100 - 2 * this.xSize, 40, xx, yy, 'RIGHT');
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();

        ctx.font = '14px Georgia';
        this.xOff = ctx.measureText(this.identifier).width;

        ctx.beginPath();
        rect2(ctx, -40 + this.xSize, -12, this.xOff + 10, 25, xx, yy, 'RIGHT');
        ctx.fillStyle = '#eee';
        ctx.strokeStyle = '#ccc';
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.textAlign = 'center';
        ctx.fillStyle = 'black';
        fillText(ctx, this.identifier, xx - 35 + this.xOff / 2 + this.xSize, yy + 5, 14);
        ctx.fill();

        ctx.beginPath();
        ctx.font = '30px Georgia';
        ctx.textAlign = 'center';
        ctx.fillStyle = ['blue', 'red'][+(this.inp1.value === undefined)];
        if (this.inp1.value !== undefined) { fillText(ctx, this.inp1.value.toString(16), xx + 35 - this.xSize, yy + 8, 25); } else { fillText(ctx, 'x', xx + 35 - this.xSize, yy + 8, 25); }
        ctx.fill();
    }

    /**
     * @memberof Flag
     * function to change direction of Flag
     * @param {string} dir - new direction
     */
    newDirection(dir) {
        if (dir === this.direction) return;
        this.direction = dir;
        this.inp1.refresh();
        if (dir === 'RIGHT' || dir === 'LEFT') {
            this.inp1.leftx = 50 - this.xSize;
        } else if (dir === 'UP') {
            this.inp1.leftx = 20;
        } else {
            this.inp1.leftx = 20;
        }
        // if(this.direction=="LEFT" || this.direction=="RIGHT") this.inp1.leftx=50-this.xSize;
        //     this.inp1.refresh();

        this.inp1.refresh();
    }
}

/**
 * @memberof Flag
 * Help Tip
 * @type {string}
 * @category modules
 */
Flag.prototype.tooltipText = 'FLag ToolTip: Use this for debugging and plotting.';
Flag.prototype.helplink = 'https://docs.circuitverse.org/#/timing_diagrams?id=using-flags';

/**
 * @memberof Flag
 * Help URL
 * @type {string}
 * @category modules
 */
Flag.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=tunnel';

/**
 * @memberof Flag
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
Flag.prototype.mutableProperties = {
    identifier: {
        name: 'Debug Flag identifier',
        type: 'text',
        maxlength: '5',
        func: 'setIdentifier',
    },
};
Flag.prototype.objectType = 'Flag';
