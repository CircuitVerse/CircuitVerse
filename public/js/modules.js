//AndGate - (x,y)-position , scope - circuit level, inputLength - no of nodes, dir - direction of gate

function changeInputSize(size) {
    if (size == undefined || size < 2 || size > 10) return;
    if (this.inputSize == size) return;
    size = parseInt(size, 10)
    var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, size, this.bitWidth);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
    // showProperties(obj);

}

function AndGate(x, y, scope = globalScope, dir = "RIGHT", inputLength = 2, bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);
    this.inp = [];

    this.inputSize = inputLength;


    //variable inputLength , node creation
    if (inputLength % 2 == 1) {
        for (var i = 0; i < inputLength / 2 - 1; i++) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        var a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (var i = inputLength / 2 + 1; i < inputLength; i++) {
            var a = new Node(-10, 10 * (i + 1 - inputLength / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (var i = 0; i < inputLength / 2; i++) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (var i = inputLength / 2; i < inputLength; i++) {
            var a = new Node(-10, 10 * (i + 1 - inputLength / 2), 0, this);
            this.inp.push(a);
        }
    }

    this.output1 = new Node(20, 0, 1, this);


}

AndGate.prototype = Object.create(CircuitElement.prototype);
AndGate.prototype.constructor = AndGate;
AndGate.prototype.alwaysResolve = true;
AndGate.prototype.verilogType = "and";

AndGate.prototype.changeInputSize = changeInputSize;
//fn to create save Json Data of object
AndGate.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1)
        },

    }
    return data;
}

//resolve output values based on inputData
AndGate.prototype.resolve = function () {
    var result = this.inp[0].value || 0;
    if (this.isResolvable() == false) {
        return;
    }
    for (var i = 1; i < this.inputSize; i++)
        result = result & ((this.inp[i].value) || 0);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
}

//fn to draw
AndGate.prototype.customDraw = function () {

    ctx = simulationArea.context;

    ctx.beginPath();
    ctx.lineWidth = correctWidth(3);
    ctx.strokeStyle = "black"; //("rgba(0,0,0,1)");
    ctx.fillStyle = "white";
    var xx = this.x;
    var yy = this.y;

    moveTo(ctx, -10, -20, xx, yy, this.direction);
    lineTo(ctx, 0, -20, xx, yy, this.direction);
    arc(ctx, 0, 0, 20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -10, 20, xx, yy, this.direction);
    lineTo(ctx, -10, -20, xx, yy, this.direction);
    ctx.closePath();

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

}

function NandGate(x, y, scope = globalScope, dir = "RIGHT", inputLength = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);
    this.inp = [];


    this.inputSize = inputLength;


    //variable inputLength , node creation
    if (inputLength % 2 == 1) {
        for (var i = 0; i < inputLength / 2 - 1; i++) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        var a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (var i = inputLength / 2 + 1; i < inputLength; i++) {
            var a = new Node(-10, 10 * (i + 1 - inputLength / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (var i = 0; i < inputLength / 2; i++) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (var i = inputLength / 2; i < inputLength; i++) {
            var a = new Node(-10, 10 * (i + 1 - inputLength / 2), 0, this);
            this.inp.push(a);
        }
    }

    this.output1 = new Node(30, 0, 1, this);


}
NandGate.prototype = Object.create(CircuitElement.prototype);
NandGate.prototype.constructor = NandGate;
NandGate.prototype.alwaysResolve = true;
NandGate.prototype.changeInputSize = changeInputSize;
NandGate.prototype.verilogType = "nand";
//fn to create save Json Data of object
NandGate.prototype.customSave = function () {
    var data = {

        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1)
        },
    }
    return data;
}
//resolve output values based on inputData
NandGate.prototype.resolve = function () {
    var result = this.inp[0].value || 0;
    if (this.isResolvable() == false) {
        return;
    }
    for (var i = 1; i < this.inputSize; i++)
        result = result & (this.inp[i].value || 0);
    result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
}
//fn to draw
NandGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.lineWidth = correctWidth(3);
    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    var xx = this.x;
    var yy = this.y;

    moveTo(ctx, -10, -20, xx, yy, this.direction);
    lineTo(ctx, 0, -20, xx, yy, this.direction);
    arc(ctx, 0, 0, 20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -10, 20, xx, yy, this.direction);
    lineTo(ctx, -10, -20, xx, yy, this.direction);
    ctx.closePath();

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.5)";
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();


}


function Multiplexer(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1, controlSignalSize = 1) {
    // //console.log("HIT");
    // //console.log(x,y,scope,dir,bitWidth,controlSignalSize);
    CircuitElement.call(this, x, y, scope, dir, bitWidth);

    this.controlSignalSize = controlSignalSize || parseInt(prompt("Enter control signal bitWidth"), 10);
    this.inputSize = 1 << this.controlSignalSize;
    this.xOff = 0;
    this.yOff = 1;
    if (this.controlSignalSize == 1) {
        this.xOff = 10;
    }
    if (this.controlSignalSize <= 3) {
        this.yOff = 2;
    }

    this.setDimensions(20 - this.xOff, this.yOff * 5 * (this.inputSize));
    this.rectangleObject = false;

    this.inp = [];
    for (var i = 0; i < this.inputSize; i++) {
        var a = new Node(-20 + this.xOff, +this.yOff * 10 * (i - this.inputSize / 2) + 10, 0, this);
        this.inp.push(a);
    }

    this.output1 = new Node(20 - this.xOff, 0, 1, this);
    this.controlSignalInput = new Node(0, this.yOff * 10 * (this.inputSize / 2 - 1) + this.xOff + 10, 0, this, this.controlSignalSize, "Control Signal");



}
Multiplexer.prototype = Object.create(CircuitElement.prototype);
Multiplexer.prototype.constructor = Multiplexer;
Multiplexer.prototype.changeControlSignalSize = function (size) {
    if (size == undefined || size < 1 || size > 32) return;
    if (this.controlSignalSize == size) return;
    var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth, size);
    this.cleanDelete();
    simulationArea.lastSelected = obj;
    return obj;
}
Multiplexer.prototype.mutableProperties = {
    "controlSignalSize": {
        name: "Control Signal Size",
        type: "number",
        max: "32",
        min: "1",
        func: "changeControlSignalSize",
    },
}
Multiplexer.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    for (var i = 0; i < this.inputSize; i++) {
        this.inp[i].bitWidth = bitWidth
    }
    this.output1.bitWidth = bitWidth;
}


//fn to create save Json Data of object
Multiplexer.prototype.isResolvable = function () {
    if (this.controlSignalInput.value != undefined && this.inp[this.controlSignalInput.value].value != undefined) return true;
    return false;
}
Multiplexer.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth, this.controlSignalSize],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
            controlSignalInput: findNode(this.controlSignalInput)
        },
    }
    return data;
}
Multiplexer.prototype.resolve = function () {

    if (this.isResolvable() == false) {
        return;
    }
    this.output1.value = this.inp[this.controlSignalInput.value].value;
    simulationArea.simulationQueue.add(this.output1);
}
Multiplexer.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    moveTo(ctx, 0, this.yOff * 10 * (this.inputSize / 2 - 1) + 10 + 0.5 * this.xOff, xx, yy, this.direction);
    lineTo(ctx, 0, this.yOff * 5 * (this.inputSize - 1) + this.xOff, xx, yy, this.direction);
    ctx.stroke();

    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");

    ctx.fillStyle = "white";
    moveTo(ctx, -20 + this.xOff, -this.yOff * 10 * (this.inputSize / 2), xx, yy, this.direction);
    lineTo(ctx, -20 + this.xOff, 20 + this.yOff * 10 * (this.inputSize / 2 - 1), xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, +this.yOff * 10 * (this.inputSize / 2 - 1) + this.xOff, xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, -this.yOff * 10 * (this.inputSize / 2) - this.xOff + 20, xx, yy, this.direction);

    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();



    ctx.beginPath();
    // ctx.lineWidth = correctWidth(2);
    ctx.fillStyle = "black";
    ctx.textAlign = "center";
    for (var i = 0; i < this.inputSize; i++) {

        if (this.direction == "RIGHT") fillText(ctx, String(i), xx + this.inp[i].x + 7, yy + this.inp[i].y + 2, 10);
        else if (this.direction == "LEFT") fillText(ctx, String(i), xx + this.inp[i].x - 7, yy + this.inp[i].y + 2, 10);
        else if (this.direction == "UP") fillText(ctx, String(i), xx + this.inp[i].x, yy + this.inp[i].y - 4, 10);
        else fillText(ctx, String(i), xx + this.inp[i].x, yy + this.inp[i].y + 10, 10);
    }
    ctx.fill();
}

function XorGate(x, y, scope = globalScope, dir = "RIGHT", inputs = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);

    this.inp = [];
    this.inputSize = inputs;

    if (inputs % 2 == 1) {
        for (var i = 0; i < inputs / 2 - 1; i++) {
            var a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        var a = new Node(-20, 0, 0, this);
        this.inp.push(a);
        for (var i = inputs / 2 + 1; i < inputs; i++) {
            var a = new Node(-20, 10 * (i + 1 - inputs / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (var i = 0; i < inputs / 2; i++) {
            var a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (var i = inputs / 2; i < inputs; i++) {
            var a = new Node(-20, 10 * (i + 1 - inputs / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(20, 0, 1, this);

}

XorGate.prototype = Object.create(CircuitElement.prototype);
XorGate.prototype.constructor = XorGate;
XorGate.prototype.alwaysResolve = true;

XorGate.prototype.changeInputSize = changeInputSize;
XorGate.prototype.verilogType = "xor";
XorGate.prototype.customSave = function () {
    // //console.log(this.scope.allNodes);
    var data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1)
        },
    }
    return data;
}
XorGate.prototype.resolve = function () {
    var result = this.inp[0].value || 0;
    if (this.isResolvable() == false) {
        return;
    }
    for (var i = 1; i < this.inputSize; i++)
        result = result ^ (this.inp[i].value || 0);

    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
}
XorGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";
    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    // arc(ctx, 0, 0, -20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    arc2(ctx, -35, 0, 25, 1.70 * (Math.PI), 0.30 * (Math.PI), xx, yy, this.direction);
    ctx.stroke();


}

function XnorGate(x, y, scope = globalScope, dir = "RIGHT", inputs = 2, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);

    this.inp = [];
    this.inputSize = inputs;

    if (inputs % 2 == 1) {
        for (var i = 0; i < inputs / 2 - 1; i++) {
            var a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        var a = new Node(-20, 0, 0, this);
        this.inp.push(a);
        for (var i = inputs / 2 + 1; i < inputs; i++) {
            var a = new Node(-20, 10 * (i + 1 - inputs / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (var i = 0; i < inputs / 2; i++) {
            var a = new Node(-20, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (var i = inputs / 2; i < inputs; i++) {
            var a = new Node(-20, 10 * (i + 1 - inputs / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(30, 0, 1, this);

}

XnorGate.prototype = Object.create(CircuitElement.prototype);
XnorGate.prototype.constructor = XnorGate;
XnorGate.prototype.alwaysResolve = true;

XnorGate.prototype.changeInputSize = changeInputSize;
XnorGate.prototype.verilogType = "xnor";
XnorGate.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1)
        },
    }
    return data;
}
XnorGate.prototype.resolve = function () {
    var result = this.inp[0].value || 0;
    if (this.isResolvable() == false) {
        return;
    }
    for (var i = 1; i < this.inputSize; i++)
        result = result ^ (this.inp[i].value || 0);
    result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
}
XnorGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";
    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    // arc(ctx, 0, 0, -20, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    arc2(ctx, -35, 0, 25, 1.70 * (Math.PI), 0.30 * (Math.PI), xx, yy, this.direction);
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();

}


function SevenSegDisplay(x, y, scope = globalScope) {
    CircuitElement.call(this, x, y, scope, "RIGHT", 1);
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
    this.direction = "RIGHT";


}
SevenSegDisplay.prototype = Object.create(CircuitElement.prototype);
SevenSegDisplay.prototype.constructor = SevenSegDisplay;
SevenSegDisplay.prototype.tooltipText = "Seven Display ToolTip: Consists of 7+1 single bit inputs."
SevenSegDisplay.prototype.customSave = function () {
    var data = {

        nodes: {
            g: findNode(this.g),
            f: findNode(this.f),
            a: findNode(this.a),
            b: findNode(this.b),
            d: findNode(this.d),
            e: findNode(this.e),
            c: findNode(this.c),
            d: findNode(this.d),
            dot: findNode(this.dot)
        },
    }
    return data;
}
SevenSegDisplay.prototype.customDrawSegment = function (x1, y1, x2, y2, color) {
    if (color == undefined) color = "lightgrey";
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
}

SevenSegDisplay.prototype.customDraw = function () {
    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    this.customDrawSegment(18, -3, 18, -38, ["lightgrey", "red"][this.b.value]);
    this.customDrawSegment(18, 3, 18, 38, ["lightgrey", "red"][this.c.value]);
    this.customDrawSegment(-18, -3, -18, -38, ["lightgrey", "red"][this.f.value]);
    this.customDrawSegment(-18, 3, -18, 38, ["lightgrey", "red"][this.e.value]);
    this.customDrawSegment(-17, -38, 17, -38, ["lightgrey", "red"][this.a.value]);
    this.customDrawSegment(-17, 0, 17, 0, ["lightgrey", "red"][this.g.value]);
    this.customDrawSegment(-15, 38, 17, 38, ["lightgrey", "red"][this.d.value]);

    ctx.beginPath();
    var dotColor = ["lightgrey", "red"][this.dot.value] || "lightgrey"
    ctx.strokeStyle = dotColor;
    rect(ctx, xx + 22, yy + 42, 2, 2);
    ctx.stroke();
}

function SixteenSegDisplay(x, y, scope = globalScope) {
    CircuitElement.call(this, x, y, scope, "RIGHT", 16);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.setDimensions(30, 50);

    this.input1 = new Node(0, -50, 0, this, 16);
    this.dot = new Node(0, 50, 0, this, 1);
    this.direction = "RIGHT";
}

SixteenSegDisplay.prototype = Object.create(CircuitElement.prototype);
SixteenSegDisplay.prototype.constructor = SixteenSegDisplay;
SixteenSegDisplay.prototype.tooltipText = "Sixteen Display ToolTip: Consists of 16+1 bit inputs.";
SixteenSegDisplay.prototype.customSave = function () {
    var data = {
        nodes: {
            input1: findNode(this.input1),
            dot: findNode(this.dot)
        }
    }
    return data;
}

SixteenSegDisplay.prototype.customDrawSegment = function (x1, y1, x2, y2, color) {
    if (color == undefined) color = "lightgrey";
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
}

SixteenSegDisplay.prototype.customDrawSegmentSlant = function (x1, y1, x2, y2, color) {
    if (color == undefined) color = "lightgrey";
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
}

SixteenSegDisplay.prototype.customDraw = function () {
    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    var color = ["lightgrey", "red"];
    var value = this.input1.value;

    this.customDrawSegment(-20, -38, 0, -38, ["lightgrey", "red"][(value >> 15) & 1]);		//a1
    this.customDrawSegment(20, -38, 0, -38, ["lightgrey", "red"][(value >> 14) & 1]);		//a2
    this.customDrawSegment(21.5, -2, 21.5, -36, ["lightgrey", "red"][(value >> 13) & 1]);	//b
    this.customDrawSegment(21.5, 2, 21.5, 36, ["lightgrey", "red"][(value >> 12) & 1]);		//c
    this.customDrawSegment(-20, 38, 0, 38, ["lightgrey", "red"][(value >> 11) & 1]);		//d1
    this.customDrawSegment(20, 38, 0, 38, ["lightgrey", "red"][(value >> 10) & 1]);			//d2
    this.customDrawSegment(-21.5, 2, -21.5, 36, ["lightgrey", "red"][(value >> 9) & 1]);	//e
    this.customDrawSegment(-21.5, -36, -21.5, -2, ["lightgrey", "red"][(value >> 8) & 1]);	//f
    this.customDrawSegment(-20, 0, 0, 0, ["lightgrey", "red"][(value >> 7) & 1]);			//g1
    this.customDrawSegment(20, 0, 0, 0, ["lightgrey", "red"][(value >> 6) & 1]);			//g2
    this.customDrawSegmentSlant(0, 0, -21, -37, ["lightgrey", "red"][(value >> 5) & 1]);	//h
    this.customDrawSegment(0, -2, 0, -36, ["lightgrey", "red"][(value >> 4) & 1]);			//i
    this.customDrawSegmentSlant(0, 0, 21, -37, ["lightgrey", "red"][(value >> 3) & 1]);		//j
    this.customDrawSegmentSlant(0, 0, 21, 37, ["lightgrey", "red"][(value >> 2) & 1]);		//k
    this.customDrawSegment(0, 2, 0, 36, ["lightgrey", "red"][(value >> 1) & 1]);			//l
    this.customDrawSegmentSlant(0, 0, -21, 37, ["lightgrey", "red"][(value >> 0) & 1]);		//m

    ctx.beginPath();
    var dotColor = ["lightgrey", "red"][this.dot.value] || "lightgrey"
    ctx.strokeStyle = dotColor;
    rect(ctx, xx + 22, yy + 42, 2, 2);
    ctx.stroke();
}

function HexDisplay(x, y, scope = globalScope) {
    CircuitElement.call(this, x, y, scope, "RIGHT", 4);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.setDimensions(30, 50);

    this.inp = new Node(0, -50, 0, this, 4);
    this.direction = "RIGHT";
}

HexDisplay.prototype = Object.create(CircuitElement.prototype);
HexDisplay.prototype.constructor = HexDisplay;
HexDisplay.prototype.tooltipText = "Hex Display ToolTip: Inputs a 4 Bit Hex number and displays it."
HexDisplay.prototype.customSave = function () {
    var data = {


        nodes: {
            inp: findNode(this.inp)
        }

    }
    return data;
}
HexDisplay.prototype.customDrawSegment = function (x1, y1, x2, y2, color) {
    if (color == undefined) color = "lightgrey";
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
}
HexDisplay.prototype.customDraw = function () {
    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.strokeStyle = "black";
    ctx.lineWidth = correctWidth(3);
    var a = b = c = d = e = f = g = 0;
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
    this.customDrawSegment(18, -3, 18, -38, ["lightgrey", "red"][b]);
    this.customDrawSegment(18, 3, 18, 38, ["lightgrey", "red"][c]);
    this.customDrawSegment(-18, -3, -18, -38, ["lightgrey", "red"][f]);
    this.customDrawSegment(-18, 3, -18, 38, ["lightgrey", "red"][e]);
    this.customDrawSegment(-17, -38, 17, -38, ["lightgrey", "red"][a]);
    this.customDrawSegment(-17, 0, 17, 0, ["lightgrey", "red"][g]);
    this.customDrawSegment(-15, 38, 17, 38, ["lightgrey", "red"][d]);

}

function OrGate(x, y, scope = globalScope, dir = "RIGHT", inputs = 2, bitWidth = 1) {
    // Calling base class constructor
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);
    // Inherit base class prototype

    this.inp = [];
    this.inputSize = inputs;


    if (inputs % 2 == 1) {
        // for (var i = 0; i < inputs / 2 - 1; i++) {
        //     var a = new Node(-10, -10 * (i + 1), 0, this);
        //     this.inp.push(a);
        // }
        // var a = new Node(-10, 0, 0, this);
        // this.inp.push(a);
        // for (var i = inputs / 2 + 1; i < inputs; i++) {
        //     var a = new Node(-10, 10 * (i + 1 - inputs / 2 - 1), 0, this);
        //     this.inp.push(a);
        // }
        for (var i = Math.floor(inputs / 2) - 1; i >= 0; i--) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        var a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (var i = 0; i < Math.floor(inputs / 2); i++) {
            var a = new Node(-10, 10 * (i + 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (var i = inputs / 2 - 1; i >= 0; i--) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (var i = 0; i < inputs / 2; i++) {
            var a = new Node(-10, 10 * (i + 1), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(20, 0, 1, this);



}
OrGate.prototype = Object.create(CircuitElement.prototype);
OrGate.prototype.constructor = OrGate;
OrGate.prototype.changeInputSize = changeInputSize;
OrGate.prototype.alwaysResolve = true;
OrGate.prototype.verilogType = "or";
OrGate.prototype.customSave = function () {
    var data = {

        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],

        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1),
        },
    }
    return data;
}
OrGate.prototype.resolve = function () {
    var result = this.inp[0].value || 0;
    if (this.isResolvable() == false) {
        return;
    }
    for (var i = 1; i < this.inputSize; i++)
        result = result | (this.inp[i].value || 0);
    this.output1.value = result;
    simulationArea.simulationQueue.add(this.output1);
}
OrGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";

    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();



}

function Stepper(x, y, scope = globalScope, dir = "RIGHT") {

    CircuitElement.call(this, x, y, scope, dir, 8);
    this.setDimensions(20, 20);

    this.output1 = new Node(20, 0, 1, this, 8);
    this.state = 0;

}
Stepper.prototype = Object.create(CircuitElement.prototype);
Stepper.prototype.constructor = Stepper;
Stepper.prototype.tooltipText = "Stepper ToolTip: Increase/Decrease value by selecting the stepper and using +/- keys."
Stepper.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction],
        nodes: {
            output1: findNode(this.output1),
        },
        values: {
            state: this.state
        }
    }
    return data;
}
Stepper.prototype.customDraw = function () {
    ctx = simulationArea.context;

    ctx.beginPath();
    ctx.font = "20px Georgia";
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    fillText(ctx, this.state.toString(16), this.x, this.y + 5);
    ctx.fill();;
}
Stepper.prototype.resolve = function () {
    this.state = Math.min(this.state, (1 << this.bitWidth) - 1);
    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);
}
Stepper.prototype.keyDown2 = function (key) {
    //console.log(key);
    if (this.state < (1 << this.bitWidth) && (key == "+" || key == "=")) this.state++;
    if (this.state > 0 && (key == "_" || key == "-")) this.state--;
}

function NotGate(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.inp1 = new Node(-10, 0, 0, this);
    this.output1 = new Node(20, 0, 1, this);


}
NotGate.prototype = Object.create(CircuitElement.prototype);
NotGate.prototype.constructor = NotGate;
NotGate.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1)
        },
    }
    return data;
}
NotGate.prototype.resolve = function () {
    if (this.isResolvable() == false) {
        return;
    }
    this.output1.value = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    simulationArea.simulationQueue.add(this.output1);
}
NotGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = "black";
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";
    moveTo(ctx, -10, -10, xx, yy, this.direction);
    lineTo(ctx, 10, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 10, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 15, 0, 5, xx, yy, this.direction);
    ctx.stroke();

}


function ForceGate(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 10);

    this.inp1 = new Node(-20, 0, 0, this);
    this.inp2 = new Node(0, 0, 0, this);
    this.output1 = new Node(20, 0, 1, this);


}
ForceGate.prototype = Object.create(CircuitElement.prototype);
ForceGate.prototype.constructor = ForceGate;
ForceGate.prototype.isResolvable = function () {
    return (this.inp1.value != undefined || this.inp2.value != undefined)
}
ForceGate.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2)
        },
    }
    return data;
}
ForceGate.prototype.resolve = function () {
    if (this.inp2.value != undefined)
        this.output1.value = this.inp2.value;
    else
        this.output1.value = this.inp1.value;
    simulationArea.simulationQueue.add(this.output1);
}
ForceGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;



    ctx.beginPath();
    ctx.fillStyle = "Black";
    ctx.textAlign = "center"

    fillText4(ctx, "I", -10, 0, xx, yy, this.direction, 10);
    fillText4(ctx, "O", 10, 0, xx, yy, this.direction, 10);
    ctx.fill();

}


function Text(x, y, scope = globalScope, label = "") {

    CircuitElement.call(this, x, y, scope, "RIGHT", 1);
    // this.setDimensions(15, 15);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.labelDirectionFixed = true;
    this.setHeight(10);
    this.setLabel(label);



}
Text.prototype = Object.create(CircuitElement.prototype);
Text.prototype.constructor = Text;
Text.prototype.tooltipText = "Text ToolTip: Use this to document your circuit."
Text.prototype.setLabel = function (str = "") {

    this.label = str;
    ctx = simulationArea.context;
    ctx.font = 14 + "px Georgia";
    this.leftDimensionX = 10;
    this.rightDimensionX = ctx.measureText(this.label).width + 10;
    //console.log(this.leftDimensionX,this.rightDimensionX,ctx.measureText(this.label))
}
Text.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.label],
    }
    return data;
}
Text.prototype.keyDown = function (key) {


    if (key.length == 1) {
        if (this.label == "Enter Text Here")
            this.setLabel(key)
        else
            this.setLabel(this.label + key);
    } else if (key == "Backspace") {
        if (this.label == "Enter Text Here")
            this.setLabel("")
        else
            this.setLabel(this.label.slice(0, -1));
    }
}
Text.prototype.draw = function () {

    if (this.label.length == 0 && simulationArea.lastSelected != this) this.delete();

    ctx = simulationArea.context;
    ctx.strokeStyle = "black";
    ctx.lineWidth = 1;



    var xx = this.x;
    var yy = this.y;

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) {
        ctx.beginPath();
        ctx.fillStyle = "white";
        rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, "RIGHT");
        ctx.fillStyle = "rgba(255, 255, 32,0.1)";
        ctx.fill();
        ctx.stroke();
    }
    ctx.beginPath();
    ctx.textAlign = "left";
    ctx.fillStyle = "black"
    fillText(ctx, this.label, xx, yy + 5, 14);
    ctx.fill();

}

function TriState(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.inp1 = new Node(-10, 0, 0, this);
    this.output1 = new Node(20, 0, 1, this);
    this.state = new Node(0, 0, 0, this, 1, "Enable");


}
TriState.prototype = Object.create(CircuitElement.prototype);
TriState.prototype.constructor = TriState;
// TriState.prototype.propagationDelay=10000;
TriState.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            state: findNode(this.state),
        },
    }
    return data;
}
// TriState.prototype.isResolvable = function(){
// 	return this.inp1.value!=undefined
// }
TriState.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
}
TriState.prototype.resolve = function () {
    if (this.isResolvable() == false) {
        return;
    }

    if (this.state.value == 1) {
        if (this.output1.value != this.inp1.value) {
            this.output1.value = this.inp1.value; //>>>0)<<(32-this.bitWidth))>>>(32-this.bitWidth);
            simulationArea.simulationQueue.add(this.output1);
        }
        simulationArea.contentionPending.clean(this);
    } else {
        if (this.output1.value != undefined && !simulationArea.contentionPending.contains(this)) {
            this.output1.value = undefined;
            simulationArea.simulationQueue.add(this.output1);
        }

    }
    simulationArea.contentionPending.clean(this);
}
TriState.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";
    moveTo(ctx, -10, -15, xx, yy, this.direction);
    lineTo(ctx, 20, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 15, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

}

function Buffer(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.state = 0;
    this.preState = 0;
    this.inp1 = new Node(-10, 0, 0, this);
    this.reset = new Node(0, 0, 0, this, 1, "reset");
    this.output1 = new Node(20, 0, 1, this);


}
Buffer.prototype = Object.create(CircuitElement.prototype);
Buffer.prototype.constructor = Buffer;
Buffer.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            reset: findNode(this.reset),
        },
    }
    return data;
}
Buffer.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
}
Buffer.prototype.isResolvable = function () {
    return true;
}
Buffer.prototype.resolve = function () {

    if (this.reset.value == 1) {
        this.state = this.preState;
    }
    if (this.inp1.value !== undefined)
        this.state = this.inp1.value;

    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);

}
Buffer.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(200,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";
    moveTo(ctx, -10, -15, xx, yy, this.direction);
    lineTo(ctx, 20, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 15, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

}

function ControlledInverter(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 15);

    this.inp1 = new Node(-10, 0, 0, this);
    this.output1 = new Node(30, 0, 1, this);
    this.state = new Node(0, 0, 0, this, 1, "Enable");


}
ControlledInverter.prototype = Object.create(CircuitElement.prototype);
ControlledInverter.prototype.constructor = ControlledInverter;
ControlledInverter.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: findNode(this.output1),
            inp1: findNode(this.inp1),
            state: findNode(this.state)
        },
    }
    return data;
}
ControlledInverter.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
}
ControlledInverter.prototype.resolve = function () {
    if (this.isResolvable() == false) {
        return;
    }
    if (this.state.value == 1) {
        this.output1.value = ((~this.inp1.value >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output1);
    }
    if (this.state.value == 0) {
        this.output1.value = undefined;
    }
}
ControlledInverter.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";
    moveTo(ctx, -10, -15, xx, yy, this.direction);
    lineTo(ctx, 20, 0, xx, yy, this.direction);
    lineTo(ctx, -10, 15, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();

}

function Adder(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 20);

    this.inpA = new Node(-20, -10, 0, this, this.bitWidth, "A");
    this.inpB = new Node(-20, 0, 0, this, this.bitWidth, "B");
    this.carryIn = new Node(-20, 10, 0, this, 1, "Cin");
    this.sum = new Node(20, 0, 1, this, this.bitWidth, "Sum");
    this.carryOut = new Node(20, 10, 1, this, 1, "Cout");



}
Adder.prototype = Object.create(CircuitElement.prototype);
Adder.prototype.constructor = Adder;
Adder.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            inpA: findNode(this.inpA),
            inpB: findNode(this.inpB),
            carryIn: findNode(this.carryIn),
            carryOut: findNode(this.carryOut),
            sum: findNode(this.sum)
        },
    }
    return data;
}
Adder.prototype.isResolvable = function () {
    return this.inpA.value != undefined && this.inpB.value != undefined;
}
Adder.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.inpA.bitWidth = bitWidth;
    this.inpB.bitWidth = bitWidth;
    this.sum.bitWidth = bitWidth;
}
Adder.prototype.resolve = function () {
    if (this.isResolvable() == false) {
        return;
    }
    var carryIn = this.carryIn.value;
    if (carryIn == undefined) carryIn = 0;
    var sum = this.inpA.value + this.inpB.value + carryIn;

    this.sum.value = ((sum) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.carryOut.value = +((sum >>> (this.bitWidth)) !== 0);
    simulationArea.simulationQueue.add(this.carryOut);
    simulationArea.simulationQueue.add(this.sum);
}

function Rom(x, y, scope = globalScope, data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) {

    CircuitElement.call(this, x, y, scope, "RIGHT", 1);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.rectangleObject = false;
    this.setDimensions(80, 50);

    this.memAddr = new Node(-80, 0, 0, this, 4, "Address");
    this.en = new Node(0, 50, 0, this, 1, "Enable");
    this.dataOut = new Node(80, 0, 1, this, 8, "DataOut");
    this.data = data || prompt("Enter data").split(' ').map(function (x) {
        return parseInt(x, 16);
    });
    //console.log(this.data);



}
Rom.prototype = Object.create(CircuitElement.prototype);
Rom.prototype.constructor = Rom;
Rom.prototype.isResolvable = function () {
    if ((this.en.value == 1 || this.en.connections.length == 0) && this.memAddr.value != undefined) return true;
    return false;
}
Rom.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.data],
        nodes: {
            memAddr: findNode(this.memAddr),
            dataOut: findNode(this.dataOut),
            en: findNode(this.en),
        },

    }
    return data;
}
Rom.prototype.findPos = function () {
    var i = Math.floor((simulationArea.mouseX - this.x + 35) / 20)
    var j = Math.floor((simulationArea.mouseY - this.y + 35) / 16);
    if (i < 0 || j < 0 || i > 3 || j > 3) return undefined;
    return j * 4 + i;
}
Rom.prototype.click = function () { // toggle
    this.selectedIndex = this.findPos();
}
Rom.prototype.keyDown = function (key) {
    if (key == "Backspace") this.delete();
    if (this.selectedIndex == undefined) return;
    key = key.toLowerCase();
    if (!~"1234567890abcdef".indexOf(key)) return;
    else {
        this.data[this.selectedIndex] = (this.data[this.selectedIndex] * 16 + parseInt(key, 16)) % 256;
    }
}
Rom.prototype.customDraw = function () {




    var ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;

    var hoverIndex = this.findPos();




    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, [this.direction, "RIGHT"][+this.directionFixed]);
    if (hoverIndex == undefined && ((!simulationArea.shiftDown && this.hover) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();
    // if (this.hover)
    //     ////console.log(this);

    ctx.strokeStyle = "black";
    ctx.fillStyle = "#fafafa";
    ctx.lineWidth = correctWidth(1);
    ctx.beginPath();

    for (var i = 0; i < 16; i += 4) {
        for (var j = i; j < i + 4; j++) {
            rect2(ctx, (j % 4) * 20, i * 4, 20, 16, xx - 35, yy - 35);
        }
    }
    ctx.fill();
    ctx.stroke();

    if (hoverIndex != undefined) {
        ctx.beginPath();
        ctx.fillStyle = "yellow";
        rect2(ctx, (hoverIndex % 4) * 20, Math.floor(hoverIndex / 4) * 16, 20, 16, xx - 35, yy - 35);
        ctx.fill();
        ctx.stroke();
    }
    if (this.selectedIndex != undefined) {
        ctx.beginPath();
        ctx.fillStyle = "lightgreen";
        rect2(ctx, (this.selectedIndex % 4) * 20, Math.floor(this.selectedIndex / 4) * 16, 20, 16, xx - 35, yy - 35);
        ctx.fill();
        ctx.stroke();
    }
    if (this.memAddr.value != undefined) {
        ctx.beginPath();
        ctx.fillStyle = "green";
        rect2(ctx, (this.memAddr.value % 4) * 20, Math.floor(this.memAddr.value / 4) * 16, 20, 16, xx - 35, yy - 35);
        ctx.fill();
        ctx.stroke();
    }

    ctx.beginPath();
    ctx.fillStyle = "Black";
    fillText3(ctx, "A", -65, 5, xx, yy, fontSize = 16, font = "Georgia", textAlign = "right");
    fillText3(ctx, "D", 75, 5, xx, yy, fontSize = 16, font = "Georgia", textAlign = "right");
    fillText3(ctx, "En", 5, 47, xx, yy, fontSize = 16, font = "Georgia", textAlign = "right");
    ctx.fill();


    ctx.beginPath();
    ctx.fillStyle = "Black";
    for (var i = 0; i < 16; i += 4) {
        for (var j = i; j < i + 4; j++) {
            var s = this.data[j].toString(16);
            if (s.length < 2) s = '0' + s;
            fillText3(ctx, s, (j % 4) * 20, i * 4, xx - 35 + 10, yy - 35 + 12, fontSize = 14, font = "Georgia", textAlign = "center")
        }
    }
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = "Black";
    for (var i = 0; i < 16; i += 4) {

        var s = i.toString(16);
        if (s.length < 2) s = '0' + s;
        fillText3(ctx, s, 0, i * 4, xx - 40, yy - 35 + 12, fontSize = 14, font = "Georgia", textAlign = "right")

    }
    ctx.fill();


}
Rom.prototype.resolve = function () {
    if (this.isResolvable() == false) {
        return;
    }
    this.dataOut.value = this.data[this.memAddr.value];
    simulationArea.simulationQueue.add(this.dataOut);
}

function Splitter(x, y, scope = globalScope, dir = "RIGHT", bitWidth = undefined, bitWidthSplit = undefined) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;

    this.bitWidthSplit = bitWidthSplit || prompt("Enter bitWidth Split").split(' ').filter(x => x != '').map(function(x) {
        return parseInt(x, 10)||1;

    });
    this.splitCount = this.bitWidthSplit.length;

    this.setDimensions(10, (this.splitCount - 1) * 10 + 10);
    this.yOffset = (this.splitCount / 2 - 1) * 20;

    this.inp1 = new Node(-10, 10 + this.yOffset, 0, this, this.bitWidth);

    this.outputs = [];
    // this.prevOutValues=new Array(this.splitCount)
    for (var i = 0; i < this.splitCount; i++)
        this.outputs.push(new Node(20, i * 20 - this.yOffset - 20, 0, this, this.bitWidthSplit[i]));

    this.prevInpValue = undefined;


}
Splitter.prototype = Object.create(CircuitElement.prototype);
Splitter.prototype.constructor = Splitter;
Splitter.prototype.tooltipText = "Splitter ToolTip: Split multiBit Input into smaller bitwidths or vice versa."
Splitter.prototype.customSave = function () {
    var data = {

        constructorParamaters: [this.direction, this.bitWidth, this.bitWidthSplit],
        nodes: {
            outputs: this.outputs.map(findNode),
            inp1: findNode(this.inp1)
        },
    }
    return data;
}
Splitter.prototype.removePropagation = function () {

    if (this.inp1.value == undefined) {
        let i = 0;

        for (i = 0; i < this.outputs.length; i++) { // False Hit
            if (this.outputs[i].value == undefined) return;
        }

        for (i = 0; i < this.outputs.length; i++) {
            if (this.outputs[i].value !== undefined) {
                this.outputs[i].value = undefined;
                simulationArea.simulationQueue.add(this.outputs[i]);
            }
        }
    } else {
        if (this.inp1.value !== undefined) {
            this.inp1.value = undefined;
            simulationArea.simulationQueue.add(this.inp1);
        }
    }

    this.prevInpValue = undefined;

}
Splitter.prototype.isResolvable = function () {
    var resolvable = false;
    if (this.inp1.value != this.prevInpValue) {
        if (this.inp1.value !== undefined) return true;
        return false;
    }
    var i;
    for (i = 0; i < this.splitCount; i++)
        if (this.outputs[i].value === undefined) break;
    if (i == this.splitCount) resolvable = true;
    return resolvable;
}
Splitter.prototype.resolve = function () {
    if (this.isResolvable() == false) {
        return;
    }
    if (this.inp1.value !== undefined && this.inp1.value != this.prevInpValue) {
        var bitCount = 1;
        for (var i = 0; i < this.splitCount; i++) {
            var bitSplitValue = extractBits(this.inp1.value, bitCount, bitCount + this.bitWidthSplit[i] - 1);
            if (this.outputs[i].value != bitSplitValue) {
                if (this.outputs[i].value != bitSplitValue) {
                    this.outputs[i].value = bitSplitValue;
                    simulationArea.simulationQueue.add(this.outputs[i]);
                }
            }
            bitCount += this.bitWidthSplit[i];
        }
    } else {
        var n = 0;
        for (var i = this.splitCount - 1; i >= 0; i--) {
            n <<= this.bitWidthSplit[i];
            n += this.outputs[i].value;
        }
        if (this.inp1.value != n) {
            this.inp1.value = n;
            simulationArea.simulationQueue.add(this.inp1);
        }
        // else if (this.inp1.value != n) {
        //     console.log("CONTENTION");
        // }
    }
    this.prevInpValue = this.inp1.value;
}
Splitter.prototype.reset = function () {
    this.prevInpValue = undefined;
}
Splitter.prototype.processVerilog = function () {

    // console.log(this.inp1.verilogLabel +":"+ this.outputs[0].verilogLabel);
    if (this.inp1.verilogLabel != "" && this.outputs[0].verilogLabel == "") {
        var bitCount = 0;
        for (var i = 0; i < this.splitCount; i++) {
            // var bitSplitValue = extractBits(this.inp1.value, bitCount, bitCount + this.bitWidthSplit[i] - 1);
            if (this.bitWidthSplit[i] > 1)
                var label = this.inp1.verilogLabel + '[' + (bitCount + this.bitWidthSplit[i] - 1) + ":" + bitCount + "]";
            else
                var label = this.inp1.verilogLabel + '[' + bitCount + "]";
            if (this.outputs[i].verilogLabel != label) {
                this.outputs[i].verilogLabel = label;
                this.scope.stack.push(this.outputs[i]);
            }
            bitCount += this.bitWidthSplit[i];
        }
    } else if (this.inp1.verilogLabel == "" && this.outputs[0].verilogLabel != "") {


        var label = "{" + this.outputs.map((x) => {
            return x.verilogLabel
        }).join(",") + "}";
        // console.log("HIT",label)
        if (this.inp1.verilogLabel != label) {
            this.inp1.verilogLabel = label;
            this.scope.stack.push(this.inp1);
        }
    }
}
Splitter.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ["black", "brown"][((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) + 0];
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();

    // drawLine(ctx, -10, -10, xx, y2, color, width)
    moveTo(ctx, -10, 10 + this.yOffset, xx, yy, this.direction);
    lineTo(ctx, 0, 0 + this.yOffset, xx, yy, this.direction);
    lineTo(ctx, 0, -20 * (this.splitCount - 1) + this.yOffset, xx, yy, this.direction);

    var bitCount = 0;
    for (var i = this.splitCount - 1; i >= 0; i--) {
        moveTo(ctx, 0, -20 * i + this.yOffset, xx, yy, this.direction);
        lineTo(ctx, 20, -20 * i + this.yOffset, xx, yy, this.direction);
    }
    ctx.stroke();
    ctx.beginPath();
    ctx.fillStyle = "black";
    for (var i = this.splitCount - 1; i >= 0; i--) {
        fillText2(ctx, bitCount + ":" + (bitCount + this.bitWidthSplit[this.splitCount - i - 1]), 12, -20 * i + this.yOffset + 10, xx, yy, this.direction);
        bitCount += this.bitWidthSplit[this.splitCount - i - 1];
    }
    ctx.fill();



}

function Ground(x, y, scope = globalScope, bitWidth = 1) {
    CircuitElement.call(this, x, y, scope, "RIGHT", bitWidth);
    this.rectangleObject = false;
    this.setDimensions(10, 10);
    this.directionFixed = true;
    this.output1 = new Node(0, -10, 1, this);
}
Ground.prototype = Object.create(CircuitElement.prototype);
Ground.prototype.tooltipText = "Ground: All bits are Low(0).";
Ground.prototype.constructor = Ground;
Ground.prototype.propagationDelay = 0;
Ground.prototype.customSave = function () {
    var data = {
        nodes: {
            output1: findNode(this.output1)
        },
        values: {
            state: this.state
        },
        constructorParamaters: [this.direction, this.bitWidth]
    }
    return data;
}
Ground.prototype.resolve = function () {
    this.output1.value = 0;
    simulationArea.simulationQueue.add(this.output1);
}
Ground.prototype.customSave = function () {
    var data = {
        nodes: {
            output1: findNode(this.output1)
        },
        constructorParamaters: [this.bitWidth],
    }
    return data;
}
Ground.prototype.customDraw = function () {

    ctx = simulationArea.context;

    ctx.beginPath();
    ctx.strokeStyle = ["black", "brown"][((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) + 0];
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;

    moveTo(ctx, 0, -10, xx, yy, this.direction);
    lineTo(ctx, 0, 0, xx, yy, this.direction);
    moveTo(ctx, -10, 0, xx, yy, this.direction);
    lineTo(ctx, 10, 0, xx, yy, this.direction);
    moveTo(ctx, -6, 5, xx, yy, this.direction);
    lineTo(ctx, 6, 5, xx, yy, this.direction);
    moveTo(ctx, -2.5, 10, xx, yy, this.direction);
    lineTo(ctx, 2.5, 10, xx, yy, this.direction);
    ctx.stroke();
}


function Power(x, y, scope = globalScope, bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, "RIGHT", bitWidth);
    this.directionFixed = true;
    this.rectangleObject = false;
    this.setDimensions(10, 10);
    this.output1 = new Node(0, 10, 1, this);
}
Power.prototype = Object.create(CircuitElement.prototype);
Power.prototype.tooltipText = "Power: All bits are High(1).";
Power.prototype.constructor = Power;
Power.prototype.propagationDelay = 0;
Power.prototype.resolve = function () {
    this.output1.value = ~0 >>> (32 - this.bitWidth);
    simulationArea.simulationQueue.add(this.output1);
}
Power.prototype.customSave = function () {
    var data = {

        nodes: {
            output1: findNode(this.output1)
        },
        constructorParamaters: [this.bitWidth],
    }
    return data;
}
Power.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);
    ctx.fillStyle = "green";
    moveTo(ctx, 0, -10, xx, yy, this.direction);
    lineTo(ctx, -10, 0, xx, yy, this.direction);
    lineTo(ctx, 10, 0, xx, yy, this.direction);
    lineTo(ctx, 0, -10, xx, yy, this.direction);
    ctx.closePath();
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    moveTo(ctx, 0, 0, xx, yy, this.direction);
    lineTo(ctx, 0, 10, xx, yy, this.direction);
    ctx.stroke();

}

function get_next_position(x = 0, scope = globalScope) {
    var possible_y = 20;

    var done = {}
    for (var i = 0; i < scope.Input.length; i++)
        if (scope.Input[i].layoutProperties.x == x)
            done[scope.Input[i].layoutProperties.y] = 1
    for (var i = 0; i < scope.Output.length; i++)
        if (scope.Output[i].layoutProperties.x == x)
            done[scope.Output[i].layoutProperties.y] = 1

    // console.log(done)
    // return possible_y;

    while (done[possible_y] || done[possible_y + 10] || done[possible_y - 10])
        possible_y += 10;


    var height = possible_y + 20;
    if (height > scope.layout.height) {
        var old_height = scope.layout.height
        scope.layout.height = height;
        for (var i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].layoutProperties.y == old_height)
                scope.Input[i].layoutProperties.y = scope.layout.height;
        }
        for (var i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].layoutProperties.y == old_height)
                scope.Output[i].layoutProperties.y = scope.layout.height;
        }
    }
    return possible_y;
}

function Input(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1, layoutProperties) {

    if (layoutProperties)
        this.layoutProperties = layoutProperties;
    else {
        this.layoutProperties = {
            x: 0,
            y: get_next_position(0, scope),
            id: generateId(),
        }
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
Input.prototype.tooltipText = "Input ToolTip: Toggle the individual bits by clicking on them."
Input.prototype.propagationDelay = 0;
Input.prototype.customSave = function () {
    var data = {
        nodes: {
            output1: findNode(this.output1)
        },
        values: {
            state: this.state
        },
        constructorParamaters: [this.direction, this.bitWidth, this.layoutProperties]
    }
    return data;
}
Input.prototype.resolve = function () {
    this.output1.value = this.state;
    simulationArea.simulationQueue.add(this.output1);
}
// Check if override is necessary!!
Input.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth < 1) return;
    var diffBitWidth = bitWidth - this.bitWidth;
    this.bitWidth = bitWidth; //||parseInt(prompt("Enter bitWidth"),10);
    this.setWidth(this.bitWidth * 10);
    this.state = 0;
    this.output1.bitWidth = bitWidth;
    if (this.direction == "RIGHT") {
        this.x -= 10 * diffBitWidth;
        this.output1.x = 10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    } else if (this.direction == "LEFT") {
        this.x += 10 * diffBitWidth;
        this.output1.x = -10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    }
}
Input.prototype.click = function () { // toggle
    var pos = this.findPos();
    if (pos == 0) pos = 1; // minor correction
    if (pos < 1 || pos > this.bitWidth) return;
    this.state = ((this.state >>> 0) ^ (1 << (this.bitWidth - pos))) >>> 0;
}
Input.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    var bin = dec2bin(this.state, this.bitWidth);
    for (var k = 0; k < this.bitWidth; k++)
        fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5);
    ctx.fill();


}
Input.prototype.newDirection = function (dir) {
    if (dir == this.direction) return;
    this.direction = dir;
    this.output1.refresh();
    if (dir == "RIGHT" || dir == "LEFT") {
        this.output1.leftx = 10 * this.bitWidth;
        this.output1.lefty = 0;
    } else {
        this.output1.leftx = 10; //10*this.bitWidth;
        this.output1.lefty = 0;
    }

    this.output1.refresh();
    this.labelDirection = oppositeDirection[this.direction];
}
Input.prototype.findPos = function () {
    return Math.round((simulationArea.mouseX - this.x + 10 * this.bitWidth) / 20.0);
}

function Output(x, y, scope = globalScope, dir = "LEFT", bitWidth = 1, layoutProperties) {
    // Calling base class constructor

    if (layoutProperties)
        this.layoutProperties = layoutProperties
    else {
        this.layoutProperties = {
            x: scope.layout.width,
            y: get_next_position(scope.layout.width, scope),
            id: generateId(),
        }
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
Output.prototype.tooltipText = "Output ToolTip: Simple output element showing output in binary."
Output.prototype.propagationDelay = 0;
Output.prototype.generateVerilog = function () {
    return "assign " + this.label + " = " + this.inp1.verilogLabel + ";"
}
Output.prototype.customSave = function () {
    var data = {
        nodes: {
            inp1: findNode(this.inp1)
        },
        constructorParamaters: [this.direction, this.bitWidth, this.layoutProperties],
    }
    return data;
}
Output.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth < 1) return;
    var diffBitWidth = bitWidth - this.bitWidth;
    this.state = undefined;
    this.inp1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
    this.setWidth(10 * this.bitWidth);

    if (this.direction == "RIGHT") {
        this.x -= 10 * diffBitWidth;
        this.inp1.x = 10 * this.bitWidth;
        this.inp1.leftx = 10 * this.bitWidth;
    } else if (this.direction == "LEFT") {
        this.x += 10 * diffBitWidth;
        this.inp1.x = -10 * this.bitWidth;
        this.inp1.leftx = 10 * this.bitWidth;
    }
}
Output.prototype.customDraw = function () {
    this.state = this.inp1.value;
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ["blue", "red"][+(this.inp1.value == undefined)];
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;

    rect2(ctx, -10 * this.bitWidth, -10, 20 * this.bitWidth, 20, xx, yy, "RIGHT");
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(255, 255, 32,0.8)";

    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.font = "20px Georgia";
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    if (this.state === undefined)
        var bin = 'x'.repeat(this.bitWidth);
    else
        var bin = dec2bin(this.state, this.bitWidth);

    for (var k = 0; k < this.bitWidth; k++)
        fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5);
    ctx.fill();

}
Output.prototype.newDirection = function (dir) {
    if (dir == this.direction) return;
    this.direction = dir;
    this.inp1.refresh();
    if (dir == "RIGHT" || dir == "LEFT") {
        this.inp1.leftx = 10 * this.bitWidth;
        this.inp1.lefty = 0;
    } else {
        this.inp1.leftx = 10; //10*this.bitWidth;
        this.inp1.lefty = 0;
    }

    this.inp1.refresh();
    this.labelDirection = oppositeDirection[this.direction];
}

function BitSelector(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 2, selectorBitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setDimensions(20, 20);
    this.selectorBitWidth = selectorBitWidth || parseInt(prompt("Enter Selector bitWidth"), 10);
    this.rectangleObject = false;
    this.inp1 = new Node(-20, 0, 0, this, this.bitWidth, "Input");
    this.output1 = new Node(20, 0, 1, this, 1, "Output");
    this.bitSelectorInp = new Node(0, 20, 0, this, this.selectorBitWidth, "Bit Selector");

}
BitSelector.prototype = Object.create(CircuitElement.prototype);
BitSelector.prototype.constructor = BitSelector;
BitSelector.prototype.changeSelectorBitWidth = function (size) {
    if (size == undefined || size < 1 || size > 32) return;
    this.selectorBitWidth = size;
    this.bitSelectorInp.bitWidth = size;
}
BitSelector.prototype.mutableProperties = {
    "selectorBitWidth": {
        name: "Selector Bit Width: ",
        type: "number",
        max: "32",
        min: "1",
        func: "changeSelectorBitWidth",
    }
}
BitSelector.prototype.customSave = function () {
    var data = {

        nodes: {
            inp1: findNode(this.inp1),
            output1: findNode(this.output1),
            bitSelectorInp: findNode(this.bitSelectorInp)
        },
        constructorParamaters: [this.direction, this.bitWidth, this.selectorBitWidth],
    }
    return data;
}
BitSelector.prototype.newBitWidth = function (bitWidth) {
    this.inp1.bitWidth = bitWidth;
    this.bitWidth = bitWidth;
}
BitSelector.prototype.resolve = function () {
    this.output1.value = extractBits(this.inp1.value, this.bitSelectorInp.value + 1, this.bitSelectorInp.value + 1); //(this.inp1.value^(1<<this.bitSelectorInp.value))==(1<<this.bitSelectorInp.value);
    simulationArea.simulationQueue.add(this.output1);
}
BitSelector.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ["blue", "red"][(this.state === undefined) + 0];
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    rect(ctx, xx - 20, yy - 20, 40, 40);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.font = "20px Georgia";
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    if (this.bitSelectorInp.value === undefined)
        var bit = 'x';
    else
        var bit = this.bitSelectorInp.value;

    fillText(ctx, bit, xx, yy + 5);
    ctx.fill();
}

function ConstantVal(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1, state = "0") {
    this.state = state || prompt("Enter value");
    CircuitElement.call(this, x, y, scope, dir, this.state.length);
    this.setDimensions(10 * this.state.length, 10);
    this.bitWidth = bitWidth || this.state.length;
    this.directionFixed = true;
    this.orientationFixed = false;
    this.rectangleObject = false;

    this.output1 = new Node(this.bitWidth * 10, 0, 1, this);
    this.wasClicked = false;
    this.label = "";

}
ConstantVal.prototype = Object.create(CircuitElement.prototype);
ConstantVal.prototype.constructor = ConstantVal;
ConstantVal.prototype.tooltipText = "Constant ToolTip: Bits are fixed. Double click element to change the bits."
ConstantVal.prototype.propagationDelay = 0;
ConstantVal.prototype.generateVerilog = function () {
    return "localparam [" + (this.bitWidth - 1) + ":0] " + this.verilogLabel + "=" + this.bitWidth + "b'" + this.state + ";";
}
ConstantVal.prototype.customSave = function () {
    var data = {
        nodes: {
            output1: findNode(this.output1)
        },
        constructorParamaters: [this.direction, this.bitWidth, this.state],
    }
    return data;
}
ConstantVal.prototype.resolve = function () {
    this.output1.value = bin2dec(this.state);
    simulationArea.simulationQueue.add(this.output1);
}
ConstantVal.prototype.dblclick = function () {
    this.state = prompt("Re enter the value") || "0";
    console.log(this.state);
    this.newBitWidth(this.state.toString().length);
    //console.log(this.state, this.bitWidth);
}
ConstantVal.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth > this.state.length) this.state = '0'.repeat(bitWidth - this.state.length) + this.state;
    else if (bitWidth < this.state.length) this.state = this.state.slice(this.bitWidth - bitWidth);
    this.bitWidth = bitWidth; //||parseInt(prompt("Enter bitWidth"),10);
    this.output1.bitWidth = bitWidth;
    this.setDimensions(10 * this.bitWidth, 10);
    if (this.direction == "RIGHT") {
        this.output1.x = 10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    } else if (this.direction == "LEFT") {
        this.output1.x = -10 * this.bitWidth;
        this.output1.leftx = 10 * this.bitWidth;
    }
}
ConstantVal.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(1);
    var xx = this.x;
    var yy = this.y;

    rect2(ctx, -10 * this.bitWidth, -10, 20 * this.bitWidth, 20, xx, yy, "RIGHT");
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    var bin = this.state; //dec2bin(this.state,this.bitWidth);
    for (var k = 0; k < this.bitWidth; k++)
        fillText(ctx, bin[k], xx - 10 * this.bitWidth + 10 + (k) * 20, yy + 5);
    ctx.fill();

}
ConstantVal.prototype.newDirection = function (dir) {
    if (dir == this.direction) return;
    this.direction = dir;
    this.output1.refresh();
    if (dir == "RIGHT" || dir == "LEFT") {
        this.output1.leftx = 10 * this.bitWidth;
        this.output1.lefty = 0;
    } else {
        this.output1.leftx = 10; //10*this.bitWidth;
        this.output1.lefty = 0;
    }

    this.output1.refresh();
    this.labelDirection = oppositeDirection[this.direction];
}

function NorGate(x, y, scope = globalScope, dir = "RIGHT", inputs = 2, bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.setDimensions(15, 20);

    this.inp = [];
    this.inputSize = inputs;

    if (inputs % 2 == 1) {
        for (var i = 0; i < inputs / 2 - 1; i++) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        var a = new Node(-10, 0, 0, this);
        this.inp.push(a);
        for (var i = inputs / 2 + 1; i < inputs; i++) {
            var a = new Node(-10, 10 * (i + 1 - inputs / 2 - 1), 0, this);
            this.inp.push(a);
        }
    } else {
        for (var i = 0; i < inputs / 2; i++) {
            var a = new Node(-10, -10 * (i + 1), 0, this);
            this.inp.push(a);
        }
        for (var i = inputs / 2; i < inputs; i++) {
            var a = new Node(-10, 10 * (i + 1 - inputs / 2), 0, this);
            this.inp.push(a);
        }
    }
    this.output1 = new Node(30, 0, 1, this);


}
NorGate.prototype = Object.create(CircuitElement.prototype);
NorGate.prototype.constructor = NorGate;
NorGate.prototype.alwaysResolve = true;
NorGate.prototype.changeInputSize = changeInputSize;
NorGate.prototype.verilogType = "nor";
NorGate.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.inputSize, this.bitWidth],
        nodes: {
            inp: this.inp.map(findNode),
            output1: findNode(this.output1)
        },
    }
    return data;
}
NorGate.prototype.resolve = function () {
    var result = this.inp[0].value || 0;
    for (var i = 1; i < this.inputSize; i++)
        result = result | (this.inp[i].value || 0);
    result = ((~result >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    this.output1.value = result
    simulationArea.simulationQueue.add(this.output1);
}
NorGate.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);

    var xx = this.x;
    var yy = this.y;
    ctx.beginPath();
    ctx.fillStyle = "white";

    moveTo(ctx, -10, -20, xx, yy, this.direction, true);
    bezierCurveTo(0, -20, +15, -10, 20, 0, xx, yy, this.direction);
    bezierCurveTo(0 + 15, 0 + 10, 0, 0 + 20, -10, +20, xx, yy, this.direction);
    bezierCurveTo(0, 0, 0, 0, -10, -20, xx, yy, this.direction);
    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.5)";
    ctx.fill();
    ctx.stroke();
    ctx.beginPath();
    drawCircle2(ctx, 25, 0, 5, xx, yy, this.direction);
    ctx.stroke();
    //for debugging
}

function DigitalLed(x, y, scope = globalScope, color = "Red") {
    // Calling base class constructor

    CircuitElement.call(this, x, y, scope, "UP", 1);
    this.rectangleObject = false;
    this.setDimensions(10, 20);
    this.inp1 = new Node(-40, 0, 0, this, 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.color = color;
    var temp = colorToRGBA(this.color)
    this.actualColor = "rgba(" + temp[0] + "," + temp[1] + "," + temp[2] + "," + 0.8 + ")";


}
DigitalLed.prototype = Object.create(CircuitElement.prototype);
DigitalLed.prototype.constructor = DigitalLed;
DigitalLed.prototype.tooltipText = "Digital Led ToolTip: Digital LED glows high when input is High(1)."
DigitalLed.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.color],
        nodes: {
            inp1: findNode(this.inp1)
        },
    }
    return data;
}
DigitalLed.prototype.mutableProperties = {
    "color": {
        name: "Color: ",
        type: "text",
        func: "changeColor",
    },
}
DigitalLed.prototype.changeColor = function (value) {
    if (validColor(value)) {
        this.color = value;
        var temp = colorToRGBA(this.color)
        this.actualColor = "rgba(" + temp[0] + "," + temp[1] + "," + temp[2] + "," + 0.8 + ")";
    }

}
DigitalLed.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.strokeStyle = "#e3e4e5";
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 0, xx, yy, this.direction);
    lineTo(ctx, -40, 0, xx, yy, this.direction);
    ctx.stroke();

    ctx.strokeStyle = "#d3d4d5";
    ctx.fillStyle = ["rgba(227,228,229,0.8)", this.actualColor][this.inp1.value || 0];
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
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();

}

function VariableLed(x, y, scope = globalScope) {
    // Calling base class constructor

    CircuitElement.call(this, x, y, scope, "UP", 8);
    this.rectangleObject = false;
    this.setDimensions(10, 20);
    this.inp1 = new Node(-40, 0, 0, this, 8);
    this.directionFixed = true;
    this.fixedBitWidth = true;


}
VariableLed.prototype = Object.create(CircuitElement.prototype);
VariableLed.prototype.constructor = VariableLed;
VariableLed.prototype.tooltipText = "Variable Led ToolTip: Variable LED inputs an 8 bit value and glows with a proportional intensity."
VariableLed.prototype.customSave = function () {
    var data = {
        nodes: {
            inp1: findNode(this.inp1)
        },
    }
    return data;
}
VariableLed.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.strokeStyle = "#353535";
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 0, xx, yy, this.direction);
    lineTo(ctx, -40, 0, xx, yy, this.direction);
    ctx.stroke();
    var c = this.inp1.value;
    var alpha = c / 255;
    ctx.strokeStyle = "#090a0a";
    ctx.fillStyle = ["rgba(255,29,43," + alpha + ")", "rgba(227, 228, 229, 0.8)"][(c === undefined || c == 0) + 0];
    ctx.lineWidth = correctWidth(1);

    ctx.beginPath();

    moveTo(ctx, -20, -9, xx, yy, this.direction);
    lineTo(ctx, 0, -9, xx, yy, this.direction);
    arc(ctx, 0, 0, 9, (-Math.PI / 2), (Math.PI / 2), xx, yy, this.direction);
    lineTo(ctx, -20, 9, xx, yy, this.direction);
    /*lineTo(ctx,-18,12,xx,yy,this.direction);
    arc(ctx,0,0,Math.sqrt(468),((Math.PI/2) + Math.acos(12/Math.sqrt(468))),((-Math.PI/2) - Math.asin(18/Math.sqrt(468))),xx,yy,this.direction);

    */
    lineTo(ctx, -20, -9, xx, yy, this.direction);
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();

}

function Button(x, y, scope = globalScope, dir = "RIGHT") {
    CircuitElement.call(this, x, y, scope, dir, 1);
    this.state = 0;
    this.output1 = new Node(30, 0, 1, this);
    this.wasClicked = false;
    this.rectangleObject = false;
    this.setDimensions(10, 10);


}
Button.prototype = Object.create(CircuitElement.prototype);
Button.prototype.constructor = Button;
Button.prototype.tooltipText = "Button ToolTip: High(1) when pressed and Low(0) when released."
Button.prototype.propagationDelay = 0;
Button.prototype.customSave = function () {
    var data = {
        nodes: {
            output1: findNode(this.output1)
        },
        values: {
            state: this.state
        },
        constructorParamaters: [this.direction, this.bitWidth]
    }
    return data;
}
Button.prototype.resolve = function () {
    if (this.wasClicked) {
        this.state = 1;
        this.output1.value = this.state;
    } else {
        this.state = 0;
        this.output1.value = this.state;
    }
    simulationArea.simulationQueue.add(this.output1);
}
Button.prototype.customDraw = function () {
    ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;
    ctx.fillStyle = "#ddd";

    ctx.strokeStyle = "#353535";
    ctx.lineWidth = correctWidth(5);

    ctx.beginPath();

    moveTo(ctx, 10, 0, xx, yy, this.direction);
    lineTo(ctx, 30, 0, xx, yy, this.direction);
    ctx.stroke();

    ctx.beginPath();

    drawCircle2(ctx, 0, 0, 12, xx, yy, this.direction);
    ctx.stroke();

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(232, 13, 13,0.6)"

    if (this.wasClicked)
        ctx.fillStyle = "rgba(232, 13, 13,0.8)";
    ctx.fill();
}

function RGBLed(x, y, scope = globalScope) {
    // Calling base class constructor

    CircuitElement.call(this, x, y, scope, "UP", 8);
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
RGBLed.prototype.tooltipText = "RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE."
RGBLed.prototype.customSave = function () {
    var data = {
        nodes: {
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
            inp3: findNode(this.inp3),
        },
    }
    return data;
}
RGBLed.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.strokeStyle = "green";
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 0, xx, yy, this.direction);
    lineTo(ctx, -40, 0, xx, yy, this.direction);
    ctx.stroke();

    ctx.strokeStyle = "red";
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, -10, xx, yy, this.direction);
    lineTo(ctx, -40, -10, xx, yy, this.direction);
    ctx.stroke();

    ctx.strokeStyle = "blue";
    ctx.lineWidth = correctWidth(3);
    ctx.beginPath();
    moveTo(ctx, -20, 10, xx, yy, this.direction);
    lineTo(ctx, -40, 10, xx, yy, this.direction);
    ctx.stroke();

    var a = this.inp1.value;
    var b = this.inp2.value;
    var c = this.inp3.value;
    ctx.strokeStyle = "#d3d4d5";
    ctx.fillStyle = ["rgba(" + a + ", " + b + ", " + c + ", 0.8)", "rgba(227, 228, 229, 0.8)"][((a === undefined || b === undefined || c === undefined)) + 0]
    //ctx.fillStyle = ["rgba(200, 200, 200, 0.3)","rgba(227, 228, 229, 0.8)"][((a === undefined || b === undefined || c === undefined) || (a == 0 && b == 0 && c == 0)) + 0];
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
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
}

function SquareRGBLed(x, y, scope = globalScope, dir = "UP", pinLength = 1) {
    CircuitElement.call(this, x, y, scope, dir, 8);
    this.rectangleObject = false;
    this.setDimensions(15, 15);
    this.pinLength = pinLength === undefined ? 1 : pinLength;
    var nodeX = -10 - 10 * pinLength;
    this.inp1 = new Node(nodeX, -10, 0, this, 8, "R");
    this.inp2 = new Node(nodeX, 0, 0, this, 8, "G");
    this.inp3 = new Node(nodeX, 10, 0, this, 8, "B");
    this.inp = [this.inp1, this.inp2, this.inp3];
    this.labelDirection = "UP";
    this.fixedBitWidth = true;

    this.changePinLength = function (pinLength) {
        if (pinLength == undefined) return;
        pinLength = parseInt(pinLength, 10);
        if (pinLength < 0 || pinLength > 1000) return;

        // Calculate the new position of the LED, so the nodes will stay in the same place.
        var diff = 10 * (pinLength - this.pinLength);
        var diffX = this.direction == "LEFT" ? -diff : this.direction == "RIGHT" ? diff : 0;
        var diffY = this.direction == "UP" ? -diff : this.direction == "DOWN" ? diff : 0;

        // Build a new LED with the new values; preserve label properties too.
        var obj = new window[this.objectType](this.x + diffX, this.y + diffY, this.scope, this.direction, pinLength);
        obj.label = this.label;
        obj.labelDirection = this.labelDirection;

        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    }

    this.mutableProperties = {
        "pinLength": {
            name: "Pin Length",
            type: "number",
            max: "1000",
            min: "0",
            func: "changePinLength",
        },
    }
}
SquareRGBLed.prototype = Object.create(CircuitElement.prototype);
SquareRGBLed.prototype.constructor = SquareRGBLed;
SquareRGBLed.prototype.tooltipText = "Square RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE."
SquareRGBLed.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.pinLength],
        nodes: {
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
            inp3: findNode(this.inp3),
        },
    }
    return data;
}
SquareRGBLed.prototype.customDraw = function () {
    var ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;
    var r = this.inp1.value;
    var g = this.inp2.value;
    var b = this.inp3.value;

    var colors = ["rgb(174,20,20)", "rgb(40,174,40)", "rgb(0,100,255)"];
    for (var i = 0; i < 3; i++) {
        var x = -10 - 10 * this.pinLength;
        var y = i * 10 - 10;
        ctx.lineWidth = correctWidth(3);

        // A gray line, which makes it easy on the eyes when the pin length is large
        ctx.beginPath();
        ctx.lineCap = "butt";
        ctx.strokeStyle = "rgb(227, 228, 229)";
        moveTo(ctx, -15, y, xx, yy, this.direction);
        lineTo(ctx, x + 10, y, xx, yy, this.direction);
        ctx.stroke();

        // A colored line, so people know which pin does what.
        ctx.lineCap = "round";
        ctx.beginPath();
        ctx.strokeStyle = colors[i];
        moveTo(ctx, x + 10, y, xx, yy, this.direction);
        lineTo(ctx, x, y, xx, yy, this.direction);
        ctx.stroke();
    }

    ctx.strokeStyle = "#d3d4d5";
    ctx.fillStyle = (r === undefined && g === undefined && b === undefined) ? "rgb(227, 228, 229)" : "rgb(" + (r || 0) + ", " + (g || 0) + ", " + (b || 0) + ")";
    ctx.lineWidth = correctWidth(1);
    ctx.beginPath();
    rect2(ctx, -15, -15, 30, 30, xx, yy, this.direction);
    ctx.stroke();

    if ((this.hover && !simulationArea.shiftDown) ||
        simulationArea.lastSelected == this ||
        simulationArea.multipleObjectSelections.contains(this)) {
        ctx.fillStyle = "rgba(255, 255, 32)";
    }

    ctx.fill();
}

function Demultiplexer(x, y, scope = globalScope, dir = "LEFT", bitWidth = 1, controlSignalSize = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.controlSignalSize = controlSignalSize || parseInt(prompt("Enter control signal bitWidth"), 10);
    this.outputsize = 1 << this.controlSignalSize;
    this.xOff = 0;
    this.yOff = 1;
    if (this.controlSignalSize == 1) {
        this.xOff = 10;
    }
    if (this.controlSignalSize <= 3) {
        this.yOff = 2;
    }

    this.changeControlSignalSize = function (size) {
        if (size == undefined || size < 1 || size > 32) return;
        if (this.controlSignalSize == size) return;
        var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth, size);
        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    }
    this.mutableProperties = {
        "controlSignalSize": {
            name: "Control Signal Size",
            type: "number",
            max: "32",
            min: "1",
            func: "changeControlSignalSize",
        },
    }
    this.newBitWidth = function (bitWidth) {
        this.bitWidth = bitWidth;
        for (var i = 0; i < this.outputsize; i++) {
            this.output1[i].bitWidth = bitWidth
        }
        this.input.bitWidth = bitWidth;
    }

    this.setDimensions(20 - this.xOff, this.yOff * 5 * (this.outputsize));
    this.rectangleObject = false;
    this.input = new Node(20 - this.xOff, 0, 0, this);

    this.output1 = [];
    for (var i = 0; i < this.outputsize; i++) {
        var a = new Node(-20 + this.xOff, +this.yOff * 10 * (i - this.outputsize / 2) + 10, 1, this);
        this.output1.push(a);
    }

    this.controlSignalInput = new Node(0, this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff + 10, 0, this, this.controlSignalSize, "Control Signal");


}
Demultiplexer.prototype = Object.create(CircuitElement.prototype);
Demultiplexer.prototype.constructor = Demultiplexer;
Demultiplexer.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth, this.controlSignalSize],
        nodes: {
            output1: this.output1.map(findNode),
            input: findNode(this.input),
            controlSignalInput: findNode(this.controlSignalInput)
        },
    }
    return data;
}
Demultiplexer.prototype.resolve = function () {

    for (var i = 0; i < this.output1.length; i++)
        this.output1[i].value = 0;

    this.output1[this.controlSignalInput.value].value = this.input.value;

    for (var i = 0; i < this.output1.length; i++)
        simulationArea.simulationQueue.add(this.output1[i]);

}
Demultiplexer.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    moveTo(ctx, 0, this.yOff * 10 * (this.outputsize / 2 - 1) + 10 + 0.5 * this.xOff, xx, yy, this.direction);
    lineTo(ctx, 0, this.yOff * 5 * (this.outputsize - 1) + this.xOff, xx, yy, this.direction);
    ctx.stroke();

    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(4);
    ctx.fillStyle = "white";
    moveTo(ctx, -20 + this.xOff, -this.yOff * 10 * (this.outputsize / 2), xx, yy, this.direction);
    lineTo(ctx, -20 + this.xOff, 20 + this.yOff * 10 * (this.outputsize / 2 - 1), xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, +this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff, xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, -this.yOff * 10 * (this.outputsize / 2) - this.xOff + 20, xx, yy, this.direction);

    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();



    ctx.beginPath();
    ctx.fillStyle = "black";
    ctx.textAlign = "center";
    //[xFill,yFill] = rotate(xx + this.output1[i].x - 7, yy + this.output1[i].y + 2);
    ////console.log([xFill,yFill])
    for (var i = 0; i < this.outputsize; i++) {
        if (this.direction == "LEFT") fillText(ctx, String(i), xx + this.output1[i].x - 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction == "RIGHT") fillText(ctx, String(i), xx + this.output1[i].x + 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction == "UP") fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y - 5, 10);
        else fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y + 10, 10);
    }
    ctx.fill();
}

function Decoder(x, y, scope = globalScope, dir = "LEFT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    // this.controlSignalSize = controlSignalSize || parseInt(prompt("Enter control signal bitWidth"), 10);
    this.outputsize = 1 << this.bitWidth;
    this.xOff = 0;
    this.yOff = 1;
    if (this.bitWidth == 1) {
        this.xOff = 10;
    }
    if (this.bitWidth <= 3) {
        this.yOff = 2;
    }

    // this.changeControlSignalSize = function(size) {
    //     if (size == undefined || size < 1 || size > 32) return;
    //     if (this.controlSignalSize == size) return;
    //     var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth, size);
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
    this.newBitWidth = function (bitWidth) {
        // this.bitWidth = bitWidth;
        // for (var i = 0; i < this.inputSize; i++) {
        //     this.outputs1[i].bitWidth = bitWidth
        // }
        // this.input.bitWidth = bitWidth;
        if (bitWidth == undefined || bitWidth < 1 || bitWidth > 32) return;
        if (this.bitWidth == bitWidth) return;
        var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, bitWidth);
        this.cleanDelete();
        simulationArea.lastSelected = obj;
        return obj;
    }

    this.setDimensions(20 - this.xOff, this.yOff * 5 * (this.outputsize));
    this.rectangleObject = false;
    this.input = new Node(20 - this.xOff, 0, 0, this);

    this.output1 = [];
    for (var i = 0; i < this.outputsize; i++) {
        var a = new Node(-20 + this.xOff, +this.yOff * 10 * (i - this.outputsize / 2) + 10, 1, this, 1);
        this.output1.push(a);
    }

    // this.controlSignalInput = new Node(0,this.yOff * 10 * (this.outputsize / 2 - 1) +this.xOff + 10, 0, this, this.controlSignalSize,"Control Signal");


}
Decoder.prototype = Object.create(CircuitElement.prototype);
Decoder.prototype.constructor = Decoder;
Decoder.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            output1: this.output1.map(findNode),
            input: findNode(this.input),
        },
    }
    return data;
}
Decoder.prototype.resolve = function () {

    for (var i = 0; i < this.output1.length; i++)
        this.output1[i].value = 0;
    this.output1[this.input.value].value = 1;
    for (var i = 0; i < this.output1.length; i++)
        simulationArea.simulationQueue.add(this.output1[i]);

}
Decoder.prototype.customDraw = function () {

    ctx = simulationArea.context;

    var xx = this.x;
    var yy = this.y;

    // ctx.beginPath();
    // moveTo(ctx, 0,this.yOff * 10 * (this.outputsize / 2 - 1) + 10 + 0.5 *this.xOff, xx, yy, this.direction);
    // lineTo(ctx, 0,this.yOff * 5 * (this.outputsize - 1) +this.xOff, xx, yy, this.direction);
    // ctx.stroke();

    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(4);
    ctx.fillStyle = "white";
    moveTo(ctx, -20 + this.xOff, -this.yOff * 10 * (this.outputsize / 2), xx, yy, this.direction);
    lineTo(ctx, -20 + this.xOff, 20 + this.yOff * 10 * (this.outputsize / 2 - 1), xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, +this.yOff * 10 * (this.outputsize / 2 - 1) + this.xOff, xx, yy, this.direction);
    lineTo(ctx, 20 - this.xOff, -this.yOff * 10 * (this.outputsize / 2) - this.xOff + 20, xx, yy, this.direction);

    ctx.closePath();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();



    ctx.beginPath();
    ctx.fillStyle = "black";
    ctx.textAlign = "center";
    //[xFill,yFill] = rotate(xx + this.output1[i].x - 7, yy + this.output1[i].y + 2);
    ////console.log([xFill,yFill])
    for (var i = 0; i < this.outputsize; i++) {
        if (this.direction == "LEFT") fillText(ctx, String(i), xx + this.output1[i].x - 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction == "RIGHT") fillText(ctx, String(i), xx + this.output1[i].x + 7, yy + this.output1[i].y + 2, 10);
        else if (this.direction == "UP") fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y - 5, 10);
        else fillText(ctx, String(i), xx + this.output1[i].x, yy + this.output1[i].y + 10, 10);
    }
    ctx.fill();
}

function Flag(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1, identifier) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.setWidth(60);
    this.setHeight(20);
    this.rectangleObject = false;
    this.directionFixed = true;
    this.orientationFixed = false;
    this.identifier = identifier || ("F" + this.scope.Flag.length);
    this.plotValues = [];

    this.xSize = 10;

    this.inp1 = new Node(40, 0, 0, this);
}
Flag.prototype = Object.create(CircuitElement.prototype);
Flag.prototype.constructor = Flag;
Flag.prototype.tooltipText = "FLag ToolTip: Use this for debugging and plotting."
Flag.prototype.setPlotValue = function () {
    var time = plotArea.stopWatch.ElapsedMilliseconds;

    // //console.log("DEB:",time);
    if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] == time)
        this.plotValues.pop();

    if (this.plotValues.length == 0) {
        this.plotValues.push([time, this.inp1.value]);
        return;
    }

    if (this.plotValues[this.plotValues.length - 1][1] == this.inp1.value)
        return;
    else
        this.plotValues.push([time, this.inp1.value]);
}
Flag.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            inp1: findNode(this.inp1),
        },
        values: {
            identifier: this.identifier
        }
    }
    return data;
}
Flag.prototype.setIdentifier = function (id = "") {
    if (id.length == 0) return;
    this.identifier = id;
    var len = this.identifier.length;
    if (len == 1) this.xSize = 20;
    else if (len > 1 && len < 4) this.xSize = 10;
    else this.xSize = 0;
}
Flag.prototype.mutableProperties = {
    "identifier": {
        name: "Debug Flag identifier",
        type: "text",
        maxlength: "5",
        func: "setIdentifier",
    },
}
Flag.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "grey";
    ctx.fillStyle = "#fcfcfc";
    ctx.lineWidth = correctWidth(1);
    var xx = this.x;
    var yy = this.y;


    rect2(ctx, -50 + this.xSize, -20, 100 - 2 * this.xSize, 40, xx, yy, "RIGHT");
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.font = "14px Georgia";
    this.xOff = ctx.measureText(this.identifier).width;

    ctx.beginPath();
    rect2(ctx, -40 + this.xSize, -12, this.xOff + 10, 25, xx, yy, "RIGHT");
    ctx.fillStyle = "#eee"
    ctx.strokeStyle = "#ccc";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    fillText(ctx, this.identifier, xx - 35 + this.xOff / 2 + this.xSize, yy + 5, 14);
    ctx.fill();

    ctx.beginPath();
    ctx.font = "30px Georgia";
    ctx.textAlign = "center";
    ctx.fillStyle = ["blue", "red"][+(this.inp1.value == undefined)];
    if (this.inp1.value !== undefined)
        fillText(ctx, this.inp1.value.toString(16), xx + 35 - this.xSize, yy + 8, 25);
    else
        fillText(ctx, "x", xx + 35 - this.xSize, yy + 8, 25);
    ctx.fill();

}
Flag.prototype.newDirection = function (dir) {
    if (dir == this.direction) return;
    this.direction = dir;
    this.inp1.refresh();
    if (dir == "RIGHT" || dir == "LEFT") {
        this.inp1.leftx = 50 - this.xSize;
    } else if (dir == "UP") {
        this.inp1.leftx = 20;
    } else {
        this.inp1.leftx = 20;
    }
    // if(this.direction=="LEFT" || this.direction=="RIGHT") this.inp1.leftx=50-this.xSize;
    //     this.inp1.refresh();

    this.inp1.refresh();
}

function MSB(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    // this.setDimensions(20, 20);
    this.leftDimensionX = 10;
    this.rightDimensionX = 20;
    this.setHeight(30);
    this.directionFixed = true;
    this.bitWidth = bitWidth || parseInt(prompt("Enter bitWidth"), 10);
    this.rectangleObject = false;
    this.inputSize = 1 << this.bitWidth;

    this.inp1 = new Node(-10, 0, 0, this, this.inputSize);
    this.output1 = new Node(20, 0, 1, this, this.bitWidth);
    this.enable = new Node(20, 20, 1, this, 1);



}
MSB.prototype = Object.create(CircuitElement.prototype);
MSB.prototype.constructor = MSB;
MSB.prototype.customSave = function () {
    var data = {

        nodes: {
            inp1: findNode(this.inp1),
            output1: findNode(this.output1),
            enable: findNode(this.enable)
        },
        constructorParamaters: [this.direction, this.bitWidth],
    }
    return data;
}
MSB.prototype.newBitWidth = function (bitWidth) {
    // this.inputSize = 1 << bitWidth
    this.inputSize = bitWidth
    this.inp1.bitWidth = this.inputSize;
    this.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
}
MSB.prototype.resolve = function () {

    var inp = this.inp1.value;
    this.output1.value = (dec2bin(inp).length) - 1
    simulationArea.simulationQueue.add(this.output1);
    if (inp != 0) {
        this.enable.value = 1;
    } else {
        this.enable.value = 0;
    }
    simulationArea.simulationQueue.add(this.enable);
}
MSB.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    rect(ctx, xx - 10, yy - 30, 30, 60);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = "black";
    ctx.textAlign = "center";
    fillText(ctx, "MSB", xx + 6, yy - 12, 10);
    fillText(ctx, "EN", xx + this.enable.x - 12, yy + this.enable.y + 3, 8);
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    if (this.output1.value != undefined) {
        fillText(ctx, this.output1.value, xx + 5, yy + 14, 13);
    }
    ctx.stroke();
    ctx.fill();
}

function LSB(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.leftDimensionX = 10;
    this.rightDimensionX = 20;
    this.setHeight(30);
    this.directionFixed = true;
    this.bitWidth = bitWidth || parseInt(prompt("Enter bitWidth"), 10);
    this.rectangleObject = false;
    this.inputSize = 1 << this.bitWidth;

    this.inp1 = new Node(-10, 0, 0, this, this.inputSize);
    this.output1 = new Node(20, 0, 1, this, this.bitWidth);
    this.enable = new Node(20, 20, 1, this, 1);



}
LSB.prototype = Object.create(CircuitElement.prototype);
LSB.prototype.constructor = LSB;
LSB.prototype.customSave = function () {
    var data = {

        nodes: {
            inp1: findNode(this.inp1),
            output1: findNode(this.output1),
            enable: findNode(this.enable)
        },
        constructorParamaters: [this.direction, this.bitWidth],
    }
    return data;
}
LSB.prototype.newBitWidth = function (bitWidth) {
    // this.inputSize = 1 << bitWidth
    this.inputSize = bitWidth
    this.inp1.bitWidth = this.inputSize;
    this.bitWidth = bitWidth;
    this.output1.bitWidth = bitWidth;
}
LSB.prototype.resolve = function () {

    var inp = dec2bin(this.inp1.value);
    var out = 0;
    for (var i = inp.length - 1; i >= 0; i--) {
        if (inp[i] == 1) {
            out = inp.length - 1 - i;
            break;
        }

    }
    this.output1.value = out;
    simulationArea.simulationQueue.add(this.output1);
    if (inp != 0) {
        this.enable.value = 1;
    } else {
        this.enable.value = 0;
    }
    simulationArea.simulationQueue.add(this.enable);
}
LSB.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    rect(ctx, xx - 10, yy - 30, 30, 60);
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = "black";
    ctx.textAlign = "center";
    fillText(ctx, "LSB", xx + 6, yy - 12, 10);
    fillText(ctx, "EN", xx + this.enable.x - 12, yy + this.enable.y + 3, 8);
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle = "green";
    ctx.textAlign = "center";
    if (this.output1.value != undefined) {
        fillText(ctx, this.output1.value, xx + 5, yy + 14, 13);
    }
    ctx.stroke();
    ctx.fill();
}

function PriorityEncoder(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.bitWidth = bitWidth || parseInt(prompt("Enter bitWidth"), 10);
    this.inputSize = 1 << this.bitWidth;

    this.yOff = 1;
    if (this.bitWidth <= 3) {
        this.yOff = 2;
    }

    this.setDimensions(20, this.yOff * 5 * (this.inputSize));
    this.directionFixed = true;
    this.rectangleObject = false;

    this.inp1 = [];
    for (var i = 0; i < this.inputSize; i++) {
        var a = new Node(-10, +this.yOff * 10 * (i - this.inputSize / 2) + 10, 0, this, 1);
        this.inp1.push(a);
    }

    this.output1 = [];
    for (var i = 0; i < this.bitWidth; i++) {
        var a = new Node(30, +2 * 10 * (i - this.bitWidth / 2) + 10, 1, this, 1);
        this.output1.push(a);
    }

    this.enable = new Node(10, 20 + this.inp1[this.inputSize - 1].y, 1, this, 1);


}
PriorityEncoder.prototype = Object.create(CircuitElement.prototype);
PriorityEncoder.prototype.constructor = PriorityEncoder;
PriorityEncoder.prototype.customSave = function () {
    var data = {

        nodes: {
            inp1: this.inp1.map(findNode),
            output1: this.output1.map(findNode),
            enable: findNode(this.enable)
        },
        constructorParamaters: [this.direction, this.bitWidth],
    }
    return data;
}
PriorityEncoder.prototype.newBitWidth = function (bitWidth) {
    if (bitWidth == undefined || bitWidth < 1 || bitWidth > 32) return;
    if (this.bitWidth == bitWidth) return;

    this.bitWidth = bitWidth;
    var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, this.bitWidth);
    this.inputSize = 1 << bitWidth;

    this.cleanDelete();
    simulationArea.lastSelected = obj;
    return obj;
}
PriorityEncoder.prototype.resolve = function () {
    var out = 0;
    var temp = 0;
    for (var i = this.inputSize - 1; i >= 0; i--) {
        if (this.inp1[i].value == 1) {
            out = dec2bin(i);
            break;
        }
    }
    temp = out;

    if (out.length != undefined) {
        this.enable.value = 1;
    } else {
        this.enable.value = 0;
    }
    simulationArea.simulationQueue.add(this.enable);

    if (temp.length == undefined) {
        temp = "0";
        for (var i = 0; i < this.bitWidth - 1; i++) {
            temp = "0" + temp;
        }
    }

    if (temp.length != this.bitWidth) {
        for (var i = temp.length; i < this.bitWidth; i++) {
            temp = "0" + temp;
        }
    }

    for (var i = this.bitWidth - 1; i >= 0; i--) {
        this.output1[this.bitWidth - 1 - i].value = Number(temp[i]);
        simulationArea.simulationQueue.add(this.output1[this.bitWidth - 1 - i]);
    }
}
PriorityEncoder.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    if (this.bitWidth <= 3)
        rect(ctx, xx - 10, yy - 10 - this.yOff * 5 * (this.inputSize), 40, 20 * (this.inputSize + 1));
    else
        rect(ctx, xx - 10, yy - 10 - this.yOff * 5 * (this.inputSize), 40, 10 * (this.inputSize + 3));
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = "black";
    ctx.textAlign = "center";
    for (var i = 0; i < this.inputSize; i++) {
        fillText(ctx, String(i), xx, yy + this.inp1[i].y + 2, 10);
    }
    for (var i = 0; i < this.bitWidth; i++) {
        fillText(ctx, String(i), xx + this.output1[0].x - 10, yy + this.output1[i].y + 2, 10);
    }
    fillText(ctx, "EN", xx + this.enable.x, yy + this.enable.y - 5, 10);
    ctx.fill();

}

function Tunnel(x, y, scope = globalScope, dir = "LEFT", bitWidth = 1, identifier) {

    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.rectangleObject = false;
    this.centerElement = true;

    this.xSize = 10;

    this.plotValues = [];
    this.inp1 = new Node(0, 0, 0, this);
    this.setIdentifier(identifier || "T");
    this.setBounds();

}
Tunnel.prototype = Object.create(CircuitElement.prototype);
Tunnel.prototype.constructor = Tunnel;
Tunnel.prototype.newDirection = function (dir) {
    if (this.direction == dir) return;
    this.direction = dir;
    this.setBounds();
}
Tunnel.prototype.overrideDirectionRotation = true;
Tunnel.prototype.setBounds = function () {

    var xRotate = 0;
    var yRotate = 0;
    if (this.direction == "LEFT") {
        xRotate = 0;
        yRotate = 0;
    } else if (this.direction == "RIGHT") {
        xRotate = 120 - this.xSize;
        yRotate = 0;
    } else if (this.direction == "UP") {
        xRotate = 60 - this.xSize / 2;
        yRotate = -20;
    } else {
        xRotate = 60 - this.xSize / 2;
        yRotate = 20;
    }

    this.leftDimensionX = Math.abs(-120 + xRotate + this.xSize);
    this.upDimensionY = Math.abs(-20 + yRotate);
    this.rightDimensionX = Math.abs(xRotate)
    this.downDimensionY = Math.abs(20 + yRotate);
    console.log(this.leftDimensionX, this.upDimensionY, this.rightDimensionX, this.downDimensionY);

    // rect2(ctx, -120 + xRotate + this.xSize, -20 + yRotate, 120 - this.xSize, 40, xx, yy, "RIGHT");


}
Tunnel.prototype.setTunnelValue = function (val) {
    this.inp1.value = val;
    for (var i = 0; i < this.inp1.connections.length; i++) {
        if (this.inp1.connections[i].value != val) {
            this.inp1.connections[i].value = val;
            simulationArea.simulationQueue.add(this.inp1.connections[i]);
        }
    }
}
Tunnel.prototype.resolve = function () {
    for (var i = 0; i < this.scope.tunnelList[this.identifier].length; i++) {
        if (this.scope.tunnelList[this.identifier][i].inp1.value != this.inp1.value) {
            this.scope.tunnelList[this.identifier][i].setTunnelValue(this.inp1.value);
        }
    }
}
Tunnel.prototype.updateScope = function (scope) {
    this.scope = scope;
    this.inp1.updateScope(scope);
    this.setIdentifier(this.identifier);
    //console.log("ShouldWork!");
}
Tunnel.prototype.setPlotValue = function () {
    var time = plotArea.stopWatch.ElapsedMilliseconds;
    if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] == time)
        this.plotValues.pop();

    if (this.plotValues.length == 0) {
        this.plotValues.push([time, this.inp1.value]);
        return;
    }

    if (this.plotValues[this.plotValues.length - 1][1] == this.inp1.value)
        return;
    else
        this.plotValues.push([time, this.inp1.value]);
}
Tunnel.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth, this.identifier],
        nodes: {
            inp1: findNode(this.inp1),
        },
        values: {
            identifier: this.identifier
        }
    }
    return data;
}
Tunnel.prototype.setIdentifier = function (id = "") {
    if (id.length == 0) return;
    if (this.scope.tunnelList[this.identifier]) this.scope.tunnelList[this.identifier].clean(this);
    this.identifier = id;
    if (this.scope.tunnelList[this.identifier]) this.scope.tunnelList[this.identifier].push(this);
    else this.scope.tunnelList[this.identifier] = [this];

    var len = this.identifier.length;
    if (len == 1) this.xSize = 40;
    else if (len > 1 && len < 4) this.xSize = 20;
    else this.xSize = 0;

    this.setBounds();
}
Tunnel.prototype.mutableProperties = {
    "identifier": {
        name: "Debug Flag identifier",
        type: "text",
        maxlength: "5",
        func: "setIdentifier",
    },
}
Tunnel.prototype.delete = function () {
    this.scope.Tunnel.clean(this);
    this.scope.tunnelList[this.identifier].clean(this);
    CircuitElement.prototype.delete.call(this);
}
Tunnel.prototype.customDraw = function () {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "grey";
    ctx.fillStyle = "#fcfcfc";
    ctx.lineWidth = correctWidth(1);
    var xx = this.x;
    var yy = this.y;

    var xRotate = 0;
    var yRotate = 0;
    if (this.direction == "LEFT") {
        xRotate = 0;
        yRotate = 0;
    } else if (this.direction == "RIGHT") {
        xRotate = 120 - this.xSize;
        yRotate = 0;
    } else if (this.direction == "UP") {
        xRotate = 60 - this.xSize / 2;
        yRotate = -20;
    } else {
        xRotate = 60 - this.xSize / 2;
        yRotate = 20;
    }

    rect2(ctx, -120 + xRotate + this.xSize, -20 + yRotate, 120 - this.xSize, 40, xx, yy, "RIGHT");
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.font = "14px Georgia";
    this.xOff = ctx.measureText(this.identifier).width;
    ctx.beginPath();
    rect2(ctx, -105 + xRotate + this.xSize, -11 + yRotate, this.xOff + 10, 23, xx, yy, "RIGHT");
    ctx.fillStyle = "#eee"
    ctx.strokeStyle = "#ccc";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    fillText(ctx, this.identifier, xx - 100 + this.xOff / 2 + xRotate + this.xSize, yy + 6 + yRotate, 14);
    ctx.fill();

    ctx.beginPath();
    ctx.font = "30px Georgia";
    ctx.textAlign = "center";
    ctx.fillStyle = ["blue", "red"][+(this.inp1.value == undefined)];
    if (this.inp1.value !== undefined)
        fillText(ctx, this.inp1.value.toString(16), xx - 23 + xRotate, yy + 8 + yRotate, 25);
    else
        fillText(ctx, "x", xx - 23 + xRotate, yy + 8 + yRotate, 25);
    ctx.fill();
}

function ALU(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 1) {
    // //console.log("HIT");
    // //console.log(x,y,scope,dir,bitWidth,controlSignalSize);
    CircuitElement.call(this, x, y, scope, dir, bitWidth);
    this.message = "ALU";

    this.setDimensions(30, 40);
    this.rectangleObject = false;

    this.inp1 = new Node(-30, -30, 0, this, this.bitwidth, "A");
    this.inp2 = new Node(-30, 30, 0, this, this.bitwidth, "B");

    this.controlSignalInput = new Node(-10, -40, 0, this, 3, "Ctrl");
    this.carryOut = new Node(-10, 40, 1, this, 1, "Cout");
    this.output = new Node(30, 0, 1, this, this.bitwidth, "Out");

}
ALU.prototype = Object.create(CircuitElement.prototype);
ALU.prototype.constructor = ALU;
ALU.prototype.tooltipText = "ALU ToolTip: 0: A&B, 1:A|B, 2:A+B, 4:A&~B, 5:A|~B, 6:A-B, 7:SLT "
ALU.prototype.newBitWidth = function (bitWidth) {
    this.bitWidth = bitWidth;
    this.inp1.bitWidth = bitWidth;
    this.inp2.bitWidth = bitWidth;
    this.output.bitWidth = bitWidth;
}
ALU.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction, this.bitWidth],
        nodes: {
            inp1: findNode(this.inp1),
            inp2: findNode(this.inp2),
            output: findNode(this.output),
            carryOut: findNode(this.carryOut),
            controlSignalInput: findNode(this.controlSignalInput)
        },
    }
    return data;
}
ALU.prototype.customDraw = function () {
    ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;
    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
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

    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
        ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.fillStyle = "Black";
    ctx.textAlign = "center"

    fillText4(ctx, "B", -23, 30, xx, yy, this.direction, 6);
    fillText4(ctx, "A", -23, -30, xx, yy, this.direction, 6);
    fillText4(ctx, "CTR", -10, -30, xx, yy, this.direction, 6);
    fillText4(ctx, "Carry", -10, 30, xx, yy, this.direction, 6);
    fillText4(ctx, "Ans", 20, 0, xx, yy, this.direction, 6);
    ctx.fill();
    ctx.beginPath();
    ctx.fillStyle = "DarkGreen";
    fillText4(ctx, this.message, 0, 0, xx, yy, this.direction, 12);
    ctx.fill();

}
ALU.prototype.resolve = function () {
    if (this.controlSignalInput.value == 0) {
        this.output.value = ((this.inp1.value) & (this.inp2.value));
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
        this.message = "A&B";
    } else if (this.controlSignalInput.value == 1) {
        this.output.value = ((this.inp1.value) | (this.inp2.value));

        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
        this.message = "A|B";
    } else if (this.controlSignalInput.value == 2) {
        var sum = this.inp1.value + this.inp2.value;
        this.output.value = ((sum) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        this.carryOut.value = +((sum >>> (this.bitWidth)) !== 0);
        simulationArea.simulationQueue.add(this.carryOut);
        simulationArea.simulationQueue.add(this.output);
        this.message = "A+B";
    } else if (this.controlSignalInput.value == 3) {
        this.message = "ALU";
        return;
    } else if (this.controlSignalInput.value == 4) {
        this.message = "A&~B";
        this.output.value = ((this.inp1.value) & this.flipBits(this.inp2.value));
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    } else if (this.controlSignalInput.value == 5) {
        this.message = "A|~B";
        this.output.value = ((this.inp1.value) | this.flipBits(this.inp2.value));
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    } else if (this.controlSignalInput.value == 6) {
        this.message = "A-B";
        this.output.value = ((this.inp1.value - this.inp2.value) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    } else if (this.controlSignalInput.value == 7) {
        this.message = "A<B";
        if (this.inp1.value < this.inp2.value)
            this.output.value = 1;
        else
            this.output.value = 0;
        simulationArea.simulationQueue.add(this.output);
        this.carryOut.value = 0;
        simulationArea.simulationQueue.add(this.carryOut);
    }

}


function Rectangle(x, y, scope = globalScope, rows = 15, cols = 20) {
    CircuitElement.call(this, x, y, scope, "RIGHT", 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.rectangleObject = false;
    this.cols = cols || parseInt(prompt("Enter cols:"));
    this.rows = rows || parseInt(prompt("Enter rows:"));
    this.setSize()

}
Rectangle.prototype = Object.create(CircuitElement.prototype);
Rectangle.prototype.constructor = Rectangle;
Rectangle.prototype.changeRowSize = function (size) {
    if (size == undefined || size < 5 || size > 1000) return;
    if (this.rows == size) return;
    this.rows = parseInt(size)
    this.setSize()
    return this;
}
Rectangle.prototype.changeColSize = function (size) {
    if (size == undefined || size < 5 || size > 1000) return;
    if (this.cols == size) return;
    this.cols = parseInt(size);
    this.setSize()
    return this;
}
Rectangle.prototype.keyDown3 = function (dir) {
    //console.log(dir)
    if (dir == "ArrowRight")
        this.changeColSize(this.cols + 2)
    if (dir == "ArrowLeft")
        this.changeColSize(this.cols - 2)
    if (dir == "ArrowDown")
        this.changeRowSize(this.rows + 2)
    if (dir == "ArrowUp")
        this.changeRowSize(this.rows - 2)
}
Rectangle.prototype.mutableProperties = {
    "cols": {
        name: "Columns",
        type: "number",
        max: "1000",
        min: "5",
        func: "changeColSize",
    },
    "rows": {
        name: "Rows",
        type: "number",
        max: "1000",
        min: "5",
        func: "changeRowSize",
    }
}
Rectangle.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.rows, this.cols],
    }
    return data;
}
Rectangle.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "rgba(0,0,0,1)";
    ctx.setLineDash([5 * globalScope.scale, 5 * globalScope.scale])
    ctx.lineWidth = correctWidth(1.5);
    var xx = this.x;
    var yy = this.y;
    rect(ctx, xx, yy, this.elementWidth, this.elementHeight);
    ctx.stroke();

    if (simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) {
        ctx.fillStyle = "rgba(255, 255, 32,0.1)";
        ctx.fill();
    }
    ctx.setLineDash([])


}
Rectangle.prototype.setSize = function () {
    this.elementWidth = this.cols * 10;
    this.elementHeight = this.rows * 10;
    this.upDimensionY = 0;
    this.leftDimensionX = 0;
    this.rightDimensionX = this.elementWidth;
    this.downDimensionY = this.elementHeight;
}


function Arrow(x, y, scope = globalScope, dir = "RIGHT") {

    CircuitElement.call(this, x, y, scope, dir, 8);
    this.rectangleObject = false;
    this.fixedBitWidth = true
    this.setDimensions(30, 20);

}
Arrow.prototype = Object.create(CircuitElement.prototype);
Arrow.prototype.constructor = Arrow;
Arrow.prototype.customSave = function () {
    var data = {
        constructorParamaters: [this.direction],
    }
    return data;
}
Arrow.prototype.customDraw = function () {

    ctx = simulationArea.context;
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    ctx.strokeStyle = "red";
    ctx.fillStyle = "white";

    ctx.beginPath();

    moveTo(ctx, -30, -3, xx, yy, this.direction);
    lineTo(ctx, 10, -3, xx, yy, this.direction);
    lineTo(ctx, 10, -15, xx, yy, this.direction);
    lineTo(ctx, 30, 0, xx, yy, this.direction);
    lineTo(ctx, 10, 15, xx, yy, this.direction);
    lineTo(ctx, 10, 3, xx, yy, this.direction);
    lineTo(ctx, -30, 3, xx, yy, this.direction);
    ctx.closePath()
    ctx.stroke();
    if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    ctx.fill();

}
