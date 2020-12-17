import CircuitElement from "../circuitElement";
import Node, { findNode } from "../node";
import simulationArea from "../simulationArea";
import { correctWidth, rect2, fillText } from "../canvasApi";
import plotArea from "../plotArea";
import { showError } from "../utils";
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
import { colors } from "../themer/themer";

export default class Tunnel extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = "LEFT",
        bitWidth = 1,
        identifier
    ) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Tunnel'].push(this);
        */
        this.rectangleObject = false;
        this.centerElement = true;
        this.xSize = 10;
        this.plotValues = [];
        this.inp1 = new Node(0, 0, 0, this);
        this.checked = false; // has this tunnel been checked by another paired tunnel
        this.setIdentifier(identifier || "T");
        this.setBounds();
        // if tunnels with this's identifier exist, then set the bitwidth to that of those tunnels
        if(this.scope.tunnelList[this.identifier].length > 0) {
            this.newBitWidth(this.scope.tunnelList[this.identifier][0].bitWidth);
        }
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
        if (this.direction === "LEFT") {
            xRotate = 0;
            yRotate = 0;
        } else if (this.direction === "RIGHT") {
            xRotate = 120 - this.xSize;
            yRotate = 0;
        } else if (this.direction === "UP") {
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
     * resolve output values based on inputData
     */
    resolve() {
        // Don't check for paired tunnels' value if already checked by another paired tunnel (O(n))
        if (this.checked) {
            this.checked = false;
            return;
        }
        // Check for bitwidth error since it bypasses node's resolve() function which usually checks bitwidths
        for (const tunnel of this.scope.tunnelList[this.identifier]) {
            if (tunnel.inp1.bitWidth !== this.inp1.bitWidth) {
                this.inp1.highlighted = true;
                tunnel.inp1.highlighted = true;
                showError(`BitWidth Error: ${this.inp1.bitWidth} and ${tunnel.inp1.bitWidth}`);
            }
            if (tunnel.inp1.value !== this.inp1.value) {
                tunnel.inp1.value = this.inp1.value;
                simulationArea.simulationQueue.add(tunnel.inp1);
            }
            if (tunnel !== this) tunnel.checked = true;
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
    }

    /**
     * @memberof Tunnel
     * function to set plot value
     */
    setPlotValue() {
        return;
        const time = plotArea.stopWatch.ElapsedMilliseconds;
        if (
            this.plotValues.length &&
            this.plotValues[this.plotValues.length - 1][0] === time
        ) {
            this.plotValues.pop();
        }

        if (this.plotValues.length === 0) {
            this.plotValues.push([time, this.inp1.value]);
            return;
        }

        if (
            this.plotValues[this.plotValues.length - 1][1] === this.inp1.value
        ) {
            return;
        }
        this.plotValues.push([time, this.inp1.value]);
    }

    /**
     * @memberof Tunnel
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [
                this.direction,
                this.bitWidth,
                this.identifier,
            ],
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
     * function to set tunnel identifier value
     * @param {string=} id - id so that every link is unique
     */
    setIdentifier(id = "") {
        if (id.length === 0) return;
        if (this.scope.tunnelList[this.identifier])
            this.scope.tunnelList[this.identifier].clean(this);
        this.identifier = id;
        if (this.scope.tunnelList[this.identifier])
            this.scope.tunnelList[this.identifier].push(this);
        else this.scope.tunnelList[this.identifier] = [this];

        // Change the bitwidth to be same as the other elements with this.identifier
        if (this.scope.tunnelList[this.identifier] && this.scope.tunnelList[this.identifier].length > 1) {
            this.bitWidth = this.inp1.bitWidth = this.scope.tunnelList[this.identifier][0].bitWidth;
        }

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
    }

    /**
     * @memberof Tunnel
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = colors["stroke"];
        ctx.fillStyle = colors["fill"];
        ctx.lineWidth = correctWidth(1);
        const xx = this.x;
        const yy = this.y;

        let xRotate = 0;
        let yRotate = 0;
        if (this.direction === "LEFT") {
            xRotate = 0;
            yRotate = 0;
        } else if (this.direction === "RIGHT") {
            xRotate = 120 - this.xSize;
            yRotate = 0;
        } else if (this.direction === "UP") {
            xRotate = 60 - this.xSize / 2;
            yRotate = -20;
        } else {
            xRotate = 60 - this.xSize / 2;
            yRotate = 20;
        }

        rect2(
            ctx,
            -120 + xRotate + this.xSize,
            -20 + yRotate,
            120 - this.xSize,
            40,
            xx,
            yy,
            "RIGHT"
        );
        if (
            (this.hover && !simulationArea.shiftDown) ||
            simulationArea.lastSelected === this ||
            simulationArea.multipleObjectSelections.contains(this)
        ) {
            ctx.fillStyle = colors["hover_select"];
        }
        ctx.fill();
        ctx.stroke();

        ctx.font = "14px Raleway";
        this.xOff = ctx.measureText(this.identifier).width;
        ctx.beginPath();
        rect2(
            ctx,
            -105 + xRotate + this.xSize,
            -11 + yRotate,
            this.xOff + 10,
            23,
            xx,
            yy,
            "RIGHT"
        );
        ctx.fillStyle = "#eee";
        ctx.strokeStyle = "#ccc";
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.textAlign = "center";
        ctx.fillStyle = "black";
        fillText(
            ctx,
            this.identifier,
            xx - 100 + this.xOff / 2 + xRotate + this.xSize,
            yy + 6 + yRotate,
            14
        );
        ctx.fill();

        ctx.beginPath();
        ctx.font = "30px Raleway";
        ctx.textAlign = "center";
        ctx.fillStyle = ["blue", "red"][+(this.inp1.value === undefined)];
        if (this.inp1.value !== undefined) {
            fillText(
                ctx,
                this.inp1.value.toString(16),
                xx - 23 + xRotate,
                yy + 8 + yRotate,
                25
            );
        } else {
            fillText(ctx, "x", xx - 23 + xRotate, yy + 8 + yRotate, 25);
        }
        ctx.fill();
    }

    /**
     * Overridden from CircuitElement. Sets all paired tunnels' bitwidths for syncronization
     * @param {number} bitWidth - bitwidth to set to
     */
    newBitWidth(bitWidth) {
        for (let tunnel of this.scope.tunnelList[this.identifier]) {
            if (tunnel.fixedBitWidth) continue;
            if (tunnel.bitWidth === undefined) continue;
            if (tunnel.bitWidth < 1) continue;
            tunnel.bitWidth = bitWidth;
            for (let i = 0; i < tunnel.nodeList.length; i++) { tunnel.nodeList[i].bitWidth = bitWidth; }
        }
    }
}

/**
 * @memberof Tunnel
 * Help Tip
 * @type {string}
 * @category modules
 */
Tunnel.prototype.tooltipText = "Tunnel ToolTip : Tunnel Selected.";
Tunnel.prototype.helplink =
    "https://docs.circuitverse.org/#/miscellaneous?id=tunnel";

Tunnel.prototype.overrideDirectionRotation = true;

/**
 * @memberof Tunnel
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
Tunnel.prototype.mutableProperties = {
    identifier: {
        name: "Debug Flag identifier",
        type: "text",
        maxlength: "5",
        func: "setIdentifier",
    },
};
Tunnel.prototype.objectType = "Tunnel";
