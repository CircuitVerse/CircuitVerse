/* eslint-disable import/no-cycle */
import Scope, { scopeList, switchCircuit } from "./circuit";
import CircuitElement from "./circuitElement";
import simulationArea from "./simulationArea";
import { scheduleBackup, checkIfBackup } from "./data/backupCircuit";
import {
    scheduleUpdate,
    updateSimulationSet,
    updateCanvasSet,
    updateSubcircuitSet,
} from "./engine";
import { loadScope } from "./data/load";
import { showError } from "./utils";

import Node, { findNode } from "./node";
import { fillText } from "./canvasApi";
import { colors } from "./themer/themer";
/**
 * Function to load a subcicuit
 * @category subcircuit
 */
export function loadSubCircuit(savedData, scope) {
    new SubCircuit(savedData.x, savedData.y, scope, savedData.id, savedData);
}

/**
 * Prompt to create subcircuit, shows list of circuits which dont depend on the current circuit
 * @param {Scope=} scope
 * @category subcircuit
 */
export function createSubCircuitPrompt(scope = globalScope) {
    console.log("hey");
    $("#insertSubcircuitDialog").empty();
    let flag = true;
    for (id in scopeList) {
        if (!scopeList[id].checkDependency(scope.id)) {
            flag = false;
            $("#insertSubcircuitDialog").append(
                `<label class="option"><input type="radio" name="subCircuitId" value="${id}" />${scopeList[id].name}</label>`
            );
        }
    }
    if (flag)
        $("#insertSubcircuitDialog").append(
            "<p>Looks like there are no other circuits which doesn't have this circuit as a dependency. Create a new one!</p>"
        );
    $("#insertSubcircuitDialog").dialog({
        maxHeight: 350,
        width: 250,
        maxWidth: 250,
        minWidth: 250,
        buttons: !flag
            ? [
                  {
                      text: "Insert SubCircuit",
                      click() {
                          if (!$("input[name=subCircuitId]:checked").val())
                              return;
                          simulationArea.lastSelected = new SubCircuit(
                              undefined,
                              undefined,
                              globalScope,
                              $("input[name=subCircuitId]:checked").val()
                          );
                          $(this).dialog("close");
                      },
                  },
              ]
            : [],
    });
}

/**
 * @class
 * @extends CircuitElement
 * @param {number} x - x coord of subcircuit
 * @param {number} y - y coord of subcircuit
 * @param {Scope=} scope - the circuit in which subcircuit has been added
 * @param {string} id - the id of the subcircuit scope
 * @param {JSON} savedData - the saved data
 * @category subcircuit
 */
export default class SubCircuit extends CircuitElement {
    constructor(
        x,
        y,
        scope = globalScope,
        id = undefined,
        savedData = undefined
    ) {
        super(x, y, scope, "RIGHT", 1); // super call
        this.objectType = "SubCircuit";
        this.scope.SubCircuit.push(this);
        this.id = id || prompt("Enter Id: ");
        this.directionFixed = true;
        this.fixedBitWidth = true;
        this.savedData = savedData;
        this.inputNodes = [];
        this.outputNodes = [];
        this.localScope = new Scope();
        var subcircuitScope = scopeList[this.id]; // Scope of the subcircuit
        // Error handing
        if (subcircuitScope == undefined) {
            // if no such scope for subcircuit exists
            showError(
                `SubCircuit : ${
                    (savedData && savedData.title) || this.id
                } Not found`
            );
        } else if (!checkIfBackup(subcircuitScope)) {
            // if there is no input/output nodes there will be no backup
            showError(
                `SubCircuit : ${
                    (savedData && savedData.title) || subcircuitScope.name
                } is an empty circuit`
            );
        } else if (subcircuitScope.checkDependency(scope.id)) {
            // check for cyclic dependency
            showError("Cyclic Circuit Error");
        }
        // Error handling, cleanup
        if (
            subcircuitScope == undefined ||
            subcircuitScope.checkDependency(scope.id) ||
            !checkIfBackup(subcircuitScope)
        ) {
            if (savedData) {
                for (var i = 0; i < savedData.inputNodes.length; i++) {
                    scope.allNodes[savedData.inputNodes[i]].deleted = true;
                }
                for (var i = 0; i < savedData.outputNodes.length; i++) {
                    scope.allNodes[savedData.outputNodes[i]].deleted = true;
                }
            }
            return;
        }

        if (this.savedData != undefined) {
            updateSubcircuitSet(true);
            scheduleUpdate();
            this.version = this.savedData.version || "1.0";

            this.id = this.savedData.id;
            for (var i = 0; i < this.savedData.inputNodes.length; i++) {
                this.inputNodes.push(
                    this.scope.allNodes[this.savedData.inputNodes[i]]
                );
                this.inputNodes[i].parent = this;
                this.inputNodes[i].layout_id =
                    subcircuitScope.Input[i].layoutProperties.id;
            }
            for (var i = 0; i < this.savedData.outputNodes.length; i++) {
                this.outputNodes.push(
                    this.scope.allNodes[this.savedData.outputNodes[i]]
                );
                this.outputNodes[i].parent = this;
                this.outputNodes[i].layout_id =
                    subcircuitScope.Output[i].layoutProperties.id;
            }
            if (this.version == "1.0") {
                // For backward compatibility
                this.version = "2.0";
                this.x -= subcircuitScope.layout.width / 2;
                this.y -= subcircuitScope.layout.height / 2;
                for (var i = 0; i < this.inputNodes.length; i++) {
                    this.inputNodes[i].x =
                        subcircuitScope.Input[i].layoutProperties.x;
                    this.inputNodes[i].y =
                        subcircuitScope.Input[i].layoutProperties.y;
                    this.inputNodes[i].leftx = this.inputNodes[i].x;
                    this.inputNodes[i].lefty = this.inputNodes[i].y;
                }
                for (var i = 0; i < this.outputNodes.length; i++) {
                    this.outputNodes[i].x =
                        subcircuitScope.Output[i].layoutProperties.x;
                    this.outputNodes[i].y =
                        subcircuitScope.Output[i].layoutProperties.y;
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
        this.buildCircuit(); // load the localScope for the subcircuit
        this.makeConnections(); // which will be wireless
    }

    /**
     * actually make all connection but are invisible so
     * it seems like the simulation is happening in other
     * Scope but it actually is not.
     */
    makeConnections() {
        for (let i = 0; i < this.inputNodes.length; i++) {
            this.localScope.Input[i].output1.connectWireLess(
                this.inputNodes[i]
            );
            this.localScope.Input[i].output1.subcircuitOverride = true;
        }

        for (let i = 0; i < this.outputNodes.length; i++) {
            this.localScope.Output[i].inp1.connectWireLess(this.outputNodes[i]);
            this.outputNodes[i].subcircuitOverride = true;
        }
    }

    /**
     * Function to remove wireless connections
     */
    removeConnections() {
        for (let i = 0; i < this.inputNodes.length; i++) {
            this.localScope.Input[i].output1.disconnectWireLess(
                this.inputNodes[i]
            );
        }

        for (let i = 0; i < this.outputNodes.length; i++) {
            this.localScope.Output[i].inp1.disconnectWireLess(
                this.outputNodes[i]
            );
        }
    }

    /**
     * loads the subcircuit and draws all the nodes
     */
    buildCircuit() {
        var subcircuitScope = scopeList[this.id];
        loadScope(this.localScope, this.data);
        this.lastUpdated = this.localScope.timeStamp;
        updateSimulationSet(true);
        updateCanvasSet(true);

        if (this.savedData == undefined) {
            this.leftDimensionX = 0;
            this.upDimensionY = 0;
            this.rightDimensionX = subcircuitScope.layout.width;
            this.downDimensionY = subcircuitScope.layout.height;
            console.log(subcircuitScope.Output.length);
            for (var i = 0; i < subcircuitScope.Output.length; i++) {
                var a = new Node(
                    subcircuitScope.Output[i].layoutProperties.x,
                    subcircuitScope.Output[i].layoutProperties.y,
                    1,
                    this,
                    subcircuitScope.Output[i].bitWidth
                );
                a.layout_id = subcircuitScope.Output[i].layoutProperties.id;
                console.log(a.absX(), a.absY());
                this.outputNodes.push(a);
            }
            for (var i = 0; i < subcircuitScope.Input.length; i++) {
                var a = new Node(
                    subcircuitScope.Input[i].layoutProperties.x,
                    subcircuitScope.Input[i].layoutProperties.y,
                    0,
                    this,
                    subcircuitScope.Input[i].bitWidth
                );
                a.layout_id = subcircuitScope.Input[i].layoutProperties.id;
                console.log(a.absX(), a.absY());
                this.inputNodes.push(a);
            }
        }
    }

    // Needs to be deprecated, removed
    reBuild() {
        // new SubCircuit(x = this.x, y = this.y, scope = this.scope, this.id);
        // this.scope.backups = []; // Because all previous states are invalid now
        // this.delete();
        // showMessage('Subcircuit: ' + subcircuitScope.name + ' has been reloaded.');
    }

    /**
     * rebuilds the subcircuit if any change to localscope is made
     */
    reBuildCircuit() {
        this.data = JSON.parse(scheduleBackup(scopeList[this.id]));
        this.localScope = new Scope();
        loadScope(this.localScope, this.data);
        this.lastUpdated = this.localScope.timeStamp;
        this.scope.timeStamp = this.localScope.timeStamp;
    }

    reset() {
        this.removeConnections();

        var subcircuitScope = scopeList[this.id];

        for (var i = 0; i < subcircuitScope.SubCircuit.length; i++) {
            subcircuitScope.SubCircuit[i].reset();
        }

        if (
            subcircuitScope.Input.length == 0 &&
            subcircuitScope.Output.length == 0
        ) {
            showError(
                `SubCircuit : ${subcircuitScope.name} is an empty circuit`
            );
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

        var temp_map_inp = {};
        for (var i = 0; i < subcircuitScope.Input.length; i++) {
            temp_map_inp[subcircuitScope.Input[i].layoutProperties.id] = [
                subcircuitScope.Input[i],
                undefined,
            ];
        }
        for (var i = 0; i < this.inputNodes.length; i++) {
            if (temp_map_inp.hasOwnProperty(this.inputNodes[i].layout_id)) {
                temp_map_inp[this.inputNodes[i].layout_id][1] = this.inputNodes[
                    i
                ];
            } else {
                this.scope.backups = [];
                this.inputNodes[i].delete();
                this.nodeList.clean(this.inputNodes[i]);
            }
        }

        for (id in temp_map_inp) {
            if (temp_map_inp[id][1]) {
                if (
                    temp_map_inp[id][0].layoutProperties.x ==
                        temp_map_inp[id][1].x &&
                    temp_map_inp[id][0].layoutProperties.y ==
                        temp_map_inp[id][1].y
                ) {
                    temp_map_inp[id][1].bitWidth = temp_map_inp[id][0].bitWidth;
                } else {
                    this.scope.backups = [];
                    temp_map_inp[id][1].delete();
                    this.nodeList.clean(temp_map_inp[id][1]);
                    temp_map_inp[id][1] = new Node(
                        temp_map_inp[id][0].layoutProperties.x,
                        temp_map_inp[id][0].layoutProperties.y,
                        0,
                        this,
                        temp_map_inp[id][0].bitWidth
                    );
                    temp_map_inp[id][1].layout_id = id;
                }
            }
        }

        this.inputNodes = [];
        for (var i = 0; i < subcircuitScope.Input.length; i++) {
            var input =
                temp_map_inp[subcircuitScope.Input[i].layoutProperties.id][0];
            if (temp_map_inp[input.layoutProperties.id][1]) {
                this.inputNodes.push(
                    temp_map_inp[input.layoutProperties.id][1]
                );
            } else {
                var a = new Node(
                    input.layoutProperties.x,
                    input.layoutProperties.y,
                    0,
                    this,
                    input.bitWidth
                );
                a.layout_id = input.layoutProperties.id;
                this.inputNodes.push(a);
            }
        }

        var temp_map_out = {};
        for (var i = 0; i < subcircuitScope.Output.length; i++) {
            temp_map_out[subcircuitScope.Output[i].layoutProperties.id] = [
                subcircuitScope.Output[i],
                undefined,
            ];
        }
        for (var i = 0; i < this.outputNodes.length; i++) {
            if (temp_map_out.hasOwnProperty(this.outputNodes[i].layout_id)) {
                temp_map_out[
                    this.outputNodes[i].layout_id
                ][1] = this.outputNodes[i];
            } else {
                this.outputNodes[i].delete();
                this.nodeList.clean(this.outputNodes[i]);
            }
        }

        for (id in temp_map_out) {
            if (temp_map_out[id][1]) {
                if (
                    temp_map_out[id][0].layoutProperties.x ==
                        temp_map_out[id][1].x &&
                    temp_map_out[id][0].layoutProperties.y ==
                        temp_map_out[id][1].y
                ) {
                    temp_map_out[id][1].bitWidth = temp_map_out[id][0].bitWidth;
                } else {
                    temp_map_out[id][1].delete();
                    this.nodeList.clean(temp_map_out[id][1]);
                    temp_map_out[id][1] = new Node(
                        temp_map_out[id][0].layoutProperties.x,
                        temp_map_out[id][0].layoutProperties.y,
                        1,
                        this,
                        temp_map_out[id][0].bitWidth
                    );
                    temp_map_out[id][1].layout_id = id;
                }
            }
        }

        this.outputNodes = [];
        for (var i = 0; i < subcircuitScope.Output.length; i++) {
            var output =
                temp_map_out[subcircuitScope.Output[i].layoutProperties.id][0];
            if (temp_map_out[output.layoutProperties.id][1]) {
                this.outputNodes.push(
                    temp_map_out[output.layoutProperties.id][1]
                );
            } else {
                var a = new Node(
                    output.layoutProperties.x,
                    output.layoutProperties.y,
                    1,
                    this,
                    output.bitWidth
                );
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

    click() {
        // this.id=prompt();
    }

    /**
     * adds all local scope inputs to the global scope simulation queue
     */
    addInputs() {
        for (let i = 0; i < subCircuitInputList.length; i++) {
            for (
                let j = 0;
                j < this.localScope[subCircuitInputList[i]].length;
                j++
            ) {
                simulationArea.simulationQueue.add(
                    this.localScope[subCircuitInputList[i]][j],
                    0
                );
            }
        }
        for (let j = 0; j < this.localScope.SubCircuit.length; j++) {
            this.localScope.SubCircuit[j].addInputs();
        }
    }

    isResolvable() {
        if (CircuitElement.prototype.isResolvable.call(this)) {
            return true;
        }
        return false;
    }

    dblclick() {
        switchCircuit(this.id);
    }

    saveObject() {
        var data = {
            x: this.x,
            y: this.y,
            id: this.id,
            inputNodes: this.inputNodes.map(findNode),
            outputNodes: this.outputNodes.map(findNode),
            version: this.version,
        };
        return data;
    }

    /**
     * not used because for now everythiing is added onto the globalscope
     */
    resolve() {
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

    isResolvable() {
        return false;
    }

    verilogName() {
        return verilog.fixName(scopeList[this.id].name);
    }

    /**
     * determines where to show label
     */
    determine_label(x, y) {
        if (x == 0) return ["left", 5, 5];
        if (x == scopeList[this.id].layout.width) return ["right", -5, 5];
        if (y == 0) return ["center", 0, 13];
        return ["center", 0, -6];
    }

    customDraw() {
        var subcircuitScope = scopeList[this.id];

        var ctx = simulationArea.context;

        ctx.lineWidth = globalScope.scale * 3;
        ctx.strokeStyle = colors["stroke"]; // ("rgba(0,0,0,1)");
        ctx.fillStyle = colors["fill"];
        var xx = this.x;
        var yy = this.y;
        ctx.beginPath();

        ctx.textAlign = "center";
        ctx.fillStyle = "black"; //colors['text_alt'];
        if (this.version == "1.0") {
            fillText(
                ctx,
                subcircuitScope.name,
                xx,
                yy - subcircuitScope.layout.height / 2 + 13,
                11
            );
        } else if (this.version == "2.0") {
            if (subcircuitScope.layout.titleEnabled) {
                fillText(
                    ctx,
                    subcircuitScope.name,
                    subcircuitScope.layout.title_x + xx,
                    yy + subcircuitScope.layout.title_y,
                    11
                );
            }
        } else {
            console.log(this.version);
        }

        for (var i = 0; i < subcircuitScope.Input.length; i++) {
            if (!subcircuitScope.Input[i].label) continue;
            var info = this.determine_label(
                this.inputNodes[i].x,
                this.inputNodes[i].y
            );
            ctx.textAlign = info[0];
            fillText(
                ctx,
                subcircuitScope.Input[i].label,
                this.inputNodes[i].x + info[1] + xx,
                yy + this.inputNodes[i].y + info[2],
                12
            );
        }

        for (var i = 0; i < subcircuitScope.Output.length; i++) {
            if (!subcircuitScope.Output[i].label) continue;
            var info = this.determine_label(
                this.outputNodes[i].x,
                this.outputNodes[i].y
            );
            ctx.textAlign = info[0];
            fillText(
                ctx,
                subcircuitScope.Output[i].label,
                this.outputNodes[i].x + info[1] + xx,
                yy + this.outputNodes[i].y + info[2],
                12
            );
        }
        ctx.fill();
        // console.log("input",this.inputNodes)
        // console.log("oput",this.outputNodes)
        for (let i = 0; i < this.outputNodes.length; i++) {
            this.outputNodes[i].draw();
        }
        for (let i = 0; i < this.inputNodes.length; i++) {
            this.inputNodes[i].draw();
        }
    }
}

SubCircuit.prototype.centerElement = true; // To center subcircuit when new
