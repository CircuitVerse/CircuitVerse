/**
 * a global function as a helper for Scope.clockTick
 */
function clockTick() {
    if (!simulationArea.clockEnabled) return;
    if (errorDetected) return;
    updateCanvas = true;
    globalScope.clockTick();
    play();
    scheduleUpdate(0, 20);
}

/**
 * a global function as a helper for simulationArea.changeClockEnable
 */
function changeClockEnable(val) {
    simulationArea.clockEnabled = val;
}

/**
 * WIP function defined but not used
 * @param {number} n
 */
function runTest(n = 10) {
    var t = new Date().getTime();
    for (var i = 0; i < n; i++) {clockTick();}
    // console.log((new Date().getTime()-t)/n);
    updateCanvas = true;
    scheduleUpdate();
}

/**
 * T flip flop has 5 input nodes:
 * clock, data input, preset, reset ,enable.
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function TflipFlop(x, y, scope = globalScope, dir = 'RIGHT') {
    CircuitElement.call(this, x, y, scope, dir, 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.setDimensions(20, 20);
    this.rectangleObject = true;
    this.clockInp = new Node(-20, +10, 0, this, 1, 'Clock');
    this.dInp = new Node(-20, -10, 0, this, this.bitWidth, 'T');
    this.qOutput = new Node(20, -10, 1, this, this.bitWidth, 'Q');
    this.qInvOutput = new Node(20, 10, 1, this, this.bitWidth, 'Q Inverse');
    this.reset = new Node(10, 20, 0, this, 1, 'Asynchronous Reset');
    this.preset = new Node(0, 20, 0, this, this.bitWidth, 'Preset');
    this.en = new Node(-10, 20, 0, this, 1, 'Enable');
    this.masterState = 0;
    this.slaveState = 0;
    this.prevClockState = 0;

    // this.wasClicked = false;
}
TflipFlop.prototype = Object.create(CircuitElement.prototype);

TflipFlop.prototype.constructor = TflipFlop;

TflipFlop.prototype.tooltipText = 'T FlipFlop ToolTip :  Changes state / Toggles whenever the clock input is strobed.';

TflipFlop.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=t-flip-flop';

/**
 * @memberof TflipFlop
 * returns true if clock is defined
 */
TflipFlop.prototype.isResolvable = function () {
    if (this.reset.value == 1) return true;
    if (this.clockInp.value != undefined && this.dInp.value != undefined) return true;
    return false;
};

/**
 * @memberof TflipFlop
 * @param {number} bitWidth - the new bitwidth 
 */
TflipFlop.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.dInp.bitWidth = bitWidth;
    this.qOutput.bitWidth = bitWidth;
    this.qInvOutput.bitWidth = bitWidth;
    this.preset.bitWidth = bitWidth;
};

/**
 * @memberof TflipFlop
 * On the leading edge of the clock signal (LOW-to-HIGH) the first stage,
 * the “master” latches the input condition at D, while the output stage is deactivated.
 * On the trailing edge of the clock signal (HIGH-to-LOW) the second “slave” stage is
 * now activated, latching on to the output from the first master circuit.
 * This fuction sets the value for the node qOutput based on
 * the previous state and input of the clock by taking xor.
 * We flip the bits to find qInvOutput
 */
TflipFlop.prototype.resolve = function () {
    if (this.reset.value == 1) {
        // if reset bit is set
        this.masterState = this.slaveState = this.preset.value || 0;
    } else if (this.en.value == 0) {
        // if enabled bit is 0
        this.prevClockState = this.clockInp.value;
    } else if (this.en.value == 1 || this.en.connections.length == 0) {
        // if enabled bit is 1 or not connected to anything.
        if (this.clockInp.value == this.prevClockState) {
            if (this.clockInp.value == 0 && this.dInp.value != undefined) {
                // value is xor of
                this.masterState = this.dInp.value ^ this.slaveState;
            }
        } else if (this.clockInp.value != undefined) {
            if (this.clockInp.value == 1) {
                this.slaveState = this.masterState;
            } else if (this.clockInp.value == 0 && this.dInp.value != undefined) {
                this.masterState = this.dInp.value ^ this.slaveState;
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
};

TflipFlop.prototype.customSave = function () {
    var data = {
        nodes: {
            clockInp: findNode(this.clockInp),
            dInp: findNode(this.dInp),
            qOutput: findNode(this.qOutput),
            qInvOutput: findNode(this.qInvOutput),
            reset: findNode(this.reset),
            preset: findNode(this.preset),
            en: findNode(this.en),
        },
        constructorParamaters: [this.direction, this.bitWidth],

    };
    return data;
};

TflipFlop.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
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
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.slaveState.toString(16), xx, yy + 5);
    ctx.fill();
};

/**
 * D flip flop has 5 input nodes:
 * clock, data input, preset, reset ,enable.
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function DflipFlop(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.directionFixed = true;
    this.setDimensions(20, 20);
    this.rectangleObject = true;
    this.clockInp = new Node(-20, +10, 0, this, 1, 'Clock');
    this.dInp = new Node(-20, -10, 0, this, this.bitWidth, 'D');
    this.qOutput = new Node(20, -10, 1, this, this.bitWidth, 'Q');
    this.qInvOutput = new Node(20, 10, 1, this, this.bitWidth, 'Q Inverse');
    this.reset = new Node(10, 20, 0, this, 1, 'Asynchronous Reset');
    this.preset = new Node(0, 20, 0, this, this.bitWidth, 'Preset');
    this.en = new Node(-10, 20, 0, this, 1, 'Enable');
    this.masterState = 0;
    this.slaveState = 0;
    this.prevClockState = 0;

    this.wasClicked = false;
}
DflipFlop.prototype = Object.create(CircuitElement.prototype);
DflipFlop.prototype.constructor = DflipFlop;
DflipFlop.prototype.tooltipText = 'D FlipFlop ToolTip : Introduces delay in timing circuit.';
DflipFlop.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=d-flip-flop';
/**
 * WIP always resolvable?
 */
DflipFlop.prototype.isResolvable = function () {
    return true;
    // if (this.reset.value == 1) return true;
    // if (this.clockInp.value != undefined && this.dInp.value != undefined) return true;
    // return false;
};

DflipFlop.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.dInp.bitWidth = bitWidth;
    this.qOutput.bitWidth = bitWidth;
    this.qInvOutput.bitWidth = bitWidth;
    this.preset.bitWidth = bitWidth;
};

/**
 * @memberof DflipFlop
 * On the leading edge of the clock signal (LOW-to-HIGH) the first stage,
 * the “master” latches the input condition at D, while the output stage is deactivated.
 * On the trailing edge of the clock signal (HIGH-to-LOW) the second “slave” stage is
 * now activated, latching on to the output from the first master circuit.
 * Then the output stage appears to be triggered on the negative edge of the clock pulse.
 * This fuction sets the value for the node qOutput based on the previous state
 * and input of the clock. We flip the bits to find qInvOutput
 */
DflipFlop.prototype.resolve = function () {
    if (this.reset.value == 1) {
        this.masterState = this.slaveState = (this.preset.value || 0);
    } else if (this.en.value == 0) {
        this.prevClockState = this.clockInp.value;
    } else if (this.en.value == 1 || this.en.connections.length == 0) { // if(this.en.value==1) // Creating Infinite Loop, WHY ??
        if (this.clockInp.value == this.prevClockState) {
            if (this.clockInp.value == 0 && this.dInp.value != undefined) {
                this.masterState = this.dInp.value;
            }
        } else if (this.clockInp.value != undefined) {
            if (this.clockInp.value == 1) {
                this.slaveState = this.masterState;
            } else if (this.clockInp.value == 0 && this.dInp.value != undefined) {
                this.masterState = this.dInp.value;
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
};
DflipFlop.prototype.customSave = function () {
    var data = {
        nodes: {
            clockInp: findNode(this.clockInp),
            dInp: findNode(this.dInp),
            qOutput: findNode(this.qOutput),
            qInvOutput: findNode(this.qInvOutput),
            reset: findNode(this.reset),
            preset: findNode(this.preset),
            en: findNode(this.en),
        },
        constructorParamaters: [this.direction, this.bitWidth],

    };
    return data;
};
DflipFlop.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
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
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.slaveState.toString(16), xx, yy + 5);
    ctx.fill();
};

/**
 * D latch has 2 input nodes:
 * clock, data input.
 * Difference between this and D - FlipFlop is
 * that Flip flop must have a clock.
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function Dlatch(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
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
Dlatch.prototype = Object.create(CircuitElement.prototype);
Dlatch.prototype.constructor = Dlatch;
Dlatch.prototype.tooltipText = 'D Latch : Single input Flip flop or D FlipFlop';
Dlatch.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=d-latch';
/**
 * Idea: shoould be D FF?
 */
Dlatch.prototype.isResolvable = function () {
    if (this.clockInp.value != undefined && this.dInp.value != undefined) return true;
    return false;
};
Dlatch.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.dInp.bitWidth = bitWidth;
    this.qOutput.bitWidth = bitWidth;
    this.qInvOutput.bitWidth = bitWidth;
    // this.preset.bitWidth = bitWidth;
};

/**
 * @memberof Dlatch
 * when the clock input is high we update the state
 * qOutput is set to the state
 */
Dlatch.prototype.resolve = function () {
    if (this.clockInp.value == 1 && this.dInp.value != undefined) {
        this.state = this.dInp.value;
    }

    if (this.qOutput.value != this.state) {
        this.qOutput.value = this.state;
        this.qInvOutput.value = this.flipBits(this.state);
        simulationArea.simulationQueue.add(this.qOutput);
        simulationArea.simulationQueue.add(this.qInvOutput);
    }
};

Dlatch.prototype.customSave = function () {
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
};

Dlatch.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
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
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.state.toString(16), xx, yy + 5);
    ctx.fill();
};

/**
 * Random is used to generate random value.
 * It has 2 input node:
 * clock and max random output value
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function Random(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.directionFixed = true;
    this.setDimensions(20, 20);
    this.rectangleObject = true;
    this.currentRandomNo = 0;
    this.clockInp = new Node(-20, +10, 0, this, 1, 'Clock');
    this.maxValue = new Node(-20, -10, 0, this, this.bitWidth, 'MaxValue');
    this.output = new Node(20, -10, 1, this, this.bitWidth, 'RandomValue');
    this.prevClockState = 0;
    this.wasClicked = false;
}

Random.prototype = Object.create(CircuitElement.prototype);

Random.prototype.constructor = Random;

Random.prototype.tooltipText = 'Random ToolTip : Random Selected.';

Random.prototype.helplink = 'https://docs.circuitverse.org/#/inputElements?id=random';

/**
 * @memberof Random
 * return true if clock is connected and if maxValue is set or unconnected.
 */
Random.prototype.isResolvable = function () {
    if (this.clockInp.value != undefined && (this.maxValue.value != undefined || this.maxValue.connections.length == 0)) {return true;}
    return false;
};

Random.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.maxValue.bitWidth = bitWidth;
    this.output.bitWidth = bitWidth;
};

/**
 * @memberof Random
 * Edge triggered when the clock state changes a
 * Random number is generated less then the maxValue.
 */
Random.prototype.resolve = function () {
    // console.log("HIT")
    var maxValue = this.maxValue.connections.length ? this.maxValue.value + 1 : (2 << (this.bitWidth - 1));
    if (this.clockInp.value != undefined) {
        if (this.clockInp.value != this.prevClockState) {
            if (this.clockInp.value == 1) {
                this.currentRandomNo = Math.floor(Math.random() * maxValue);
            }
            this.prevClockState = this.clockInp.value;
        }
    }
    if (this.output.value != this.currentRandomNo) {
        this.output.value = this.currentRandomNo;
        simulationArea.simulationQueue.add(this.output);
    }
};

Random.prototype.customSave = function () {
    var data = {
        nodes: {
            clockInp: findNode(this.clockInp),
            maxValue: findNode(this.maxValue),
            output: findNode(this.output),
        },
        constructorParamaters: [this.direction, this.bitWidth],

    };
    return data;
};

Random.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    xx = this.x;
    yy = this.y;
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.currentRandomNo.toString(10), this.x, this.y + 5);
    ctx.fill();
    ctx.beginPath();
    moveTo(ctx, -20, 5, xx, yy, this.direction);
    lineTo(ctx, -15, 10, xx, yy, this.direction);
    lineTo(ctx, -20, 15, xx, yy, this.direction);
    ctx.stroke();
};

/**
 * SR flip flop has 6 input nodes:
 * clock, S input, R input, preset, reset ,enable.
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function SRflipFlop(x, y, scope = globalScope, dir = 'RIGHT') {
    CircuitElement.call(this, x, y, scope, dir, 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.setDimensions(20, 20);
    this.rectangleObject = true;
    this.R = new Node(-20, +10, 0, this, 1, 'R');
    this.S = new Node(-20, -10, 0, this, 1, 'S');
    this.qOutput = new Node(20, -10, 1, this, 1, 'Q');
    this.qInvOutput = new Node(20, 10, 1, this, 1, 'Q Inverse');
    this.reset = new Node(10, 20, 0, this, 1, 'Asynchronous Reset');
    this.preset = new Node(0, 20, 0, this, 1, 'Preset');
    this.en = new Node(-10, 20, 0, this, 1, 'Enable');
    this.state = 0;
    // this.slaveState = 0;
    // this.prevClockState = 0;
    // this.wasClicked = false;
}

SRflipFlop.prototype = Object.create(CircuitElement.prototype);

SRflipFlop.prototype.constructor = SRflipFlop;

SRflipFlop.prototype.tooltipText = 'SR FlipFlop ToolTip : SR FlipFlop Selected.';

SRflipFlop.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=sr-flip-flop';

SRflipFlop.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.dInp.bitWidth = bitWidth;
    this.qOutput.bitWidth = bitWidth;
    this.qInvOutput.bitWidth = bitWidth;
    this.preset.bitWidth = bitWidth;
};
/**
 * @memberof SRflipFlop
 * always resolvable
 */
SRflipFlop.prototype.isResolvable = function () {
    return true;
    if (this.reset.value == 1) return true;
    if (this.S.value != undefined && this.R.value != undefined) return true;
    return false;
};

/**
 * @memberof SRflipFlop
 * function to resolve SR flip flop if S != R we can
 * set this.state to value S.
 */
SRflipFlop.prototype.resolve = function () {
    if (this.reset.value == 1) {
        this.state = this.preset.value || 0;
    } else if ((this.en.value == 1 || this.en.connections == 0) && this.S.value ^ this.R.value) {
        this.state = this.S.value;
    }

    // console.log(this.reset.value != 1 && this.en.value && this.S.value && this.R.value && this.S.value ^ this.R.value);
    if (this.qOutput.value != this.state) {
        this.qOutput.value = this.state;
        this.qInvOutput.value = this.flipBits(this.state);
        simulationArea.simulationQueue.add(this.qOutput);
        simulationArea.simulationQueue.add(this.qInvOutput);
    }
};

SRflipFlop.prototype.customSave = function () {
    var data = {
        nodes: {
            S: findNode(this.S),
            R: findNode(this.R),
            qOutput: findNode(this.qOutput),
            qInvOutput: findNode(this.qInvOutput),
            reset: findNode(this.reset),
            preset: findNode(this.preset),
            en: findNode(this.en),
        },
        constructorParamaters: [this.direction],

    };
    return data;
};

SRflipFlop.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;

    // rect(ctx, xx - 20, yy - 20, 40, 40);
    // moveTo(ctx, -20, 5, xx, yy, this.direction);
    // lineTo(ctx, -15, 10, xx, yy, this.direction);
    // lineTo(ctx, -20, 15, xx, yy, this.direction);


    // if ((this.b.hover&&!simulationArea.shiftDown)|| simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.state.toString(16), xx, yy + 5);
    ctx.fill();
};

/**
 * JK flip flop has 6 input nodes:
 * clock, J input, K input, preset, reset ,enable.
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function JKflipFlop(x, y, scope = globalScope, dir = 'RIGHT') {
    CircuitElement.call(this, x, y, scope, dir, 1);
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

JKflipFlop.prototype = Object.create(CircuitElement.prototype);

JKflipFlop.prototype.constructor = JKflipFlop;

JKflipFlop.prototype.tooltipText = 'JK FlipFlop ToolTip : gated SR flip-flop with the addition of a clock input.';

JKflipFlop.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=jk-flip-flop';

/**
 * @memberof JKflipFlop
 * if none of the predefined nodes have been deleted it isresolvable
 */
JKflipFlop.prototype.isResolvable = function () {
    if (this.reset.value == 1) return true;
    if (this.clockInp.value != undefined && this.J.value != undefined && this.K.value != undefined) return true;
    return false;
};

JKflipFlop.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.dInp.bitWidth = bitWidth;
    this.qOutput.bitWidth = bitWidth;
    this.qInvOutput.bitWidth = bitWidth;
    this.preset.bitWidth = bitWidth;
};

/**
 * @memberof JKflipFlop
 * Edge triggered master slave JK flip flop is resolved by
 * setting the slaveState = masterState when there is an edge
 * in the clock. masterState = this.J when no change in clock.
 */
JKflipFlop.prototype.resolve = function () {
    if (this.reset.value == 1) {
        this.masterState = this.slaveState = this.preset.value || 0;
    } else if (this.en.value == 0) {
        this.prevClockState = this.clockInp.value;
    } else if (this.en.value == 1 || this.en.connections.length == 0) {
        if (this.clockInp.value == this.prevClockState) {
            if (this.clockInp.value == 0 && this.J.value != undefined && this.K.value != undefined) {
                if (this.J.value && this.K.value) {this.masterState = 1 ^ this.slaveState;}
                else if (this.J.value ^ this.K.value) {this.masterState = this.J.value;}
            }
        } else if (this.clockInp.value != undefined) {
            if (this.clockInp.value == 1) {
                this.slaveState = this.masterState;
            } else if (this.clockInp.value == 0 && this.J.value != undefined && this.K.value != undefined) {
                if (this.J.value && this.K.value) {this.masterState = 1 ^ this.slaveState;}
                else if (this.J.value ^ this.K.value) {this.masterState = this.J.value;}
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
};
JKflipFlop.prototype.customSave = function () {
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
};
JKflipFlop.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
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
    ctx.font = '20px Georgia';
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    fillText(ctx, this.slaveState.toString(16), xx, yy + 5);
    ctx.fill();
};

/**
 * TypeWriter - We can give 4 inputs:
 * clock and input of 7 bits are main input required
 * on the edge change the data is added onto the display
 * screen of the typewriter
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function TTY(x, y, scope = globalScope, rows = 3, cols = 32) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.cols = cols || parseInt(prompt('Enter cols:'));
    this.rows = rows || parseInt(prompt('Enter rows:'));

    this.elementWidth = Math.max(40, Math.ceil(this.cols / 2) * 20);
    this.elementHeight = Math.max(40, Math.ceil(this.rows * 15 / 20) * 20);
    this.setWidth(this.elementWidth / 2);
    this.setHeight(this.elementHeight / 2);
    // this.element = new Element(x, y, "TTY",this.elementWidth/2, this,this.elementHeight/2);

    this.clockInp = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 10, 0, this, 1, 'Clock');
    this.asciiInp = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 30, 0, this, 7, 'Ascii Input');
    // this.qOutput = new Node(20, -10, 1, this);
    this.reset = new Node(30 - this.elementWidth / 2, this.elementHeight / 2, 0, this, 1, 'Reset');
    this.en = new Node(10 - this.elementWidth / 2, this.elementHeight / 2, 0, this, 1, 'Enable');
    // this.masterState = 0;
    // this.slaveState = 0;
    this.prevClockState = 0;

    this.data = '';
    this.buffer = '';
}
TTY.prototype = Object.create(CircuitElement.prototype);
TTY.prototype.constructor = TTY;
TTY.prototype.tooltipText = 'TTY ToolTip : Tele typewriter selected.';
TTY.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=tty';
/**
 * @memberof TTY
 * this funciton is used to change the size of the screen
 */
TTY.prototype.changeRowSize = function (size) {
    if (size == undefined || size < 1 || size > 10) return;
    if (this.rows == size) return;
    var obj = new window[this.objectType](this.x, this.y, this.scope, size, this.cols);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
};

/**
 * @memberof TTY
 * this funciton is used to change the size of the screen
 */
TTY.prototype.changeColSize = function (size) {
    if (size == undefined || size < 20 || size > 100) return;
    if (this.cols == size) return;
    var obj = new window[this.objectType](this.x, this.y, this.scope, this.rows, size);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
};

TTY.prototype.mutableProperties = {
    'cols': {
        name: 'Columns',
        type: 'number',
        max: '100',
        min: '20',
        func: 'changeColSize',
    },
    'rows': {
        name: 'Rows',
        type: 'number',
        max: '10',
        min: '1',
        func: 'changeRowSize',
    },
};

/**
 * @memberof TTY
 * if no input or enable key is set to 0 returns false
 */
TTY.prototype.isResolvable = function() {
    if (this.reset.value == 1) return true;
    if (this.en.value == 0||(this.en.connections.length&&this.en.value==undefined)) return false;
    else if (this.clockInp.value == undefined) return false;
    else if (this.asciiInp.value == undefined) return false;
    return true;
};

/**
 * @memberof TTY
 * To resolve the Typewriter clock and input of 7 bits are
 * used to get the ascii and then on the edge change the
 * data is added onto the display screen of the typewriter.
 */
TTY.prototype.resolve = function () {
    if (this.reset.value == 1) {
        this.data = '';
        return;
    }
    if (this.en.value == 0) {
        this.buffer = '';
        return;
    }

    if (this.clockInp.value == this.prevClockState) {
        if (this.clockInp.value == 0) {
            this.buffer = String.fromCharCode(this.asciiInp.value);
        }
    } else if (this.clockInp.value != undefined) {
        if (this.clockInp.value == 1) {
            this.data += this.buffer;
            if (this.data.length > this.cols * this.rows) {this.data = this.data.slice(1);}
        } else if (this.clockInp.value == 0) {
            this.buffer = String.fromCharCode(this.asciiInp.value);
        }
        this.prevClockState = this.clockInp.value;
    }
};
TTY.prototype.customSave = function () {
    var data = {
        nodes: {
            clockInp: findNode(this.clockInp),
            asciiInp: findNode(this.asciiInp),
            reset: findNode(this.reset),
            en: findNode(this.en),
        },
        constructorParamaters: [this.rows, this.cols],
    };
    return data;
};
TTY.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    // rect(ctx, xx - this.elementWidth/2, yy - this.elementHeight/2, this.elementWidth, this.elementHeight);

    moveTo(ctx, -this.elementWidth / 2, this.elementHeight / 2 - 15, xx, yy, this.direction);
    lineTo(ctx, 5 - this.elementWidth / 2, this.elementHeight / 2 - 10, xx, yy, this.direction);
    lineTo(ctx, -this.elementWidth / 2, this.elementHeight / 2 - 5, xx, yy, this.direction);


    // if ((this.b.hover&&!simulationArea.shiftDown)|| simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
    //     ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    // ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    var startY = -7.5 * this.rows + 3;
    for (var i = 0; i < this.data.length; i += this.cols) {
        var lineData = this.data.slice(i, i + this.cols);
        lineData += ' '.repeat(this.cols - lineData.length);
        fillText3(ctx, lineData, 0, startY + (i / this.cols) * 15 + 9, xx, yy, fontSize = 15, font = 'Courier New', textAlign = 'center');
    }
    ctx.fill();
};

/**
 * KeyBoard - We can give 3 inputs: clock, enable and available.
 * An output of 7 bits is given out when clockInp = 1.
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function Keyboard(x, y, scope = globalScope, bufferSize = 32) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;

    this.bufferSize = bufferSize || parseInt(prompt('Enter buffer size:'));
    this.elementWidth = Math.max(80, Math.ceil(this.bufferSize / 2) * 20);
    this.elementHeight = 40; // Math.max(40,Math.ceil(this.rows*15/20)*20);
    this.setWidth(this.elementWidth / 2);
    this.setHeight(this.elementHeight / 2);

    this.clockInp = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 10, 0, this, 1, 'Clock');
    this.asciiOutput = new Node(30, this.elementHeight / 2, 1, this, 7, 'Ascii Output');
    this.available = new Node(10, this.elementHeight / 2, 1, this, 1, 'Available');
    this.reset = new Node(-10, this.elementHeight / 2, 0, this, 1, 'Reset');
    this.en = new Node(-30, this.elementHeight / 2, 0, this, 1, 'Enable');
    this.prevClockState = 0;
    this.buffer = '';
    this.bufferOutValue = undefined;
}
Keyboard.prototype = Object.create(CircuitElement.prototype);
Keyboard.prototype.constructor = Keyboard;
Keyboard.prototype.tooltipText = 'Keyboard';
Keyboard.prototype.helplink = 'https://docs.circuitverse.org/#/Sequential?id=keyboard';

/**
 * @memberof Keyboard
 * this funcion sets the size of maximum input that can
 * be given to the keyboard at once before it starts sending data.
 */
Keyboard.prototype.changeBufferSize = function (size) {
    if (size == undefined || size < 20 || size > 100) return;
    if (this.bufferSize == size) return;
    var obj = new window[this.objectType](this.x, this.y, this.scope, size);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
};
Keyboard.prototype.mutableProperties = {
    'bufferSize': {
        name: 'Buffer Size',
        type: 'number',
        max: '100',
        min: '20',
        func: 'changeBufferSize',
    },
};

/**
 * @memberof Keyboard
 * Adds the keyy pressed to the buffer
 */
Keyboard.prototype.keyDown = function (key) {
    if (key.length != 1) return;
    this.buffer += key;
    if (this.buffer.length > this.bufferSize) {this.buffer = this.buffer.slice(1);}
    // console.log(key)
};

/**
 * @memberof Keyboard
 * not resolvable if enable = 0 or clock is undefined
 */
Keyboard.prototype.isResolvable = function() {
    if (this.reset.value == 1) return true;
    if (this.en.value == 0||(this.en.connections.length&&this.en.value==undefined)) return false;
    else if (this.clockInp.value == undefined) return false;
    return true;
};

/**
 * @memberof Keyboard
 * Whenever clock is enabled (1) then one charecter
 * from the buffer is converted to ascii and transmitted 
 * through the output nodes.
 */
Keyboard.prototype.resolve = function () {
    if (this.reset.value == 1) {
        this.buffer = '';
        return;
    }
    if (this.en.value == 0) {
        return;
    }

    if (this.available.value != 0) {
        this.available.value = 0; // this.bufferOutValue;
        simulationArea.simulationQueue.add(this.available);
    }

    if (this.clockInp.value == this.prevClockState) {
        if (this.clockInp.value == 0) {
            if (this.buffer.length) {
                this.bufferOutValue = this.buffer[0].charCodeAt(0);
            } else {
                this.bufferOutValue = undefined;
            }
        }
    } else if (this.clockInp.value != undefined) {
        if (this.clockInp.value == 1 && this.buffer.length) {
            if (this.bufferOutValue == this.buffer[0].charCodeAt(0)) { // WHY IS THIS REQUIRED ??
                this.buffer = this.buffer.slice(1);
            }
        } else if (this.buffer.length) {
                this.bufferOutValue = this.buffer[0].charCodeAt(0);
            } else {
                this.bufferOutValue = undefined;
            }
        this.prevClockState = this.clockInp.value;
    }

    if (this.asciiOutput.value != this.bufferOutValue) {
        this.asciiOutput.value = this.bufferOutValue;
        simulationArea.simulationQueue.add(this.asciiOutput);
    }

    if (this.bufferOutValue !== undefined && this.available.value != 1) {
        this.available.value = 1; // this.bufferOutValue;
        simulationArea.simulationQueue.add(this.available);
    }
};
Keyboard.prototype.customSave = function () {
    var data = {
        nodes: {
            clockInp: findNode(this.clockInp),
            asciiOutput: findNode(this.asciiOutput),
            available: findNode(this.available),
            reset: findNode(this.reset),
            en: findNode(this.en),
        },
        constructorParamaters: [this.bufferSize],
    };
    return data;
};
Keyboard.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    moveTo(ctx, -this.elementWidth / 2, this.elementHeight / 2 - 15, xx, yy, this.direction);
    lineTo(ctx, 5 - this.elementWidth / 2, this.elementHeight / 2 - 10, xx, yy, this.direction);
    lineTo(ctx, -this.elementWidth / 2, this.elementHeight / 2 - 5, xx, yy, this.direction);

    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = 'green';
    ctx.textAlign = 'center';
    var lineData = this.buffer + ' '.repeat(this.bufferSize - this.buffer.length);
    fillText3(ctx, lineData, 0, +5, xx, yy, fontSize = 15, font = 'Courier New', textAlign = 'center');
    ctx.fill();
};

/**
 * Clock
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn
 */
function Clock(x, y, scope = globalScope, dir = 'RIGHT') {
    CircuitElement.call(this, x, y, scope, dir, 1);
    this.fixedBitWidth = true;
    this.output1 = new Node(10, 0, 1, this, 1);
    this.state = 0;
    this.output1.value = this.state;
    this.wasClicked = false;
    this.interval = null;
}

Clock.prototype = Object.create(CircuitElement.prototype);
Clock.prototype.constructor = Clock;
Clock.prototype.tooltipText = 'Clock';
Clock.prototype.customSave = function () {
    var data = {
        nodes: {
            output1: findNode(this.output1),
        },
        constructorParamaters: [this.direction],
    };
    return data;
};

Clock.prototype.resolve = function () {
    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);
};

Clock.prototype.toggleState = function () { // toggleState
    this.state = (this.state + 1) % 2;
    this.output1.value = this.state;
};

Clock.prototype.click = Clock.prototype.toggleState;
Clock.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.strokeStyle = ('rgba(0,0,0,1)');
    ctx.fillStyle = 'white';
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    ctx.strokeStyle = ['DarkGreen', 'Lime'][this.state];
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
};
