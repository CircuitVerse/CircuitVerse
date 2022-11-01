/*
    # Primary Developers
    1) James H-J Yeh, Ph.D.
    2) Satvik Ramaprasad

    refer verilog_documentation.md
*/
import { scopeList } from "./circuit";
import { errorDetectedGet } from "./engine";
import { download } from "./utils";
import { getProjectName } from "./data/save";
import modules from "./modules";
import { sanitizeLabel } from "./verilogHelpers";
import CodeMirror from "codemirror/lib/codemirror.js";
import "codemirror/lib/codemirror.css";
import "codemirror/addon/hint/show-hint.css";
import "codemirror/mode/verilog/verilog.js";
import "codemirror/addon/edit/closebrackets.js";
import "codemirror/addon/hint/anyword-hint.js";
import "codemirror/addon/hint/show-hint.js";
import "codemirror/addon/display/autorefresh.js";
import { openInNewTab, copyToClipboard, showMessage } from "./utils";

var editora;

export function generateVHDL() {
    var dialog = $("#vhdl-export-code-window-div");
    var data = vhdl.exportVHDL();
    var bitselectorkeys = Object.keys(scopeList)
    var bitselectorerror = false

    for (var i = 0; i < scopeList[bitselectorkeys].BitSelector.length; i++){
        if(scopeList[bitselectorkeys].BitSelector[i].output1.connections[0].bitWidth != 1){
            editora.setValue("//ERROR\n// CircuitVerse's BitSelector only allows output with size 1 bit width.")
            bitselectorerror = true
            break
        } else if (Math.pow(2, scopeList[bitselectorkeys].BitSelector[i].bitSelectorInp.bitWidth) > scopeList[bitselectorkeys].BitSelector[i].inp1.bitWidth ) {
            editora.setValue("//ERROR\n// ERRO DE LARGURA")
            bitselectorerror = true
            break
        }
    }
    
    if(bitselectorerror === false){
        editora.setValue(data);
    }

    $("#vhdl-export-code-window-div .CodeMirror").css(
        "height",
        $(window).height() - 200
    );
    dialog.dialog({
        resizable: false,
        width: "90%",
        height: "auto",
        position: { my: "center", at: "center", of: window },
        buttons: [
            {
                text: "Download Verilog File",
                click() {
                    var fileName = getProjectName() || "Untitled";
                    download(fileName + ".v", editor.getValue());
                },
            },
            {
                text: "Copy to Clipboard",
                click() {
                    copyToClipboard(editor.getValue());
                    showMessage("Code has been copied");
                },
            },
            {
                text: "Try in EDA Playground",
                click() {
                    copyToClipboard(teste.getValue());
                    openInNewTab("https://www.edaplayground.com/x/XZpY");
                },
            },
        ],
    });
}

export function setupVHDLExportCodeWindow() {
    var myTextarea2 = document.getElementById("vhdl-export-code-window");
    editora = CodeMirror.fromTextArea(myTextarea2, {
        mode: "verilog",
        autoRefresh: true,
        styleActiveLine: true,
        lineNumbers: true,
        autoCloseBrackets: true,
        smartIndent: true,
        indentWithTabs: true,
        extraKeys: { "Ctrl-Space": "autocomplete" },
    });
}

export var vhdl = {
    exportVHDL: function (scope = undefined) {
        var dependencyList = {};
        // Reset Verilog Element State
        for (var elem in modules) {
            // Not sure if globalScope here is correct.
            if (modules[elem].resetVerilog) {
                modules[elem].resetVerilog();
            }
        }

        // List of devices under test for which testbench needs to be created
        var DUTs = [];
        var SubCircuitIds = new Set();

        // Generate SubCircuit Dependency Graph
        for (id in scopeList) {
            dependencyList[id] = scopeList[id].getDependencies();
            for (var i = 0; i < scopeList[id].SubCircuit.length; i++) {
                SubCircuitIds.add(scopeList[id].SubCircuit[i].id);
            }
        }

        for (id in scopeList) {
            if (!SubCircuitIds.has(id)) DUTs.push(scopeList[id]);
        }

        // DFS on SubCircuit Dependency Graph
        var visited = {};
        var elementTypesUsed = {};
        var output = "";
        if (scope) {
            // generate verilog only for scope
            output += this.exportVHDLScope(
                scope.id,
                visited,
                dependencyList,
                elementTypesUsed
            );
        } else {
            // generate verilog for everything
            for (id in scopeList) {
                output += this.exportVHDLScope(
                    id,
                    visited,
                    dependencyList,
                    elementTypesUsed
                );
            }
        }
        // Add Circuit Element - Module Specific Verilog Code
        for (var element in elementTypesUsed) {
            // If element has custom verilog
            if (modules[element] && modules[element].moduleVHDL) {
                output += modules[element].moduleVHDL();
            }
        }

        var report = this.generateReport(elementTypesUsed);
        var testbench = this.generateTestBenchCode(DUTs);

        return report + testbench + output;
    },
    generateReport: function (elementTypesUsed) {
        var output = "";
        return output;
    },
    generateTestBenchCode: function (DUTs) {
        return "";
    },
    // Recursive DFS function
    exportVHDLScope: function (id, visited, dependencyList, elementTypesUsed) {
        // Already Visited
        if (visited[id]) return "";
        // Mark as Visited
        visited[id] = true;

        var output = "";
        // DFS on dependencies
        for (var i = 0; i < dependencyList[id].length; i++)
            output +=
                this.exportVHDLScope(
                    dependencyList[id][i],
                    visited,
                    dependencyList,
                    elementTypesUsed
                ) + "\n";

        var scope = scopeList[id];
        // Initialize labels for all elements
        this.resetLabels(scope);
        this.setLabels(scope);
        
        if(scope.BitSelector.length !== 0) {
            output += "library IEEE;\nuse IEEE.std_logic_1164.all;\nuse IEEE.std_logic_unsigned.all;\n";
            output += "use IEEE.NUMERIC_STD.ALL;\n\n"
        } else{
            output += "library IEEE;\nuse IEEE.std_logic_1164.all;\n\n";
        }
        output += this.generateHeaderVHDL(scope);
        output += this.generateInputList(scope);
        output += this.generateOutputList(scope);
        output +=
            ");\nEND ENTITY;\n\nARCHITECTURE " +
            sanitizeLabel(scope.name) +
            " OF portas IS\n"; // generate output first to be consistent

        // Note: processGraph function populates scope.verilogWireList
        var res = "    " + this.processGraph(scope, elementTypesUsed);

        // Generate Wire Initialization Code
        for (var bitWidth = 1; bitWidth <= 32; bitWidth++) {
            var wireList = scope.verilogWireList[bitWidth];
            // Hack for splitter
            wireList = wireList.filter((x) => !x.includes("["));
            if (wireList.length == 0) continue;
            if (bitWidth == 1)
                output += "  SIGNAL " + wireList.join(", ") + ": STD_LOGIC;\n";
            else
                output += "  SIGNAL " + wireList.join(", ") + ": STD_LOGIC_VECTOR (" + (bitWidth - 1) + " DOWNTO 0);\n"
        }
        if((scope.Multiplexer.length != 0) || (scope.Demultiplexer.length != 0)){
            output += ""
        } else{
            output += "  BEGIN\n";
        }

        console.log(scopeList[Object.keys(scopeList)].Demultiplexer.length)
        if((scopeList[Object.keys(scopeList)].Demultiplexer.length === 0) && (scopeList[Object.keys(scopeList)].Multiplexer.length === 0)){
            if(scopeList[Object.keys(scopeList)].BitSelector.length != 0) {
                output += `  PROCESS(`
                
                for(var i = 0; i < scopeList[Object.keys(scopeList)].BitSelector.length; i++){
                    if(i === scopeList[Object.keys(scopeList)].BitSelector.length - 1){
                        output += `${scopeList[Object.keys(scopeList)].BitSelector[i].inp1.verilogLabel}, ${scopeList[Object.keys(scopeList)].BitSelector[i].bitSelectorInp.verilogLabel}`
                    } else{
                        output += `${scopeList[Object.keys(scopeList)].BitSelector[i].inp1.verilogLabel}, ${scopeList[Object.keys(scopeList)].BitSelector[i].bitSelectorInp.verilogLabel},`
                    }
                }
    
                output += `)\n  BEGIN\n`
            }
        }

        // Append Wire connections and module instantiations
        output += res;

        if(scopeList[Object.keys(scopeList)].BitSelector.length != 0) {
            output += `  END PROCESS;\n`
        }

        // Append footer
        output += "END " + sanitizeLabel(scope.name) + ";";

        return output;
    },
    // Performs DFS on the graph and generates netlist of wires and connections
    processGraph: function (scope, elementTypesUsed) {
        // Initializations
        var res = "";
        scope.stack = [];
        scope.verilogWireList = [];
        for (var i = 0; i <= 32; i++) scope.verilogWireList.push(new Array());

        var verilogResolvedSet = new Set();

        // Start DFS from inputs
        for (var i = 0; i < inputList.length; i++) {
            for (var j = 0; j < scope[inputList[i]].length; j++) {
                scope.stack.push(scope[inputList[i]][j]);
            }
        }

        // Iterative DFS on circuit graph
        while (scope.stack.length) {
            if (errorDetectedGet()) return;
            var elem = scope.stack.pop();

            if (verilogResolvedSet.has(elem)) continue;

            // Process verilog creates variable names and adds elements to DFS stack
            elem.processVerilog();

            // Record usage of element type
            if (elem.objectType != "Node") {
                if (elementTypesUsed[elem.objectType])
                    elementTypesUsed[elem.objectType]++;
                else elementTypesUsed[elem.objectType] = 1;
            }

            if (
                elem.objectType != "Node" &&
                elem.objectType != "Input" &&
                elem.objectType != "Clock"
            ) {
                verilogResolvedSet.add(elem);
            }
        }
        var componentVHDL = 0;
        var portVHDL = 0;
        var orderedSet;
       orderedSet = Array.from(verilogResolvedSet)

       for(i=0; i<orderedSet.length; i++){
        if(orderedSet[i].objectType === 'Demultiplexer'){
            orderedSet.unshift(orderedSet[i])
            i++
            orderedSet.splice(i,1)
        }
       }

       for(i=0; i<orderedSet.length; i++){
        if(orderedSet[i].objectType === 'Multiplexer'){
            orderedSet.unshift(orderedSet[i])
            i++
            orderedSet.splice(i,1)
        }
       }

       // ------------------------------- REMOVER ISSO NO FIM --------------------------------//
       console.log(orderedSet)

       var VHDLSet = new Set(orderedSet)
        
        // Generate connection verilog code and module instantiations
        for (var elem of VHDLSet) {
            if((componentVHDL==0) && ((elem.objectType == 'Demultiplexer') || (elem.objectType == 'Multiplexer'))){
                res += elem.generateVHDL() + "\n";
                componentVHDL=1
            }
        }

        for (var elem of VHDLSet) {
            if((portVHDL==0) && ((elem.objectType == 'Demultiplexer') || (elem.objectType == 'Multiplexer'))){
                res += elem.generatePortMapVHDL() + "\n";
                portVHDL=1
            }
        }

        for (var elem of VHDLSet) {
            if((elem.objectType != 'Multiplexer') && (elem.objectType != 'Demultiplexer')){
                res += elem.generateVHDL() + "\n";
            }
        }
        
        return res;
    },

    resetLabels: function (scope) {
        for (var i = 0; i < scope.allNodes.length; i++) {
            scope.allNodes[i].verilogLabel = "";
        }
    },
    // Sets labels for all Circuit Elements elements
    setLabels: function (scope = globalScope) {
        /**
         * Sets a name for each element. If element is already labeled,
         * the element is used directly, otherwise an automated label is provided
         * sanitizeLabel is a helper function to escape white spaces
         */
        for (var i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].label == "") scope.Input[i].label = "inp_" + i;
            else scope.Input[i].label = sanitizeLabel(scope.Input[i].label);
            // copy label to node
            scope.Input[i].output1.verilogLabel = scope.Input[i].label;
        }
        for (var i = 0; i < scope.ConstantVal.length; i++) {
            if (scope.ConstantVal[i].label == "")
                scope.ConstantVal[i].label = "const_" + i;
            else
                scope.ConstantVal[i].label = sanitizeLabel(
                    scope.ConstantVal[i].label
                );
            // copy label to node
            scope.ConstantVal[i].output1.verilogLabel =
                scope.ConstantVal[i].label;
        }

        // copy label to clock
        for (var i = 0; i < scope.Clock.length; i++) {
            if (scope.Clock[i].label == "") scope.Clock[i].label = "clk_" + i;
            else scope.Clock[i].label = sanitizeLabel(scope.Clock[i].label);
            scope.Clock[i].output1.verilogLabel = scope.Clock[i].label;
        }

        for (var i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].label == "") scope.Output[i].label = "out_" + i;
            else scope.Output[i].label = sanitizeLabel(scope.Output[i].label);
        }
        for (var i = 0; i < scope.SubCircuit.length; i++) {
            if (scope.SubCircuit[i].label == "")
                scope.SubCircuit[i].label =
                    scope.SubCircuit[i].data.name + "_" + i;
            else
                scope.SubCircuit[i].label = sanitizeLabel(
                    scope.SubCircuit[i].label
                );
        }
        for (var i = 0; i < moduleList.length; i++) {
            var m = moduleList[i];
            for (var j = 0; j < scope[m].length; j++) {
                scope[m][j].verilogLabel =
                    sanitizeLabel(scope[m][j].label) ||
                    scope[m][j].verilogName() + "_" + j;
            }
        }
    },
    generateHeaderVHDL: function (scope = globalScope) {
        // Example: module HalfAdder (a,b,s,c);
        var res = "ENTITY portas IS \n  PORT(\n";
        return res;
    },
    generateHeaderHelper: function (scope = globalScope) {
        // Example: (a,b,s,c);
        var res = "(";
        var pins = [];
        for (var i = 0; i < scope.Output.length; i++) {
            pins.push(scope.Output[i].label);
        }
        for (var i = 0; i < scope.Clock.length; i++) {
            pins.push(scope.Clock[i].label);
        }
        for (var i = 0; i < scope.Input.length; i++) {
            pins.push(scope.Input[i].label);
        }
        res += pins.join(", ");
        res += ");\n";
        return res;
    },
    generateInputList: function (scope = globalScope) {
        var inputs = {};
        for (var i = 1; i <= 32; i++) inputs[i] = [];

        for (var i = 0; i < scope.Input.length; i++) {
            inputs[scope.Input[i].bitWidth].push(scope.Input[i].label);
        }

        for (var i = 0; i < scope.Clock.length; i++) {
            inputs[scope.Clock[i].bitWidth].push(scope.Clock[i].label);
        }

        var res = "";

        for(var i = 0; i < scope.Input.length; i++){
            if(scope.Input[i].bitWidth == 1){
                res += `    ${scope.Input[i].verilogLabel}: IN STD_LOGIC;\n`
            }else{
                res += `    ${scope.Input[i].verilogLabel}: IN STD_LOGIC_VECTOR (${scope.Input[i].bitWidth - 1} DOWNTO 0);\n`
            }
        }

        return res;
    },
    generateOutputList: function (scope = globalScope) {
        // Example 1: output s,cout;
        var outputs = {};
        for (var i = 0; i < scope.Output.length; i++) {
            if (outputs[scope.Output[i].bitWidth])
                outputs[scope.Output[i].bitWidth].push(scope.Output[i].label);
            else outputs[scope.Output[i].bitWidth] = [scope.Output[i].label];
        }
        var res = "";
        
        for(var i = 0; i < scope.Output.length; i++){
            if(i != scope.Output.length - 1) {
                if(scope.Output[i].bitWidth == 1){
                    res += `    ${scope.Output[i].verilogLabel}: OUT STD_LOGIC;\n`
                }else{
                    res += `    ${scope.Output[i].verilogLabel}: OUT STD_LOGIC_VECTOR (${scope.Output[i].bitWidth - 1} DOWNTO 0);\n`
                }
            } else{
                if(scope.Output[i].bitWidth == 1){
                    res += `    ${scope.Output[i].verilogLabel}: OUT STD_LOGIC`
                }else{
                    res += `    ${scope.Output[i].verilogLabel}: OUT STD_LOGIC_VECTOR (${scope.Output[i].bitWidth - 1} DOWNTO 0)`
                }
            }
        }

        return res;
    },
};
