import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo } from '../canvasApi';
/**
 * @class
 * Clock
 * Clock
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 * @category sequential
 */
import getColors from '../modules/colors';
export default class Clock extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT') {
        super(x, y, scope, dir, 1);
        /*
        this.scope['Clock'].push(this);
        */
        this.fixedBitWidth = true;
        this.output1 = new Node(10, 0, 1, this, 1);
        this.state = 0;
        this.output1.value = this.state;
        this.wasClicked = false;
        this.interval = null;
    }

    customSave() {
        var data = {
            nodes: {
                output1: findNode(this.output1),
            },
            constructorParamaters: [this.direction],
        };
        return data;
    }

    resolve() {
        this.output1.value = this.state;
        simulationArea.simulationQueue.add(this.output1);
    }

    toggleState() { // toggleState
        this.state = (this.state + 1) % 2;
        this.output1.value = this.state;
    }

    customDraw() {
        const colors = getColors();
        var ctx = simulationArea.context;
        ctx.strokeStyle = (colors['stroke']);
        ctx.fillStyle = colors['fill'];
        ctx.stroke();
        ctx.fill();
        ctx.lineWidth = correctWidth(3);
        var xx = this.x;
        var yy = this.y;

        ctx.beginPath();
        ctx.strokeStyle = [colors['wire_con'], colors['wire_pow']][this.state];
        ctx.lineWidth = correctWidth(2);
        if (this.state == 0) {
            moveTo(ctx, -6, 0, xx, yy, 'RIGHT');
            lineTo(ctx, -6, 5, xx, yy, 'RIGHT');
            lineTo(ctx, 0, 5, xx, yy, 'RIGHT');
            lineTo(ctx, 0, -5, xx, yy, 'RIGHT');
            lineTo(ctx, 6, -5, xx, yy, 'RIGHT');
            lineTo(ctx, 6, 0, xx, yy, 'RIGHT');
        } else {
            moveTo(ctx, -6, 0, xx, yy, 'RIGHT');
            lineTo(ctx, -6, -5, xx, yy, 'RIGHT');
            lineTo(ctx, 0, -5, xx, yy, 'RIGHT');
            lineTo(ctx, 0, 5, xx, yy, 'RIGHT');
            lineTo(ctx, 6, 5, xx, yy, 'RIGHT');
            lineTo(ctx, 6, 0, xx, yy, 'RIGHT');
        }
        ctx.stroke();
    }
}

Clock.prototype.tooltipText = 'Clock';

Clock.prototype.click = Clock.prototype.toggleState;
Clock.prototype.objectType = 'Clock';
