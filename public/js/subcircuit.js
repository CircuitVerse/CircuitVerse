function loadSubCircuit(savedData, scope) {
    var v = new SubCircuit(savedData["x"], savedData["y"], scope, savedData["id"], savedData);
    // if(v.version == "1.0"){
    // 	v.version = "2.0";
    // 	v.x-=v.width/2;
    // 	v.y-=v.height/2;
    // }
}

//subCircuit class
function SubCircuit(x, y, scope = globalScope, id = undefined, savedData = undefined) {

    this.id = id || prompt("Enter Id: ");
    var subcircuitScope = scopeList[this.id]; // Scope of the subcircuit

    // Error handing
    if (subcircuitScope == undefined) {
        showError("SubCircuit : " + ((savedData && savedData.title) || this.id) + " Not found");
    } else if (!checkIfBackup(subcircuitScope)) {
        showError("SubCircuit : " + ((savedData && savedData.title) || subcircuitScope.name) + " is an empty circuit");
    } else if (subcircuitScope.checkDependency(scope.id)) {
        showError("Cyclic Circuit Error");
    }

    // Error handling, cleanup
    if (subcircuitScope == undefined || subcircuitScope.checkDependency(scope.id) || !checkIfBackup(subcircuitScope)) {
        if (savedData) {
            for (var i = 0; i < savedData["inputNodes"].length; i++) {
                scope.allNodes[savedData["inputNodes"][i]].deleted = true;

            }
            for (var i = 0; i < savedData["outputNodes"].length; i++) {
                scope.allNodes[savedData["outputNodes"][i]].deleted = true;
            }
        }
        return;

    }

    CircuitElement.call(this, x, y, scope, "RIGHT", 1);
    this.directionFixed = true;
    this.fixedBitWidth = true;

    this.savedData = savedData;
    this.inputNodes = [];
    this.outputNodes = [];
    this.localScope = new Scope();

    if (this.savedData != undefined) {
        updateSubcircuit = true;
        scheduleUpdate();

        this.version = this.savedData["version"] || "1.0";

        this.id = this.savedData["id"];
        for (var i = 0; i < this.savedData["inputNodes"].length; i++) {
            this.inputNodes.push(this.scope.allNodes[this.savedData["inputNodes"][i]]);
            this.inputNodes[i].parent = this;
            this.inputNodes[i].layout_id = subcircuitScope.Input[i].layoutProperties.id
        }
        for (var i = 0; i < this.savedData["outputNodes"].length; i++) {
            this.outputNodes.push(this.scope.allNodes[this.savedData["outputNodes"][i]]);
            this.outputNodes[i].parent = this;
            this.outputNodes[i].layout_id = subcircuitScope.Output[i].layoutProperties.id;
        }
        if (this.version == "1.0") { // For backward compatibility
            this.version = "2.0";
            this.x -= subcircuitScope.layout.width / 2;
            this.y -= subcircuitScope.layout.height / 2;
            for (var i = 0; i < this.inputNodes.length; i++) {
                this.inputNodes[i].x = subcircuitScope.Input[i].layoutProperties.x;
                this.inputNodes[i].y = subcircuitScope.Input[i].layoutProperties.y;
                this.inputNodes[i].leftx = this.inputNodes[i].x;
                this.inputNodes[i].lefty = this.inputNodes[i].y;
            }
            for (var i = 0; i < this.outputNodes.length; i++) {
                this.outputNodes[i].x = subcircuitScope.Output[i].layoutProperties.x;
                this.outputNodes[i].y = subcircuitScope.Output[i].layoutProperties.y;
                this.outputNodes[i].leftx = this.outputNodes[i].x;
                this.outputNodes[i].lefty = this.outputNodes[i].y;
            }

        }

        if (this.version == "2.0") {
            this.leftDimensionX = 0;
            this.upDimensionY = 0;
            this.rightDimensionX = subcircuitScope.layout.width;
            this.downDimensionY = subcircuitScope.layout.height;
        }

        this.nodeList.extend(this.inputNodes);
        this.nodeList.extend(this.outputNodes);

    } else {
        this.version = "2.0";
    }

    this.data = JSON.parse(scheduleBackup(subcircuitScope));
    this.buildCircuit();
    this.makeConnections();

}

SubCircuit.prototype = Object.create(CircuitElement.prototype);
SubCircuit.prototype.constructor = SubCircuit;

SubCircuit.prototype.makeConnections = function() {
    for (let i = 0; i < this.inputNodes.length; i++) {
        this.localScope.Input[i].output1.connectWireLess(this.inputNodes[i]);
        this.localScope.Input[i].output1.subcircuitOverride = true;
    }

    for (let i = 0; i < this.outputNodes.length; i++) {
        this.localScope.Output[i].inp1.connectWireLess(this.outputNodes[i]);
        this.outputNodes[i].subcircuitOverride = true;
    }

}

SubCircuit.prototype.removeConnections = function() {
    for (let i = 0; i < this.inputNodes.length; i++) {
        this.localScope.Input[i].output1.disconnectWireLess(this.inputNodes[i]);
    }

    for (let i = 0; i < this.outputNodes.length; i++)
        this.localScope.Output[i].inp1.disconnectWireLess(this.outputNodes[i]);
}

SubCircuit.prototype.buildCircuit = function() {

    var subcircuitScope = scopeList[this.id];
    loadScope(this.localScope, this.data);
    this.lastUpdated = this.localScope.timeStamp;
    updateSimulation = true;
    updateCanvas = true;

    if (this.savedData == undefined) {
        this.leftDimensionX = 0;
        this.upDimensionY = 0;
        this.rightDimensionX = subcircuitScope.layout.width;
        this.downDimensionY = subcircuitScope.layout.height;

        for (var i = 0; i < subcircuitScope.Output.length; i++) {
            var a = new Node(subcircuitScope.Output[i].layoutProperties.x, subcircuitScope.Output[i].layoutProperties.y, 1, this, subcircuitScope.Output[i].bitWidth);
            a.layout_id = subcircuitScope.Output[i].layoutProperties.id;
            this.outputNodes.push(a);
        }
        for (var i = 0; i < subcircuitScope.Input.length; i++) {
            var a = new Node(subcircuitScope.Input[i].layoutProperties.x, subcircuitScope.Input[i].layoutProperties.y, 0, this, subcircuitScope.Input[i].bitWidth);
            a.layout_id = subcircuitScope.Input[i].layoutProperties.id;
            this.inputNodes.push(a);
        }
    }

}

// Needs to be deprecated, removed
SubCircuit.prototype.reBuild = function() {
    return;
    new SubCircuit(x = this.x, y = this.y, scope = this.scope, this.id)
    this.scope.backups = []; // Because all previous states are invalid now
    this.delete();
    showMessage("Subcircuit: " + subcircuitScope.name + " has been reloaded.")
}

SubCircuit.prototype.reBuildCircuit = function() {
    this.data = JSON.parse(scheduleBackup(scopeList[this.id]));
    this.localScope = new Scope();
    loadScope(this.localScope, this.data);
    this.lastUpdated = this.localScope.timeStamp;
    this.scope.timeStamp = this.localScope.timeStamp;

}

SubCircuit.prototype.reset = function() {

    this.removeConnections();

    var subcircuitScope = scopeList[this.id];

    for (var i = 0; i < subcircuitScope.SubCircuit.length; i++) {
        subcircuitScope.SubCircuit[i].reset();
    }

    if (subcircuitScope.Input.length == 0 && subcircuitScope.Output.length == 0) {
        showError("SubCircuit : " + subcircuitScope.name + " is an empty circuit");
        this.delete();
        this.scope.backups = [];
        return;
    }

    subcircuitScope.layout.height = subcircuitScope.layout.height;
    subcircuitScope.layout.width = subcircuitScope.layout.width;
    this.leftDimensionX = 0;
    this.upDimensionY = 0;
    this.rightDimensionX = subcircuitScope.layout.width;
    this.downDimensionY = subcircuitScope.layout.height;


    var temp_map_inp = {}
    for (var i = 0; i < subcircuitScope.Input.length; i++) {
        temp_map_inp[subcircuitScope.Input[i].layoutProperties.id] = [subcircuitScope.Input[i], undefined];
    }
    for (var i = 0; i < this.inputNodes.length; i++) {
        if (temp_map_inp.hasOwnProperty(this.inputNodes[i].layout_id)) {
            temp_map_inp[this.inputNodes[i].layout_id][1] = this.inputNodes[i];
        } else {
            this.scope.backups = [];
            this.inputNodes[i].delete();
            this.nodeList.clean(this.inputNodes[i])
        }
    }

    for (id in temp_map_inp) {
        if (temp_map_inp[id][1]) {
            if (temp_map_inp[id][0].layoutProperties.x == temp_map_inp[id][1].x && temp_map_inp[id][0].layoutProperties.y == temp_map_inp[id][1].y)
                temp_map_inp[id][1].bitWidth = temp_map_inp[id][0].bitWidth;
            else {
                this.scope.backups = [];
                temp_map_inp[id][1].delete();
                this.nodeList.clean(temp_map_inp[id][1]);
                temp_map_inp[id][1] = new Node(temp_map_inp[id][0].layoutProperties.x, temp_map_inp[id][0].layoutProperties.y, 0, this, temp_map_inp[id][0].bitWidth)
                temp_map_inp[id][1].layout_id = id;
            }
        }
    }

    this.inputNodes = []
    for (var i = 0; i < subcircuitScope.Input.length; i++) {
        var input = temp_map_inp[subcircuitScope.Input[i].layoutProperties.id][0]
        if (temp_map_inp[input.layoutProperties.id][1])
            this.inputNodes.push(temp_map_inp[input.layoutProperties.id][1])
        else {
            var a = new Node(input.layoutProperties.x, input.layoutProperties.y, 0, this, input.bitWidth);
            a.layout_id = input.layoutProperties.id;
            this.inputNodes.push(a);
        }
    }

    var temp_map_out = {}
    for (var i = 0; i < subcircuitScope.Output.length; i++) {
        temp_map_out[subcircuitScope.Output[i].layoutProperties.id] = [subcircuitScope.Output[i], undefined];
    }
    for (var i = 0; i < this.outputNodes.length; i++) {
        if (temp_map_out.hasOwnProperty(this.outputNodes[i].layout_id)) {
            temp_map_out[this.outputNodes[i].layout_id][1] = this.outputNodes[i];
        } else {
            this.outputNodes[i].delete();
            this.nodeList.clean(this.outputNodes[i])
        }
    }

    for (id in temp_map_out) {
        if (temp_map_out[id][1]) {
            if (temp_map_out[id][0].layoutProperties.x == temp_map_out[id][1].x && temp_map_out[id][0].layoutProperties.y == temp_map_out[id][1].y)
                temp_map_out[id][1].bitWidth = temp_map_out[id][0].bitWidth;
            else {
                temp_map_out[id][1].delete();
                this.nodeList.clean(temp_map_out[id][1])
                temp_map_out[id][1] = new Node(temp_map_out[id][0].layoutProperties.x, temp_map_out[id][0].layoutProperties.y, 1, this, temp_map_out[id][0].bitWidth)
                temp_map_out[id][1].layout_id = id
            }
        }
    }

    this.outputNodes = []
    for (var i = 0; i < subcircuitScope.Output.length; i++) {
        var output = temp_map_out[subcircuitScope.Output[i].layoutProperties.id][0]
        if (temp_map_out[output.layoutProperties.id][1])
            this.outputNodes.push(temp_map_out[output.layoutProperties.id][1])
        else {
            var a = new Node(output.layoutProperties.x, output.layoutProperties.y, 1, this, output.bitWidth);
            a.layout_id = output.layoutProperties.id;
            this.outputNodes.push(a);
        }
    }

    if (subcircuitScope.timeStamp > this.lastUpdated) {
        this.reBuildCircuit();
    }

    this.localScope.reset();

    this.makeConnections();



}

SubCircuit.prototype.click = function() {
    // this.id=prompt();
}

SubCircuit.prototype.addInputs = function() {
    for (let i = 0; i < subCircuitInputList.length; i++)
        for (let j = 0; j < this.localScope[subCircuitInputList[i]].length; j++)
            simulationArea.simulationQueue.add(this.localScope[subCircuitInputList[i]][j], 0)
    for (let j = 0; j < this.localScope.SubCircuit.length; j++)
        this.localScope.SubCircuit[j].addInputs();
}
SubCircuit.prototype.isResolvable = function() {
    if (CircuitElement.prototype.isResolvable.call(this))
        return true;
    return false;
}
SubCircuit.prototype.dblclick = function() {
    switchCircuit(this.id)
}
SubCircuit.prototype.saveObject = function() {
    var data = {
        x: this.x,
        y: this.y,
        id: this.id,
        inputNodes: this.inputNodes.map(findNode),
        outputNodes: this.outputNodes.map(findNode),
        version: this.version,
    }
    return data;
}

SubCircuit.prototype.resolve = function() {


    // deprecated
    // var subcircuitScope = this.localScope;//scopeList[this.id];
    // // this.scope.pending.clean(this); // To remove any pending instances
    // // return;
    //
    // for (i = 0; i < subcircuitScope.Input.length; i++) {
    //     subcircuitScope.Input[i].state = this.inputNodes[i].value;
    // }
    //
    // for (i = 0; i < subcircuitScope.Input.length; i++) {
    //     simulationArea.simulationQueue.add(subcircuitScope.Input[i]);
    // }
    // play(subcircuitScope);
    //
    // for (i = 0; i < subcircuitScope.Output.length; i++) {
    //     this.outputNodes[i].value = subcircuitScope.Output[i].inp1.value;
    // }
    // for (i = 0; i < subcircuitScope.Output.length; i++) {
    //     this.scope.stack.push(this.outputNodes[i]);
    // }

}

SubCircuit.prototype.isResolvable = function() {
    return false
}

SubCircuit.prototype.verilogName = function() {
    return verilog.fixName(scopeList[this.id].name);
}

SubCircuit.prototype.customDraw = function() {

    var subcircuitScope = scopeList[this.id];

    ctx = simulationArea.context;

    ctx.lineWidth = globalScope.scale * 3;
    ctx.strokeStyle = "black"; //("rgba(0,0,0,1)");
    ctx.fillStyle = "white";
    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();

    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    if (this.version == "1.0")
        fillText(ctx, subcircuitScope.name, xx, yy - subcircuitScope.layout.height / 2 + 13, 11);
    else if (this.version == "2.0"){
        if(subcircuitScope.layout.titleEnabled){
            fillText(ctx, subcircuitScope.name, subcircuitScope.layout.title_x + xx, yy + subcircuitScope.layout.title_y, 11);
        }
    }
    else
        console.log(this.version)

    for (var i = 0; i < subcircuitScope.Input.length; i++) {
        if (!subcircuitScope.Input[i].label) continue;
        var info = this.determine_label(this.inputNodes[i].x, this.inputNodes[i].y);
        ctx.textAlign = info[0];
        fillText(ctx, subcircuitScope.Input[i].label, this.inputNodes[i].x + info[1] + xx, yy + this.inputNodes[i].y + info[2], 12);
    }

    for (var i = 0; i < subcircuitScope.Output.length; i++) {
        if (!subcircuitScope.Output[i].label) continue;
        var info = this.determine_label(this.outputNodes[i].x, this.outputNodes[i].y);
        ctx.textAlign = info[0];
        fillText(ctx, subcircuitScope.Output[i].label, this.outputNodes[i].x + info[1] + xx, yy + this.outputNodes[i].y + info[2], 12);
    }
    ctx.fill();

    for (var i = 0; i < this.inputNodes.length; i++)
        this.inputNodes[i].draw();
    for (var i = 0; i < this.outputNodes.length; i++)
        this.outputNodes[i].draw();

}
SubCircuit.prototype.centerElement = true; // To center subcircuit when new

SubCircuit.prototype.determine_label = function(x, y) {
    if (x == 0) return ["left", 5, 5]
    if (x == scopeList[this.id].layout.width) return ["right", -5, 5]
    if (y == 0) return ["center", 0, 13]
    return ["center", 0, -6]
}
