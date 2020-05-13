/* eslint-disable no-alert */
/* eslint-disable consistent-return */
/* eslint-disable no-multi-assign */
/* eslint-disable no-restricted-globals */
/* eslint-disable func-names */
/* eslint-disable no-bitwise */
/* eslint-disable no-param-reassign */
/**
 * @module modules
 */
/**
 * Function to change the number of input node
 * @param {number} size - new input size
 * @return {CircuitElement}
 */
function changeInputSize(size) {
    if (size === undefined || size < 2 || size > 10) return;
    if (this.inputSize === size) return;
    size = parseInt(size, 10);
    const obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, size, this.bitWidth);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
    // showProperties(obj);
}

/**
 * AndGate - (x,y)-position , scope - circuit level, inputLength - no of nodes, dir - direction of gate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of And Gate.
 * @param {number} y - y coordinate of And Gate.
 * @param {Scope=} scope - Cirucit on which and gate is drawn
 * @param {string=} dir - direction of And Gate
 * @param {number=} inputLength - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */
function AndGate(x, y, scope = globalScope, dir = 'RIGHT', inputLength = 2, bitWidth = 1) {
    /**
     * super call
     */
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);
    this.inp = [];
    this.inputSize = inputLength;

    // variable inputLength , node creation
    if (inputLength % 2 === 1) {
        for (let i = 0; i < inputLength / 2 - 1; i++) {
            const a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        let a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (let i = inputLength / 2 + 1; i < inputLength; i++) {
            a = new Node(-10, 10 * (i + 1 - inputLength / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (let i = 0; i < inputLength / 2; i++) {
            const a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (let i = inputLength / 2; i < inputLength; i++) {
            const a = new Node(-10, 10 * (i + 1 - inputLength / 2), 0, this);
            this.inp.push(a);
        }
    }

    this.output1 = new Node(20, 0, 1, this);
}

/**
 * @memberof AndGate
 * copy the prototype of CircuitELement to AndGate
 */
AndGate.prototype = Object.create(CircuitElement.prototype);

/**
 * @memberof AndGate
 * constructor of AndGate
 */
AndGate.prototype.constructor = AndGate;

/**
 * @memberof AndGate
 * Help Tip
 * @type {string}
 */
AndGate.prototype.tooltipText = 'And Gate Tooltip : Implements logical conjunction';

/**
 * @memberof AndGate
 * @type {boolean}
 */
AndGate.prototype.alwaysResolve = true;

/**
 * @memberof AndGate
 * @type {string}
 */
AndGate.prototype.verilogType = 'and';

/**
 * @memberof AndGate
 * function to change input nodes of the gate
 */
AndGate.prototype.changeInputSize = changeInputSize;
AndGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=and-gate';

/**
 * @memberof AndGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
AndGate.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },

    };
    return data;
};

/**
 * @memberof AndGate
 * resolve output values based on inputData
 */
AndGate.prototype.resolve = function () {
    let result = this.inp[0].value || 0;
    if (this.isResolvable() === false) {
        return;
    }
    for (let i = 1; i < this.inputSize; i++) result &= ((this.inp[i].value) || 0);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof AndGate
 * function to draw And Gate
 */
AndGate.prototype.customDraw = function () {
    ctx = simulationArea.context;

    ctx.beginPath();
    ctx.lineWidth = correctWidth(3);
    ctx.strokeStyle = 'black'; // ("rgba(0,0,0,1)");
    ctx.fillStyle = 'white';
    const xx = this.x;
    const yy = this.y;

    moveTo(ctx, -10, -20, xx, yy, this.direction);
    lineTo(ctx, 0, -20, xx, yy, this.direction);
    arc(ctx, 0, 0, 20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -10, 20, xx, yy, this.direction);
    lineTo(ctx, -10, -20, xx, yy, this.direction);
    ctx.closePath();

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
};

/**
 * NandGate - (x,y)-position , scope - circuit level, inputLength - no of nodes, dir - direction of gate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of nand Gate.
 * @param {number} y - y coordinate of nand Gate.
 * @param {Scope=} scope - Cirucit on which nand gate is drawn
 * @param {string=} dir - direction of nand Gate
 * @param {number=} inputLength - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */

function NandGate(x, y, scope = globalScope, dir = 'RIGHT', inputLength = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);
    this.inp = [];
    this.inputSize = inputLength;
    // variable inputLength , node creation
    if (inputLength % 2 === 1) {
        for (let i = 0; i < inputLength / 2 - 1; i++) {
            const a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        let a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (let i = inputLength / 2 + 1; i < inputLength; i++) {
            a = new Node(-10, 10 * (i + 1 - inputLength / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (let i = 0; i < inputLength / 2; i++) {
            const a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (let i = inputLength / 2; i < inputLength; i++) {
            const a = new Node(-10, 10 * (i + 1 - inputLength / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(30, 0, 1, this);
}

/**
 * @memberof NandGate
 * copy the prototype of CircuitELement to NandGate
 */
NandGate.prototype = Object.create(CircuitElement.prototype);

/**
 * @memberof NandGate
 * constructor of NandGate
 */
NandGate.prototype.constructor = NandGate;

/**
 * @memberof NandGate
 * Help Tip
 * @type {string}
 */
NandGate.prototype.tooltipText = 'Nand Gate ToolTip : Combination of AND and NOT gates';

/**
 * @memberof NandGate
 * @type {boolean}
 */
NandGate.prototype.alwaysResolve = true;

/**
 * @memberof NandGate
 * function to change input nodes of the gate
 */
NandGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof NandGate
 * @type {string}
 */
NandGate.prototype.verilogType = 'nand';
NandGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=nand-gate';
/**
 * @memberof NandGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
// fn to create save Json Data of object
NandGate.prototype.customSave = function () {
    const data = {

        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },
    };
    return data;
};

/**
 * @memberof NandGate
 * resolve output values based on inputData
 */
NandGate.prototype.resolve = function () {
    let result = this.inp[0].value || 0;
    if (this.isResolvable() === false) {
        return;
    }
    for (let i = 1; i < this.inputSize; i++) result &= (this.inp[i].value || 0);
    result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof NandGate
 * function to draw nand Gate
 */
NandGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.lineWidth = correctWidth(3);
    ctx.strokeStyle = 'black';
    ctx.fillStyle = 'white';
    const xx = this.x;
    const yy = this.y;
    moveTo(ctx, -10, -20, xx, yy, this.direction);
    lineTo(ctx, 0, -20, xx, yy, this.direction);
    arc(ctx, 0, 0, 20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -10, 20, xx, yy, this.direction);
    lineTo(ctx, -10, -20, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.5)';
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * Multiplexer - (x,y)-position , scope - circuit level, inputLength - no of nodes, dir - direction of gate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} controlSignalSize - Documentation is WIP
 */
function Multiplexer(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, controlSignalSize = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.controlSignalSize = controlSignalSize || parseInt(prompt('Enter control signal bitWidth'), 10);
    this.inputSize = 1 << this.controlSignalSize;
    this.xOff = 0;
    this.yOff = 1;
    if (this.controlSignalSize === 1) {
        this.xOff = 10;
    }
    if (this.controlSignalSize <= 3) {
        this.yOff = 2;
    }
    this.setDimensions(20 - this.xOff, this.yOff * 5 * (this.inputSize));
    this.rectangleObject = false;
    this.inp = [];
    for (let i = 0; i < this.inputSize; i++) {
        const a = new Node(-20 + this.xOff, +this.yOff * 10 * (i - this.inputSize / 2) + 10, 0, this);
        this.inp.push(a);
    }
    this.output1 = new Node(20 - this.xOff, 0, 1, this);
    this.controlSignalInput = new Node(0, this.yOff * 10 * (this.inputSize / 2 - 1) + this.xOff + 10, 0, this, this.controlSignalSize, 'Control Signal');
}

/**
 * @memberof Multiplexer
 * copy the prototype of CircuitELement to Multiplexer
 */
Multiplexer.prototype = Object.create(CircuitElement.prototype);

/**
 * @memberof Multiplexer
 * constructor of Multiplexer
 */
Multiplexer.prototype.constructor = Multiplexer;

/**
 * @memberof Multiplexer
 * Help Tip
 * @type {string}
 */
Multiplexer.prototype.tooltipText = 'Multiplexer ToolTip : Multiple inputs and a single line output.';
Multiplexer.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=multiplexer';

/**
 * @memberof Multiplexer
 * function to change control signal of the element
 */
Multiplexer.prototype.changeControlSignalSize = function (size) {
    if (size === undefined || size < 1 || size > 32) return;
    if (this.controlSignalSize === size) return;
    const obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth, size);
    this.cleanDelete();
    simulationArea.lastSelected = obj;
    return obj;
};

/**
 * @memberof Multiplexer
 * multable properties of element
 * @type {JSON}
 */
Multiplexer.prototype.mutableProperties = {
    controlSignalSize: {
        name: 'Control Signal Size',
        type: 'number',
        max: '32',
        min: '1',
        func: 'changeControlSignalSize',
    },
};

/**
 * @memberof Multiplexer
 * function to change bitwidth of the element
 * @param {number} bitWidth - bitwidth
 */
Multiplexer.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    for (let i = 0; i < this.inputSize; i++) {
        this.inp[i].bitWidth = bitWidth;
    }
    this.output1.bitWidth = bitWidth;
};

/**
 * @memberof Multiplexer
 * @type {boolean}
 */
Multiplexer.prototype.isResolvable = function () {
    if (this.controlSignalInput.value !== undefined && this.inp[this.controlSignalInput.value].value !== undefined) return true;
    return false;
};

/**
 * @memberof Multiplexer
 * fn to create save Json Data of object
 * @return {JSON}
 */
Multiplexer.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth, this.controlSignalSize],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
            controlSignalInput: findNode(this.controlSignalInput),
        },
    };
    return data;
};

/**
 * @memberof Multiplexer
 * resolve output values based on inputData
 */
Multiplexer.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }
    this.output1.value = this.inp[this.controlSignalInput.value].value;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof Multiplexer
 * function to draw element
 */
Multiplexer.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    ctx.beginPath();
    moveTo(ctx, 0, this.yOff * 10 * (this.inputSize / 2 - 1) + 10 + 0.5 * this.xOff, xx, yy, this.direction);
    lineTo(ctx, 0, this.yOff * 5 * (this.inputSize - 1) + this.xOff, xx, yy, this.direction);
    ctx.stroke();

    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');

    ctx.fillStyle = 'white';
    moveTo(ctx, -20 + this.xOff, -this.yOff * 10 * (this.inputSize / 2), xx, yy, this.direction);
    lineTo(ctx, -20 + this.xOff, 20 + this.yOff * 10 * (this.inputSize / 2 - 1), xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, +this.yOff * 10 * (this.inputSize / 2 - 1) + this.xOff, xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, -this.yOff * 10 * (this.inputSize / 2) - this.xOff + 20, xx, yy, this.direction);

    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    // ctx.lineWidth = correctWidth(2);
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';
    for (let i = 0; i < this.inputSize; i++) {
        if (this.direction === 'RIGHT') fillText(ctx, String(i), xx + this.inp[i].x + 7, yy + this.inp[i].y + 2, 10);
        else if (this.direction === 'LEFT') fillText(ctx, String(i), xx + this.inp[i].x - 7, yy + this.inp[i].y + 2, 10);
        else if (this.direction === 'UP') fillText(ctx, String(i), xx + this.inp[i].x, yy + this.inp[i].y - 4, 10);
        else fillText(ctx, String(i), xx + this.inp[i].x, yy + this.inp[i].y + 10, 10);
    }
    ctx.fill();
};

/**
 * XorGate - (x,y)-position , scope - circuit level, inputLength - no of nodes, dir - direction of element
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputs - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */
function XorGate(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);

    this.inp = [];
    this.inputSize = inputs;

    if (inputs % 2 === 1) {
        for (let i = 0; i < inputs / 2 - 1; i++) {
            const a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        let a = new Node(-20, 0, 0, this);
        this.inp.push(a);
        for (let i = inputs / 2 + 1; i < inputs; i++) {
            a = new Node(-20, 10 * (i + 1 - inputs / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (let i = 0; i < inputs / 2; i++) {
            const a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (let i = inputs / 2; i < inputs; i++) {
            const a = new Node(-20, 10 * (i + 1 - inputs / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(20, 0, 1, this);
}

/**
 * @memberof XorGate
 * copy the prototype of CircuitELement to XorGate
 */
XorGate.prototype = Object.create(CircuitElement.prototype);

/**
 * @memberof XorGate
 * constructor of XorGate
 */
XorGate.prototype.constructor = XorGate;

/**
 * @memberof XorGate
 * Help Tip
 * @type {string}
 */
XorGate.prototype.tooltipText = 'Xor Gate Tooltip : Implements an exclusive OR.';

/**
 * @memberof XorGate
 * @type {boolean}
 */
XorGate.prototype.alwaysResolve = true;

/**
 * @memberof XorGate
 * function to change input nodes of the element
 */
XorGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof XorGate
 * @type {string}
 */
XorGate.prototype.verilogType = 'xor';
XorGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=xor-gate';

/**
 * @memberof XorGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
XorGate.prototype.customSave = function () {
    // //console.log(this.scope.allNodes);
    const data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },
    };
    return data;
};

/**
 * @memberof XorGate
 * resolve output values based on inputData
 */
XorGate.prototype.resolve = function () {
    let result = this.inp[0].value || 0;
    if (this.isResolvable() === false) {
        return;
    }
    for (let i = 1; i < this.inputSize; i++) result ^= (this.inp[i].value || 0);

    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof XorGate
 * function to draw element
 */
XorGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';
    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    // arc(ctx, 0, 0, -20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    arc2(ctx, -35, 0, 25, 1.70 * (Math.PI), 0.30 * (Math.PI), xx, yy, this.direction);
    ctx.stroke();
};

/**
 * XnorGate - (x,y)-position , scope - circuit level, inputLength - no of nodes, dir - direction of element
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputLength - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */
function XnorGate(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);

    this.inp = [];
    this.inputSize = inputs;

    if (inputs % 2 === 1) {
        for (let i = 0; i < inputs / 2 - 1; i++) {
            const a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        let a = new Node(-20, 0, 0, this);
        this.inp.push(a);
        for (let i = inputs / 2 + 1; i < inputs; i++) {
            a = new Node(-20, 10 * (i + 1 - inputs / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (let i = 0; i < inputs / 2; i++) {
            const a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (let i = inputs / 2; i < inputs; i++) {
            const a = new Node(-20, 10 * (i + 1 - inputs / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(30, 0, 1, this);
}

XnorGate.prototype = Object.create(CircuitElement.prototype);
XnorGate.prototype.constructor = XnorGate;

/**
 * @memberof XnorGate
 * @type {boolean}
 */
XnorGate.prototype.alwaysResolve = true;

/**
 * @memberof XnorGate
 * Help Tip
 * @type {string}
 */
XnorGate.prototype.tooltipText = 'Xnor Gate ToolTip : Logical complement of the XOR gate';

/**
 * @memberof XnorGate
 * function to change input nodes of the element
 */
XnorGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof XnorGate
 * @type {string}
 */
XnorGate.prototype.verilogType = 'xnor';
XnorGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=xnor-gate';

/**
 * @memberof XnorGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
XnorGate.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },
    };
    return data;
};

/**
 * @memberof XnorGate
 * resolve output values based on inputData
 */
XnorGate.prototype.resolve = function () {
    let result = this.inp[0].value || 0;
    if (this.isResolvable() === false) {
        return;
    }
    for (let i = 1; i < this.inputSize; i++) result ^= (this.inp[i].value || 0);
    result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof XnorGate
 * function to draw element
 */
XnorGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';
    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    // arc(ctx, 0, 0, -20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    arc2(ctx, -35, 0, 25, 1.70 * (Math.PI), 0.30 * (Math.PI), xx, yy, this.direction);
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * SevenSegDisplay
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 */
function SevenSegDisplay(x, y, scope = globalScope) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 1);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.setDimensions(30, 50);

    this.g = new Node(-20, -50, 0, this);
    this.f = new Node(-10, -50, 0, this);
    this.a = new Node(+10, -50, 0, this);
    this.b = new Node(+20, -50, 0, this);
    this.e = new Node(-20, +50, 0, this);
    this.d = new Node(-10, +50, 0, this);
    this.c = new Node(+10, +50, 0, this);
    this.dot = new Node(+20, +50, 0, this);
    this.direction = 'RIGHT';
}
SevenSegDisplay.prototype = Object.create(CircuitElement.prototype);
SevenSegDisplay.prototype.constructor = SevenSegDisplay;

/**
 * @memberof SevenSegDisplay
 * Help Tip
 * @type {string}
 */
SevenSegDisplay.prototype.tooltipText = 'Seven Display ToolTip: Consists of 7+1 single bit inputs.';

/**
 * @memberof SevenSegDisplay
 * Help URL
 * @type {string}
 */
SevenSegDisplay.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=seven-segment-display';

/**
 * @memberof SevenSegDisplay
 * fn to create save Json Data of object
 * @return {JSON}
 */
SevenSegDisplay.prototype.customSave = function () {
    const data = {

        nodes: {
            g: findNode(this.g),
            f: findNode(this.f),
            a: findNode(this.a),
            b: findNode(this.b),
            d: findNode(this.d),
            e: findNode(this.e),
            c: findNode(this.c),
            dot: findNode(this.dot),
        },
    };
    return data;
};

/**
 * @memberof SevenSegDisplay
 * helper function to create save Json Data of object
 */
SevenSegDisplay.prototype.customDrawSegment = function (x1, y1, x2, y2, color) {
    if (color === undefined) color = 'lightgrey';
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = correctWidth(5);
    xx = this.x;
    yy = this.y;
    moveTo(ctx, x1, y1, xx, yy, this.direction);
    lineTo(ctx, x2, y2, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
};

/**
 * @memberof SevenSegDisplay
 * function to draw element
 */
SevenSegDisplay.prototype.customDraw = function () {
    ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    this.customDrawSegment(18, -3, 18, -38, ['lightgrey', 'red'][this.b.value]);
    this.customDrawSegment(18, 3, 18, 38, ['lightgrey', 'red'][this.c.value]);
    this.customDrawSegment(-18, -3, -18, -38, ['lightgrey', 'red'][this.f.value]);
    this.customDrawSegment(-18, 3, -18, 38, ['lightgrey', 'red'][this.e.value]);
    this.customDrawSegment(-17, -38, 17, -38, ['lightgrey', 'red'][this.a.value]);
    this.customDrawSegment(-17, 0, 17, 0, ['lightgrey', 'red'][this.g.value]);
    this.customDrawSegment(-15, 38, 17, 38, ['lightgrey', 'red'][this.d.value]);
    ctx.beginPath();
    const dotColor = ['lightgrey', 'red'][this.dot.value] || 'lightgrey';
    ctx.strokeStyle = dotColor;
    rect(ctx, xx + 22, yy + 42, 2, 2);
    ctx.stroke();
};

/**
 * SixteenSegDisplay
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 */
function SixteenSegDisplay(x, y, scope = globalScope) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 16);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.setDimensions(30, 50);
    this.input1 = new Node(0, -50, 0, this, 16);
    this.dot = new Node(0, 50, 0, this, 1);
    this.direction = 'RIGHT';
}

SixteenSegDisplay.prototype = Object.create(CircuitElement.prototype);
SixteenSegDisplay.prototype.constructor = SixteenSegDisplay;

/**
 * @memberof SixteenSegDisplay
 * Help Tip
 * @type {string}
 */
SixteenSegDisplay.prototype.tooltipText = 'Sixteen Display ToolTip: Consists of 16+1 bit inputs.';

/**
 * @memberof SixteenSegDisplay
 * Help URL
 * @type {string}
 */
SixteenSegDisplay.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=sixteen-segment-display';

/**
 * @memberof SixteenSegDisplay
 * fn to create save Json Data of object
 * @return {JSON}
 */
SixteenSegDisplay.prototype.customSave = function () {
    const data = {
        nodes: {
            input1: findNode(this.input1),
            dot: findNode(this.dot),
        },
    };
    return data;
};

/**
 * @memberof SixteenSegDisplay
 * function to draw element
 */
SixteenSegDisplay.prototype.customDrawSegment = function (x1, y1, x2, y2, color) {
    if (color === undefined) color = 'lightgrey';
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = correctWidth(4);
    xx = this.x;
    yy = this.y;
    moveTo(ctx, x1, y1, xx, yy, this.direction);
    lineTo(ctx, x2, y2, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
};

/**
 * @memberof SixteenSegDisplay
 * function to draw element
 */
SixteenSegDisplay.prototype.customDrawSegmentSlant = function (x1, y1, x2, y2, color) {
    if (color === undefined) color = 'lightgrey';
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = correctWidth(3);
    xx = this.x;
    yy = this.y;
    moveTo(ctx, x1, y1, xx, yy, this.direction);
    lineTo(ctx, x2, y2, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
};

/**
 * @memberof SixteenSegDisplay
 * function to draw element
 */
SixteenSegDisplay.prototype.customDraw = function () {
    ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    const color = ['lightgrey', 'red'];
    const { value } = this.input1;
    this.customDrawSegment(-20, -38, 0, -38, ['lightgrey', 'red'][(value >> 15) & 1]);// a1
    this.customDrawSegment(20, -38, 0, -38, ['lightgrey', 'red'][(value >> 14) & 1]);// a2
    this.customDrawSegment(21.5, -2, 21.5, -36, ['lightgrey', 'red'][(value >> 13) & 1]);// b
    this.customDrawSegment(21.5, 2, 21.5, 36, ['lightgrey', 'red'][(value >> 12) & 1]);// c
    this.customDrawSegment(-20, 38, 0, 38, ['lightgrey', 'red'][(value >> 11) & 1]);// d1
    this.customDrawSegment(20, 38, 0, 38, ['lightgrey', 'red'][(value >> 10) & 1]);// d2
    this.customDrawSegment(-21.5, 2, -21.5, 36, ['lightgrey', 'red'][(value >> 9) & 1]);// e
    this.customDrawSegment(-21.5, -36, -21.5, -2, ['lightgrey', 'red'][(value >> 8) & 1]);// f
    this.customDrawSegment(-20, 0, 0, 0, ['lightgrey', 'red'][(value >> 7) & 1]);// g1
    this.customDrawSegment(20, 0, 0, 0, ['lightgrey', 'red'][(value >> 6) & 1]);// g2
    this.customDrawSegmentSlant(0, 0, -21, -37, ['lightgrey', 'red'][(value >> 5) & 1]);// h
    this.customDrawSegment(0, -2, 0, -36, ['lightgrey', 'red'][(value >> 4) & 1]);// i
    this.customDrawSegmentSlant(0, 0, 21, -37, ['lightgrey', 'red'][(value >> 3) & 1]);// j
    this.customDrawSegmentSlant(0, 0, 21, 37, ['lightgrey', 'red'][(value >> 2) & 1]);// k
    this.customDrawSegment(0, 2, 0, 36, ['lightgrey', 'red'][(value >> 1) & 1]);// l
    this.customDrawSegmentSlant(0, 0, -21, 37, ['lightgrey', 'red'][(value >> 0) & 1]);// m
    ctx.beginPath();
    const dotColor = ['lightgrey', 'red'][this.dot.value] || 'lightgrey';
    ctx.strokeStyle = dotColor;
    rect(ctx, xx + 22, yy + 42, 2, 2);
    ctx.stroke();
};

/**
 * HexDisplay
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 */
function HexDisplay(x, y, scope = globalScope) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 4);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.setDimensions(30, 50);
    this.inp = new Node(0, -50, 0, this, 4);
    this.direction = 'RIGHT';
}

HexDisplay.prototype = Object.create(CircuitElement.prototype);
HexDisplay.prototype.constructor = HexDisplay;

/**
 * @memberof HexDisplay
 * Help Tip
 * @type {string}
 */
HexDisplay.prototype.tooltipText = 'Hex Display ToolTip: Inputs a 4 Bit Hex number and displays it.';

/**
 * @memberof HexDisplay
 * Help URL
 * @type {string}
 */
HexDisplay.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=hex-display';

/**
 * @memberof HexDisplay
 * fn to create save Json Data of object
 * @return {JSON}
 */
HexDisplay.prototype.customSave = function () {
    const data = {

        nodes: {
            inp: findNode(this.inp),
        },

    };
    return data;
};

/**
 * @memberof HexDisplay
 * function to draw element
 */
HexDisplay.prototype.customDrawSegment = function (x1, y1, x2, y2, color) {
    if (color === undefined) color = 'lightgrey';
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = correctWidth(5);
    xx = this.x;
    yy = this.y;

    moveTo(ctx, x1, y1, xx, yy, this.direction);
    lineTo(ctx, x2, y2, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
};

/**
 * @memberof HexDisplay
 * function to draw element
 */
HexDisplay.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    ctx.strokeStyle = 'black';
    ctx.lineWidth = correctWidth(3);
    let a = b = c = d = e = f = g = 0;
    switch (this.inp.value) {
    case 0:
        a = b = c = d = e = f = 1;
        break;
    case 1:
        b = c = 1;
        break;
    case 2:
        a = b = g = e = d = 1;
        break;
    case 3:
        a = b = g = c = d = 1;
        break;
    case 4:
        f = g = b = c = 1;
        break;
    case 5:
        a = f = g = c = d = 1;
        break;
    case 6:
        a = f = g = e = c = d = 1;
        break;
    case 7:
        a = b = c = 1;
        break;
    case 8:
        a = b = c = d = e = g = f = 1;
        break;
    case 9:
        a = f = g = b = c = 1;
        break;
    case 0xA:
        a = f = b = c = g = e = 1;
        break;
    case 0xB:
        f = e = g = c = d = 1;
        break;
    case 0xC:
        a = f = e = d = 1;
        break;
    case 0xD:
        b = c = g = e = d = 1;
        break;
    case 0xE:
        a = f = g = e = d = 1;
        break;
    case 0xF:
        a = f = g = e = 1;
        break;
    default:
    }
    this.customDrawSegment(18, -3, 18, -38, ['lightgrey', 'red'][b]);
    this.customDrawSegment(18, 3, 18, 38, ['lightgrey', 'red'][c]);
    this.customDrawSegment(-18, -3, -18, -38, ['lightgrey', 'red'][f]);
    this.customDrawSegment(-18, 3, -18, 38, ['lightgrey', 'red'][e]);
    this.customDrawSegment(-17, -38, 17, -38, ['lightgrey', 'red'][a]);
    this.customDrawSegment(-17, 0, 17, 0, ['lightgrey', 'red'][g]);
    this.customDrawSegment(-15, 38, 17, 38, ['lightgrey', 'red'][d]);
};

/**
 * OrGate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputs - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */
function OrGate(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
    // Calling base class constructor
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);
    // Inherit base class prototype
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
OrGate.prototype = Object.create(CircuitElement.prototype);
OrGate.prototype.constructor = OrGate;

/**
 * @memberof OrGate
 * Help Tip
 * @type {string}
 */
OrGate.prototype.tooltipText = 'Or Gate Tooltip : Implements logical disjunction';

/**
 * @memberof OrGate
 * function to change input nodes of the element
 */
OrGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof SevenSegDisplay
 * @type {boolean}
 */
OrGate.prototype.alwaysResolve = true;

/**
 * @memberof SevenSegDisplay
 * @type {string}
 */
OrGate.prototype.verilogType = 'or';
OrGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=or-gate';

/**
 * @memberof OrGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
OrGate.prototype.customSave = function () {
    const data = {

        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],

        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },
    };
    return data;
};

/**
 * @memberof OrGate
 * resolve output values based on inputData
 */
OrGate.prototype.resolve = function () {
    let result = this.inp[0].value || 0;
    if (this.isResolvable() === false) {
        return;
    }
    for (let i = 1; i < this.inputSize; i++) result |= (this.inp[i].value || 0);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof OrGate
 * function to draw element
 */
OrGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';

    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
};

/**
 * Stepper
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bitwidth of element
 */
function Stepper(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 8) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 20);

    this.output1 = new Node(20, 0, 1, this, bitWidth);
    this.state = 0;
}
Stepper.prototype = Object.create(CircuitElement.prototype);
Stepper.prototype.constructor = Stepper;

/**
 * @memberof Stepper
 * Help Tip
 * @type {string}
 */
Stepper.prototype.tooltipText = 'Stepper ToolTip: Increase/Decrease value by selecting the stepper and using +/- keys.';

/**
 * @memberof Stepper
 * Help URL
 * @type {string}
 */
Stepper.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=stepper';

/**
 * @memberof Stepper
 * fn to create save Json Data of object
 * @return {JSON}
 */
Stepper.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
        },
        values: {
            state: this.state,
        },
    };
    return data;
};

/**
 * @memberof Stepper
 * function to draw element
 */
Stepper.prototype.customDraw = function () {
    ctx = simulationArea.context;

    ctx.beginPath();
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.state.toString(16), this.x, this.y + 5);
    ctx.fill();
};

/**
 * @memberof Stepper
 * resolve output values based on inputData
 */
Stepper.prototype.resolve = function () {
    this.state = Math.min(this.state, (1 << this.bitWidth) - 1);
    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * Listener function for increasing value of state
 * @memberof Stepper
 * @param {string} key - the key pressed
 */
Stepper.prototype.keyDown2 = function (key) {
    // console.log(key);
    if (this.state < (1 << this.bitWidth) && (key === '+' || key === '=')) this.state++;
    if (this.state > 0 && (key === '_' || key === '-')) this.state--;
};

/**
 * NotGate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function NotGate(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.inp1 = new Node(-10, 0, 0, this);
    this.output1 = new Node(20, 0, 1, this);
}
NotGate.prototype = Object.create(CircuitElement.prototype);
NotGate.prototype.constructor = NotGate;

/**
 * @memberof NotGate
 * Help Tip
 * @type {string}
 */
NotGate.prototype.tooltipText = 'Not Gate Tooltip : Inverts the input digital signal.';
NotGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=not-gate';

/**
 * @memberof NotGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
NotGate.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
        },
    };
    return data;
};

/**
 * @memberof NotGate
 * resolve output values based on inputData
 */
NotGate.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }
    this.output1.value = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof NotGate
 * function to draw element
 */
NotGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = 'black';
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';
    moveTo(ctx, -10, -10, xx, yy, this.direction);
    lineTo(ctx, 10, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 10, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 15, 0, 5, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * ForceGate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function ForceGate(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 10);

    this.inp1 = new Node(-20, 0, 0, this);
    this.inp2 = new Node(0, 0, 0, this);
    this.output1 = new Node(20, 0, 1, this);
}
ForceGate.prototype = Object.create(CircuitElement.prototype);
ForceGate.prototype.constructor = ForceGate;

/**
 * @memberof ForceGate
 * Help Tip
 * @type {string}
 */
ForceGate.prototype.tooltipText = 'Force Gate ToolTip : ForceGate Selected.';

/**
 * @memberof ForceGate
 * Checks if the element is resolvable
 * @return {boolean}
 */
ForceGate.prototype.isResolvable = function () {
    return (this.inp1.value !== undefined || this.inp2.value !== undefined);
};

/**
 * @memberof ForceGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
ForceGate.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
        },
    };
    return data;
};

/**
 * @memberof ForceGate
 * resolve output values based on inputData
 */
ForceGate.prototype.resolve = function () {
    if (this.inp2.value !== undefined) { this.output1.value = this.inp2.value; } else { this.output1.value = this.inp1.value; }
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof ForceGate
 * function to draw element
 */
ForceGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;

    ctx.beginPath();
    ctx.fillStyle = 'Black';
    ctx.textAlign = 'center';

    fillText4(ctx, 'I', -10, 0, xx, yy, this.direction, 10);
    fillText4(ctx, 'O', 10, 0, xx, yy, this.direction, 10);
    ctx.fill();
};

/**
 * Text
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} label - label of element
 * @param {number=} fontSize - font size
 */
function Text(x, y, scope = globalScope, label = '', fontSize = 14) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 1);
    // this.setDimensions(15, 15);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.labelDirectionFixed = true;
    this.setHeight(10);
    this.setLabel(label);
    this.setFontSize(fontSize);
}
Text.prototype = Object.create(CircuitElement.prototype);
Text.prototype.constructor = Text;

/**
 * @memberof Text
 * Help Tip
 * @type {string}
 */
Text.prototype.tooltipText = 'Text ToolTip: Use this to document your circuit.';

/**
 * @memberof Text
 * Help URL
 * @type {string}
 */
Text.prototype.helplink = 'https://docs.circuitverse.org/#/annotation?id=adding-labels';

/**
 * @memberof Text
 * function for setting text inside the element
 * @param {string=} str - the label
 */
Text.prototype.setLabel = function (str = '') {
    this.label = str;
    ctx = simulationArea.context;
    ctx.font = `${this.fontSize}px Georgia`;
    this.leftDimensionX = 10;
    this.rightDimensionX = ctx.measureText(this.label).width + 10;
    // console.log(this.leftDimensionX,this.rightDimensionX,ctx.measureText(this.label))
};

/**
 * @memberof Text
 * function for setting font size inside the element
 * @param {number=} str - the font size
 */
Text.prototype.setFontSize = function (fontSize = 14) {
    this.fontSize = fontSize;
    ctx = simulationArea.context;
    ctx.font = `${this.fontSize}px Georgia`;
    this.leftDimensionX = 10;
    this.rightDimensionX = ctx.measureText(this.label).width + 10;
};

/**
 * @memberof Text
 * fn to create save Json Data of object
 * @return {JSON}
 */
Text.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.label, this.fontSize],
    };
    return data;
};

/**
 * @memberof Text
 * Listener function for Text Box
 * @param {string} key - the label
 */
Text.prototype.keyDown = function (key) {
    if (key.length === 1) {
        if (this.label === 'Enter Text Here') { this.setLabel(key); } else { this.setLabel(this.label + key); }
    } else if (key === 'Backspace') {
        if (this.label === 'Enter Text Here') { this.setLabel(''); } else { this.setLabel(this.label.slice(0, -1)); }
    }
};

/**
 * @memberof Text
 * Mutable properties of the element
 * @type {JSON}
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

/**
 * @memberof Text
 * Function for drawing text box
 */
Text.prototype.draw = function () {
    if (this.label.length === 0 && simulationArea.lastSelected !== this) this.delete();
    ctx = simulationArea.context;
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
};

/**
 * TriState
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function TriState(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.inp1 = new Node(-10, 0, 0, this);
    this.output1 = new Node(20, 0, 1, this);
    this.state = new Node(0, 0, 0, this, 1, 'Enable');
}
TriState.prototype = Object.create(CircuitElement.prototype);
TriState.prototype.constructor = TriState;

/**
 * @memberof TriState
 * Help Tip
 * @type {string}
 */
TriState.prototype.tooltipText = 'TriState ToolTip : Effectively removes the output from the circuit.';
TriState.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=tri-state-buffer';

// TriState.prototype.propagationDelay=10000;

/**
 * @memberof TriState
 * fn to create save Json Data of object
 * @return {JSON}
 */
TriState.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            state: findNode(this.state),
        },
    };
    return data;
};

/**
 * @memberof TriState
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
TriState.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
};

/**
 * @memberof TriState
 * resolve output values based on inputData
 */
TriState.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }

    if (this.state.value === 1) {
        if (this.output1.value !== this.inp1.value) {
            this.output1.value = this.inp1.value; // >>>0)<<(32-this.bitWidth))>>>(32-this.bitWidth);
            simulationArea.simulationQueue.add(this.output1);
        }
        simulationArea.contentionPending.clean(this);
    } else if (this.output1.value !== undefined && !simulationArea.contentionPending.contains(this)) {
        this.output1.value = undefined;
        simulationArea.simulationQueue.add(this.output1);
    }
    simulationArea.contentionPending.clean(this);
};

/**
 * @memberof TriState
 * function to draw element
 */
TriState.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';
    moveTo(ctx, -10, -15, xx, yy, this.direction);
    lineTo(ctx, 20, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 15, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
};

/**
 * Buffer
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function Buffer(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);
    this.state = 0;
    this.preState = 0;
    this.inp1 = new Node(-10, 0, 0, this);
    this.reset = new Node(0, 0, 0, this, 1, 'reset');
    this.output1 = new Node(20, 0, 1, this);
}
Buffer.prototype = Object.create(CircuitElement.prototype);
Buffer.prototype.constructor = Buffer;

/**
 * @memberof Buffer
 * Help Tip
 * @type {string}
 */
Buffer.prototype.tooltipText = 'Buffer ToolTip : Isolate the input from the output.';
Buffer.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=buffer';

/**
 * @memberof Buffer
 * fn to create save Json Data of object
 * @return {JSON}
 */
Buffer.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            reset: findNode(this.reset),
        },
    };
    return data;
};

/**
 * @memberof Buffer
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
Buffer.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
};

/**
 * @memberof Buffer
 * Checks if the element is resolvable
 * @return {boolean}
 */
Buffer.prototype.isResolvable = function () {
    return true;
};

/**
 * @memberof Buffer
 * resolve output values based on inputData
 */
Buffer.prototype.resolve = function () {
    if (this.reset.value === 1) {
        this.state = this.preState;
    }
    if (this.inp1.value !== undefined) { this.state = this.inp1.value; }

    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof Buffer
 * function to draw element
 */
Buffer.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(200,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';
    moveTo(ctx, -10, -15, xx, yy, this.direction);
    lineTo(ctx, 20, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 15, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
};

/**
 * ControlledInverter
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function ControlledInverter(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.inp1 = new Node(-10, 0, 0, this);
    this.output1 = new Node(30, 0, 1, this);
    this.state = new Node(0, 0, 0, this, 1, 'Enable');
}
ControlledInverter.prototype = Object.create(CircuitElement.prototype);
ControlledInverter.prototype.constructor = ControlledInverter;

/**
 * @memberof ControlledInverter
 * Help Tip
 * @type {string}
 */
ControlledInverter.prototype.tooltipText = 'Controlled Inverter ToolTip : Controlled buffer and NOT gate.';

/**
 * @memberof ControlledInverter
 * fn to create save Json Data of object
 * @return {JSON}
 */
ControlledInverter.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            state: findNode(this.state),
        },
    };
    return data;
};

/**
 * @memberof ControlledInverter
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
ControlledInverter.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
};

/**
 * @memberof ControlledInverter
 * resolve output values based on inputData
 */
ControlledInverter.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }
    if (this.state.value === 1) {
        this.output1.value = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output1);
    }
    if (this.state.value === 0) {
        this.output1.value = undefined;
    }
};

/**
 * @memberof ControlledInverter
 * function to draw element
 */
ControlledInverter.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';
    moveTo(ctx, -10, -15, xx, yy, this.direction);
    lineTo(ctx, 20, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 15, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * Adder
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function Adder(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 20);

    this.inpA = new Node(-20, -10, 0, this, this.bitWidth, 'A');
    this.inpB = new Node(-20, 0, 0, this, this.bitWidth, 'B');
    this.carryIn = new Node(-20, 10, 0, this, 1, 'Cin');
    this.sum = new Node(20, 0, 1, this, this.bitWidth, 'Sum');
    this.carryOut = new Node(20, 10, 1, this, 1, 'Cout');
}
Adder.prototype = Object.create(CircuitElement.prototype);
Adder.prototype.constructor = Adder;

/**
 * @memberof Adder
 * Help Tip
 * @type {string}
 */
Adder.prototype.tooltipText = 'Adder ToolTip : Performs addition of numbers.';
Adder.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=adder';

/**
 * @memberof Adder
 * fn to create save Json Data of object
 * @return {JSON}
 */
Adder.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            inpA: findNode(this.inpA),
            inpB: findNode(this.inpB),
            carryIn: findNode(this.carryIn),
            carryOut: findNode(this.carryOut),
            sum: findNode(this.sum),
        },
    };
    return data;
};

/**
 * @memberof Adder
 * Checks if the element is resolvable
 * @return {boolean}
 */
Adder.prototype.isResolvable = function () {
    return this.inpA.value !== undefined && this.inpB.value !== undefined;
};

/**
 * @memberof Adder
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
Adder.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.inpA.bitWidth = bitWidth;
    this.inpB.bitWidth = bitWidth;
    this.sum.bitWidth = bitWidth;
};

/**
 * @memberof Adder
 * resolve output values based on inputData
 */
Adder.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }
    let carryIn = this.carryIn.value;
    if (carryIn === undefined) carryIn = 0;
    const sum = this.inpA.value + this.inpB.value + carryIn;

    this.sum.value = ((sum) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.carryOut.value = +((sum >>> (this.bitWidth)) !== 0);
    simulationArea.simulationQueue.add(this.carryOut);
    simulationArea.simulationQueue.add(this.sum);
};

/**
 * TwoComplement
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function TwoComplement(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);
    this.inp1 = new Node(-10, 0, 0, this, this.bitWidth, 'input stream');
    this.output1 = new Node(20, 0, 1, this, this.bitWidth, "2's complement");
}
TwoComplement.prototype = Object.create(CircuitElement.prototype);
TwoComplement.prototype.constructor = TwoComplement;

/**
 * @memberof TwoComplement
 * Help Tip
 * @type {string}
 */
TwoComplement.prototype.tooltipText = "Two's Complement Tooltip : Calculates the two's complement";

/**
 * @memberof TwoComplement
 * fn to create save Json Data of object
 * @return {JSON}
 */
TwoComplement.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
        },
    };
    return data;
};

/**
 * @memberof TwoComplement
 * resolve output values based on inputData
 */
TwoComplement.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }
    let output = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    output += 1;
    this.output1.value = ((output) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof TwoComplement
 * function to draw element
 */
TwoComplement.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = 'black';
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'black';
    fillText(ctx, "2'", xx, yy, 10);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.beginPath();
    drawCircle2(ctx, 5, 0, 15, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * Rom
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {Array=} data - bit width per node.
 */
function Rom(x, y, scope = globalScope, data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 1);
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
Rom.prototype = Object.create(CircuitElement.prototype);
Rom.prototype.constructor = Rom;

/**
 * @memberof Rom
 * Help Tip
 * @type {string}
 */
Rom.prototype.tooltipText = 'Read-only memory';
Rom.prototype.helplink = 'https://docs.circuitverse.org/#/memoryElements?id=rom';

/**
 * @memberof Rom
 * Checks if the element is resolvable
 * @return {boolean}
 */
Rom.prototype.isResolvable = function () {
    if ((this.en.value === 1 || this.en.connections.length === 0) && this.memAddr.value !== undefined) return true;
    return false;
};

/**
 * @memberof Rom
 * fn to create save Json Data of object
 * @return {JSON}
 */
Rom.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.data],
        nodes: {
            memAddr: findNode(this.memAddr),
            dataOut: findNode(this.dataOut),
            en: findNode(this.en),
        },

    };
    return data;
};

/**
 * @memberof Rom
 * function to find position [ Documentation is a WIP ]
 * @return {number}
 */
Rom.prototype.findPos = function () {
    const i = Math.floor((simulationArea.mouseX - this.x + 35) / 20);
    const j = Math.floor((simulationArea.mouseY - this.y + 35) / 16);
    if (i < 0 || j < 0 || i > 3 || j > 3) return undefined;
    return j * 4 + i;
};

/**
 * @memberof Rom
 * listener function to set selected index [ Documentation is a WIP ]
 * @return {number}
 */
Rom.prototype.click = function () { // toggle
    this.selectedIndex = this.findPos();
};

/**
 * @memberof Rom
 * listener function to find position [ Documentation is a WIP ]
 * @return {number}
 */
Rom.prototype.keyDown = function (key) {
    if (key === 'Backspace') this.delete();
    if (this.selectedIndex === undefined) return;
    key = key.toLowerCase();
    if (!~'1234567890abcdef'.indexOf(key)) return;

    this.data[this.selectedIndex] = (this.data[this.selectedIndex] * 16 + parseInt(key, 16)) % 256;
};

/**
 * @memberof Rom
 * function to draw element
 */
Rom.prototype.customDraw = function () {
    const ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    const hoverIndex = this.findPos();
    ctx.strokeStyle = 'black';
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, [this.direction, 'RIGHT'][+this.directionFixed]);
    if (hoverIndex === undefined && ((!simulationArea.shiftDown && this.hover) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this))) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
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
        ctx.fillStyle = 'green';
        rect2(ctx, (this.memAddr.value % 4) * 20, Math.floor(this.memAddr.value / 4) * 16, 20, 16, xx - 35, yy - 35);
        ctx.fill();
        ctx.stroke();
    }

    ctx.beginPath();
    ctx.fillStyle = 'Black';
    fillText3(ctx, 'A', -65, 5, xx, yy, fontSize = 16, font = 'Georgia', textAlign = 'right');
    fillText3(ctx, 'D', 75, 5, xx, yy, fontSize = 16, font = 'Georgia', textAlign = 'right');
    fillText3(ctx, 'En', 5, 47, xx, yy, fontSize = 16, font = 'Georgia', textAlign = 'right');
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = 'Black';
    for (let i = 0; i < 16; i += 4) {
        for (let j = i; j < i + 4; j++) {
            let s = this.data[j].toString(16);
            if (s.length < 2) s = `0${s}`;
            fillText3(ctx, s, (j % 4) * 20, i * 4, xx - 35 + 10, yy - 35 + 12, fontSize = 14, font = 'Georgia', textAlign = 'center');
        }
    }
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = 'Black';
    for (let i = 0; i < 16; i += 4) {
        let s = i.toString(16);
        if (s.length < 2) s = `0${s}`;
        fillText3(ctx, s, 0, i * 4, xx - 40, yy - 35 + 12, fontSize = 14, font = 'Georgia', textAlign = 'right');
    }
    ctx.fill();
};

/**
 * @memberof Rom
 * resolve output values based on inputData
 */
Rom.prototype.resolve = function () {
    if (this.isResolvable() === false) {
        return;
    }
    this.dataOut.value = this.data[this.memAddr.value];
    simulationArea.simulationQueue.add(this.dataOut);
};

/**
 * Splitter
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} bitWidthSplit - number of input nodes
 */
function Splitter(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = undefined, bitWidthSplit = undefined) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;

    this.bitWidthSplit = bitWidthSplit || prompt('Enter bitWidth Split').split(' ').filter((lambda) => lambda !== '').map((lambda) => parseInt(lambda, 10) || 1);
    this.splitCount = this.bitWidthSplit.length;

    this.setDimensions(10, (this.splitCount - 1) * 10 + 10);
    this.yOffset = (this.splitCount / 2 - 1) * 20;

    this.inp1 = new Node(-10, 10 + this.yOffset, 0, this, this.bitWidth);

    this.outputs = [];
    // this.prevOutValues=new Array(this.splitCount)
    for (let i = 0; i < this.splitCount; i++) { this.outputs.push(new Node(20, i * 20 - this.yOffset - 20, 0, this, this.bitWidthSplit[i])); }

    this.prevInpValue = undefined;
}
Splitter.prototype = Object.create(CircuitElement.prototype);
Splitter.prototype.constructor = Splitter;

/**
 * @memberof Splitter
 * Help Tip
 * @type {string}
 */
Splitter.prototype.tooltipText = 'Splitter ToolTip: Split multiBit Input into smaller bitwidths or vice versa.';

/**
 * @memberof Splitter
 * Help URL
 * @type {string}
 */
Splitter.prototype.helplink = 'https://docs.circuitverse.org/#/splitter';

/**
 * @memberof Splitter
 * fn to create save Json Data of object
 * @return {JSON}
 */
Splitter.prototype.customSave = function () {
    const data = {

        constructorParamaters: [this.direction, this.bitWidth, this.bitWidthSplit],
        nodes: {
            outputs: this.outputs.map(findNode),
            inp1: findNode(this.inp1),
        },
    };
    return data;
};

/**
 * @memberof Splitter
 * fn to remove proporgation [Documentation is a WIP]
 * @return {JSON}
 */
Splitter.prototype.removePropagation = function () {
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
};

/**
 * @memberof Splitter
 * Checks if the element is resolvable
 * @return {boolean}
 */
Splitter.prototype.isResolvable = function () {
    let resolvable = false;
    if (this.inp1.value !== this.prevInpValue) {
        if (this.inp1.value !== undefined) return true;
        return false;
    }
    let i;
    for (i = 0; i < this.splitCount; i++) { if (this.outputs[i].value === undefined) break; }
    if (i === this.splitCount) resolvable = true;
    return resolvable;
};

/**
 * @memberof Splitter
 * resolve output values based on inputData
 */
Splitter.prototype.resolve = function () {
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
        if (this.inp1.value !== n) {
            this.inp1.value = n;
            simulationArea.simulationQueue.add(this.inp1);
        }
        // else if (this.inp1.value !== n) {
        //     console.log("CONTENTION");
        // }
    }
    this.prevInpValue = this.inp1.value;
};

/**
 * @memberof Splitter
 * fn to reset values of splitter
 */
Splitter.prototype.reset = function () {
    this.prevInpValue = undefined;
};

/**
 * @memberof Splitter
 * fn to process verilog of the element
 * @return {JSON}
 */
Splitter.prototype.processVerilog = function () {
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
};

/**
 * @memberof Splitter
 * function to draw element
 */
Splitter.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ['black', 'brown'][((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) + 0];
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
    ctx.fillStyle = 'black';
    for (let i = this.splitCount - 1; i >= 0; i--) {
        fillText2(ctx, `${bitCount}:${bitCount + this.bitWidthSplit[this.splitCount - i - 1]}`, 12, -20 * i + this.yOffset + 10, xx, yy, this.direction);
        bitCount += this.bitWidthSplit[this.splitCount - i - 1];
    }
    ctx.fill();
};

/**
 * Ground
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} bitWidth - bit width per node.
 */
function Ground(x, y, scope = globalScope, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', bitWidth);
    this.rectangleObject = false;
    this.setDimensions(10, 10);
    this.directionFixed = true;
    this.output1 = new Node(0, -10, 1, this);
}

Ground.prototype = Object.create(CircuitElement.prototype);
Ground.prototype.constructor = Ground;

/**
 * @memberof Ground
 * Help Tip
 * @type {string}
 */
Ground.prototype.tooltipText = 'Ground: All bits are Low(0).';

/**
 * @memberof Ground
 * Help URL
 * @type {string}
 */
Ground.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=ground';

/**
 * @memberof Ground
 * @type {number}
 */
Ground.prototype.propagationDelay = 0;

/**
 * @memberof Ground
 * fn to create save Json Data of object
 * @return {JSON}
 */
Ground.prototype.customSave = function () {
    const data = {
        nodes: {
            output1: findNode(this.output1),
        },
        values: {
            state: this.state,
        },
        constructorParamaters: [this.direction, this.bitWidth],
    };
    return data;
};

/**
 * @memberof Ground
 * resolve output values based on inputData
 */
Ground.prototype.resolve = function () {
    this.output1.value = 0;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof Ground
 * fn to create save Json Data of object
 * @return {JSON}
 */
Ground.prototype.customSave = function () {
    const data = {
        nodes: {
            output1: findNode(this.output1),
        },
        constructorParamaters: [this.bitWidth],
    };
    return data;
};

/**
 * @memberof Ground
 * function to draw element
 */
Ground.prototype.customDraw = function () {
    ctx = simulationArea.context;

    ctx.beginPath();
    ctx.strokeStyle = ['black', 'brown'][((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) + 0];
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;

    moveTo(ctx, 0, -10, xx, yy, this.direction);
    lineTo(ctx, 0, 0, xx, yy, this.direction);
    moveTo(ctx, -10, 0, xx, yy, this.direction);
    lineTo(ctx, 10, 0, xx, yy, this.direction);
    moveTo(ctx, -6, 5, xx, yy, this.direction);
    lineTo(ctx, 6, 5, xx, yy, this.direction);
    moveTo(ctx, -2.5, 10, xx, yy, this.direction);
    lineTo(ctx, 2.5, 10, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * Power
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} bitWidth - bit width per node.
 */
function Power(x, y, scope = globalScope, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', bitWidth);
    this.directionFixed = true;
    this.rectangleObject = false;
    this.setDimensions(10, 10);
    this.output1 = new Node(0, 10, 1, this);
}
Power.prototype = Object.create(CircuitElement.prototype);
Power.prototype.constructor = Power;

/**
 * @memberof Power
 * Help Tip
 * @type {string}
 */
Power.prototype.tooltipText = 'Power: All bits are High(1).';

/**
 * @memberof Power
 * Help URL
 * @type {string}
 */
Power.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=power';

/**
 * @memberof Power
 * @type {number}
 */
Power.prototype.propagationDelay = 0;

/**
 * @memberof Power
 * resolve output values based on inputData
 */
Power.prototype.resolve = function () {
    this.output1.value = ~0 >>> (32 - this.bitWidth);
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof Power
 * fn to create save Json Data of object
 * @return {JSON}
 */
Power.prototype.customSave = function () {
    const data = {

        nodes: {
            output1: findNode(this.output1),
        },
        constructorParamaters: [this.bitWidth],
    };
    return data;
};

/**
 * @memberof Power
 * function to draw element
 */
Power.prototype.customDraw = function () {
    ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);
    ctx.fillStyle = 'green';
    moveTo(ctx, 0, -10, xx, yy, this.direction);
    lineTo(ctx, -10, 0, xx, yy, this.direction);
    lineTo(ctx, 10, 0, xx, yy, this.direction);
    lineTo(ctx, 0, -10, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    moveTo(ctx, 0, 0, xx, yy, this.direction);
    lineTo(ctx, 0, 10, xx, yy, this.direction);
    ctx.stroke();
};

function getNextPosition(x = 0, scope = globalScope) {
    let possibleY = 20;
    const done = {};
    for (let i = 0; i < scope.Input.length; i++) {
        if (scope.Input[i].layoutProperties.x === x) { done[scope.Input[i].layoutProperties.y] = 1; }
    }
    for (let i = 0; i < scope.Output.length; i++) {
        if (scope.Output[i].layoutProperties.x === x) { done[scope.Output[i].layoutProperties.y] = 1; }
    }
    while (done[possibleY] || done[possibleY + 10] || done[possibleY - 10]) { possibleY += 10; }
    const height = possibleY + 20;
    if (height > scope.layout.height) {
        const oldHeight = scope.layout.height;
        scope.layout.height = height;
        for (let i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].layoutProperties.y === oldHeight) { scope.Input[i].layoutProperties.y = scope.layout.height; }
        }
        for (let i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].layoutProperties.y === oldHeight) { scope.Output[i].layoutProperties.y = scope.layout.height; }
        }
    }
    return possibleY;
}

/**
 * Input
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {Object=} layoutProperties - x,y and id
 */
function Input(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, layoutProperties) {
    if (layoutProperties) { this.layoutProperties = layoutProperties; } else {
        this.layoutProperties = {
            x: 0,
            y: getNextPosition(0, scope),
            id: generateId(),
        };
    }

    // Call base class constructor
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.state = 0;
    this.orientationFixed = false;
    this.state = bin2dec(this.state); // in integer format
    this.output1 = new Node(this.bitWidth * 10, 0, 1, this);
    this.wasClicked = false;
    this.directionFixed = true;
    this.setWidth(this.bitWidth * 10);
    this.rectangleObject = true; // Trying to make use of base class draw
}
Input.prototype = Object.create(CircuitElement.prototype);
Input.prototype.constructor = Input;

/**
 * @memberof Input
 * Help Tip
 * @type {string}
 */
Input.prototype.tooltipText = 'Input ToolTip: Toggle the individual bits by clicking on them.';

/**
 * @memberof Input
 * Help URL
 * @type {string}
 */
Input.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=input';

/**
 * @memberof Input
 * @type {number}
 */
Input.prototype.propagationDelay = 0;

/**
 * @memberof Input
 * fn to create save Json Data of object
 * @return {JSON}
 */
Input.prototype.customSave = function () {
    const data = {
        nodes: {
            output1: findNode(this.output1),
        },
        values: {
            state: this.state,
        },
        constructorParamaters: [this.direction, this.bitWidth, this.layoutProperties],
    };
    return data;
};

/**
 * @memberof Input
 * resolve output values based on inputData
 */
Input.prototype.resolve = function () {
    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);
};
// Check if override is necessary!!

/**
 * @memberof Input
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
Input.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth < 1) return;
    const diffBitWidth = bitWidth - this.bitWidth;
    this.bitWidth = bitWidth; // ||parseInt(prompt("Enter bitWidth"),10);
    this.setWidth(this.bitWidth * 10);
    this.state = 0;
    this.output1.bitWidth = bitWidth;
    if (this.direction === 'RIGHT') {
        this.x -= 10 * diffBitWidth;
        this.output1.x = 10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    } else if (this.direction === 'LEFT') {
        this.x += 10 * diffBitWidth;
        this.output1.x = -10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    }
};

/**
 * @memberof Input
 * listener function to set selected index [ Documentation is a WIP ]
 */
Input.prototype.click = function () { // toggle
    let pos = this.findPos();
    if (pos === 0) pos = 1; // minor correction
    if (pos < 1 || pos > this.bitWidth) return;
    this.state = ((this.state >>> 0) ^ (1 << (this.bitWidth - pos))) >>> 0;
};

/**
 * @memberof Input
 * function to draw element
 */
Input.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;

    ctx.beginPath();
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    const bin = dec2bin(this.state, this.bitWidth);
    for (let k = 0; k < this.bitWidth; k++) { fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5); }
    ctx.fill();
};

/**
 * @memberof Input
 * function to change direction of input
 * @param {string} dir - new direction
 */
Input.prototype.newDirection = function (dir) {
    if (dir === this.direction) return;
    this.direction = dir;
    this.output1.refresh();
    if (dir === 'RIGHT' || dir === 'LEFT') {
        this.output1.leftx = 10 * this.bitWidth;
        this.output1.lefty = 0;
    } else {
        this.output1.leftx = 10; // 10*this.bitWidth;
        this.output1.lefty = 0;
    }

    this.output1.refresh();
    this.labelDirection = oppositeDirection[this.direction];
};

/**
 * @memberof Input
 * function to find position of mouse click [Documentation is a WIP]
 */
Input.prototype.findPos = function () {
    return Math.round((simulationArea.mouseX - this.x + 10 * this.bitWidth) / 20.0);
};

/**
 * Output
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputLength - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */
function Output(x, y, scope = globalScope, dir = 'LEFT', bitWidth = 1, layoutProperties) {
    // Calling base class constructor

    if (layoutProperties) { this.layoutProperties = layoutProperties; } else {
        this.layoutProperties = {
            x: scope.layout.width,
            y: getNextPosition(scope.layout.width, scope),
            id: generateId(),
        };
    }

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.directionFixed = true;
    this.orientationFixed = false;
    this.setDimensions(this.bitWidth * 10, 10);
    this.inp1 = new Node(this.bitWidth * 10, 0, 0, this);
}
Output.prototype = Object.create(CircuitElement.prototype);
Output.prototype.constructor = Output;

/**
 * @memberof Output
 * Help Tip
 * @type {string}
 */
Output.prototype.tooltipText = 'Output ToolTip: Simple output element showing output in binary.';

/**
 * @memberof Output
 * Help URL
 * @type {string}
 */
Output.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=output';

/**
 * @memberof Output
 * @type {number}
 */
Output.prototype.propagationDelay = 0;

/**
 * @memberof Output
 * function to generate verilog for output
 * @return {string}
 */
Output.prototype.generateVerilog = function () {
    return `assign ${this.label} = ${this.inp1.verilogLabel};`;
};

/**
 * @memberof Output
 * fn to create save Json Data of object
 * @return {JSON}
 */
Output.prototype.customSave = function () {
    const data = {
        nodes: {
            inp1: findNode(this.inp1),
        },
        constructorParamaters: [this.direction, this.bitWidth, this.layoutProperties],
    };
    return data;
};

/**
 * @memberof Output
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
Output.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth < 1) return;
    const diffBitWidth = bitWidth - this.bitWidth;
    this.state = undefined;
    this.inp1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
    this.setWidth(10 * this.bitWidth);

    if (this.direction === 'RIGHT') {
        this.x -= 10 * diffBitWidth;
        this.inp1.x = 10 * this.bitWidth;
        this.inp1.leftx = 10 * this.bitWidth;
    } else if (this.direction === 'LEFT') {
        this.x += 10 * diffBitWidth;
        this.inp1.x = -10 * this.bitWidth;
        this.inp1.leftx = 10 * this.bitWidth;
    }
};

/**
 * @memberof Output
 * function to draw element
 */
Output.prototype.customDraw = function () {
    this.state = this.inp1.value;
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ['blue', 'red'][+(this.inp1.value === undefined)];
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;

    rect2(ctx, -10 * this.bitWidth, -10, 20 * this.bitWidth, 20, xx, yy, 'RIGHT');
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }

    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    let bin;
    if (this.state === undefined) { bin = 'x'.repeat(this.bitWidth); } else { bin = dec2bin(this.state, this.bitWidth); }

    for (let k = 0; k < this.bitWidth; k++) { fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5); }
    ctx.fill();
};

/**
 * @memberof Output
 * function to change direction of Output
 * @param {string} dir - new direction
 */
Output.prototype.newDirection = function (dir) {
    if (dir === this.direction) return;
    this.direction = dir;
    this.inp1.refresh();
    if (dir === 'RIGHT' || dir === 'LEFT') {
        this.inp1.leftx = 10 * this.bitWidth;
        this.inp1.lefty = 0;
    } else {
        this.inp1.leftx = 10; // 10*this.bitWidth;
        this.inp1.lefty = 0;
    }

    this.inp1.refresh();
    this.labelDirection = oppositeDirection[this.direction];
};

/**
 * BitSelector
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} selectorBitWidth - WIP
 */
function BitSelector(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 2, selectorBitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 20);
    this.selectorBitWidth = selectorBitWidth || parseInt(prompt('Enter Selector bitWidth'), 10);
    this.rectangleObject = false;
    this.inp1 = new Node(-20, 0, 0, this, this.bitWidth, 'Input');
    this.output1 = new Node(20, 0, 1, this, 1, 'Output');
    this.bitSelectorInp = new Node(0, 20, 0, this, this.selectorBitWidth, 'Bit Selector');
}
BitSelector.prototype = Object.create(CircuitElement.prototype);
BitSelector.prototype.constructor = BitSelector;

/**
 * @memberof BitSelector
 * Help Tip
 * @type {string}
 */
BitSelector.prototype.tooltipText = 'BitSelector ToolTip : Divides input bits into several equal-sized groups.';
BitSelector.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=bit-selector';

/**
 * @memberof BitSelector
 * Function to change selector Bitwidth
 * @param {size}
 */
BitSelector.prototype.changeSelectorBitWidth = function (size) {
    if (size === undefined || size < 1 || size > 32) return;
    this.selectorBitWidth = size;
    this.bitSelectorInp.bitWidth = size;
};

/**
 * @memberof BitSelector
 * Mutable properties of the element
 * @type {JSON}
 */
BitSelector.prototype.mutableProperties = {
    selectorBitWidth: {
        name: 'Selector Bit Width: ',
        type: 'number',
        max: '32',
        min: '1',
        func: 'changeSelectorBitWidth',
    },
};

/**
 * @memberof BitSelector
 * fn to create save Json Data of object
 * @return {JSON}
 */
BitSelector.prototype.customSave = function () {
    const data = {

        nodes: {
            inp1: findNode(this.inp1),
            output1: findNode(this.output1),
            bitSelectorInp: findNode(this.bitSelectorInp),
        },
        constructorParamaters: [this.direction, this.bitWidth, this.selectorBitWidth],
    };
    return data;
};

/**
 * @memberof BitSelector
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
BitSelector.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
};

/**
 * @memberof BitSelector
 * resolve output values based on inputData
 */
BitSelector.prototype.resolve = function () {
    this.output1.value = extractBits(this.inp1.value, this.bitSelectorInp.value + 1, this.bitSelectorInp.value + 1); // (this.inp1.value^(1<<this.bitSelectorInp.value))==(1<<this.bitSelectorInp.value);
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof BitSelector
 * function to draw element
 */
BitSelector.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ['blue', 'red'][(this.state === undefined) + 0];
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;
    rect(ctx, xx - 20, yy - 20, 40, 40);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    if (this.bitSelectorInp.value === undefined) { const bit = 'x'; } else { const bit = this.bitSelectorInp.value; }

    fillText(ctx, bit, xx, yy + 5);
    ctx.fill();
};

/**
 * ConstantVal
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {string=} state - The state of element
 */
function ConstantVal(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, state = '0') {
    this.state = state || prompt('Enter value');
    CircuitElement.call(this, x, y, scope, dir, this.state.length);
    this.setDimensions(10 * this.state.length, 10);
    this.bitWidth = bitWidth || this.state.length;
    this.directionFixed = true;
    this.orientationFixed = false;
    this.rectangleObject = false;

    this.output1 = new Node(this.bitWidth * 10, 0, 1, this);
    this.wasClicked = false;
    this.label = '';
}
ConstantVal.prototype = Object.create(CircuitElement.prototype);
ConstantVal.prototype.constructor = ConstantVal;

/**
 * @memberof ConstantVal
 * Help Tip
 * @type {string}
 */
ConstantVal.prototype.tooltipText = 'Constant ToolTip: Bits are fixed. Double click element to change the bits.';

/**
 * @memberof ConstantVal
 * Help URL
 * @type {string}
 */
ConstantVal.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=constantval';

/**
 * @memberof ConstantVal
 * @type {number}
 */
ConstantVal.prototype.propagationDelay = 0;
ConstantVal.prototype.generateVerilog = function () {
    return `localparam [${this.bitWidth - 1}:0] ${this.verilogLabel}=${this.bitWidth}b'${this.state};`;
};

/**
 * @memberof ConstantVal
 * fn to create save Json Data of object
 * @return {JSON}
 */
ConstantVal.prototype.customSave = function () {
    const data = {
        nodes: {
            output1: findNode(this.output1),
        },
        constructorParamaters: [this.direction, this.bitWidth, this.state],
    };
    return data;
};

/**
 * @memberof ConstantVal
 * resolve output values based on inputData
 */
ConstantVal.prototype.resolve = function () {
    this.output1.value = bin2dec(this.state);
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof ConstantVal
 * updates state using a prompt when dbl clicked
 */
ConstantVal.prototype.dblclick = function () {
    this.state = prompt('Re enter the value') || '0';
    this.newBitWidth(this.state.toString().length);
    // console.log(this.state, this.bitWidth);
};

/**
 * @memberof ConstantVal
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
ConstantVal.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth > this.state.length) this.state = '0'.repeat(bitWidth - this.state.length) + this.state;
    else if (bitWidth < this.state.length) this.state = this.state.slice(this.bitWidth - bitWidth);
    this.bitWidth = bitWidth; // ||parseInt(prompt("Enter bitWidth"),10);
    this.output1.bitWidth = bitWidth;
    this.setDimensions(10 * this.bitWidth, 10);
    if (this.direction === 'RIGHT') {
        this.output1.x = 10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    } else if (this.direction === 'LEFT') {
        this.output1.x = -10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    }
};

/**
 * @memberof ConstantVal
 * function to draw element
 */
ConstantVal.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(1);
    const xx = this.x;
    const yy = this.y;

    rect2(ctx, -10 * this.bitWidth, -10, 20 * this.bitWidth, 20, xx, yy, 'RIGHT');
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    const bin = this.state; // dec2bin(this.state,this.bitWidth);
    for (let k = 0; k < this.bitWidth; k++) { fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5); }
    ctx.fill();
};

/**
 * @memberof ConstantVal
 * function to change direction of ConstantVal
 * @param {string} dir - new direction
 */
ConstantVal.prototype.newDirection = function (dir) {
    if (dir === this.direction) return;
    this.direction = dir;
    this.output1.refresh();
    if (dir === 'RIGHT' || dir === 'LEFT') {
        this.output1.leftx = 10 * this.bitWidth;
        this.output1.lefty = 0;
    } else {
        this.output1.leftx = 10; // 10*this.bitWidth;
        this.output1.lefty = 0;
    }

    this.output1.refresh();
    this.labelDirection = oppositeDirection[this.direction];
};

/**
 * NorGate
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} inputs - number of input nodes
 * @param {number=} bitWidth - bit width per node.
 */
function NorGate(x, y, scope = globalScope, dir = 'RIGHT', inputs = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);

    this.inp = [];
    this.inputSize = inputs;

    if (inputs % 2 === 1) {
        for (let i = 0; i < inputs / 2 - 1; i++) {
            const a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        let a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (let i = inputs / 2 + 1; i < inputs; i++) {
            a = new Node(-10, 10 * (i + 1 - inputs / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (let i = 0; i < inputs / 2; i++) {
            const a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (let i = inputs / 2; i < inputs; i++) {
            const a = new Node(-10, 10 * (i + 1 - inputs / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(30, 0, 1, this);
}
NorGate.prototype = Object.create(CircuitElement.prototype);
NorGate.prototype.constructor = NorGate;

/**
 * @memberof NorGate
 * Help Tip
 * @type {string}
 */
NorGate.prototype.tooltipText = 'Nor Gate ToolTip : Combination of OR gate and NOT gate.';

/**
 * @memberof NorGate
 * @type {boolean}
 */
NorGate.prototype.alwaysResolve = true;


/**
 * @memberof SevenSegDisplay
 * function to change input nodes of the element
 */
NorGate.prototype.changeInputSize = changeInputSize;

/**
 * @memberof SevenSegDisplay
 * @type {string}
 */
NorGate.prototype.verilogType = 'nor';
NorGate.prototype.helplink = 'https://docs.circuitverse.org/#/gates?id=nor-gate';

/**
 * @memberof NorGate
 * fn to create save Json Data of object
 * @return {JSON}
 */
NorGate.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },
    };
    return data;
};

/**
 * @memberof NorGate
 * resolve output values based on inputData
 */
NorGate.prototype.resolve = function () {
    let result = this.inp[0].value || 0;
    for (let i = 1; i < this.inputSize; i++) result |= (this.inp[i].value || 0);
    result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof NorGate
 * function to draw element
 */
NorGate.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(3);

    const xx = this.x;
    const yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = 'white';

    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.5)';
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();
    // for debugging
};

/**
 * DigitalLed
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} color - color of led
 */
function DigitalLed(x, y, scope = globalScope, color = 'Red') {
    // Calling base class constructor

    CircuitElement.call(this, x, y, scope, 'UP', 1);
    this.rectangleObject = false;
    this.setDimensions(10, 20);
    this.inp1 = new Node(-40, 0, 0, this, 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.color = color;
    const temp = colorToRGBA(this.color);
    this.actualColor = `rgba(${temp[0]},${temp[1]},${temp[2]},${0.8})`;
}
DigitalLed.prototype = Object.create(CircuitElement.prototype);
DigitalLed.prototype.constructor = DigitalLed;

/**
 * @memberof DigitalLed
 * Help Tip
 * @type {string}
 */
DigitalLed.prototype.tooltipText = 'Digital Led ToolTip: Digital LED glows high when input is High(1).';

/**
 * @memberof DigitalLed
 * Help URL
 * @type {string}
 */
DigitalLed.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=digital-led';

/**
 * @memberof DigitalLed
 * fn to create save Json Data of object
 * @return {JSON}
 */
DigitalLed.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.color],
        nodes: {
            inp1: findNode(this.inp1),
        },
    };
    return data;
};

/**
 * @memberof DigitalLed
 * Mutable properties of the element
 * @type {JSON}
 */
DigitalLed.prototype.mutableProperties = {
    color: {
        name: 'Color: ',
        type: 'text',
        func: 'changeColor',
    },
};

/**
 * @memberof DigitalLed
 * function to change color of the led
 */
DigitalLed.prototype.changeColor = function (value) {
    if (validColor(value)) {
        this.color = value;
        const temp = colorToRGBA(this.color);
        this.actualColor = `rgba(${temp[0]},${temp[1]},${temp[2]},${0.8})`;
    }
};

/**
 * @memberof DigitalLed
 * function to draw element
 */
DigitalLed.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    ctx.strokeStyle = '#e3e4e5';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 0, xx, yy, this.direction);
    lineTo(ctx, -40, 0, xx, yy, this.direction);
    ctx.stroke();

    ctx.strokeStyle = '#d3d4d5';
    ctx.fillStyle = ['rgba(227,228,229,0.8)', this.actualColor][this.inp1.value || 0];
    ctx.lineWidth = correctWidth(1);

    ctx.beginPath();

    moveTo(ctx, -15, -9, xx, yy, this.direction);
    lineTo(ctx, 0, -9, xx, yy, this.direction);
    arc(ctx, 0, 0, 9, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -15, 9, xx, yy, this.direction);
    lineTo(ctx, -18, 12, xx, yy, this.direction);
    arc(ctx, 0, 0, Math.sqrt(468), ((Math.PI / 2) + Math.acos(12 / Math.sqrt(468))), ((-Math.PI / 2) - Math.asin(18 / Math.sqrt(468))), xx, yy, this.direction);
    lineTo(ctx, -15, -9, xx, yy, this.direction);
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
};

/**
 * VariableLed
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 */
function VariableLed(x, y, scope = globalScope) {
    // Calling base class constructor

    CircuitElement.call(this, x, y, scope, 'UP', 8);
    this.rectangleObject = false;
    this.setDimensions(10, 20);
    this.inp1 = new Node(-40, 0, 0, this, 8);
    this.directionFixed = true;
    this.fixedBitWidth = true;
}
VariableLed.prototype = Object.create(CircuitElement.prototype);
VariableLed.prototype.constructor = VariableLed;

/**
 * @memberof VariableLed
 * Help Tip
 * @type {string}
 */
VariableLed.prototype.tooltipText = 'Variable Led ToolTip: Variable LED inputs an 8 bit value and glows with a proportional intensity.';

/**
 * @memberof VariableLed
 * Help URL
 * @type {string}
 */
VariableLed.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=variable-led';

/**
 * @memberof VariableLed
 * fn to create save Json Data of object
 * @return {JSON}
 */
VariableLed.prototype.customSave = function () {
    const data = {
        nodes: {
            inp1: findNode(this.inp1),
        },
    };
    return data;
};

/**
 * @memberof VariableLed
 * function to draw element
 */
VariableLed.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    ctx.strokeStyle = '#353535';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 0, xx, yy, this.direction);
    lineTo(ctx, -40, 0, xx, yy, this.direction);
    ctx.stroke();
    const c = this.inp1.value;
    const alpha = c / 255;
    ctx.strokeStyle = '#090a0a';
    ctx.fillStyle = [`rgba(255,29,43,${alpha})`, 'rgba(227, 228, 229, 0.8)'][(c === undefined || c === 0) + 0];
    ctx.lineWidth = correctWidth(1);

    ctx.beginPath();

    moveTo(ctx, -20, -9, xx, yy, this.direction);
    lineTo(ctx, 0, -9, xx, yy, this.direction);
    arc(ctx, 0, 0, 9, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -20, 9, xx, yy, this.direction);
    /* lineTo(ctx,-18,12,xx,yy,this.direction);
    arc(ctx,0,0,Math.sqrt(468),((Math.PI/2) + Math.acos(12/Math.sqrt(468))),((-Math.PI/2) - Math.asin(18/Math.sqrt(468))),xx,yy,this.direction);

    */
    lineTo(ctx, -20, -9, xx, yy, this.direction);
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
};

/**
 * Button
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 */
function Button(x, y, scope = globalScope, dir = 'RIGHT') {
    CircuitElement.call(this, x, y, scope, dir, 1);
    this.state = 0;
    this.output1 = new Node(30, 0, 1, this);
    this.wasClicked = false;
    this.rectangleObject = false;
    this.setDimensions(10, 10);
}
Button.prototype = Object.create(CircuitElement.prototype);
Button.prototype.constructor = Button;

/**
 * @memberof Button
 * Help Tip
 * @type {string}
 */
Button.prototype.tooltipText = 'Button ToolTip: High(1) when pressed and Low(0) when released.';

/**
 * @memberof Button
 * Help URL
 * @type {string}
 */
Button.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=button';

/**
 * @memberof Button
 * @type {number}
 */
Button.prototype.propagationDelay = 0;

/**
 * @memberof Button
 * fn to create save Json Data of object
 * @return {JSON}
 */
Button.prototype.customSave = function () {
    const data = {
        nodes: {
            output1: findNode(this.output1),
        },
        values: {
            state: this.state,
        },
        constructorParamaters: [this.direction, this.bitWidth],
    };
    return data;
};

/**
 * @memberof Button
 * resolve output values based on inputData
 */
Button.prototype.resolve = function () {
    if (this.wasClicked) {
        this.state = 1;
        this.output1.value = this.state;
    } else {
        this.state = 0;
        this.output1.value = this.state;
    }
    simulationArea.simulationQueue.add(this.output1);
};

/**
 * @memberof Button
 * function to draw element
 */
Button.prototype.customDraw = function () {
    ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    ctx.fillStyle = '#ddd';

    ctx.strokeStyle = '#353535';
    ctx.lineWidth = correctWidth(5);

    ctx.beginPath();

    moveTo(ctx, 10, 0, xx, yy, this.direction);
    lineTo(ctx, 30, 0, xx, yy, this.direction);
    ctx.stroke();

    ctx.beginPath();

    drawCircle2(ctx, 0, 0, 12, xx, yy, this.direction);
    ctx.stroke();

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(232, 13, 13,0.6)'; }

    if (this.wasClicked) { ctx.fillStyle = 'rgba(232, 13, 13,0.8)'; }
    ctx.fill();
};


/**
 * RGBLed
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 */
function RGBLed(x, y, scope = globalScope) {
    // Calling base class constructor
    CircuitElement.call(this, x, y, scope, 'UP', 8);
    this.rectangleObject = false;
    this.inp = [];
    this.setDimensions(10, 10);
    this.inp1 = new Node(-40, -10, 0, this, 8);
    this.inp2 = new Node(-40, 0, 0, this, 8);
    this.inp3 = new Node(-40, 10, 0, this, 8);
    this.inp.push(this.inp1);
    this.inp.push(this.inp2);
    this.inp.push(this.inp3);
    this.directionFixed = true;
    this.fixedBitWidth = true;
}
RGBLed.prototype = Object.create(CircuitElement.prototype);
RGBLed.prototype.constructor = RGBLed;

/**
 * @memberof RGBLed
 * Help Tip
 * @type {string}
 */
RGBLed.prototype.tooltipText = 'RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE.';

/**
 * @memberof RGBLed
 * Help URL
 * @type {string}
 */
RGBLed.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=rgb-led';

/**
 * @memberof RGBLed
 * fn to create save Json Data of object
 * @return {JSON}
 */
RGBLed.prototype.customSave = function () {
    const data = {
        nodes: {
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
            inp3: findNode(this.inp3),
        },
    };
    return data;
};

/**
 * @memberof RGBLed
 * function to draw element
 */
RGBLed.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    ctx.strokeStyle = 'green';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 0, xx, yy, this.direction);
    lineTo(ctx, -40, 0, xx, yy, this.direction);
    ctx.stroke();

    ctx.strokeStyle = 'red';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, -10, xx, yy, this.direction);
    lineTo(ctx, -40, -10, xx, yy, this.direction);
    ctx.stroke();

    ctx.strokeStyle = 'blue';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 10, xx, yy, this.direction);
    lineTo(ctx, -40, 10, xx, yy, this.direction);
    ctx.stroke();

    const a = this.inp1.value;
    const b = this.inp2.value;
    const c = this.inp3.value;
    ctx.strokeStyle = '#d3d4d5';
    ctx.fillStyle = [`rgba(${a}, ${b}, ${c}, 0.8)`, 'rgba(227, 228, 229, 0.8)'][((a === undefined || b === undefined || c === undefined)) + 0];
    // ctx.fillStyle = ["rgba(200, 200, 200, 0.3)","rgba(227, 228, 229, 0.8)"][((a === undefined || b === undefined || c === undefined) || (a === 0 && b === 0 && c === 0)) + 0];
    ctx.lineWidth = correctWidth(1);

    ctx.beginPath();

    moveTo(ctx, -18, -11, xx, yy, this.direction);
    lineTo(ctx, 0, -11, xx, yy, this.direction);
    arc(ctx, 0, 0, 11, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -18, 11, xx, yy, this.direction);
    lineTo(ctx, -21, 15, xx, yy, this.direction);
    arc(ctx, 0, 0, Math.sqrt(666), ((Math.PI / 2) + Math.acos(15 / Math.sqrt(666))), ((-Math.PI / 2) - Math.asin(21 / Math.sqrt(666))), xx, yy, this.direction);
    lineTo(ctx, -18, -11, xx, yy, this.direction);
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
};

/**
 * SquareRGBLed
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} pinLength - pins per node.
 */
function SquareRGBLed(x, y, scope = globalScope, dir = 'UP', pinLength = 1) {
    CircuitElement.call(this, x, y, scope, dir, 8);
    this.rectangleObject = false;
    this.setDimensions(15, 15);
    this.pinLength = pinLength === undefined ? 1 : pinLength;
    const nodeX = -10 - 10 * pinLength;
    this.inp1 = new Node(nodeX, -10, 0, this, 8, 'R');
    this.inp2 = new Node(nodeX, 0, 0, this, 8, 'G');
    this.inp3 = new Node(nodeX, 10, 0, this, 8, 'B');
    this.inp = [this.inp1, this.inp2, this.inp3];
    this.labelDirection = 'UP';
    this.fixedBitWidth = true;

    // eslint-disable-next-line no-shadow
    this.changePinLength = function (pinLength) {
        if (pinLength === undefined) return;
        pinLength = parseInt(pinLength, 10);
        if (pinLength < 0 || pinLength > 1000) return;

        // Calculate the new position of the LED, so the nodes will stay in the same place.
        const diff = 10 * (pinLength - this.pinLength);
        // eslint-disable-next-line no-nested-ternary
        const diffX = this.direction === 'LEFT' ? -diff : this.direction === 'RIGHT' ? diff : 0;
        // eslint-disable-next-line no-nested-ternary
        const diffY = this.direction === 'UP' ? -diff : this.direction === 'DOWN' ? diff : 0;

        // Build a new LED with the new values; preserve label properties too.
        const obj = new window[this.objectType](this.x + diffX, this.y + diffY, this.scope, this.direction, pinLength);
        obj.label = this.label;
        obj.labelDirection = this.labelDirection;

        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    };

    this.mutableProperties = {
        pinLength: {
            name: 'Pin Length',
            type: 'number',
            max: '1000',
            min: '0',
            func: 'changePinLength',
        },
    };
}
SquareRGBLed.prototype = Object.create(CircuitElement.prototype);
SquareRGBLed.prototype.constructor = SquareRGBLed;

/**
 * @memberof SquareRGBLed
 * Help Tip
 * @type {string}
 */
SquareRGBLed.prototype.tooltipText = 'Square RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE.';

/**
 * @memberof SquareRGBLed
 * Help URL
 * @type {string}
 */
SquareRGBLed.prototype.helplink = 'https://docs.circuitverse.org/#/outputs?id=square-rgb-led';

/**
 * @memberof SquareRGBLed
 * fn to create save Json Data of object
 * @return {JSON}
 */
SquareRGBLed.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.pinLength],
        nodes: {
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
            inp3: findNode(this.inp3),
        },
    };
    return data;
};

/**
 * @memberof SquareRGBLed
 * function to draw element
 */
SquareRGBLed.prototype.customDraw = function () {
    const ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    const r = this.inp1.value;
    const g = this.inp2.value;
    const b = this.inp3.value;

    const colors = ['rgb(174,20,20)', 'rgb(40,174,40)', 'rgb(0,100,255)'];
    for (let i = 0; i < 3; i++) {
        const x = -10 - 10 * this.pinLength;
        const y = i * 10 - 10;
        ctx.lineWidth = correctWidth(3);

        // A gray line, which makes it easy on the eyes when the pin length is large
        ctx.beginPath();
        ctx.lineCap = 'butt';
        ctx.strokeStyle = 'rgb(227, 228, 229)';
        moveTo(ctx, -15, y, xx, yy, this.direction);
        lineTo(ctx, x + 10, y, xx, yy, this.direction);
        ctx.stroke();

        // A colored line, so people know which pin does what.
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.strokeStyle = colors[i];
        moveTo(ctx, x + 10, y, xx, yy, this.direction);
        lineTo(ctx, x, y, xx, yy, this.direction);
        ctx.stroke();
    }

    ctx.strokeStyle = '#d3d4d5';
    ctx.fillStyle = (r === undefined && g === undefined && b === undefined) ? 'rgb(227, 228, 229)' : `rgb(${r || 0}, ${g || 0}, ${b || 0})`;
    ctx.lineWidth = correctWidth(1);
    ctx.beginPath();
    rect2(ctx, -15, -15, 30, 30, xx, yy, this.direction);
    ctx.stroke();

    if ((this.hover && !simulationArea.shiftDown)
        || simulationArea.lastSelected === this
        || simulationArea.multipleObjectSelections.contains(this)) {
        ctx.fillStyle = 'rgba(255, 255, 32)';
    }

    ctx.fill();
};

/**
 * Demultiplexer
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {number=} controlSignalSize - WIP
 */
function Demultiplexer(x, y, scope = globalScope, dir = 'LEFT', bitWidth = 1, controlSignalSize = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.controlSignalSize = controlSignalSize || parseInt(prompt('Enter control signal bitWidth'), 10);
    this.outputsize = 1 << this.controlSignalSize;
    this.xOff = 0;
    this.yOff = 1;
    if (this.controlSignalSize === 1) {
        this.xOff = 10;
    }
    if (this.controlSignalSize <= 3) {
        this.yOff = 2;
    }

    this.changeControlSignalSize = function (size) {
        if (size === undefined || size < 1 || size > 32) return;
        if (this.controlSignalSize === size) return;
        const obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth, size);
        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    };
    this.mutableProperties = {
        controlSignalSize: {
            name: 'Control Signal Size',
            type: 'number',
            max: '32',
            min: '1',
            func: 'changeControlSignalSize',
        },
    };
    // eslint-disable-next-line no-shadow
    this.newBitWidth = function (bitWidth) {
        this.bitWidth = bitWidth;
        for (let i = 0; i < this.outputsize; i++) {
            this.output1[i].bitWidth = bitWidth;
        }
        this.input.bitWidth = bitWidth;
    };

    this.setDimensions(20 - this.xOff, this.yOff * 5 * (this.outputsize));
    this.rectangleObject = false;
    this.input = new Node(20 - this.xOff, 0, 0, this);

    this.output1 = [];
    for (let i = 0; i < this.outputsize; i++) {
        const a = new Node(-20 + this.xOff, +this.yOff * 10 * (i - this.outputsize / 2) + 10, 1, this);
        this.output1.push(a);
    }

    this.controlSignalInput = new Node(0, this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff + 10, 0, this, this.controlSignalSize, 'Control Signal');
}
Demultiplexer.prototype = Object.create(CircuitElement.prototype);
Demultiplexer.prototype.constructor = Demultiplexer;

/**
 * @memberof Demultiplexer
 * Help Tip
 * @type {string}
 */
Demultiplexer.prototype.tooltipText = 'DeMultiplexer ToolTip : Multiple outputs and a single line input.';
Demultiplexer.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=demultiplexer';

/**
 * @memberof Demultiplexer
 * fn to create save Json Data of object
 * @return {JSON}
 */
Demultiplexer.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth, this.controlSignalSize],
        nodes: {
            output1: this.output1.map(findNode),
            input: findNode(this.input),
            controlSignalInput: findNode(this.controlSignalInput),
        },
    };
    return data;
};

/**
 * @memberof Demultiplexer
 * resolve output values based on inputData
 */
Demultiplexer.prototype.resolve = function () {
    for (let i = 0; i < this.output1.length; i++) { this.output1[i].value = 0; }

    this.output1[this.controlSignalInput.value].value = this.input.value;

    for (let i = 0; i < this.output1.length; i++) { simulationArea.simulationQueue.add(this.output1[i]); }
};

/**
 * @memberof Demultiplexer
 * function to draw element
 */
Demultiplexer.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    ctx.beginPath();
    moveTo(ctx, 0, this.yOff * 10 * (this.outputsize / 2 - 1) + 10 + 0.5 * this.xOff, xx, yy, this.direction);
    lineTo(ctx, 0, this.yOff * 5 * (this.outputsize - 1) + this.xOff, xx, yy, this.direction);
    ctx.stroke();

    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(4);
    ctx.fillStyle = 'white';
    moveTo(ctx, -20 + this.xOff, -this.yOff * 10 * (this.outputsize / 2), xx, yy, this.direction);
    lineTo(ctx, -20 + this.xOff, 20 + this.yOff * 10 * (this.outputsize / 2 - 1), xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, +this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff, xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, -this.yOff * 10 * (this.outputsize / 2) - this.xOff + 20, xx, yy, this.direction);

    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';
    // [xFill,yFill] = rotate(xx + this.output1[i].x - 7, yy + this.output1[i].y + 2);
    // //console.log([xFill,yFill])
    for (let i = 0; i < this.outputsize; i++) {
        if (this.direction === 'LEFT') fillText(ctx, String(i), xx + this.output1[i].x - 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction === 'RIGHT') fillText(ctx, String(i), xx + this.output1[i].x + 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction === 'UP') fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y - 5, 10);
        else fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y + 10, 10);
    }
    ctx.fill();
};

/**
 * Decoder
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function Decoder(x, y, scope = globalScope, dir = 'LEFT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    // this.controlSignalSize = controlSignalSize || parseInt(prompt("Enter control signal bitWidth"), 10);
    this.outputsize = 1 << this.bitWidth;
    this.xOff = 0;
    this.yOff = 1;
    if (this.bitWidth === 1) {
        this.xOff = 10;
    }
    if (this.bitWidth <= 3) {
        this.yOff = 2;
    }

    // this.changeControlSignalSize = function(size) {
    //     if (size === undefined || size < 1 || size > 32) return;
    //     if (this.controlSignalSize === size) return;
    //     let obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth, size);
    //     this.cleanDelete();
    //     simulationArea.lastSelected = obj;
    //     return obj;
    // }
    // this.mutableProperties = {
    //     "controlSignalSize": {
    //         name: "Control Signal Size",
    //         type: "number",
    //         max: "32",
    //         min: "1",
    //         func: "changeControlSignalSize",
    //     },
    // }
    // eslint-disable-next-line no-shadow
    this.newBitWidth = function (bitWidth) {
        // this.bitWidth = bitWidth;
        // for (let i = 0; i < this.inputSize; i++) {
        //     this.outputs1[i].bitWidth = bitWidth
        // }
        // this.input.bitWidth = bitWidth;
        if (bitWidth === undefined || bitWidth < 1 || bitWidth > 32) return;
        if (this.bitWidth === bitWidth) return;
        const obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, bitWidth);
        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    };

    this.setDimensions(20 - this.xOff, this.yOff * 5 * (this.outputsize));
    this.rectangleObject = false;
    this.input = new Node(20 - this.xOff, 0, 0, this);

    this.output1 = [];
    for (let i = 0; i < this.outputsize; i++) {
        const a = new Node(-20 + this.xOff, +this.yOff * 10 * (i - this.outputsize / 2) + 10, 1, this, 1);
        this.output1.push(a);
    }

    // this.controlSignalInput = new Node(0,this.yOff * 10 * (this.outputsize / 2 - 1) +this.xOff + 10, 0, this, this.controlSignalSize,"Control Signal");
}
Decoder.prototype = Object.create(CircuitElement.prototype);
Decoder.prototype.constructor = Decoder;

/**
 * @memberof Decoder
 * Help Tip
 * @type {string}
 */
Decoder.prototype.tooltipText = 'Decoder ToolTip : Converts coded inputs into coded outputs.';
Decoder.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=decoder';

/**
 * @memberof Decoder
 * fn to create save Json Data of object
 * @return {JSON}
 */
Decoder.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: this.output1.map(findNode),
            input: findNode(this.input),
        },
    };
    return data;
};

/**
 * @memberof Decoder
 * resolve output values based on inputData
 */
Decoder.prototype.resolve = function () {
    for (let i = 0; i < this.output1.length; i++) { this.output1[i].value = 0; }
    this.output1[this.input.value].value = 1;
    for (let i = 0; i < this.output1.length; i++) { simulationArea.simulationQueue.add(this.output1[i]); }
};

/**
 * @memberof Decoder
 * function to draw element
 */
Decoder.prototype.customDraw = function () {
    ctx = simulationArea.context;

    const xx = this.x;
    const yy = this.y;

    // ctx.beginPath();
    // moveTo(ctx, 0,this.yOff * 10 * (this.outputsize / 2 - 1) + 10 + 0.5 *this.xOff, xx, yy, this.direction);
    // lineTo(ctx, 0,this.yOff * 5 * (this.outputsize - 1) +this.xOff, xx, yy, this.direction);
    // ctx.stroke();

    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.lineWidth = correctWidth(4);
    ctx.fillStyle = 'white';
    moveTo(ctx, -20 + this.xOff, -this.yOff * 10 * (this.outputsize / 2), xx, yy, this.direction);
    lineTo(ctx, -20 + this.xOff, 20 + this.yOff * 10 * (this.outputsize / 2 - 1), xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, +this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff, xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, -this.yOff * 10 * (this.outputsize / 2) - this.xOff + 20, xx, yy, this.direction);

    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';
    // [xFill,yFill] = rotate(xx + this.output1[i].x - 7, yy + this.output1[i].y + 2);
    // //console.log([xFill,yFill])
    for (let i = 0; i < this.outputsize; i++) {
        if (this.direction === 'LEFT') fillText(ctx, String(i), xx + this.output1[i].x - 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction === 'RIGHT') fillText(ctx, String(i), xx + this.output1[i].x + 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction === 'UP') fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y - 5, 10);
        else fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y + 10, 10);
    }
    ctx.fill();
};

/**
 * Flag
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {string} identifier - id
 */
function Flag(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1, identifier) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
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
Flag.prototype = Object.create(CircuitElement.prototype);
Flag.prototype.constructor = Flag;

/**
 * @memberof Flag
 * Help Tip
 * @type {string}
 */
Flag.prototype.tooltipText = 'FLag ToolTip: Use this for debugging and plotting.';
Flag.prototype.helplink = 'https://docs.circuitverse.org/#/timing_diagrams?id=using-flags';

/**
 * @memberof Flag
 * Help URL
 * @type {string}
 */
Flag.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=tunnel';

/**
 * @memberof Flag
 * funtion to Set plot values
 * @type {string}
 */
Flag.prototype.setPlotValue = function () {
    const time = plotArea.stopWatch.ElapsedMilliseconds;

    // //console.log("DEB:",time);
    if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] === time) { this.plotValues.pop(); }

    if (this.plotValues.length === 0) {
        this.plotValues.push([time, this.inp1.value]);
        return;
    }

    if (this.plotValues[this.plotValues.length - 1][1] === this.inp1.value) { return; }
    this.plotValues.push([time, this.inp1.value]);
};

/**
 * @memberof Flag
 * fn to create save Json Data of object
 * @return {JSON}
 */
Flag.prototype.customSave = function () {
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
};

/**
 * @memberof Flag
 * set the flag id
 * @param {number} id - identifier for flag
 */
Flag.prototype.setIdentifier = function (id = '') {
    if (id.length === 0) return;
    this.identifier = id;
    const len = this.identifier.length;
    if (len === 1) this.xSize = 20;
    else if (len > 1 && len < 4) this.xSize = 10;
    else this.xSize = 0;
};

/**
 * @memberof Flag
 * Mutable properties of the element
 * @type {JSON}
 */
Flag.prototype.mutableProperties = {
    identifier: {
        name: 'Debug Flag identifier',
        type: 'text',
        maxlength: '5',
        func: 'setIdentifier',
    },
};

/**
 * @memberof Flag
 * function to draw element
 */
Flag.prototype.customDraw = function () {
    ctx = simulationArea.context;
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
};

/**
 * @memberof Flag
 * function to change direction of Flag
 * @param {string} dir - new direction
 */
Flag.prototype.newDirection = function (dir) {
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
};

/**
 * MSB
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function MSB(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    // this.setDimensions(20, 20);
    this.leftDimensionX = 10;
    this.rightDimensionX = 20;
    this.setHeight(30);
    this.directionFixed = true;
    this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10);
    this.rectangleObject = false;
    this.inputSize = 1 << this.bitWidth;

    this.inp1 = new Node(-10, 0, 0, this, this.inputSize);
    this.output1 = new Node(20, 0, 1, this, this.bitWidth);
    this.enable = new Node(20, 20, 1, this, 1);
}
MSB.prototype = Object.create(CircuitElement.prototype);
MSB.prototype.constructor = MSB;

/**
 * @memberof MSB
 * Help Tip
 * @type {string}
 */
MSB.prototype.tooltipText = 'MSB ToolTip : The most significant bit or the high-order bit.';
MSB.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=most-significant-bit-msb-detector';

/**
 * @memberof MSB
 * fn to create save Json Data of object
 * @return {JSON}
 */
MSB.prototype.customSave = function () {
    const data = {

        nodes: {
            inp1: findNode(this.inp1),
            output1: findNode(this.output1),
            enable: findNode(this.enable),
        },
        constructorParamaters: [this.direction, this.bitWidth],
    };
    return data;
};

/**
 * @memberof MSB
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
MSB.prototype.newBitWidth = function (bitWidth) {
    // this.inputSize = 1 << bitWidth
    this.inputSize = bitWidth;
    this.inp1.bitWidth = this.inputSize;
    this.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
};

/**
 * @memberof MSB
 * resolve output values based on inputData
 */
MSB.prototype.resolve = function () {
    const inp = this.inp1.value;
    this.output1.value = (dec2bin(inp).length) - 1;
    simulationArea.simulationQueue.add(this.output1);
    if (inp !== 0) {
        this.enable.value = 1;
    } else {
        this.enable.value = 0;
    }
    simulationArea.simulationQueue.add(this.enable);
};

/**
 * @memberof MSB
 * function to draw element
 */
MSB.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = 'black';
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;
    rect(ctx, xx - 10, yy - 30, 30, 60);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';
    fillText(ctx, 'MSB', xx + 6, yy - 12, 10);
    fillText(ctx, 'EN', xx + this.enable.x - 12, yy + this.enable.y + 3, 8);
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    if (this.output1.value !== undefined) {
        fillText(ctx, this.output1.value, xx + 5, yy + 14, 13);
    }
    ctx.stroke();
    ctx.fill();
};

/**
 * LSB
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function LSB(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.leftDimensionX = 10;
    this.rightDimensionX = 20;
    this.setHeight(30);
    this.directionFixed = true;
    this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10);
    this.rectangleObject = false;
    this.inputSize = 1 << this.bitWidth;

    this.inp1 = new Node(-10, 0, 0, this, this.inputSize);
    this.output1 = new Node(20, 0, 1, this, this.bitWidth);
    this.enable = new Node(20, 20, 1, this, 1);
}
LSB.prototype = Object.create(CircuitElement.prototype);
LSB.prototype.constructor = LSB;

/**
 * @memberof LSB
 * Help Tip
 * @type {string}
 */
LSB.prototype.tooltipText = 'LSB ToolTip : The least significant bit or the low-order bit.';
LSB.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=least-significant-bit-lsb-detector';

/**
 * @memberof LSB
 * fn to create save Json Data of object
 * @return {JSON}
 */
LSB.prototype.customSave = function () {
    const data = {

        nodes: {
            inp1: findNode(this.inp1),
            output1: findNode(this.output1),
            enable: findNode(this.enable),
        },
        constructorParamaters: [this.direction, this.bitWidth],
    };
    return data;
};

/**
 * @memberof LSB
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
LSB.prototype.newBitWidth = function (bitWidth) {
    // this.inputSize = 1 << bitWidth
    this.inputSize = bitWidth;
    this.inp1.bitWidth = this.inputSize;
    this.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
};

/**
 * @memberof LSB
 * resolve output values based on inputData
 */
LSB.prototype.resolve = function () {
    const inp = dec2bin(this.inp1.value);
    let out = 0;
    for (let i = inp.length - 1; i >= 0; i--) {
        if (inp[i] === 1) {
            out = inp.length - 1 - i;
            break;
        }
    }
    this.output1.value = out;
    simulationArea.simulationQueue.add(this.output1);
    if (inp !== 0) {
        this.enable.value = 1;
    } else {
        this.enable.value = 0;
    }
    simulationArea.simulationQueue.add(this.enable);
};

/**
 * @memberof LSB
 * function to draw element
 */
LSB.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = 'black';
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;
    rect(ctx, xx - 10, yy - 30, 30, 60);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';
    fillText(ctx, 'LSB', xx + 6, yy - 12, 10);
    fillText(ctx, 'EN', xx + this.enable.x - 12, yy + this.enable.y + 3, 8);
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    if (this.output1.value !== undefined) {
        fillText(ctx, this.output1.value, xx + 5, yy + 14, 13);
    }
    ctx.stroke();
    ctx.fill();
};

/**
 * PriorityEncoder
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function PriorityEncoder(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10);
    this.inputSize = 1 << this.bitWidth;

    this.yOff = 1;
    if (this.bitWidth <= 3) {
        this.yOff = 2;
    }

    this.setDimensions(20, this.yOff * 5 * (this.inputSize));
    this.directionFixed = true;
    this.rectangleObject = false;

    this.inp1 = [];
    for (let i = 0; i < this.inputSize; i++) {
        const a = new Node(-10, +this.yOff * 10 * (i - this.inputSize / 2) + 10, 0, this, 1);
        this.inp1.push(a);
    }

    this.output1 = [];
    for (let i = 0; i < this.bitWidth; i++) {
        const a = new Node(30, +2 * 10 * (i - this.bitWidth / 2) + 10, 1, this, 1);
        this.output1.push(a);
    }

    this.enable = new Node(10, 20 + this.inp1[this.inputSize - 1].y, 1, this, 1);
}
PriorityEncoder.prototype = Object.create(CircuitElement.prototype);
PriorityEncoder.prototype.constructor = PriorityEncoder;

/**
 * @memberof PriorityEncoder
 * Help Tip
 * @type {string}
 */
PriorityEncoder.prototype.tooltipText = 'Priority Encoder ToolTip : Compresses binary inputs into a smaller number of outputs.';
PriorityEncoder.prototype.helplink = 'https://docs.circuitverse.org/#/decodersandplexers?id=priority-encoder';

/**
 * @memberof PriorityEncoder
 * fn to create save Json Data of object
 * @return {JSON}
 */
PriorityEncoder.prototype.customSave = function () {
    const data = {

        nodes: {
            inp1: this.inp1.map(findNode),
            output1: this.output1.map(findNode),
            enable: findNode(this.enable),
        },
        constructorParamaters: [this.direction, this.bitWidth],
    };
    return data;
};

/**
 * @memberof PriorityEncoder
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
PriorityEncoder.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth === undefined || bitWidth < 1 || bitWidth > 32) return;
    if (this.bitWidth === bitWidth) return;

    this.bitWidth = bitWidth;
    const obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth);
    this.inputSize = 1 << bitWidth;

    this.cleanDelete();
    simulationArea.lastSelected = obj;
    return obj;
};

/**
 * @memberof PriorityEncoder
 * resolve output values based on inputData
 */
PriorityEncoder.prototype.resolve = function () {
    let out = 0;
    let temp = 0;
    for (let i = this.inputSize - 1; i >= 0; i--) {
        if (this.inp1[i].value === 1) {
            out = dec2bin(i);
            break;
        }
    }
    temp = out;

    if (out.length !== undefined) {
        this.enable.value = 1;
    } else {
        this.enable.value = 0;
    }
    simulationArea.simulationQueue.add(this.enable);

    if (temp.length === undefined) {
        temp = '0';
        for (let i = 0; i < this.bitWidth - 1; i++) {
            temp = `0${temp}`;
        }
    }

    if (temp.length !== this.bitWidth) {
        for (let i = temp.length; i < this.bitWidth; i++) {
            temp = `0${temp}`;
        }
    }

    for (let i = this.bitWidth - 1; i >= 0; i--) {
        this.output1[this.bitWidth - 1 - i].value = Number(temp[i]);
        simulationArea.simulationQueue.add(this.output1[this.bitWidth - 1 - i]);
    }
};

/**
 * @memberof PriorityEncoder
 * function to draw element
 */
PriorityEncoder.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = 'black';
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;
    if (this.bitWidth <= 3) { rect(ctx, xx - 10, yy - 10 - this.yOff * 5 * (this.inputSize), 40, 20 * (this.inputSize + 1)); } else { rect(ctx, xx - 10, yy - 10 - this.yOff * 5 * (this.inputSize), 40, 10 * (this.inputSize + 3)); }
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'black';
    ctx.textAlign = 'center';
    for (let i = 0; i < this.inputSize; i++) {
        fillText(ctx, String(i), xx, yy + this.inp1[i].y + 2, 10);
    }
    for (let i = 0; i < this.bitWidth; i++) {
        fillText(ctx, String(i), xx + this.output1[0].x - 10, yy + this.output1[i].y + 2, 10);
    }
    fillText(ctx, 'EN', xx + this.enable.x, yy + this.enable.y - 5, 10);
    ctx.fill();
};

/**
 * Tunnel
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 * @param {string=} identifier - number of input nodes
 */
function Tunnel(x, y, scope = globalScope, dir = 'LEFT', bitWidth = 1, identifier) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.centerElement = true;
    this.xSize = 10;
    this.plotValues = [];
    this.inp1 = new Node(0, 0, 0, this);
    this.setIdentifier(identifier || 'T');
    this.setBounds();
}
Tunnel.prototype = Object.create(CircuitElement.prototype);
Tunnel.prototype.constructor = Tunnel;

/**
 * @memberof Tunnel
 * Help Tip
 * @type {string}
 */
Tunnel.prototype.tooltipText = 'Tunnel ToolTip : Tunnel Selected.';
Tunnel.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=tunnel';

/**
 * @memberof Tunnel
 * function to change direction of Tunnel
 * @param {string} dir - new direction
 */
Tunnel.prototype.newDirection = function (dir) {
    if (this.direction === dir) return;
    this.direction = dir;
    this.setBounds();
};
Tunnel.prototype.overrideDirectionRotation = true;
Tunnel.prototype.setBounds = function () {
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
};

/**
 * @memberof Tunnel
 * function to set tunnel value
 * @param {number} val - tunnel value
 */
Tunnel.prototype.setTunnelValue = function (val) {
    this.inp1.value = val;
    for (let i = 0; i < this.inp1.connections.length; i++) {
        if (this.inp1.connections[i].value !== val) {
            this.inp1.connections[i].value = val;
            simulationArea.simulationQueue.add(this.inp1.connections[i]);
        }
    }
};

/**
 * @memberof Tunnel
 * resolve output values based on inputData
 */
Tunnel.prototype.resolve = function () {
    for (let i = 0; i < this.scope.tunnelList[this.identifier].length; i++) {
        if (this.scope.tunnelList[this.identifier][i].inp1.value !== this.inp1.value) {
            this.scope.tunnelList[this.identifier][i].setTunnelValue(this.inp1.value);
        }
    }
};

/**
 * @memberof Tunnel
 * function to set tunnel value
 * @param {Scope} scope - tunnel value
 */
Tunnel.prototype.updateScope = function (scope) {
    this.scope = scope;
    this.inp1.updateScope(scope);
    this.setIdentifier(this.identifier);
    // console.log("ShouldWork!");
};

/**
 * @memberof Tunnel
 * function to set plot value
 */
Tunnel.prototype.setPlotValue = function () {
    const time = plotArea.stopWatch.ElapsedMilliseconds;
    if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] === time) { this.plotValues.pop(); }

    if (this.plotValues.length === 0) {
        this.plotValues.push([time, this.inp1.value]);
        return;
    }

    if (this.plotValues[this.plotValues.length - 1][1] === this.inp1.value) { return; }
    this.plotValues.push([time, this.inp1.value]);
};

/**
 * @memberof Tunnel
 * fn to create save Json Data of object
 * @return {JSON}
 */
Tunnel.prototype.customSave = function () {
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
};

/**
 * @memberof Tunnel
 * function to set tunnel value
 * @param {string=} id - id is a WIP
 */
Tunnel.prototype.setIdentifier = function (id = '') {
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
};

/**
 * @memberof Tunnel
 * Mutable properties of the element
 * @type {JSON}
 */
Tunnel.prototype.mutableProperties = {
    identifier: {
        name: 'Debug Flag identifier',
        type: 'text',
        maxlength: '5',
        func: 'setIdentifier',
    },
};

/**
 * @memberof Tunnel
 * delete the tunnel element
 */
Tunnel.prototype.delete = function () {
    this.scope.Tunnel.clean(this);
    this.scope.tunnelList[this.identifier].clean(this);
    CircuitElement.prototype.delete.call(this);
};

/**
 * @memberof Tunnel
 * function to draw element
 */
Tunnel.prototype.customDraw = function () {
    ctx = simulationArea.context;
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
};

/**
 * ALU
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 * @param {number=} bitWidth - bit width per node.
 */
function ALU(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    // //console.log("HIT");
    // //console.log(x,y,scope,dir,bitWidth,controlSignalSize);
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.message = 'ALU';

    this.setDimensions(30, 40);
    this.rectangleObject = false;

    this.inp1 = new Node(-30, -30, 0, this, this.bitwidth, 'A');
    this.inp2 = new Node(-30, 30, 0, this, this.bitwidth, 'B');

    this.controlSignalInput = new Node(-10, -40, 0, this, 3, 'Ctrl');
    this.carryOut = new Node(-10, 40, 1, this, 1, 'Cout');
    this.output = new Node(30, 0, 1, this, this.bitwidth, 'Out');
}
ALU.prototype = Object.create(CircuitElement.prototype);
ALU.prototype.constructor = ALU;

/**
 * @memberof ALU
 * Help Tip
 * @type {string}
 */
ALU.prototype.tooltipText = 'ALU ToolTip: 0: A&B, 1:A|B, 2:A+B, 4:A&~B, 5:A|~B, 6:A-B, 7:SLT ';

/**
 * @memberof ALU
 * Help URL
 * @type {string}
 */
ALU.prototype.helplink = 'https://docs.circuitverse.org/#/miscellaneous?id=alu';

/**
 * @memberof ALU
 * function to change bitwidth of the element
 * @param {number} bitWidth - new bitwidth
 */
ALU.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.inp1.bitWidth = bitWidth;
    this.inp2.bitWidth = bitWidth;
    this.output.bitWidth = bitWidth;
};

/**
 * @memberof ALU
 * fn to create save Json Data of object
 * @return {JSON}
 */
ALU.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
            output: findNode(this.output),
            carryOut: findNode(this.carryOut),
            controlSignalInput: findNode(this.controlSignalInput),
        },
    };
    return data;
};

/**
 * @memberof ALU
 * function to draw element
 */
ALU.prototype.customDraw = function () {
    ctx = simulationArea.context;
    const xx = this.x;
    const yy = this.y;
    ctx.strokeStyle = 'black';
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, 30, 10, xx, yy, this.direction);
    lineTo(ctx, 30, -10, xx, yy, this.direction);
    lineTo(ctx, 10, -40, xx, yy, this.direction);
    lineTo(ctx, -30, -40, xx, yy, this.direction);
    lineTo(ctx, -30, -20, xx, yy, this.direction);
    lineTo(ctx, -20, -10, xx, yy, this.direction);
    lineTo(ctx, -20, 10, xx, yy, this.direction);
    lineTo(ctx, -30, 20, xx, yy, this.direction);
    lineTo(ctx, -30, 40, xx, yy, this.direction);
    lineTo(ctx, 10, 40, xx, yy, this.direction);
    lineTo(ctx, 30, 10, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) { ctx.fillStyle = 'rgba(255, 255, 32,0.8)'; }
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'Black';
    ctx.textAlign = 'center';

    fillText4(ctx, 'B', -23, 30, xx, yy, this.direction, 6);
    fillText4(ctx, 'A', -23, -30, xx, yy, this.direction, 6);
    fillText4(ctx, 'CTR', -10, -30, xx, yy, this.direction, 6);
    fillText4(ctx, 'Carry', -10, 30, xx, yy, this.direction, 6);
    fillText4(ctx, 'Ans', 20, 0, xx, yy, this.direction, 6);
    ctx.fill();
    ctx.beginPath();
    ctx.fillStyle = 'DarkGreen';
    fillText4(ctx, this.message, 0, 0, xx, yy, this.direction, 12);
    ctx.fill();
};

/**
 * @memberof ALU
 * resolve output values based on inputData
 */
ALU.prototype.resolve = function () {
    if (this.controlSignalInput.value === 0) {
        this.output.value = ((this.inp1.value) & (this.inp2.value));
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
        this.message = 'A&B';
    } else if (this.controlSignalInput.value === 1) {
        this.output.value = ((this.inp1.value) | (this.inp2.value));

        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
        this.message = 'A|B';
    } else if (this.controlSignalInput.value === 2) {
        const sum = this.inp1.value + this.inp2.value;
        this.output.value = ((sum) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        this.carryOut.value = +((sum >>> (this.bitWidth)) !== 0);
        simulationArea.simulationQueue.add(this.carryOut);
        simulationArea.simulationQueue.add(this.output);
        this.message = 'A+B';
    } else if (this.controlSignalInput.value === 3) {
        this.message = 'ALU';
    } else if (this.controlSignalInput.value === 4) {
        this.message = 'A&~B';
        this.output.value = ((this.inp1.value) & this.flipBits(this.inp2.value));
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    } else if (this.controlSignalInput.value === 5) {
        this.message = 'A|~B';
        this.output.value = ((this.inp1.value) | this.flipBits(this.inp2.value));
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    } else if (this.controlSignalInput.value === 6) {
        this.message = 'A-B';
        this.output.value = ((this.inp1.value - this.inp2.value) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    } else if (this.controlSignalInput.value === 7) {
        this.message = 'A<B';
        if (this.inp1.value < this.inp2.value) { this.output.value = 1; } else { this.output.value = 0; }
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    }
};


/**
 * Rectangle
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} rows - number of rows
 * @param {number=} cols - number of columns.
 */
function Rectangle(x, y, scope = globalScope, rows = 15, cols = 20) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.rectangleObject = false;
    this.cols = cols || parseInt(prompt('Enter cols:'), 10);
    this.rows = rows || parseInt(prompt('Enter rows:'), 10);
    this.setSize();
}
Rectangle.prototype = Object.create(CircuitElement.prototype);
Rectangle.prototype.constructor = Rectangle;

/**
 * @memberof Rectangle
 * Help Tip
 * @type {string}
 */
Rectangle.prototype.tooltipText = 'Rectangle ToolTip : Used to Box the Circuit or area you want to highlight.';
Rectangle.prototype.helplink = 'https://docs.circuitverse.org/#/annotation?id=rectangle';
Rectangle.prototype.propagationDelayFixed = true;

/**
 * @memberof Rectangle
 * @param {number} size - new size of rows
 */
Rectangle.prototype.changeRowSize = function (size) {
    if (size === undefined || size < 5 || size > 1000) return;
    if (this.rows === size) return;
    this.rows = parseInt(size, 10);
    this.setSize();
    return this;
};

/**
 * @memberof Rectangle
 * @param {number} size - new size of columns
 */
Rectangle.prototype.changeColSize = function (size) {
    if (size === undefined || size < 5 || size > 1000) return;
    if (this.cols === size) return;
    this.cols = parseInt(size, 10);
    this.setSize();
    return this;
};
/**
 * @memberof Rectangle
 * listener function to change direction of rectangle
 * @param {string} dir - new direction
 */
Rectangle.prototype.keyDown3 = function (dir) {
    if (dir === 'ArrowRight') { this.changeColSize(this.cols + 2); }
    if (dir === 'ArrowLeft') { this.changeColSize(this.cols - 2); }
    if (dir === 'ArrowDown') { this.changeRowSize(this.rows + 2); }
    if (dir === 'ArrowUp') { this.changeRowSize(this.rows - 2); }
};

/**
 * @memberof Rectangle
 * Mutable properties of the element
 * @type {JSON}
 */
Rectangle.prototype.mutableProperties = {
    cols: {
        name: 'Columns',
        type: 'number',
        max: '1000',
        min: '5',
        func: 'changeColSize',
    },
    rows: {
        name: 'Rows',
        type: 'number',
        max: '1000',
        min: '5',
        func: 'changeRowSize',
    },
};

/**
 * @memberof Rectangle
 * fn to create save Json Data of object
 * @return {JSON}
 */
Rectangle.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.rows, this.cols],
    };
    return data;
};

/**
 * @memberof Rectangle
 * function to draw element
 */
Rectangle.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = 'rgba(0,0,0,1)';
    ctx.setLineDash([5 * globalScope.scale, 5 * globalScope.scale]);
    ctx.lineWidth = correctWidth(1.5);
    const xx = this.x;
    const yy = this.y;
    rect(ctx, xx, yy, this.elementWidth, this.elementHeight);
    ctx.stroke();

    if (simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) {
        ctx.fillStyle = 'rgba(255, 255, 32,0.1)';
        ctx.fill();
    }
    ctx.setLineDash([]);
};

/**
 * @memberof Rectangle
 * function to reset or (internally) set size
 */
Rectangle.prototype.setSize = function () {
    this.elementWidth = this.cols * 10;
    this.elementHeight = this.rows * 10;
    this.upDimensionY = 0;
    this.leftDimensionX = 0;
    this.rightDimensionX = this.elementWidth;
    this.downDimensionY = this.elementHeight;
};

/**
 * Arrow
 * @class
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {string=} dir - direction of element
 */
function Arrow(x, y, scope = globalScope, dir = 'RIGHT') {
    CircuitElement.call(this, x, y, scope, dir, 8);
    this.rectangleObject = false;
    this.fixedBitWidth = true;
    this.setDimensions(30, 20);
}
Arrow.prototype = Object.create(CircuitElement.prototype);
Arrow.prototype.constructor = Arrow;

/**
 * @memberof Arrow
 * Help Tip
 * @type {string}
 */
Arrow.prototype.tooltipText = 'Arrow ToolTip : Arrow Selected.';
Arrow.prototype.propagationDelayFixed = true;
Arrow.prototype.helplink = 'https://docs.circuitverse.org/#/annotation?id=arrow';

/**
 * @memberof Arrow
 * fn to create save Json Data of object
 * @return {JSON}
 */
Arrow.prototype.customSave = function () {
    const data = {
        constructorParamaters: [this.direction],
    };
    return data;
};

/**
 * @memberof Arrow
 * function to draw element
 */
Arrow.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.lineWidth = correctWidth(3);
    const xx = this.x;
    const yy = this.y;
    ctx.strokeStyle = 'red';
    ctx.fillStyle = 'white';

    ctx.beginPath();

    moveTo(ctx, -30, -3, xx, yy, this.direction);
    lineTo(ctx, 10, -3, xx, yy, this.direction);
    lineTo(ctx, 10, -15, xx, yy, this.direction);
    lineTo(ctx, 30, 0, xx, yy, this.direction);
    lineTo(ctx, 10, 15, xx, yy, this.direction);
    lineTo(ctx, 10, 3, xx, yy, this.direction);
    lineTo(ctx, -30, 3, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
    ctx.fill();
};
