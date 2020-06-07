import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { rect2, fillText } from '../canvasApi';
/**
 * @class
 * Text
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} label - label of element
 * @param {number=} fontSize - font size
 * @category modules
 */
export default class Text extends CircuitElement {
    constructor(x, y, scope = globalScope, label = '', fontSize = 14) {
        super(x, y, scope, 'RIGHT', 1);
        /* this is done in this.baseSetup() now
        this.scope['Text'].push(this);
        */
        // this.setDimensions(15, 15);
        this.fixedBitWidth = true;
        this.directionFixed = true;
        this.labelDirectionFixed = true;
        this.setHeight(10);
        this.setLabel(label);
        this.setFontSize(fontSize);
    }

    /**
     * @memberof Text
     * function for setting text inside the element
     * @param {string=} str - the label
     */
    setLabel(str = '') {
        this.label = str;
        const ctx = simulationArea.context;
        ctx.font = `${this.fontSize}px Georgia`;
        this.leftDimensionX = 10;
        this.rightDimensionX = ctx.measureText(this.label).width + 10;
        // console.log(this.leftDimensionX,this.rightDimensionX,ctx.measureText(this.label))
    }

    /**
     * @memberof Text
     * function for setting font size inside the element
     * @param {number=} str - the font size
     */
    setFontSize(fontSize = 14) {
        this.fontSize = fontSize;
        const ctx = simulationArea.context;
        ctx.font = `${this.fontSize}px Georgia`;
        this.leftDimensionX = 10;
        this.rightDimensionX = ctx.measureText(this.label).width + 10;
    }

    /**
     * @memberof Text
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.label, this.fontSize],
        };
        return data;
    }

    /**
     * @memberof Text
     * Listener function for Text Box
     * @param {string} key - the label
     */
    keyDown(key) {
        if (key.length === 1) {
            if (this.label === 'Enter Text Here') { this.setLabel(key); } else { this.setLabel(this.label + key); }
        } else if (key === 'Backspace') {
            if (this.label === 'Enter Text Here') { this.setLabel(''); } else { this.setLabel(this.label.slice(0, -1)); }
        }
    }

    /**
     * @memberof Text
     * Function for drawing text box
     */
    draw() {
        if (this.label.length === 0 && simulationArea.lastSelected !== this) this.delete();
        const ctx = simulationArea.context;
        ctx.strokeStyle = 'black';
        ctx.lineWidth = 1;
        const xx = this.x;
        const yy = this.y;
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) {
            ctx.beginPath();
            ctx.fillStyle = 'white';
            const magicDimenstion = this.fontSize - 14;
            rect2(ctx, -this.leftDimensionX, -this.upDimensionY - magicDimenstion,
                this.leftDimensionX + this.rightDimensionX,
                this.upDimensionY + this.downDimensionY + magicDimenstion, this.x, this.y, 'RIGHT');
            ctx.fillStyle = 'rgba(255, 255, 32,0.1)';
            ctx.fill();
            ctx.stroke();
        }
        ctx.beginPath();
        ctx.textAlign = 'left';
        ctx.fillStyle = 'black';
        fillText(ctx, this.label, xx, yy + 5, this.fontSize);
        ctx.fill();
    }
}

/**
 * @memberof Text
 * Help Tip
 * @type {string}
 * @category modules
 */
Text.prototype.tooltipText = 'Text ToolTip: Use this to document your circuit.';

/**
 * @memberof Text
 * Help URL
 * @type {string}
 * @category modules
 */
Text.prototype.helplink = 'https://docs.circuitverse.org/#/annotation?id=adding-labels';

/**
 * @memberof Text
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
Text.prototype.mutableProperties = {
    fontSize: {
        name: 'Font size: ',
        type: 'number',
        max: '84',
        min: '14',
        func: 'setFontSize',
    },
};
Text.prototype.objectType = 'Text';
