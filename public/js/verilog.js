/*
    # Primary Developers
    1) James H-J Yeh, Ph.D.
    2) Satvik Ramaprasad

    refer verilog_documentation.md 
*/

function generateVerilog() {
    var data = verilog.exportVerilog();
    download(projectName + ".v", data);
}

verilog = {
    // Entry point to verilog generation
    // scope = undefined means export all circuits
    exportVerilog:function(scope = undefined){
        var dependencyList = {};
        
        // Generate SubCircuit Dependency Graph
        for (id in scopeList)
            dependencyList[id] = scopeList[id].getDependencies();

        // DFS on SubCircuit Dependency Graph
        var visited = {};
        var elementTypesUsed = new Set();
        var output = "";
        if(scope) {
            // generate verilog only for scope
            output += this.exportVerilogScope(scope.id,visited,dependencyList, elementTypesUsed);
        }
        else {
            // generate verilog for everything
            for (id in scopeList) {
                output += this.exportVerilogScope(id,visited,dependencyList, elementTypesUsed);
            }
        }
        // Add Circuit Element - Module Specific Verilog Code
        for(var element of elementTypesUsed) {
            // If element has custom verilog
            if (window[element].moduleVerilog) {
                output += window[element].moduleVerilog();
            }
        }
        return output;
    },
    // Recursive DFS function
    exportVerilogScope: function(id,visited,dependencyList, elementTypesUsed){
        // Already Visited
        if (visited[id]) return "";
        // Mark as Visited
        visited[id] = true;

        var output = "";
        // DFS on dependencies
        for (var i = 0; i < dependencyList[id].length; i++)
            output += this.exportVerilogScope(dependencyList[id][i],visited,dependencyList, elementTypesUsed)+"\n";

        var scope = scopeList[id];
        // Initialize labels for all elements
        this.resetLabels(scope);
        this.setLabels(scope);

        output += this.generateHeader(scope);
        output += this.generateOutputList(scope); // generate output first to be consistent
        output += this.generateInputList(scope);

         // Note: processGraph function populates scope.verilogWireList
        var res = this.processGraph(scope, elementTypesUsed);

        // Generate Wire Initialization Code
        for (var bitWidth = 1; bitWidth<= 32; bitWidth++){
            if(scope.verilogWireList[bitWidth].length == 0) 
                continue;
            if(bitWidth == 1)
                output += "  wire " + scope.verilogWireList[bitWidth].join(", ") + ";\n";
            else
                output += "  wire [" +(bitWidth-1)+":0] " + scope.verilogWireList[bitWidth].join(", ") + ";\n";
        }

        // Append Wire connections and module instantiations
        output += res;

        // Append footer
        output += "endmodule\n";
        return output;
    },
    // Performs DFS on the graph and generates netlist of wires and connections
    processGraph: function(scope, elementTypesUsed){
        // Initializations
        var res = "";
        scope.stack = [];
        scope.verilogWireList = [];
        for(var i = 0; i <= 32; i++)
            scope.verilogWireList.push(new Array());

        var verilogResolvedSet = new Set();
            
        // Start DFS from inputs
        for (var i = 0; i < inputList.length; i++) {
            for (var j = 0; j < scope[inputList[i]].length; j++) {
                scope.stack.push(scope[inputList[i]][j]);
            }
        }
        
        // Iterative DFS on circuit graph
        while (scope.stack.length) {
            if (errorDetected) return;
            var elem = scope.stack.pop();

            if(verilogResolvedSet.has(elem))
                continue;

            // Process verilog creates variable names and adds elements to DFS stack
            elem.processVerilog();

            // Record usage of element type
            elementTypesUsed.add(elem.objectType);

            if(elem.objectType!="Node" && elem.objectType!="Input") {
                verilogResolvedSet.add(elem);
            }
        }

        // Generate connection verilog code and module instantiations
        for(var elem of verilogResolvedSet) {
            res += "  " + elem.generateVerilog() + "\n";
        }
        return res;
    },

    resetLabels: function(scope){
        for(var i=0;i<scope.allNodes.length;i++){
            scope.allNodes[i].verilogLabel="";
        }
    },
    // Sets labels for all Circuit Elements elements
    setLabels: function(scope=globalScope){
        /**
         * Sets a name for each element. If element is already labeled,
         * the element is used directly, otherwise an automated label is provided
         * santizeLabel is a helper function to escape white spaces
         */
        for(var i=0;i<scope.Input.length;i++){
            if(scope.Input[i].label=="")
                scope.Input[i].label="inp_"+i;
            else
                scope.Input[i].label=this.santizeLabel(scope.Input[i].label)
            // copy label to node
            scope.Input[i].output1.verilogLabel = scope.Input[i].label;
        }
        for(var i=0;i<scope.ConstantVal.length;i++){
            if(scope.ConstantVal[i].label=="")
                scope.ConstantVal[i].label="const_"+i;
            else
                scope.ConstantVal[i].label=this.santizeLabel(scope.ConstantVal[i].label)
            // copy label to node
            scope.ConstantVal[i].output1.verilogLabel=scope.ConstantVal[i].label;
        }
        for(var i=0;i<scope.Output.length;i++){
            if(scope.Output[i].label=="")
                scope.Output[i].label="out_"+i;
            else
                scope.Output[i].label=this.santizeLabel(scope.Output[i].label)
        }
        for(var i=0;i<scope.SubCircuit.length;i++){
            if(scope.SubCircuit[i].label=="")
                scope.SubCircuit[i].label=scope.SubCircuit[i].data.name+"_"+i;
            else
                scope.SubCircuit[i].label=this.santizeLabel(scope.SubCircuit[i].label)
        }
        for(var i=0;i<moduleList.length;i++){
            var m = moduleList[i];
            for(var j=0;j<scope[m].length;j++){
                scope[m][j].verilogLabel = this.santizeLabel(scope[m][j].label) || (scope[m][j].verilogName()+"_"+j);
            }
        }
    },
    generateHeader:function(scope=globalScope){
        // Example: module HalfAdder (a,b,s,c);
        var res="\nmodule " + this.santizeLabel(scope.name) + "(";
        var pins = [];
        for(var i=0;i<scope.Output.length;i++){
            pins.push(scope.Output[i].label);
        }
        for(var i=0;i<scope.Clock.length;i++){
            pins.push(scope.Clock[i].label);
        }
        for(var i=0;i<scope.Input.length;i++){
            pins.push(scope.Input[i].label);
        }
        res += pins.join(", ");
        res += ");\n";
        return res;
    },
    generateInputList:function(scope=globalScope){
        var inputs={}
        for(var i=0;i<scope.Input.length;i++){
            if(inputs[scope.Input[i].bitWidth])
                inputs[scope.Input[i].bitWidth].push(scope.Input[i].label);
            else
                inputs[scope.Input[i].bitWidth] = [scope.Input[i].label];
        }
        var res="";
        for (bitWidth in inputs){
            if(bitWidth==1)
                res+="  input "+ inputs[1].join(", ") + ";\n";
            else
                res+="  input ["+(bitWidth-1)+":0] "+ inputs[bitWidth].join(", ") + ";\n";
        }

        return res;
    },
    generateOutputList:function(scope=globalScope){
        // Example 1: output s,cout;
        var outputs={}
        for(var i=0;i<scope.Output.length;i++){
            if(outputs[scope.Output[i].bitWidth])
                outputs[scope.Output[i].bitWidth].push(scope.Output[i].label);
            else
                outputs[scope.Output[i].bitWidth] = [scope.Output[i].label];
        }
        var res="";
        for (bitWidth in outputs){
            if(bitWidth==1)
                res+="  output "+ outputs[1].join(",  ") + ";\n";
            else
                res+="  output ["+(bitWidth-1)+":0] "+ outputs[bitWidth].join(", ") + ";\n";
        }

        return res;
    },
    santizeLabel: function(name){
        return name.replace(/ Inverse/g, "_inv").replace(/ /g , "_");
    },
    generateNodeName: function(node, currentCount, totalCount) {
        if(node.verilogLabel) return node.verilogLabel;
        var parentVerilogLabel = node.verilogLabel;
        var nodeName;
        if(node.label) {
            nodeName = verilog.santizeLabel(node.label);
        }
        else {
            nodeName = (totalCount > 1) ? "out_" + currentCount: "out";
        }
        return parentVerilogLabel + "_" + nodeName;
    }
}
