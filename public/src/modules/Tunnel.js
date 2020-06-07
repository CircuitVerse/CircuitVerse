import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, rect2, fillText } from '../canvasApi';
import plotArea from '../plotArea';
/**
 * @class
 * Tunnel
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {string=} identifier - number of input nodes
 * @category modules
 */
export default class Tunnel extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'LEFT', bitWidth = 1, identifier) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Tunnel'].push(this);
        */
        this.rectangleObject = false;
        this.centerElement = true;
        this.xSize = 10;
        this.plotValues = [];
        this.inp1 = new Node(0, 0, 0, this);
        this.setIdentifier(identifier || 'T');
        this.setBounds();
    }

    /**
     * @memberof Tunnel
     * function to change direction of Tunnel
     * @param {string} dir - new direction
     */
    newDirection(dir) {
        if (this.direction === dir) return;
        this.direction = dir;
        this.setBounds();
    }

    setBounds() {
        let xRotate = 0;
        let yRotate = 0;
        if (this.direction === 'LEFT') {
            xRotate = 0;
            yRotate = 0;
        } else if (this.direction === 'RIGHT') {
            xRotate = 120 - this.xSize;
            yRotate = 0;
        } else if (this.direction === 'UP') {
            xRotate = 60 - this.xSize / 2;
            yRotate = -20;
        } else {
            xRotate = 60 - this.xSize / 2;
            yRotate = 20;
        }

        this.leftDimensionX = Math.abs(-120 + xRotate + this.xSize);
        this.upDimensionY = Math.abs(-20 + yRotate);
        this.rightDimensionX = Math.abs(xRotate);
        this.downDimensionY = Math.abs(20 + yRotate);

        // rect2(ctx, -120 + xRotate + this.xSize, -20 + yRotate, 120 - this.xSize, 40, xx, yy, "RIGHT");
    }

    /**
     * @memberof Tunnel
     * function to set tunnel value
     * @param {number} val - tunnel value
     */
    setTunnelValue(val) {
        this.inp1.value = val;
        for (let i = 0; i < this.inp1.connections.length; i++) {
            if (this.inp1.connections[i].value !== val) {
                this.inp1.connections[i].value = val;
                simulationArea.simulationQueue.add(this.inp1.connections[i]);
            }
        }
    }

    /**
     * @memberof Tunnel
     * resolve output values based on inputData
     */
    resolve() {
        for (let i = 0; i < this.scope.tunnelList[this.identifier].length; i++) {
            if (this.scope.tunnelList[this.identifier][i].inp1.value !== this.inp1.value) {
                this.scope.tunnelList[this.identifier][i].setTunnelValue(this.inp1.value);
            }
        }
    }

    /**
     * @memberof Tunnel
     * function to set tunnel value
     * @param {Scope} scope - tunnel value
     */
    updateScope(scope) {
        this.scope = scope;
        this.inp1.updateScope(scope);
        this.setIdentifier(this.identifier);
        // console.log("ShouldWork!");
    }

    /**
     * @memberof Tunnel
     * function to set plot value
     */
    setPlotValue() {
        const time = plotArea.stopWatch.ElapsedMilliseconds;
        if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] === time) { this.plotValues.pop(); }

        if (this.plotValues.length === 0) {
            this.plotValues.push([time, this.inp1.value]);
            return;
        }

        if (this.plotValues[this.plotValues.length - 1][1] === this.inp1.value) { return; }
        this.plotValues.push([time, this.inp1.value]);
    }

    /**
     * @memberof Tunnel
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth, this.identifier],
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
     * @memberof Tunnel
     * function to set tunnel value
     * @param {string=} id - id so that every link is unique
     */
    setIdentifier(id = '') {
        if (id.length === 0) return;
        if (this.scope.tunnelList[this.identifier]) this.scope.tunnelList[this.identifier].clean(this);
        this.identifier = id;
        if (this.scope.tunnelList[this.identifier]) this.scope.tunnelList[this.identifier].push(this);
        else this.scope.tunnelList[this.identifier] = [this];
        const len = this.identifier.length;
        if (len === 1) this.xSize = 40;
        else if (len > 1 && len < 4) this.xSize = 20;
        else this.xSize = 0;
        this.setBounds();
    }

    /**
     * @memberof Tunnel
     * delete the tunnel element
     */
    delete() {
        this.scope.Tunnel.clean(this);
        this.scope.tunnelList[this.identifier].clean(this);
        super.delete();
        this.scope.Tunnel.push(this);
    }

    /**
     * @memberof Tunnel
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

        let xRotate = 0;
        let yRotate = 0;
        if (this.direction === 'LEFT') {
            xRotate = 0;
            yRotate = 0;
        } else if (this.direction === 'RIGHT') {
            xRotate = 120 - this.xSize;
            yRotate = 0;
        } else if (this.direction === 'UP') {
            xRotate = 60 - this.xSize / 2;
            yRotate = -20;
        } else {
            xRotate = 60 - this.xSize / 2;
            yRotate = 20;
        }

        rect2(ctx, -120 + xRotate + this.xSize, -20 + yRotate, 120 - this.xSize, 40, xx, yy, 'RIGHT');
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }
        ctx.fill();
        ctx.stroke();

        ctx.font = '14px Georgia';
        this.xOff = ctx.measureText(this.identifier).width;
        ctx.beginPath();
        rect2(ctx, -105 + xRotate + this.xSize, -11 + yRotate, this.xOff + 10, 23, xx, yy, 'RIGHT');
        ctx.fillStyle = '#eee';
        ctx.strokeStyle = '#ccc';
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.textAlign = 'center';
        ctx.fillStyle = 'black';
        fillText(ctx, this.identifier, xx - 100 + this.xOff / 2 + xRotate + this.xSize, yy + 6 + yRotate, 14);
        ctx.fill();

        ctx.beginPath();
        ctx.font = '30px Georgia';
        ctx.textAlign = 'center';
        ctx.fillStyle = ['blue', 'red'][+(this.inp1.value === undefined)];
        if (this.inp1.value !== undefined) { fillText(ctx, this.inp1.value.toString(16), xx - 23 + xRotate, yy + 8 + yRotate, 25); } else { fillText(ctx, 'x', xx - 23 + xRotate, yy + 8 + yRotate, 25); }
        ctx.fill();
    }
}

/**
 * @memberof Tunnel
 * Help Tip
 * @type {string}
 * @category modules
 */
Tunnel.prototype.tooltipText = 'Tunnel ToolTip : Tunnel Selected.';
Tunnel.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=tunnel';

Tunnel.prototype.overrideDirectionRotation = true;

/**
 * @memberof Tunnel
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
Tunnel.prototype.mutableProperties = {
    identifier: {
        name: 'Debug Flag identifier',
        type: 'text',
        maxlength: '5',
        func: 'setIdentifier',
    },
};
Tunnel.prototype.objectType = 'Tunnel';
