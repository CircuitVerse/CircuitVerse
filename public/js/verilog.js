function convertVerilog() {
    var data = verilog.exportVerilog();

    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(data));
    element.setAttribute('download', projectName + ".v");
    element.style.display = 'none';
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}
verilog = {
    exportVerilog:function(){
        var dependencyList = {};
        var completed = {};
        for (id in scopeList)
            dependencyList[id] = scopeList[id].getDependencies();

		//call resetVerilog for the element if it exists 
		//currently for Mux, Demux, Enc, Dec, can be useful for others
		//**** is there a way to not use eval()?
        for (var i = 0; i < circuitElementList.length; i++) {            
            var str = circuitElementList[i] + ".resetVerilog"; // make sure this exists
            if (eval(str)) {
                output += eval(str + "();");
            }
        }

        var output = "";
        for (id in scopeList) {
            output  +=this.exportVerilogScope_r(id,completed,dependencyList);
        }

		//call moduleVerilog to generate the element definition
		//currently for DFF, TFF, Mux, Demux, Enc, Dec, can be useful for others
		//**** is there a way to not use eval()?
        for (var i = 0; i < circuitElementList.length; i++) {            
            var str = circuitElementList[i] + ".moduleVerilog"; // make sure this exists
            if (eval(str)) {
                output += eval(str + "();");
            }
        }
        return output;
    },
    exportVerilogScope:function(scope=globalScope){
        var dependencyList = {};
        var completed = {};
        for (id in scopeList)
            dependencyList[id] = scopeList[id].getDependencies();

        var output = this.exportVerilogScope_r(scope.id,completed,dependencyList);

        return output;

    },
    exportVerilogScope_r: function(id,completed={},dependencyList={}){
        var output = "";
        if (completed[id]) return output;

        for (var i = 0; i < dependencyList[id].length; i++)
            output += this.exportVerilogScope_r(dependencyList[id][i],completed,dependencyList)+"\n";
        completed[id] = true;

        var scope = scopeList[id];
    	// This part is explicitely added to add the SubCircuit and process its outputs
        for(var i = 0; i < scope.Clock.length; i++) {
//            console.log(scope.Clock[i].label);
            if (scope.Clock[i].label == "") {
                scope.Clock[i].label = "clk"+i;
//                console.log(scope.Clock[i].label);
            }
        }
        this.resetLabels(scope);
        this.getReady(scope);

        output += this.generateHeader(scope);
        output += this.generateOutputList(scope); // generate output first to be consistent
        output += this.generateInputList(scope);
        var res = this.processGraph(scope);
        for (bitWidth in scope.verilogWireList){
            if(bitWidth == 1)
                output += "  wire " + scope.verilogWireList[bitWidth].join(", ") + ";\n";
            else
                output += "  wire [" +(bitWidth-1)+":0] " + scope.verilogWireList[bitWidth].join(", ") + ";\n";
        }
        output += res;

        output += "endmodule\n";
        return output;
    },
    processGraph: function(scope=globalScope){
        var res = "";
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
        
        // This part is explicitely added to add the SubCircuit and process its outputs
        for(var i = 0; i < scope.SubCircuit.length; i++){
            order.push(scope.SubCircuit[i]);
            scope.SubCircuit[i].processVerilog();
        }

        // This part is explicitely added to add the Outputs and process its outputs
        for(var i = 0; i < scope.Output.length; i++){
            order.push(scope.Output[i]);
            // scope.Output[i].processVerilog();
        }

        /* for making DigitalLed Output
        // This part is explicitely added to add the DigitalLed and process its outputs
        for(var i = 0; i < scope.DigitalLed.length; i++){
            order.push(scope.DigitalLed[i]);
            // scope.DigitalLed[i].processVerilog();
        }

		// for making HexDisplay Output
        // This part is explicitely added to add the HexDisplay and process its outputs
        for(var i = 0; i < scope.HexDisplay.length; i++){
            order.push(scope.HexDisplay[i]);
            // scope.HexDisplay[i].processVerilog();
        }
        */
        
        // This part is explicitely added to add the Splitter INPUTS and process its outputs
        for(var i = 0; i < scope.Splitter.length; i++){
            if (scope.Splitter[i].inp1.connections[0].type != 1) {
                order.push(scope.Splitter[i]);
                scope.Splitter[i].processVerilog();
            }
        }
        
        while (scope.stack.length || scope.pending.length) {
            if (errorDetected) return;
            if(scope.stack.length)
                elem = scope.stack.pop();
            else
                elem = scope.pending.pop();
            // console.log(elem)
            elem.processVerilog();
            if(elem.objectType != "Node" && elem.objectType != "Clock" 
                && elem.objectType != "Input" && elem.objectType != "Splitter") {
                if(!order.contains(elem))
                    order.push(elem);
            }
            stepCount++;
            if (stepCount > 10000) {
                // console.log(elem)
                showError("Simulation Stack limit exceeded: maybe due to cyclic paths or contention");
                return;
            }
        }
        for(var i = 0; i < order.length;i++) {
            elem = order[i];
            // console.log(elem.objectType);
            // if (elem.blah) console.log(elem.blah());
            res += "  " + elem.generateVerilog() + "\n";
        }
        return res;
    },

    resetLabels: function(scope){
        for(var i=0;i<scope.allNodes.length;i++){
            scope.allNodes[i].verilogLabel="";
        }
    },
    getReady: function(scope=globalScope){
        for(var i=0;i<scope.Input.length;i++){
            if(scope.Input[i].label=="")
                scope.Input[i].label="inp_"+i;
            else
                scope.Input[i].label=this.fixName(scope.Input[i].label)

            scope.Input[i].output1.verilogLabel=scope.Input[i].label;
        }
        for(var i=0;i<scope.ConstantVal.length;i++){
            if(scope.ConstantVal[i].label=="")
                scope.ConstantVal[i].label="const_"+i;
            else
                scope.ConstantVal[i].label=this.fixName(scope.ConstantVal[i].label)

            scope.ConstantVal[i].output1.verilogLabel=scope.ConstantVal[i].label;
        }
        for(var i=0;i<scope.Output.length;i++){
            if(scope.Output[i].label=="")
                scope.Output[i].label="out_"+i;
            else
                scope.Output[i].label=this.fixName(scope.Output[i].label)
        }
        /* for making them output
        for(var i=0;i<scope.DigitalLed.length;i++){
            if(scope.DigitalLed[i].label=="")
                scope.DigitalLed[i].label="led_"+i;
            else
                scope.DigitalLed[i].label=this.fixName(scope.DigitalLed[i].label)
        }
        for(var i=0;i<scope.HexDisplay.length;i++){
            if(scope.HexDisplay[i].label=="")
                scope.HexDisplay[i].label="hexdisp_"+i;
            else
                scope.HexDisplay[i].label=this.fixName(scope.HexDisplay[i].label)
        }
        */
        for(var i=0;i<scope.SubCircuit.length;i++){
            if(scope.SubCircuit[i].label=="")
                scope.SubCircuit[i].label=scope.SubCircuit[i].data.name+"_"+i;
            else
                scope.SubCircuit[i].label=this.fixName(scope.SubCircuit[i].label)
        }
        for(var i=0;i<moduleList.length;i++){
            var m = moduleList[i];
            // console.log(m)
            for(var j=0;j<scope[m].length;j++){
                scope[m][j].verilogLabel = this.fixName(scope[m][j].label) || (scope[m][j].verilogName()+"_"+j);
            }
        }
    },
    generateHeader:function(scope=globalScope){
        var res="\nmodule " + this.fixName(scope.name) + "(";

        var pins = [];
        for(var i=0;i<scope.Output.length;i++){
            pins.push(scope.Output[i].label);
        }
        /* for making them output
        for(var i=0;i<scope.DigitalLed.length;i++){
            pins.push(scope.DigitalLed[i].label);
        }  
        for(var i=0;i<scope.HexDisplay.length;i++){
            pins.push(scope.HexDisplay[i].label);
        }
        */              
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
        for(var i=0;i<scope.Clock.length;i++){
            if(inputs[1])
                inputs[1].push(scope.Clock[i].label);
            else
                inputs[1] = [scope.Clock[i].label];
        }
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
        var outputs={}
        for(var i=0;i<scope.Output.length;i++){
            if(outputs[scope.Output[i].bitWidth])
                outputs[scope.Output[i].bitWidth].push(scope.Output[i].label);
            else
                outputs[scope.Output[i].bitWidth] = [scope.Output[i].label];
        }
        /* for making them output
        for(var i=0;i<scope.DigitalLed.length;i++){
            if(outputs[scope.DigitalLed[i].bitWidth])
                outputs[scope.DigitalLed[i].bitWidth].push(scope.DigitalLed[i].label);
            else
                outputs[scope.DigitalLed[i].bitWidth] = [scope.DigitalLed[i].label];
        }
        for(var i=0;i<scope.HexDisplay.length;i++){
            if(outputs[scope.HexDisplay[i].bitWidth])
                outputs[scope.HexDisplay[i].bitWidth].push(scope.HexDisplay[i].label);
            else
                outputs[scope.HexDisplay[i].bitWidth] = [scope.HexDisplay[i].label];
        }
        */
        var res="";
        for (bitWidth in outputs){
            if(bitWidth==1)
                res+="  output "+ outputs[1].join(",  ") + ";\n";
            else
                res+="  output ["+(bitWidth-1)+":0] "+ outputs[bitWidth].join(", ") + ";\n";
        }

        return res;
    },
    fixNameInv: function(name){
        return name.replace(/ Inverse/g, "_inv").replace(/ /g , "_");
    },
    fixName: function(name){
        return name.replace(/ /g , "_");
    }
}
