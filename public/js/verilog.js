/**
 * @typedef {Object} verilog
 */
verilog = {
    /**
     * @method
     * return the verilog for the project
     * @return {string}
     */
    exportVerilog() {
        var dependencyList = {};
        var completed = {};
        for (id in scopeList) {dependencyList[id] = scopeList[id].getDependencies();}
        var output = '';
        for (id in scopeList) {output+=this.exportVerilogScope_r(id,completed,dependencyList);}
        return output;
    },
    /**
     * returns verilog of a scope
     * @param {Scope=} scope - whose verilog we want
     * @return {string}
     */
    exportVerilogScope(scope = globalScope) {
        var dependencyList = {};
        var completed = {};
        for (id in scopeList) {dependencyList[id] = scopeList[id].getDependencies();}

        var output = this.exportVerilogScope_r(scope.id, completed, dependencyList);

        return output;
    },
    /**
     * A reccursive function to get verilog of a scope and all it's subcircuits
     * @param {number} id - the iterator over scopes
     * @param {array} completed - a boolean array, true if subcircuit dependencies for a circuit it has been added
     * @param {JSON} dependencyList - contains the id's of subcircuits a circuit depends on
     */
    exportVerilogScope_r(id, completed = {}, dependencyList = {}) {
        var output = '';
        if (completed[id]) return output;

        for (var i = 0; i < dependencyList[id].length; i++) {output+=this.exportVerilogScope_r(dependencyList[id][i],completed,dependencyList)+"\n";}
        completed[id] = true;

        var scope = scopeList[id];
        this.resetLabels(scope);
        this.getReady(scope);

        output += this.generateHeader(scope);
        output += this.generateInputList(scope);
        output += this.generateOutputList(scope);
        var res = this.processGraph(scope);
        for (bitWidth in scope.verilogWireList) {
            if (bitWidth == 1) {output+="wire "+ scope.verilogWireList[bitWidth].join(",") + ";\n";}
            else {output+="wire ["+(bitWidth-1)+":0] "+ scope.verilogWireList[bitWidth].join(",") + ";\n";}
        }
        output += res;

        output += 'endmodule\n';
        return output;
    },
    /**
     * Function to get process graph
     * @param {Scope} scope - scope for which we want process graph
     */
    processGraph(scope = globalScope) {
        var res = '';
        scope.stack = [];
        scope.pending = [];
        scope.verilogWireList = {};

        for (var i = 0; i < inputList.length; i++) {
            for (var j = 0; j < scope[inputList[i]].length; j++) {
                scope.stack.push(scope[inputList[i]][j]);
            }
        }
        var stepCount = 0;
        var elem = undefined;

        var order = [];

        while (scope.stack.length || scope.pending.length) {
            if (errorDetected) return;
            if (scope.stack.length) {elem = scope.stack.pop();}
            else {elem = scope.pending.pop();}
            // console.log(elem)
            elem.processVerilog();
            if (elem.objectType != 'Node' && elem.objectType != 'Input' && elem.objectType != 'Splitter') {
                if (!order.contains(elem)) {order.push(elem);}
            }
            stepCount++;
            if (stepCount > 10000) {
                // console.log(elem)
                showError('Simulation Stack limit exceeded: maybe due to cyclic paths or contention');
                return;
            }
        }
        for (var i = 0; i < order.length; i++) {res += order[i].generateVerilog() + "\n";}
        return res;
    },
    /**
     * function to resey verilog labels of all nodes
     * @param {Scope} scope
     */
    resetLabels(scope) {
        for (var i = 0; i < scope.allNodes.length; i++) {
            scope.allNodes[i].verilogLabel = '';
        }
    },
    /**
     * function called to setup getVerilogForScope_r()
     * @param {Scope} scope 
     */
    getReady(scope = globalScope) {
        for (var i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].label == '') {scope.Input[i].label="Inp_"+i;}
            else {scope.Input[i].label=this.fixName(scope.Input[i].label)};

            scope.Input[i].output1.verilogLabel = scope.Input[i].label;
        }

        for (var i = 0; i < scope.ConstantVal.length; i++) {
            if (scope.ConstantVal[i].label == '') {scope.ConstantVal[i].label="Constant_"+i;}
            else {scope.ConstantVal[i].label=this.fixName(scope.ConstantVal[i].label)};

            scope.ConstantVal[i].output1.verilogLabel = scope.ConstantVal[i].label;
        }
        for (var i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].label == '') {scope.Output[i].label="Out_"+i;}
            else {scope.Output[i].label=this.fixName(scope.Output[i].label)};
        }

        for (var i = 0; i < moduleList.length; i++) {
            var m = moduleList[i];
            for (var j = 0; j < scope[m].length; j++) {
                scope[m][j].verilogLabel = this.fixName(scope[m][j].label) || (`${scope[m][j].verilogName()}_${j}`);
            }
        }
    },
    /**
     * generate header for the verilog
     * @param {Scope} scope 
     * @return {string}
     */
    generateHeader(scope = globalScope) {
        return 'module ' + this.fixName(scope.name) + ' (' + scope.Input.map((x) => {return x.label}).join(',') + ',' + scope.Output.map((x) => {return x.label}).join(',') + ');\n';
    },
    /**
     * generate input list for the verilog
     * @param {Scope} scope
     * @return {string}
     */
    generateInputList(scope = globalScope) {
        var inputs = {};
        for (var i = 0; i < scope.Input.length; i++) {
            if (inputs[scope.Input[i].bitWidth]) {inputs[scope.Input[i].bitWidth].push(scope.Input[i].label);}
            else {inputs[scope.Input[i].bitWidth] = [scope.Input[i].label];}
        }
        var res = '';
        for (bitWidth in inputs) {
            if (bitWidth == 1) {res+="input "+ inputs[1].join(",") + ";\n";}
            else {res+="input ["+(bitWidth-1)+":0] "+ inputs[bitWidth].join(",") + ";\n";}
        }

        return res;
    },
    /**
     * generate output list for the verilog
     * @param {Scope} scope
     * @return {string}
     */
    generateOutputList(scope = globalScope) {
        var outputs = {};
        for (var i = 0; i < scope.Output.length; i++) {
            if (outputs[scope.Output[i].bitWidth]) {outputs[scope.Output[i].bitWidth].push(scope.Output[i].label);}
            else {outputs[scope.Output[i].bitWidth] = [scope.Output[i].label];}
        }
        var res = '';
        for (bitWidth in outputs) {
            if (bitWidth == 1) {res+="output "+ outputs[1].join(",") + ";\n";}
            else {res+="output ["+(bitWidth-1)+":0] "+ outputs[bitWidth].join(",") + ";\n";}
        }

        return res;
    },
    /**
     * Helper function to replace space by underscore
     * @param {string} name 
     */
    fixName(name) {
        return name.replace(/ /g, '_');
    },
};
