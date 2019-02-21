/** 
 * RAM Component.
 * 
 * Two settings are available:
 * - addressWidth: 1 to 20, default=10. Controls the width of the address input.
 * - bitWidth: 1 to 32, default=8. Controls the width of data pins.
 * 
 * Amount of memory in the element is 2^addressWidth x bitWidth bits.
 * Minimum RAM size is: 2^1  x  1 = 2 bits.
 * Maximum RAM size is: 2^20 x 32 = 1M x 32 bits => 32 Mbits => 4MB.
 * Maximum 8-bits size: 2^20 x  8 = 1M x 8 bits => 1MB.
 * Default RAM size is: 2^10 x  8 = 1024 bytes => 1KB.
 *
 * RAMs are volatile therefore this component does not persist the memory contents.
 * 
 * Changes to addressWidth and bitWidth also cause data to be lost.
 * Think of these operations as being equivalent to taking a piece of RAM out of a 
 * circuit board and replacing it with another RAM of different size.
 * 
 * The contents of the RAM can be reset to zero by setting the RESET pin 1 or 
 * or by selecting the component and pressing the "Reset" button in the properties window.
 * 
 * The contents of the RAM can be dumped to the console by transitioning CORE DUMP pin to 1
 * or by selecting the component and pressing the "Core Dump" button in the properties window.
 * Address spaces that have not been written will show up as `undefined` in the core dump. 
 * 
 * NOTE: The maximum address width of 20 is arbitrary.
 * Larger values are possible, but in practice circuits won't need this much
 * memory and keeping the value small helps avoid allocating too much memory on the browser.
 * Internally we use a sparse array, so only the addresses that are written are actually
 * allocated. Nevertheless, it is better to prevent large allocations from happening
 * by keeping the max addressWidth small. If needed, we can increase the max.
 */
function RAM(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 8, addressWidth = 10) {
    CircuitElement.call(this, x, y, scope, dir, Math.min(Math.max(1, bitWidth), 32));
    this.setDimensions(60, 40);

    this.directionFixed = true;
    this.labelDirection = "UP";

    this.addressWidth = Math.min(Math.max(1, addressWidth), 20);
    this.address = new Node(-this.leftDimensionX, -20, 0, this, this.addressWidth, "ADDRESS");
    this.dataIn = new Node(-this.leftDimensionX, 0, 0, this, this.bitWidth, "DATA IN");
    this.write = new Node(-this.leftDimensionX, 20, 0, this, 1, "WRITE");
    this.reset = new Node(0, this.downDimensionY, 0, this, 1, "RESET");
    this.coreDump = new Node(-20, this.downDimensionY, 0, this, 1, "CORE DUMP");
    this.dataOut = new Node(this.rightDimensionX, 0, 1, this, this.bitWidth, "DATA OUT");
    this.prevCoreDumpValue = undefined;

    this.clearData()
}
RAM.prototype = Object.create(CircuitElement.prototype);
RAM.prototype.tooltipText = "Random Access Memory";
RAM.prototype.constructor = RAM;
RAM.prototype.mutableProperties = {
    "addressWidth": {
        name: "Address Width",
        type: "number",
        max: "20",
        min: "1",
        func: "changeAddressWidth",
    },
    "dump": {
        name: "Core Dump",
        type: "button",
        func: "dump",
    },
    "reset": {
        name: "Reset",
        type: "button",
        func: "clearData",
    },
}
RAM.prototype.customSave = function () {
    return {
        // NOTE: data is not persisted since RAMs are volatile.
        constructorParamaters: [this.direction, this.bitWidth, this.addressWidth],
        nodes: {
            address: findNode(this.address),
            dataIn: findNode(this.dataIn),
            write: findNode(this.write),
            reset: findNode(this.reset),
            coreDump: findNode(this.coreDump),
            dataOut: findNode(this.dataOut),
        },
    }
}
RAM.prototype.newBitWidth = function (value) {
    value = parseInt(value);
    if (!isNaN(value) && this.bitWidth != value && value >= 1 && value <= 32) {
        this.bitWidth = value;
        this.dataIn.bitWidth = value;
        this.dataOut.bitWidth = value;
        this.clearData();
    }
}
RAM.prototype.changeAddressWidth = function (value) {
    value = parseInt(value);
    if (!isNaN(value) && this.addressWidth != value && value >= 1 && value <= 20) {
        this.addressWidth = value;
        this.address.bitWidth = value;
        this.clearData();
    }
}
RAM.prototype.clearData = function () {
    this.data = new Array(Math.pow(2, this.addressWidth));
    this.tooltipText = this.memSizeString() + " Random Access Memory";
}
RAM.prototype.isResolvable = function () {
    return this.address.value !== undefined || this.reset.value !== undefined || this.coreDump.value !== undefined;
}
RAM.prototype.resolve = function () {
    if (this.write.value == 1) {
        this.data[this.address.value] = this.dataIn.value;
    }

    if (this.reset.value == 1) {
        this.clearData();
    }

    if (this.coreDump.value && this.prevCoreDumpValue != this.coreDump.value) {
        this.dump();
    }
    this.prevCoreDumpValue = this.coreDump.value;

    this.dataOut.value = this.data[this.address.value] || 0;
    simulationArea.simulationQueue.add(this.dataOut);
}
RAM.prototype.customDraw = function () {
    var ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    ctx.strokeStyle = "gray";
    ctx.fillStyle = this.write.value ? "red" : "lightgreen";
    ctx.lineWidth = correctWidth(1);
    drawCircle2(ctx, 50, -30, 3, xx, yy, this.direction);
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    fillText2(ctx, this.memSizeString(), 0, -10, xx, yy, this.direction);
    fillText2(ctx, "RAM", 0, 10, xx, yy, this.direction);
    fillText2(ctx, "A", this.address.x + 12, this.address.y, xx, yy, this.direction);
    fillText2(ctx, "DI", this.dataIn.x + 12, this.dataIn.y, xx, yy, this.direction);
    fillText2(ctx, "W", this.write.x + 12, this.write.y, xx, yy, this.direction);
    fillText2(ctx, "DO", this.dataOut.x - 17, this.dataOut.y, xx, yy, this.direction);
    ctx.fill();
}
RAM.prototype.memSizeString = function () {
    var mag = ['', 'K', 'M'];
    var unit = this.bitWidth == 8 ? "B" : this.bitWidth == 1 ? "b" : " x " + this.bitWidth + 'b';
    var v = Math.pow(2, this.addressWidth);
    var m = 0;
    while (v >= 1024 && m < mag.length - 1) {
        v /= 1024;
        m++;
    }
    return v + mag[m] + unit;
}
RAM.prototype.dump = function () {
    var logLabel = console.group && this.label;
    if (logLabel) {
        console.group(this.label);
    }

    console.log(this.data)

    if (logLabel) {
        console.groupEnd();
    }
}
