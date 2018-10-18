



verilog={

    exportVerilog:function(){
        var dependencyList = {};
        var completed = {};
        for (id in scopeList)
            dependencyList[id] = scopeList[id].getDependencies();

        var output="";
        for (id in scopeList)
            output+=this.exportVerilogScope_r(id,completed,dependencyList);

        return output;

    },
    exportVerilogScope:function(scope=globalScope){
        var dependencyList = {};
        var completed = {};
        for (id in scopeList)
            dependencyList[id] = scopeList[id].getDependencies();

        var output=this.exportVerilogScope_r(scope.id,completed,dependencyList);

        return output;

    },
    exportVerilogScope_r: function(id,completed={},dependencyList={}){
        var output="";
        if (completed[id]) return output;

        for (var i = 0; i < dependencyList[id].length; i++)
            output+=this.exportVerilogScope_r(dependencyList[id][i],completed,dependencyList)+"\n";
        completed[id] = true;

        var scope = scopeList[id];
        this.resetLabels(scope);
        this.getReady(scope);

        output+=this.generateHeader(scope);
        output+=this.generateInputList(scope);
        output+=this.generateOutputList(scope);
        var res=this.processGraph(scope);
        for (bitWidth in scope.verilogWireList){
            if(bitWidth==1)
                output+="wire "+ scope.verilogWireList[bitWidth].join(",") + ";\n";
            else
                output+="wire ["+(bitWidth-1)+":0] "+ scope.verilogWireList[bitWidth].join(",") + ";\n";
        }
        output+=res;

        output+="endmodule\n";
        return output;
    },
    processGraph: function(scope=globalScope){

        var res=""
        scope.stack=[];
        scope.pending=[];
        scope.verilogWireList={};

        for (var i = 0; i < inputList.length; i++) {
            for (var j = 0; j < scope[inputList[i]].length; j++) {
                scope.stack.push(scope[inputList[i]][j]);
            }
        }
        var stepCount = 0;
        var elem = undefined;

        var order=[];

        while (scope.stack.length || scope.pending.length) {
            if (errorDetected) return;
            if(scope.stack.length)
                elem = scope.stack.pop();
            else
                elem = scope.pending.pop();
            // console.log(elem)
            elem.processVerilog();
            if(elem.objectType!="Node" && elem.objectType!="Input"&& elem.objectType!="Splitter") {
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
        for(var i=0;i<order.length;i++)
            res += order[i].generateVerilog() + "\n";
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
                scope.Input[i].label="Inp_"+i;
            else
                scope.Input[i].label=this.fixName(scope.Input[i].label)

            scope.Input[i].output1.verilogLabel=scope.Input[i].label;
        }

        for(var i=0;i<scope.ConstantVal.length;i++){
            if(scope.ConstantVal[i].label=="")
                scope.ConstantVal[i].label="Constant_"+i;
            else
                scope.ConstantVal[i].label=this.fixName(scope.ConstantVal[i].label)

            scope.ConstantVal[i].output1.verilogLabel=scope.ConstantVal[i].label;
        }
        for(var i=0;i<scope.Output.length;i++){
            if(scope.Output[i].label=="")
                scope.Output[i].label="Out_"+i;
            else
                scope.Output[i].label=this.fixName(scope.Output[i].label)
        }

        for(var i=0;i<moduleList.length;i++){
            var m = moduleList[i];
            for(var j=0;j<scope[m].length;j++){
                scope[m][j].verilogLabel = this.fixName(scope[m][j].label) || (scope[m][j].verilogName()+"_"+j);
            }
        }

    },
    generateHeader:function(scope=globalScope){
        return "module "+this.fixName(scope.name)+" (" + scope.Input.map(function(x){return x.label}).join(",") + ","+scope.Output.map(function(x){return x.label}).join(",")  +");\n";
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
                res+="input "+ inputs[1].join(",") + ";\n";
            else
                res+="input ["+(bitWidth-1)+":0] "+ inputs[bitWidth].join(",") + ";\n";
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
        var res="";
        for (bitWidth in outputs){
            if(bitWidth==1)
                res+="output "+ outputs[1].join(",") + ";\n";
            else
                res+="output ["+(bitWidth-1)+":0] "+ outputs[bitWidth].join(",") + ";\n";
        }

        return res;
    },
    fixName: function(name){
        return name.replace(/ /g , "_");
    }


}
