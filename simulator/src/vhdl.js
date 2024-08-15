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
import { generateSTDType, hasComponent, removeDuplicateComponent } from "./helperVHDL";

var editora;

export function generateVHDL() {
    var dialog = $("#vhdl-export-code-window-div");
    let data = vhdl.exportVHDL();
    let bitselectorerror = false
    const scopeIndex = Object.keys(scopeList)
    const bitSelector = scopeList[scopeIndex].BitSelector

    for (var i = 0; i < bitSelector.length; i++){
        if(bitSelector[i].output1.connections[0].bitWidth != 1){
            editora.setValue("//ERROR\n// CircuitVerse's BitSelector only allows output with size 1 bit width.")
            bitselectorerror = true
            break
        } else if (Math.pow(2, bitSelector[i].bitSelectorInp.bitWidth) > bitSelector[i].inp1.bitWidth ) {
            editora.setValue("//ERROR\n// The bit width of the select input must be the square root of the bit input.")
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
                text: "Download VHDL File",
                click() {
                    var fileName = getProjectName() || "Untitled";
                    download(fileName + ".vhd", editora.getValue());
                },
            },
            {
                text: "Copy to Clipboard",
                click() {
                    copyToClipboard(editora.getValue());
                    showMessage("Code has been copied");
                },
            },
            {
                text: "Try in EDA Playground",
                click() {
                    copyToClipboard(editora.getValue());
                    openInNewTab("https://www.edaplayground.com/x/KCFA");
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
        return output;
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
        
        output += (hasComponent(scope.BitSelector))
            ? "library IEEE;\nuse IEEE.std_logic_1164.all;\nuse IEEE.std_logic_unsigned.all;\nuse IEEE.NUMERIC_STD.ALL;\n\n"
            : "library IEEE;\nuse IEEE.std_logic_1164.all;\n\n"
        output += this.generateHeaderVHDL(scope);
        output += this.generateInputList(scope);
        output += this.generateOutputList(scope);
        output +=
            "\n  );\nEND ENTITY;\n\nARCHITECTURE " +
            sanitizeLabel(scope.name) +
            " OF portas IS\n";

        // Note: processGraph function populates scope.verilogWireList
        var res = this.processGraph(scope, elementTypesUsed);

        // Generate Wire Initialization Code
        for (var bitWidth = 1; bitWidth <= 32; bitWidth++) {
            var wireList = scope.verilogWireList[bitWidth];
            // Hack for splitter
            wireList = wireList.filter((x) => !x.includes("["));
            if (wireList.length == 0) continue;
            
            scope.PriorityEncoder.forEach((component) => {
                wireList = wireList.filter((x) => !x.includes(component.enable.verilogLabel))
            })
            
            output += "  SIGNAL " + wireList.join(", ") + generateSTDType("", bitWidth) + ";\n"
        }

        
        if((hasComponent(scope.Multiplexer)) || (hasComponent(scope.Demultiplexer)) || (hasComponent(scope.Decoder)) || (hasComponent(scope.Dlatch)) || (hasComponent(scope.DflipFlop)) || (hasComponent(scope.TflipFlop)) || (hasComponent(scope.JKflipFlop)) || (hasComponent(scope.SRflipFlop)) || (hasComponent(scope.MSB)) || (hasComponent(scope.LSB)) || (hasComponent(scope.PriorityEncoder))){
            output += ""
        } else{
            output += "  BEGIN\n";
        }

        const ScopeComponents = scopeList[Object.keys(scopeList)]
        if((!hasComponent(ScopeComponents.Demultiplexer)) && (!hasComponent(ScopeComponents.Multiplexer)) && (!hasComponent(ScopeComponents.Decoder)) && (!hasComponent(ScopeComponents.Dlatch)) && (!hasComponent(scope.DflipFlop)) && (!hasComponent(scope.TflipFlop)) && (!hasComponent(scope.JKflipFlop)) && (!hasComponent(scope.SRflipFlop)) && (!hasComponent(scope.MSB)) && (!hasComponent(scope.LSB)) && (!hasComponent(scope.PriorityEncoder))){
            if(hasComponent(ScopeComponents.BitSelector)) {
                output += `  PROCESS(`
                let outputProcessed = []
                for(var i = 0; i < ScopeComponents.BitSelector.length; i++){
                    outputProcessed[i] = `${ScopeComponents.BitSelector[i].inp1.verilogLabel}, ${ScopeComponents.BitSelector[i].bitSelectorInp.verilogLabel}`
                }
                output += outputProcessed.join(',')
                output += `)\n    BEGIN\n`
            }
        }

        // Append Wire connections and module instantiations
        output += res;

        if(hasComponent(ScopeComponents.BitSelector)) {
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

        var vhdlResolvedSet = new Set();

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

            if (vhdlResolvedSet.has(elem)) continue;

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
                vhdlResolvedSet.add(elem);
            }
        }
        let componentVHDL = 0;
        let portVHDL = 0;
        let orderedSet;
        orderedSet = Array.from(vhdlResolvedSet)

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'Demultiplexer'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'Multiplexer'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'Decoder'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'Dlatch'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'DflipFlop'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'TflipFlop'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'JKflipFlop'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'SRflipFlop'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'MSB'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'LSB'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        for(i = 0; i < orderedSet.length; i++){
            if(orderedSet[i].objectType === 'PriorityEncoder'){
                orderedSet.unshift(orderedSet[i])
                i++
                orderedSet.splice(i,1)
            }
        }

        let VHDLSet = new Set(orderedSet)
        
        let componentArray = []
        // Generate connection verilog code and module instantiations
        for (var elem of VHDLSet) {
            if((componentVHDL==0) && ((elem.objectType == 'Demultiplexer') || (elem.objectType == 'Multiplexer') || (elem.objectType == 'Decoder') || (elem.objectType == 'Dlatch')) || (elem.objectType == 'DflipFlop') || (elem.objectType == 'TflipFlop') || (elem.objectType == 'JKflipFlop') || (elem.objectType == 'SRflipFlop') || (elem.objectType == 'MSB') || (elem.objectType == 'LSB') || (elem.objectType == 'PriorityEncoder')){
                componentArray = [...componentArray, elem.generateVHDL()]
                componentVHDL=1
            }
        }
        const componentArrayFiltered = removeDuplicateComponent(componentArray)

        componentArrayFiltered.forEach(el => res += el + "\n")

        console.log(res)

        for (var elem of VHDLSet) {
            if((portVHDL==0) && ((elem.objectType == 'Demultiplexer') || (elem.objectType == 'Multiplexer') || (elem.objectType == 'Decoder') || (elem.objectType == 'Dlatch') || (elem.objectType == 'DflipFlop') || (elem.objectType == 'TflipFlop') || (elem.objectType == 'JKflipFlop') || (elem.objectType == 'SRflipFlop') || (elem.objectType == 'MSB') || (elem.objectType == 'LSB') || (elem.objectType == 'PriorityEncoder'))){
                res += elem.generatePortMapVHDL() + "\n";
                portVHDL=1
            }
        }

        for (var elem of VHDLSet) {
            if((elem.objectType != 'Multiplexer') && (elem.objectType != 'Demultiplexer') && (elem.objectType != 'Decoder') && (elem.objectType != 'Dlatch') && (elem.objectType != 'DflipFlop') && (elem.objectType != 'TflipFlop') && (elem.objectType != 'JKflipFlop') && (elem.objectType != 'SRflipFlop') && (elem.objectType != 'MSB') && (elem.objectType != 'LSB') && (elem.objectType != 'PriorityEncoder')){
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
        return "ENTITY portas IS \n  PORT(\n";
    },
    generateInputList: function (scope = globalScope) {
        // Example 1: in0: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        let res = '';
        scope.Input.forEach(el => {
            res += `    ${el.verilogLabel}${generateSTDType('IN', el.bitWidth)};\n`
        })

        scope.Clock.forEach(el => {
            res += `    ${el.verilogLabel}${generateSTDType('IN', el.bitWidth)};\n`
        })

        return res;
    },
    generateOutputList: function (scope = globalScope) {
        // Example 1: out0: OUT STD_LOGIC;
        let res = [];

        scope.Output.forEach((el, index) => {
            res[index] = `    ${el.verilogLabel}${generateSTDType('OUT', el.bitWidth)}`
        })

        return res.join(';\n');
    },
};
