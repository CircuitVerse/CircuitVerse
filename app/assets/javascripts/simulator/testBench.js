function TB_Input(x, y, scope = globalScope, dir = "RIGHT",  identifier, testData) {

    CircuitElement.call(this, x, y, scope, dir, 1);
    // this.setDimensions(60,20);

    // this.xSize=10;

    // this.plotValues = [];
    // this.inp1 = new Node(0, 0, 0, this);
    // this.inp1 = new Node(100, 100, 0, this);
    this.setIdentifier (identifier|| "Test1");
    this.testData=testData || {"inputs":[],"outputs":[],"n":0}
    this.clockInp = new Node(0,20, 0,this,1);
    this.outputs = []

    this.running = false;
    this.iteration=0;

    this.setup();

}
TB_Input.prototype = Object.create(CircuitElement.prototype);
TB_Input.prototype.constructor = TB_Input;
TB_Input.prototype.centerElement = true;
TB_Input.prototype.dblclick=function(){
    this.testData=JSON.parse(prompt("Enter TestBench Json"));
    this.setup();
}
TB_Input.prototype.setDimensions=function() {
    this.leftDimensionX = 0;
    this.rightDimensionX = 120;

    this.upDimensionY = 0;
    this.downDimensionY = 40 + this.testData.inputs.length * 20;
}
TB_Input.prototype.setup=function(){

    this.iteration = 0;
    this.running = false;

    this.nodeList.clean(this.clockInp);
    this.deleteNodes();
    this.nodeList = []
    this.nodeList.push(this.clockInp);
    // this.clockInp = new Node(0,20, 0,this,1);

    this.setDimensions();

    this.prevClockState = 0;
    this.outputs = [];

    for(var i = 0; i < this.testData.inputs.length; i++ ){
        this.outputs.push(new Node(this.rightDimensionX, 30+i*20, 1, this, bitWidth = this.testData.inputs[i].bitWidth,label=this.testData.inputs[i].label));
    }

    for(var i =0; i<this.scope.TB_Output.length;i++){
        if(this.scope.TB_Output[i].identifier == this.identifier)
            this.scope.TB_Output[i].setup();
    }
}

TB_Input.prototype.toggleState=function(){
    this.running=!this.running;
    this.prevClockState=0;
}
TB_Input.prototype.resetIterations=function(){
    this.iteration=0;
    this.prevClockState=0;
}
TB_Input.prototype.resolve=function(){
    if(this.clockInp.value !=  this.prevClockState){
        this.prevClockState = this.clockInp.value;
        if(this.clockInp.value == 1 && this.running){
            if(this.iteration<this.testData.n){
                this.iteration++;
            }
            else{
                this.running = false;
            }
        }
    }
    if(this.running && this.iteration)
    for(var i=0;i<this.testData.inputs.length;i++){
        console.log(this.testData.inputs[i].values[this.iteration-1]);
        this.outputs[i].value = parseInt(this.testData.inputs[i].values[this.iteration-1],2);
        simulationArea.simulationQueue.add(this.outputs[i]);
    }

}

TB_Input.prototype.setPlotValue = function() {
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
TB_Input.prototype.customSave = function() {
    var data = {
        constructorParamaters: [this.direction,   this.identifier, this.testData],
        nodes: {
            outputs: this.outputs.map(findNode),
            clockInp: findNode(this.clockInp)
        },
    }
    return data;
}
TB_Input.prototype.setIdentifier = function(id = "") {
    if (id.length == 0 || id==this.identifier) return;


    for(var i =0; i<this.scope.TB_Output.length;i++){
        this.scope.TB_Output[i].checkPairing();
    }


    for(var i =0; i<this.scope.TB_Output.length;i++){
        if(this.scope.TB_Output[i].identifier == this.identifier)
            this.scope.TB_Output[i].identifier = id;
    }

    this.identifier = id;

    this.checkPaired();
}
TB_Input.prototype.checkPaired=function(){
    for(var i =0; i<this.scope.TB_Output.length;i++){
        if(this.scope.TB_Output[i].identifier == this.identifier)
            this.scope.TB_Output[i].checkPairing();
    }
}
TB_Input.prototype.delete = function () {
    CircuitElement.prototype.delete.call(this)
    this.checkPaired();
}
TB_Input.prototype.mutableProperties = {
    "identifier": {
        name: "TestBench Name:",
        type: "text",
        maxlength: "10",
        func: "setIdentifier",
    },
    "iteration": {
        name: "Reset Iterations",
        type: "button",
        func: "resetIterations",
    },
    "toggleState": {
        name: "Toggle State",
        type: "button",
        func: "toggleState",
    },
}
TB_Input.prototype.customDraw = function() {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "grey";
    ctx.fillStyle = "#fcfcfc";
    ctx.lineWidth = correctWidth(1);
    var xx = this.x;
    var yy = this.y;

    var xRotate=0;
    var yRotate=0;
    if(this.direction=="LEFT") {
        xRotate=0;
        yRotate=0;
    }else if(this.direction=="RIGHT") {
        xRotate=120-this.xSize;
        yRotate=0;
    }else if(this.direction=="UP") {
        xRotate=60-this.xSize/2;
        yRotate=-20;
    }else{
        xRotate=60-this.xSize/2;
        yRotate=20;
    }

    // rect2(ctx, -120+xRotate+this.xSize, -20+yRotate, 120-this.xSize, 40, xx, yy, "RIGHT");
    // if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
    //     ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    // ctx.fill();
    // ctx.stroke();
    //
    // ctx.font = "14px Georgia";
    // this.xOff = ctx.measureText(this.identifier).width;
    // ctx.beginPath();
    // rect2(ctx, -105+xRotate+this.xSize, -11+yRotate,this.xOff + 10, 23, xx, yy, "RIGHT");
    // ctx.fillStyle = "#eee"
    // ctx.strokeStyle = "#ccc";
    // ctx.fill();
    // ctx.stroke();
    //




    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    fillText(ctx, this.identifier + " [INPUT]", xx + this.rightDimensionX/ 2 , yy + 14 , 10);

    fillText(ctx, ["Not Running","Running"][+this.running], xx + this.rightDimensionX/ 2 , yy + 14 + 10 + 20*this.testData.inputs.length, 10);
    fillText(ctx, "Case: "+(this.iteration), xx + this.rightDimensionX/ 2 , yy + 14 + 20 + 20*this.testData.inputs.length, 10);
    // fillText(ctx, "Case: "+this.iteration, xx  , yy + 20+14, 10);
    ctx.fill();


    ctx.font = "30px Georgia";
    ctx.textAlign = "right";
    ctx.fillStyle = "blue";
    ctx.beginPath();
    for(var i=0;i<this.testData.inputs.length;i++){
        // ctx.beginPath();
        fillText(ctx, this.testData.inputs[i].label , this.rightDimensionX - 5 + xx , 30+i*20 + yy+4, 10);

    }

    ctx.fill();
    if(this.running && this.iteration){
        ctx.font = "30px Georgia";
        ctx.textAlign = "left";
        ctx.fillStyle = "blue";
        ctx.beginPath();
        for(var i=0;i<this.testData.inputs.length;i++){
            fillText(ctx, this.testData.inputs[i].values[this.iteration-1] , 5 + xx , 30+i*20 + yy+4, 10);
        }

        ctx.fill();
    }

    //
    //
    // ctx.font = "30px Georgia";
    // ctx.textAlign = "center";
    // ctx.fillStyle = ["blue", "red"][+(this.inp1.value == undefined)];
    // if (this.inp1.value !== undefined)
    //     fillText(ctx, this.inp1.value.toString(16), xx - 23 + xRotate, yy + 8 + yRotate, 25);
    // else
    //     fillText(ctx, "x", xx - 23 + xRotate, yy + 8 + yRotate, 25);
    // ctx.fill();

    ctx.beginPath();
    ctx.strokeStyle = ("rgba(0,0,0,1)");
    ctx.lineWidth = correctWidth(3);
    var xx = this.x;
    var yy = this.y;
    // rect(ctx, xx - 20, yy - 20, 40, 40);
    moveTo(ctx, 0, 15, xx, yy, this.direction);
    lineTo(ctx, 5, 20, xx, yy, this.direction);
    lineTo(ctx, 0, 25, xx, yy, this.direction);

    ctx.stroke();
}










function TB_Output(x, y, scope = globalScope, dir = "RIGHT",  identifier) {

    CircuitElement.call(this, x, y, scope, dir, 1);
    // this.setDimensions(60,20);

    // this.xSize=10;

    // this.plotValues = [];
    // this.inp1 = new Node(0, 0, 0, this);
    // this.inp1 = new Node(100, 100, 0, this);
    this.setIdentifier (identifier|| "Test1");
    this.inputs = []
    this.testBenchInput = undefined;

    this.setup();

}

TB_Output.prototype = Object.create(CircuitElement.prototype);
TB_Output.prototype.constructor = TB_Output;
TB_Output.prototype.centerElement = true;
// TB_Output.prototype.dblclick=function(){
//     this.testData=JSON.parse(prompt("Enter TestBench Json"));
//     this.setup();
// }
TB_Output.prototype.setDimensions=function() {
    this.leftDimensionX = 0;
    this.rightDimensionX = 160;

    this.upDimensionY = 0;
    this.downDimensionY = 40;
    if(this.testBenchInput)
    this.downDimensionY = 40 + this.testBenchInput.testData.outputs.length * 20;
}
TB_Output.prototype.setup = function(){

    // this.iteration = 0;
    // this.running = false;

    // this.nodeList.clean(this.clockInp);
    this.deleteNodes();
    this.nodeList = []



    this.inputs = [];
    this.testBenchInput = undefined;
    for(var i=0;i<this.scope.TB_Input.length;i++){
        if(this.scope.TB_Input[i].identifier == this.identifier) {
            this.testBenchInput = this.scope.TB_Input[i];
            break;
        }
    }

    this.setDimensions();

    if(this.testBenchInput){
        for(var i = 0; i < this.testBenchInput.testData.outputs.length; i++ ){
            this.inputs.push(new Node(0, 30+i*20, NODE_INPUT, this, bitWidth = this.testBenchInput.testData.outputs[i].bitWidth,label=this.testBenchInput.testData.outputs[i].label));
        }
    }

}

// TB_Output.prototype.toggleState=function(){
//     this.running=!this.running;
//     this.prevClockState=0;
// }
// TB_Output.prototype.resetIterations=function(){
//     this.iteration=0;
//     this.prevClockState=0;
// }
// TB_Output.prototype.resolve=function(){
//     if(this.clockInp.value !=  this.prevClockState){
//         this.prevClockState = this.clockInp.value;
//         if(this.clockInp.value == 1 && this.running){
//             if(this.iteration<this.testData.n){
//                 this.iteration++;
//             }
//             else{
//                 this.running = false;
//             }
//         }
//     }
//     if(this.running && this.iteration)
//     for(var i=0;i<this.testData.inputs.length;i++){
//         console.log(this.testData.inputs[i].values[this.iteration-1]);
//         this.outputs[i].value = parseInt(this.testData.inputs[i].values[this.iteration-1],2);
//         simulationArea.simulationQueue.add(this.outputs[i]);
//     }
//
// }
// TB_Output.prototype.setPlotValue = function() {
//     var time = plotArea.stopWatch.ElapsedMilliseconds;
//     if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] == time)
//         this.plotValues.pop();
//
//     if (this.plotValues.length == 0) {
//         this.plotValues.push([time, this.inp1.value]);
//         return;
//     }
//
//     if (this.plotValues[this.plotValues.length - 1][1] == this.inp1.value)
//         return;
//     else
//         this.plotValues.push([time, this.inp1.value]);
// }
TB_Output.prototype.customSave = function() {
    var data = {
        constructorParamaters: [this.direction,   this.identifier],
        nodes: {
            inputs: this.inputs.map(findNode),
        },
    }
    return data;
}
TB_Output.prototype.setIdentifier = function(id = "") {
    if (id.length == 0 || id==this.identifier) return;
    this.identifier = id;
    this.setup();
}
TB_Output.prototype.checkPairing = function(id = "") {
    if(this.testBenchInput){
        if(this.testBenchInput.deleted || this.testBenchInput.identifier!=this.identifier){
            this.setup();
        }
    }
    else {
        this.setup();
    }
}
TB_Output.prototype.mutableProperties = {
    "identifier": {
        name: "TestBench Name:",
        type: "text",
        maxlength: "10",
        func: "setIdentifier",
    },
}

TB_Output.prototype.customDraw = function() {
    ctx = simulationArea.context;
    ctx.beginPath();
    ctx.strokeStyle = "grey";
    ctx.fillStyle = "#fcfcfc";
    ctx.lineWidth = correctWidth(1);
    var xx = this.x;
    var yy = this.y;

    var xRotate=0;
    var yRotate=0;
    if(this.direction=="LEFT") {
        xRotate=0;
        yRotate=0;
    }else if(this.direction=="RIGHT") {
        xRotate=120-this.xSize;
        yRotate=0;
    }else if(this.direction=="UP") {
        xRotate=60-this.xSize/2;
        yRotate=-20;
    }else{
        xRotate=60-this.xSize/2;
        yRotate=20;
    }

    // rect2(ctx, -120+xRotate+this.xSize, -20+yRotate, 120-this.xSize, 40, xx, yy, "RIGHT");
    // if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this))
    //     ctx.fillStyle = "rgba(255, 255, 32,0.8)";
    // ctx.fill();
    // ctx.stroke();
    //
    // ctx.font = "14px Georgia";
    // this.xOff = ctx.measureText(this.identifier).width;
    // ctx.beginPath();
    // rect2(ctx, -105+xRotate+this.xSize, -11+yRotate,this.xOff + 10, 23, xx, yy, "RIGHT");
    // ctx.fillStyle = "#eee"
    // ctx.strokeStyle = "#ccc";
    // ctx.fill();
    // ctx.stroke();
    //




    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    fillText(ctx, this.identifier + " [OUTPUT]", xx + this.rightDimensionX/ 2 , yy + 14 , 10);

    // fillText(ctx, ["Not Running","Running"][+this.running], xx + this.rightDimensionX/ 2 , yy + 14 + 10 + 20*this.testData.inputs.length, 10);
    // fillText(ctx, "Case: "+(this.iteration), xx + this.rightDimensionX/ 2 , yy + 14 + 20 + 20*this.testData.inputs.length, 10);
    fillText(ctx, ["Unpaired","Paired"][ +(this.testBenchInput!=undefined)], xx + this.rightDimensionX/ 2 , yy + this.downDimensionY - 5, 10);
    ctx.fill();




    if(this.testBenchInput){
        ctx.beginPath();
        ctx.font = "30px Georgia";
        ctx.textAlign = "left";
        ctx.fillStyle = "blue";
        for(var i=0;i<this.testBenchInput.testData.outputs.length;i++){
            // ctx.beginPath();
            fillText(ctx, this.testBenchInput.testData.outputs[i].label ,  5 + xx , 30+i*20 + yy+4, 10);

        }
        ctx.fill();

        if(this.testBenchInput.running && this.testBenchInput.iteration){
            ctx.beginPath();
            ctx.font = "30px Georgia";
            ctx.textAlign = "right";
            ctx.fillStyle = "blue";
            ctx.beginPath();
            for(var i=0;i<this.testBenchInput.testData.outputs.length;i++){
                fillText(ctx, this.testBenchInput.testData.outputs[i].values[this.testBenchInput.iteration-1] ,  xx +this.rightDimensionX-5 , 30+i*20 + yy+4, 10);
            }

            ctx.fill();
        }

        if(this.testBenchInput.running && this.testBenchInput.iteration){
            ctx.beginPath();
            ctx.font = "30px Georgia";
            ctx.textAlign = "center";
            ctx.fillStyle = "blue";

            for(var i=0;i<this.testBenchInput.testData.outputs.length;i++){
                if(this.inputs[i].value!=undefined){
                    ctx.beginPath();
                    if(this.testBenchInput.testData.outputs[i].values[this.testBenchInput.iteration-1]=="x"||parseInt(this.testBenchInput.testData.outputs[i].values[this.testBenchInput.iteration-1],2)==this.inputs[i].value)
                        ctx.fillStyle="green"
                    else
                        ctx.fillStyle="red"
                    fillText(ctx, dec2bin(this.inputs[i].value,this.inputs[i].bitWidth) ,  xx +this.rightDimensionX/2 , 30+i*20 + yy+4, 10);
                    ctx.fill();
                }
                else{
                    ctx.beginPath();
                    if(this.testBenchInput.testData.outputs[i].values[this.testBenchInput.iteration-1]=="x")
                        ctx.fillStyle="green"
                    else
                        ctx.fillStyle="red"
                    fillText(ctx, "X" ,  xx +this.rightDimensionX/2 , 30+i*20 + yy+4, 10);
                    ctx.fill();
                }

            }


        }


    }



    //
    //
    // ctx.font = "30px Georgia";
    // ctx.textAlign = "center";
    // ctx.fillStyle = ["blue", "red"][+(this.inp1.value == undefined)];
    // if (this.inp1.value !== undefined)
    //     fillText(ctx, this.inp1.value.toString(16), xx - 23 + xRotate, yy + 8 + yRotate, 25);
    // else
    //     fillText(ctx, "x", xx - 23 + xRotate, yy + 8 + yRotate, 25);
    // ctx.fill();

}
