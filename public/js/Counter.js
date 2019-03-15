/**
 * Counter component.
 * 
 * Counts from zero to a particular maximum value, which is either
 * specified by an input pin or determined by the Counter's bitWidth.
 * 
 * The counter outputs its current value and a flag that indicates
 * when the output value is zero and the clock is 1.
 * 
 * The counter can be reset to zero at any point using the RESET pin.
 */
function Counter(x, y, scope = globalScope, bitWidth = 8) {
    CircuitElement.call(this, x, y, scope, "RIGHT", bitWidth);
    this.directionFixed = true;
    this.rectangleObject = true;

    this.setDimensions(20, 20);

    this.maxValue = new Node(-20, -10, 0, this, this.bitWidth, "MaxValue");
    this.clock = new Node(-20, +10, 0, this, 1, "Clock");
    this.reset = new Node(0, 20, 0, this, 1, "Reset");
    this.output = new Node(20, -10, 1, this, this.bitWidth, "Value");
    this.zero = new Node(20, 10, 1, this, 1, "Zero");

    this.value = 0;
    this.prevClockState = undefined;
}
Counter.prototype = Object.create(CircuitElement.prototype);
Counter.prototype.constructor = Counter;
Counter.prototype.tooltipText = "Counter: a binary counter from zero to a given maximum value";
Counter.prototype.customSave = function () {
    return {
        nodes: {
            maxValue: findNode(this.maxValue),
            clock: findNode(this.clock),
            reset: findNode(this.reset),
            output: findNode(this.output),
            zero: findNode(this.zero),
        },
        constructorParamaters: [this.bitWidth]
    };
}
Counter.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.maxValue.bitWidth = bitWidth;
    this.output.bitWidth = bitWidth;
};
Counter.prototype.isResolvable = function () {
    return true;
}
Counter.prototype.resolve = function () {
    // Max value is either the value in the input pin or the max allowed by the bitWidth.
    var maxValue = this.maxValue.value != undefined ? this.maxValue.value : (1 << this.bitWidth) - 1;
    var outputValue = this.value;

    // Increase value when clock is raised
    if (this.clock.value != this.prevClockState && this.clock.value == 1) {
        outputValue++;
    }
    this.prevClockState = this.clock.value;

    // Limit to the effective maximum value; this also accounts for bitWidth changes.
    outputValue = outputValue % (maxValue + 1);

    // Reset to zero if RESET pin is on
    if (this.reset.value == 1) {
        outputValue = 0;
    }

    // Output the new value
    this.value = outputValue;
    if (this.output.value != outputValue) {
        this.output.value = outputValue;
        simulationArea.simulationQueue.add(this.output);
    }

    // Output the zero signal
    var zeroValue = this.clock.value == 1 && outputValue == 0 ? 1 : 0;
    if (this.zero.value != zeroValue) {
        this.zero.value = zeroValue;
        simulationArea.simulationQueue.add(this.zero);
    }
}
Counter.prototype.customDraw = function () {
    var ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    ctx.font = "20px Georgia";
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    fillText(ctx, this.value.toString(16), this.x, this.y + 5);
    ctx.fill();

    ctx.beginPath();
    moveTo(ctx, -20, 5, xx, yy, this.direction);
    lineTo(ctx, -15, 10, xx, yy, this.direction);
    lineTo(ctx, -20, 15, xx, yy, this.direction);
    ctx.stroke();
}