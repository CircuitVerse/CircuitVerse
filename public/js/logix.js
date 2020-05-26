// Size of canvas
var width;
var height;
var listenToSimulator=true; //enables key down listener on the simulator

var createNode=false //Flag to create node when its value ==true 
var stopWire=true //flag for stopoing making Nodes when the second terminal reaches a Node (closed path) 

uniqueIdCounter = 0; // To be deprecated
unit = 10; // size of each division/ not used everywhere, to be deprecated

wireToBeChecked = 0; // when node disconnects from another node
willBeUpdated = false; // scheduleUpdate() will be called if true
objectSelection = false; // Flag for object selection
errorDetected = false; // Flag for error detection

prevErrorMessage = undefined; // Global variable for error messages
prevShowMessage = undefined; // Global variable for error messages

updatePosition = true; // Flag for updating position
updateSimulation = true; // Flag for updating simulation
updateCanvas = true; // Flag for rendering

gridUpdate = true; // Flag for updating grid
updateSubcircuit = true; // Flag for updating subCircuits

loading = false; // Flag - all assets are loaded

DPR = 1; // devicePixelRatio, 2 for retina displays, 1 for low resolution displays

projectSaved = true; // Flag for project saved or not

lightMode = false; // To be deprecated

layoutMode = false; // Flag for mode

forceResetNodes = true; // FLag to reset all Nodes




//Exact same name as object constructor
//This list needs to be updated when new circuitselements are created


function setupElementLists() {

    $('#menu').empty();

    window.circuitElementList = metadata.circuitElementList;
    window.annotationList = metadata.annotationList;
    window.inputList = metadata.inputList;
    window.subCircuitInputList = metadata.subCircuitInputList;
    window.moduleList = [...circuitElementList, ...annotationList]
    window.updateOrder = ["wires", ...circuitElementList, "nodes", ...annotationList]; // Order of update
    window.renderOrder = [...(moduleList.slice().reverse()), "wires", "allNodes"]; // Order of render


    function createIcon(element) {
        return `<div class="icon logixModules pointerCursor" id="${element}" >
            <img src= "/img/${element}.svg" >
            <p class="img__description">${element}</p>
        </div>`;
    }

    let elementHierarchy = metadata.elementHierarchy;
    for (category in elementHierarchy) {
        let htmlIcons = '';

        let categoryData = elementHierarchy[category];

        for (let i = 0; i < categoryData.length; i++) {
            let element = categoryData[i];
            htmlIcons += createIcon(element);
        }

        let accordionData = `<div class="panelHeader">${category}</div>
            <div class="panel" style="overflow-y:hidden;">
              ${htmlIcons}
            </div>`;

        $('#menu').append(accordionData);

    }


}

// setupElementLists()


// circuitElementList = [
//     "Input", "Output", "NotGate", "OrGate", "AndGate", "NorGate", "NandGate", "XorGate", "XnorGate", "SevenSegDisplay", "SixteenSegDisplay", "HexDisplay",
//     "Multiplexer", "BitSelector", "Splitter", "Power", "Ground", "ConstantVal", "ControlledInverter", "TriState", "Adder", "Rom", "RAM", "EEPROM", "TflipFlop",
//     "JKflipFlop", "SRflipFlop", "DflipFlop", "TTY", "Keyboard", "Clock", "DigitalLed", "Stepper", "VariableLed", "RGBLed", "SquareRGBLed", "RGBLedMatrix", "Button", "Demultiplexer",
//     "Buffer", "SubCircuit", "Flag", "MSB", "LSB", "PriorityEncoder", "Tunnel", "ALU", "Decoder", "Random", "Counter", "Dlatch", "TB_Input", "TB_Output", "ForceGate",
// ];

// annotationList = ["Text", "Rectangle", "Arrow"]

// moduleList = [...circuitElementList, ...annotationList]
// updateOrder = ["wires", ...circuitElementList, "nodes", ...annotationList]; // Order of update
// renderOrder = [...(moduleList.slice().reverse()), "wires", "allNodes"]; // Order of render

// // Exact same name as object constructor
// // All the combinational modules which give rise to an value(independently)

// inputList = ["Random","Buffer", "Stepper", "Ground", "Power", "ConstantVal", "Input", "Clock", "Button","Dlatch","JKflipFlop","TflipFlop","SRflipFlop","DflipFlop"];
// subCircuitInputList=["Clock", "Button","Buffer", "Stepper", "Ground", "Power", "ConstantVal","Dlatch","JKflipFlop","TflipFlop","SRflipFlop","DflipFlop"]

// inputList = ["Random", "Dlatch", "JKflipFlop", "TflipFlop", "SRflipFlop", "DflipFlop", "Buffer", "Stepper", "Ground", "Power", "ConstantVal", "Input", "Clock", "Button", "Counter"];
// subCircuitInputList = ["Random", "Dlatch", "JKflipFlop", "TflipFlop", "SRflipFlop", "DflipFlop", "Buffer", "Stepper", "Ground", "Power", "ConstantVal", "Clock", "Button", "Counter"];

//Scope object for each circuit level, globalScope for outer level
scopeList = {};


// Helper function to show error
function showError(error) {
    errorDetected = true;
    if (error == prevErrorMessage) return;
    prevErrorMessage = error;
    var id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append("<div class='alert alert-danger' role='alert' id='" + id + "'> " + error + "</div>");
    setTimeout(function() {
        prevErrorMessage = undefined;
        $('#' + id).fadeOut();
    }, 1500);
}

function showRestricted() {
    $('#restrictedDiv').removeClass("display--none");
    // Show no help text for restricted elements
    $("#Help").removeClass("show");
    $('#restrictedDiv').html("The element has been restricted by mentor. Usage might lead to deduction in marks");
}

function hideRestricted() {
    $('#restrictedDiv').addClass("display--none");
}

function updateRestrictedElementsList() {
    if (restrictedElements.length === 0) return;

    const restrictedCircuitElementsUsed = globalScope.restrictedCircuitElementsUsed;
    let restrictedStr = "";

    restrictedCircuitElementsUsed.forEach((element) => {
        restrictedStr += `${element}, `;
    });

    if (restrictedStr === "") {
        restrictedStr = "None";
    } else {
        restrictedStr = restrictedStr.slice(0, -2);
    }

    $("#restrictedElementsDiv--list").html(restrictedStr);
}


function updateRestrictedElementsInScope(scope = globalScope) {
    // Do nothing if no restricted elements
    if (restrictedElements.length === 0) return;

    let restrictedElementsUsed = [];
    restrictedElements.forEach((element) => {
        if (scope[element].length > 0) {
            restrictedElementsUsed.push(element);
        }
    });

    scope.restrictedCircuitElementsUsed = restrictedElementsUsed;
    updateRestrictedElementsList();
}

// Helper function to show message
function showMessage(mes) {
    if (mes == prevShowMessage) return;
    prevShowMessage = mes
    var id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append("<div class='alert alert-success' role='alert' id='" + id + "'> " + mes + "</div>");
    setTimeout(function() {
        prevShowMessage = undefined;
        $('#' + id).fadeOut()
    }, 2500);
}

// Helper function to open a new tab
function openInNewTab(url) {
    var win = window.open(url, '_blank');
    win.focus();
}

// Following function need to be improved - remove mutability etc
//fn to remove elem in array
Array.prototype.clean = function(deleteValue) {
    for (var i = 0; i < this.length; i++) {
        if (this[i] == deleteValue) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
};

// Following function need to be improved
Array.prototype.extend = function(other_array) {
    /* you should include a test to check whether other_array really is an array */
    other_array.forEach(function(v) {
        this.push(v)
    }, this);
}

// Following function need to be improved
//fn to check if an elem is in an array
Array.prototype.contains = function(value) {
    return this.indexOf(value) > -1
};

// Helper function to return unique list
function uniq(a) {
    var seen = {};
    return a.filter(function(item) {
        return seen.hasOwnProperty(item) ? false : (seen[item] = true);
    });
}

// Currently Focussed circuit/scope
globalScope = undefined;

// Base circuit class
// All circuits are stored in a scope

function Scope(name = "localScope", id = undefined) {
    this.restrictedCircuitElementsUsed = [];
    this.id = id || Math.floor((Math.random() * 100000000000) + 1);
    this.CircuitElement = [];

    //root object for referring to main canvas - intermediate node uses this
    this.root = new CircuitElement(0, 0, this, "RIGHT", 1);
    this.backups = [];
    this.timeStamp = new Date().getTime();

    this.ox = 0;
    this.oy = 0;
    this.scale = DPR;
    this.tunnelList = {};
    this.stack = []

    this.name = name;
    this.pending = []
    this.nodes = []; //intermediate nodes only
    this.allNodes = [];
    this.wires = [];

    // Creating arrays for other module elements
    for (var i = 0; i < moduleList.length; i++) {
        this[moduleList[i]] = [];
    }

    // Setting default layout
    this.layout = { // default position
        width: 100,
        height: 40,
        title_x: 50,
        title_y: 13,
        titleEnabled: true,
    }


    // FOR SOME UNKNOWN REASON, MAKING THE COPY OF THE LIST COMMON
    // TO ALL SCOPES EITHER BY PROTOTYPE OR JUST BY REFERNCE IS CAUSING ISSUES
    // The issue comes regarding copy/paste operation, after 5-6 operations it becomes slow for unknown reasons
    // CHANGE/ REMOVE WITH CAUTION
    // this.objects = ["wires", ...circuitElementList, "nodes", ...annotationList];
    // this.renderObjectOrder = [ ...(moduleList.slice().reverse()), "wires", "allNodes"];
}

// Resets all nodes recursively
Scope.prototype.reset = function() {
    for (var i = 0; i < this.allNodes.length; i++)
        this.allNodes[i].reset();
    for (var i = 0; i < this.Splitter.length; i++) {
        this.Splitter[i].reset();
    }
    for (var i = 0; i < this.SubCircuit.length; i++) {
        this.SubCircuit[i].reset();
    }

}

// Adds all inputs to simulationQueue
Scope.prototype.addInputs = function() {
    for (var i = 0; i < inputList.length; i++) {
        for (var j = 0; j < this[inputList[i]].length; j++) {
            simulationArea.simulationQueue.add(this[inputList[i]][j], 0);
        }
    }

    for (let j = 0; j < this.SubCircuit.length; j++)
        this.SubCircuit[j].addInputs();

}

// Ticks clocks recursively -- needs to be deprecated and synchronize all clocks with a global clock
Scope.prototype.clockTick = function() {
    for (var i = 0; i < this.Clock.length; i++)
        this.Clock[i].toggleState(); //tick clock!
    for (var i = 0; i < this.SubCircuit.length; i++)
        this.SubCircuit[i].localScope.clockTick(); //tick clock!
}

// Checks if this circuit contains directly or indirectly scope with id
// Recursive nature
Scope.prototype.checkDependency = function(id) {
    if (id == this.id) return true;
    for (var i = 0; i < this.SubCircuit.length; i++)
        if (this.SubCircuit[i].id == id) return true;

    for (var i = 0; i < this.SubCircuit.length; i++)
        if (scopeList[this.SubCircuit[i].id].checkDependency(id)) return true;

    return false
}

// Get dependency list - list of all circuits, this circuit depends on
Scope.prototype.getDependencies = function() {
    var list = []
    for (var i = 0; i < this.SubCircuit.length; i++) {
        list.push(this.SubCircuit[i].id);
        list.extend(scopeList[this.SubCircuit[i].id].getDependencies());
    }
    return uniq(list);
}

// helper function to reduce layout size
Scope.prototype.fixLayout = function() {
    var max_y = 20;
    for (var i = 0; i < this.Input.length; i++)
        max_y = Math.max(this.Input[i].layoutProperties.y, max_y)
    for (var i = 0; i < this.Output.length; i++)
        max_y = Math.max(this.Output[i].layoutProperties.y, max_y)
    if (max_y != this.layout.height)
        this.layout.height = max_y + 10;
}

// Function which centers the circuit to the correct zoom level
Scope.prototype.centerFocus = function(zoomIn = true) {
    if (layoutMode) return;
    findDimensions(this);
    var minX = simulationArea.minWidth || 0;
    var minY = simulationArea.minHeight || 0;
    var maxX = simulationArea.maxWidth || 0;
    var maxY = simulationArea.maxHeight || 0;

    var reqWidth = maxX - minX + 150;
    var reqHeight = maxY - minY + 150;

    this.scale = Math.min(width / reqWidth, height / reqHeight)

    if (!zoomIn)
        this.scale = Math.min(this.scale, DPR);
    this.scale = Math.max(this.scale, DPR / 10);

    this.ox = (-minX) * this.scale + (width - (maxX - minX) * this.scale) / 2;
    this.oy = (-minY) * this.scale + (height - (maxY - minY) * this.scale) / 2;
}

//fn to setup environment
function setupEnvironment() {

    projectId = generateId();
    updateSimulation = true;
    DPR = window.devicePixelRatio || 1;
    newCircuit("Main");

    data = {}
    resetup();
}


function setup() {

    setupElementLists();
    setupEnvironment();
    if (!embed)
        setupUI();
    startListeners();

    // Load project data after 1 second - needs to be improved, delay needs to be eliminated
    setTimeout(function() {
        if (logix_project_id != 0) {
            $('.loadingIcon').fadeIn();
            $.ajax({
                url: '/simulator/get_data',
                type: 'POST',
                beforeSend: function(xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
                },
                data: {
                    "id": logix_project_id
                },
                success: function(response) {
                    data = (response);

                    if (data) {
                        load(data);
                        simulationArea.changeClockTime(data["timePeriod"] || 500);
                    }
                    $('.loadingIcon').fadeOut();
                },
                failure: function() {
                    alert("Error: could not load ");
                    $('.loadingIcon').fadeOut();
                }
            });

        }

        // Restore unsaved data and save
        else if (localStorage.getItem("recover_login") && userSignedIn) {
            var data = JSON.parse(localStorage.getItem("recover_login"));
            load(data);
            localStorage.removeItem("recover");
            localStorage.removeItem("recover_login");
            save();
        }

        // Restore unsaved data which didn't get saved due to error
        else if (localStorage.getItem("recover")) {
            showMessage("We have detected that you did not save your last work. Don't worry we have recovered them. Access them using Project->Recover")
        }
    }, 1000);


}

// Helper function to recover unsaved data
function recoverProject() {
    if (localStorage.getItem("recover")) {
        var data = JSON.parse(localStorage.getItem("recover"));
        if (confirm("Would you like to recover: " + data.name)) {
            load(data);
        }
        localStorage.removeItem("recover");
    } else {
        showError("No recover project found")
    }
}

// Toggle light mode
function changeLightMode(val) {
    if (!val && lightMode) {
        lightMode = false;
        DPR = window.devicePixelRatio || 1;
        globalScope.scale *= DPR;
    } else if (val && !lightMode) {
        lightMode = true;
        globalScope.scale /= DPR;
        DPR = 1
        $('#miniMap').fadeOut('fast');
    }
    resetup();
}

//to resize window and setup things
function resetup() {

    DPR = window.devicePixelRatio || 1;
    if (lightMode)
        DPR = 1;
    width = document.getElementById("simulationArea").clientWidth * DPR;
    if (!embed) {
        height = (document.getElementById("simulation").clientHeight - document.getElementById("toolbar").clientHeight) * DPR;
    } else {
        height = (document.getElementById("simulation").clientHeight) * DPR;
    }

    //setup simulationArea
    backgroundArea.setup();
    if (!embed) plotArea.setup();
    simulationArea.setup();

    // update();
    dots();

    document.getElementById("backgroundArea").style.height = height / DPR + 100;
    document.getElementById("backgroundArea").style.width = width / DPR + 100;
    document.getElementById("canvasArea").style.height = height / DPR;
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width + 100 * DPR;
    backgroundArea.canvas.height = height + 100 * DPR;
    if (!embed) {
        plotArea.c.width = document.getElementById("plot").clientWidth;
        plotArea.c.height = document.getElementById("plot").clientHeight
    }

    updateCanvas = true;
    update(); // INEFFICIENT, needs to be deprecated
    simulationArea.prevScale = 0;
    dots(true, false);
}

window.onresize = resetup; // listener
window.onorientationchange = resetup; // listener

//for mobiles
window.addEventListener('orientationchange', resetup); // listener

// Object that holds data and objects of grid canvas
var backgroundArea = {
    canvas: document.getElementById("backgroundArea"),
    setup: function() {
        this.canvas.width = width;
        this.canvas.height = height;
        this.context = this.canvas.getContext("2d");
        dots(true, false);
    },
    clear: function() {
        if (!this.context) return;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
}


//simulation environment object - holds simulation canvas
var simulationArea = {
    canvas: document.getElementById("simulationArea"),
    selected: false,
    hover: false,
    clockState: 0,
    clockEnabled: true,
    lastSelected: undefined,
    stack: [],
    prevScale: 0,
    oldx: 0,
    oldy: 0,
    objectList: [],
    maxHeight: 0,
    maxWidth: 0,
    minHeight: 0,
    minWidth: 0,
    multipleObjectSelections: [],
    copyList: [],
    shiftDown: false,
    controlDown: false,
    timePeriod: 500,
    mouseX: 0,
    mouseY: 0,
    mouseDownX: 0,
    mouseDownY: 0,
    simulationQueue: undefined,

    clickCount: 0, //double click
    lock: "unlocked",
    timer: function() {
        ckickTimer = setTimeout(function() {
            simulationArea.clickCount = 0;
        }, 600);
    },

    setup: function() {
        this.canvas.width = width;
        this.canvas.height = height;
        this.simulationQueue = new EventQueue(10000);
        this.context = this.canvas.getContext("2d");
        simulationArea.changeClockTime(simulationArea.timePeriod)
        this.mouseDown = false;
    },
    changeClockTime: function(t) {
        if (t < 50) return;
        clearInterval(simulationArea.ClockInterval);
        t = t || prompt("Enter Time Period:");
        simulationArea.timePeriod = t;
        simulationArea.ClockInterval = setInterval(clockTick, t);
    },
    clear: function() {
        if (!this.context) return;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
}
changeClockTime = simulationArea.changeClockTime

// Kept for archival purposes - needs to be removed
//
// function copyPaste(copyList) {
//     if(copyList.length==0)return;
//     tempScope = new Scope(globalScope.name,globalScope.id);
//     var oldOx=globalScope.ox;
//     var oldOy=globalScope.oy;
//     var oldScale=globalScope.scale;
//     d = backUp(globalScope);
//     loadScope(tempScope, d);
//     scopeList[tempScope.id]=tempScope;
//     tempScope.backups=globalScope.backups;
//     for (var i = 0; i < updateOrder.length; i++){
//         var prevLength=globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
//         // if(globalScope[updateOrder[i]].length)////console.log("deleting, ",globalScope[updateOrder[i]]);
//         for (var j = 0; j < globalScope[updateOrder[i]].length; j++) {
//             var obj = globalScope[updateOrder[i]][j];
//             if (obj.objectType != 'Wire') { //}&&obj.objectType!='CircuitElement'){//}&&(obj.objectType!='Node'||obj.type==2)){
//                 if (!copyList.contains(globalScope[updateOrder[i]][j])) {
//                     ////console.log("DELETE:", globalScope[updateOrder[i]][j]);
//                     globalScope[updateOrder[i]][j].cleanDelete();
//                 }
//             }
//
//             if(globalScope[updateOrder[i]].length!=prevLength){
//                 prevLength--;
//                 j--;
//             }
//         }
//     }
//
//     // updateSimulation = true;
//     // update(globalScope);
//     ////console.log("DEBUG1",globalScope.wires.length)
//     var prevLength=globalScope.wires.length;
//     for (var i = 0; i < globalScope.wires.length; i++) {
//         globalScope.wires[i].checkConnections();
//         if(globalScope.wires.length!=prevLength){
//             prevLength--;
//             i--;
//         }
//     }
//     ////console.log(globalScope.wires,globalScope.allNodes)
//     ////console.log("DEBUG2",globalScope.wires.length)
//     // update(globalScope);
//     // ////console.log(globalScope.wires.length)
//
//     var approxX=0;
//     var approxY=0;
//     for (var i = 0; i < copyList.length; i++) {
//         approxX+=copyList[i].x;
//         approxY+=copyList[i].y;
//     }
//     approxX/=copyList.length;
//     approxY/=copyList.length;
//
//     approxX=Math.round(approxX/10)*10
//     approxY=Math.round(approxY/10)*10
//     for (var i = 0; i < updateOrder.length; i++)
//         for (var j = 0; j < globalScope[updateOrder[i]].length; j++) {
//             var obj = globalScope[updateOrder[i]][j];
//             obj.updateScope(tempScope);
//         }
//
//
//     for (var i = 0; i < copyList.length; i++) {
//         // ////console.log(copyList[i]);
//         copyList[i].x += simulationArea.mouseX-approxX;
//         copyList[i].y += simulationArea.mouseY-approxY;
//
//     }
//
//
//     // for (var i = 0; i < globalScope.wires.length; i++) {
//     //     globalScope.wires[i].updateScope(tempScope);
//     // }
//
//     for (l in globalScope) {
//         if (globalScope[l] instanceof Array && l != "objects") {
//             tempScope[l].extend(globalScope[l]);
//             // ////console.log("Copying , ",l);
//         }
//     }
//
//     // update(tempScope);
//
//
//     simulationArea.multipleObjectSelections = [];//copyList.slice();
//     simulationArea.copyList = [];//copyList.slice();
//     canvasUpdate=true;
//     updateSimulation = true;
//     globalScope = tempScope;
//     scheduleUpdate();
//     globalScope.ox=oldOx;
//     globalScope.oy=oldOy;
//     globalScope.scale=oldScale;
//
// // }

// paste function
function paste(copyData) {

    if (copyData == undefined) return;
    var data = JSON.parse(copyData);
    if (!data["logixClipBoardData"]) return;

    var currentScopeId = globalScope.id;
    for (var i = 0; i < data.scopes.length; i++) {
        if (scopeList[data.scopes[i].id] == undefined) {
            var scope = newCircuit(data.scopes[i].name, data.scopes[i].id);
            loadScope(scope, data.scopes[i]);
            scopeList[data.scopes[i].id] = scope;
        }
    }

    switchCircuit(currentScopeId);
    var tempScope = new Scope(globalScope.name, globalScope.id);
    var oldOx = globalScope.ox;
    var oldOy = globalScope.oy;
    var oldScale = globalScope.scale;
    loadScope(tempScope, data);

    var prevLength = tempScope.allNodes.length
    for (var i = 0; i < tempScope.allNodes.length; i++) {
        tempScope.allNodes[i].checkDeleted();
        if (tempScope.allNodes.length != prevLength) {
            prevLength--;
            i--;
        }
    }

    var approxX = 0;
    var approxY = 0;
    var count = 0

    for (var i = 0; i < updateOrder.length; i++) {
        for (var j = 0; j < tempScope[updateOrder[i]].length; j++) {
            var obj = tempScope[updateOrder[i]][j];
            obj.updateScope(globalScope);
            if (obj.objectType != "Wire") {
                approxX += obj.x;
                approxY += obj.y;
                count++;
            }
        }
    }

    for (var j = 0; j < tempScope.CircuitElement.length; j++) {
        var obj = tempScope.CircuitElement[j]
        obj.updateScope(globalScope);
    }

    approxX /= count
    approxY /= count

    approxX = Math.round(approxX / 10) * 10
    approxY = Math.round(approxY / 10) * 10


    for (var i = 0; i < updateOrder.length; i++) {
        for (var j = 0; j < tempScope[updateOrder[i]].length; j++) {
            var obj = tempScope[updateOrder[i]][j];
            if (obj.objectType != "Wire") {
                obj.x += simulationArea.mouseX - approxX;
                obj.y += simulationArea.mouseY - approxY;
            }
        }
    }

    for (l in tempScope) {
        if (tempScope[l] instanceof Array && l != "objects" && l != "CircuitElement") {
            globalScope[l].extend(tempScope[l]);
        }
    }
    for (var i = 0; i < tempScope.Input.length; i++) {
        tempScope.Input[i].layoutProperties.y = get_next_position(0, globalScope);
        tempScope.Input[i].layoutProperties.id = generateId();
    }
    for (var i = 0; i < tempScope.Output.length; i++) {
        tempScope.Output[i].layoutProperties.x = globalScope.layout.width;
        tempScope.Output[i].layoutProperties.id = generateId();
        tempScope.Output[i].layoutProperties.y = get_next_position(globalScope.layout.width, globalScope);
    }

    canvasUpdate = true;
    updateSimulation = true;
    updateSubcircuit = true;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;


    forceResetNodes = true
}

function cut(copyList) {
    if (copyList.length == 0) return;
    var tempScope = new Scope(globalScope.name, globalScope.id);
    var oldOx = globalScope.ox;
    var oldOy = globalScope.oy;
    var oldScale = globalScope.scale;
    d = backUp(globalScope);
    loadScope(tempScope, d);
    scopeList[tempScope.id] = tempScope;

    for (var i = 0; i < copyList.length; i++) {
        var obj = copyList[i];
        if (obj.objectType == "Node") obj.objectType = "allNodes"
        for (var j = 0; j < tempScope[obj.objectType].length; j++) {
            if (tempScope[obj.objectType][j].x == obj.x && tempScope[obj.objectType][j].y == obj.y && (obj.objectType != "Node" || obj.type == 2)) {
                tempScope[obj.objectType][j].delete();
                break;
            }

        }
    }
    tempScope.backups = globalScope.backups;
    for (var i = 0; i < updateOrder.length; i++) {
        var prevLength = globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
        for (var j = 0; j < globalScope[updateOrder[i]].length; j++) {
            var obj = globalScope[updateOrder[i]][j];
            if (obj.objectType != 'Wire') { //}&&obj.objectType!='CircuitElement'){//}&&(obj.objectType!='Node'||obj.type==2)){
                if (!copyList.contains(globalScope[updateOrder[i]][j])) {
                    globalScope[updateOrder[i]][j].cleanDelete();
                }
            }

            if (globalScope[updateOrder[i]].length != prevLength) {
                prevLength--;
                j--;
            }
        }
    }

    var prevLength = globalScope.wires.length;
    for (var i = 0; i < globalScope.wires.length; i++) {
        globalScope.wires[i].checkConnections();
        if (globalScope.wires.length != prevLength) {
            prevLength--;
            i--;
        }
    }

    updateSimulation = true;

    var data = backUp(globalScope);
    data['logixClipBoardData'] = true;
    var dependencyList = globalScope.getDependencies();
    data["dependencies"] = {};
    for (dependency in dependencyList)
        data.dependencies[dependency] = backUp(scopeList[dependency]);
    data['logixClipBoardData'] = true;
    data = JSON.stringify(data);

    simulationArea.multipleObjectSelections = []; //copyList.slice();
    simulationArea.copyList = []; //copyList.slice();
    canvasUpdate = true;
    updateSimulation = true;
    globalScope = tempScope;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;
    forceResetNodes = true
    return data;
}

function copy(copyList, cut = false) {

    if (copyList.length == 0) return;
    var tempScope = new Scope(globalScope.name, globalScope.id);
    var oldOx = globalScope.ox;
    var oldOy = globalScope.oy;
    var oldScale = globalScope.scale;
    var d = backUp(globalScope);

    loadScope(tempScope, d);
    scopeList[tempScope.id] = tempScope;

    if (cut) {
        for (var i = 0; i < copyList.length; i++) {
            var obj = copyList[i];
            if (obj.objectType == "Node") obj.objectType = "allNodes"
            for (var j = 0; j < tempScope[obj.objectType].length; j++) {
                if (tempScope[obj.objectType][j].x == obj.x && tempScope[obj.objectType][j].y == obj.y && (obj.objectType != "Node" || obj.type == 2)) {
                    tempScope[obj.objectType][j].delete();
                    break;
                }

            }
        }
    }
    tempScope.backups = globalScope.backups;
    for (var i = 0; i < updateOrder.length; i++) {
        var prevLength = globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
        for (var j = 0; j < globalScope[updateOrder[i]].length; j++) {
            var obj = globalScope[updateOrder[i]][j];
            if (obj.objectType != 'Wire') { //}&&obj.objectType!='CircuitElement'){//}&&(obj.objectType!='Node'||obj.type==2)){
                if (!copyList.contains(globalScope[updateOrder[i]][j])) {
                    ////console.log("DELETE:", globalScope[updateOrder[i]][j]);
                    globalScope[updateOrder[i]][j].cleanDelete();
                }
            }

            if (globalScope[updateOrder[i]].length != prevLength) {
                prevLength--;
                j--;
            }
        }
    }

    var prevLength = globalScope.wires.length;
    for (var i = 0; i < globalScope.wires.length; i++) {
        globalScope.wires[i].checkConnections();
        if (globalScope.wires.length != prevLength) {
            prevLength--;
            i--;
        }
    }

    updateSimulation = true;

    var data = backUp(globalScope);
    data.scopes = []
    var dependencyList = {};
    var requiredDependencies = globalScope.getDependencies();
    var completed = {};
    for (id in scopeList)
        dependencyList[id] = scopeList[id].getDependencies();

    function saveScope(id) {

        if (completed[id]) return;
        for (var i = 0; i < dependencyList[id].length; i++)
            saveScope(dependencyList[id][i]);
        completed[id] = true;
        data.scopes.push(backUp(scopeList[id]));

    }

    for (var i = 0; i < requiredDependencies.length; i++)
        saveScope(requiredDependencies[i]);

    data['logixClipBoardData'] = true;
    data = JSON.stringify(data);

    simulationArea.multipleObjectSelections = []; //copyList.slice();
    simulationArea.copyList = []; //copyList.slice();
    canvasUpdate = true;
    updateSimulation = true;
    globalScope = tempScope;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;
    forceResetNodes = true
    return data;
}

// Function selects all the elements from the scope
function selectAll(scope = globalScope) {
    circuitElementList.forEach((val, _, __) => {
        if (scope.hasOwnProperty(val)) {
            simulationArea.multipleObjectSelections.push(...scope[val]);
        }
    });

    if (scope.nodes) {
        simulationArea.multipleObjectSelections.push(...scope.nodes);
    }
}

// The Circuit element class serves as the abstract class for all circuit elements.
// Data Members: /* Insert Description */
// Prototype Methods:
//          - update: Used to update the state of object on mouse applicationCache
//          - isHover: Used to check if mouse is hovering over object


function CircuitElement(x, y, scope, dir, bitWidth) {
    // Data member initializations
    this.objectType = this.constructor.name;
    this.x = x;
    this.y = y;

    this.hover = false;
    if (this.x == undefined || this.y == undefined) {
        this.x = simulationArea.mouseX;
        this.y = simulationArea.mouseY;
        this.newElement = true;
        this.hover = true;
    }

    this.deleteNodesWhenDeleted = true; // FOR NOW - TO CHECK LATER

    this.nodeList = []
    this.clicked = false;

    this.oldx = x;
    this.oldy = y;

    /**
     The following attributes help in setting the touch area bound. They are the distances from the center.
     Note they are all positive distances from center. They will automatically be rotated when direction is changed.
     To stop the rotation when direction is changed, check overrideDirectionRotation attribute.
     **/
    this.leftDimensionX = 10;
    this.rightDimensionX = 10;
    this.upDimensionY = 10;
    this.downDimensionY = 10;

    this.rectangleObject = true;
    this.label = "";
    this.scope = scope;

    this.scope[this.objectType].push(this);

    this.bitWidth = bitWidth || parseInt(prompt("Enter bitWidth"), 10) || 1;
    this.direction = dir;
    this.directionFixed = false;
    this.labelDirectionFixed = false;
    this.labelDirection = oppositeDirection[dir];
    this.orientationFixed = true;
    this.fixedBitWidth = false;

    scheduleUpdate();

    this.queueProperties = {
        inQueue: false,
        time: undefined,
        index: undefined,
    }

}

CircuitElement.prototype.alwaysResolve = false
CircuitElement.prototype.propagationDelay = 100
CircuitElement.prototype.flipBits = function(val) {
    return ((~val >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
}
CircuitElement.prototype.absX = function() {
    return this.x;
}
CircuitElement.prototype.absY = function() {
    return this.y;
}
CircuitElement.prototype.copyFrom = function(obj) {
    var properties = ["label", "labelDirection"];
    for (var i = 0; i < properties.length; i++) {
        if (obj[properties[i]] !== undefined)
            this[properties[i]] = obj[properties[i]];
    }
}

/* Methods to be Implemented for derivedClass
        saveObject(); //To generate JSON-safe data that can be loaded
        customDraw(); //This is to draw the custom design of the circuit(Optional)
        resolve(); // To execute digital logic(Optional)
        override isResolvable(); // custom logic for checking if module is ready
        override newDirection(dir) //To implement custom direction logic(Optional)
        newOrientation(dir) //To implement custom orientation logic(Optional)
    */

// Method definitions

CircuitElement.prototype.updateScope = function(scope) {
    this.scope = scope;
    for (var i = 0; i < this.nodeList.length; i++)
        this.nodeList[i].scope = scope;
}

CircuitElement.prototype.saveObject = function() {
    var data = {
        x: this.x,
        y: this.y,
        objectType: this.objectType,
        label: this.label,
        direction: this.direction,
        labelDirection: this.labelDirection,
        propagationDelay: this.propagationDelay,
        customData: this.customSave()
    }
    return data;

}
CircuitElement.prototype.customSave = function() {
    return {
        values: {},
        nodes: {},
        constructorParamaters: [],
    }
}

CircuitElement.prototype.checkHover = function() {

    if (simulationArea.mouseDown) return;
    for (var i = 0; i < this.nodeList.length; i++) {
        this.nodeList[i].checkHover();
    }
    if (!simulationArea.mouseDown) {
        if (simulationArea.hover == this) {
            this.hover = this.isHover();
            if (!this.hover) simulationArea.hover = undefined;
        } else if (!simulationArea.hover) {
            this.hover = this.isHover();
            if (this.hover) simulationArea.hover = this;
        } else {
            this.hover = false
        }
    }
}

//This sets the width and height of the element if its rectangular
// and the reference point is at the center of the object.
//width and height define the X and Y distance from the center.
//Effectively HALF the actual width and height.
// NOT OVERRIDABLE
CircuitElement.prototype.setDimensions = function(width, height) {
    this.leftDimensionX = this.rightDimensionX = width;
    this.downDimensionY = this.upDimensionY = height;
}
CircuitElement.prototype.setWidth = function(width) {
    this.leftDimensionX = this.rightDimensionX = width;
}
CircuitElement.prototype.setHeight = function(height) {
    this.downDimensionY = this.upDimensionY = height;
}

// The update method is used to change the parameters of the object on mouse click and hover.
// Return Value: true if state has changed else false
// NOT OVERRIDABLE

// When true this.isHover() will not rotate bounds. To be used when bounds are set manually.
CircuitElement.prototype.overrideDirectionRotation = false;

CircuitElement.prototype.startDragging = function() {
    this.oldx = this.x;
    this.oldy = this.y;
}
CircuitElement.prototype.drag = function() {
    this.x = this.oldx + simulationArea.mouseX - simulationArea.mouseDownX;
    this.y = this.oldy + simulationArea.mouseY - simulationArea.mouseDownY;
}
CircuitElement.prototype.update = function() {

    var update = false;

    update |= this.newElement;
    if (this.newElement) {
        if (this.centerElement) {
            this.x = Math.round((simulationArea.mouseX - (this.rightDimensionX - this.leftDimensionX) / 2) / 10) * 10;
            this.y = Math.round((simulationArea.mouseY - (this.downDimensionY - this.upDimensionY) / 2) / 10) * 10;
        } else {
            this.x = simulationArea.mouseX;
            this.y = simulationArea.mouseY;
        }

        if (simulationArea.mouseDown) {
            this.newElement = false;
            simulationArea.lastSelected = this;
        } else return;
    }

    for (var i = 0; i < this.nodeList.length; i++) {
        update |= this.nodeList[i].update();
    }

    if (!simulationArea.hover || simulationArea.hover == this)
        this.hover = this.isHover();

    if (!simulationArea.mouseDown) this.hover = false;


    if ((this.clicked || !simulationArea.hover) && this.isHover()) {
        this.hover = true;
        simulationArea.hover = this;
    } else if (!simulationArea.mouseDown && this.hover && this.isHover() == false) {
        if (this.hover) simulationArea.hover = undefined;
        this.hover = false;
    }

    if (simulationArea.mouseDown && (this.clicked)) {

        this.drag();
        if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
            for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                simulationArea.multipleObjectSelections[i].drag();
            }
        }

        update |= true;
    } else if (simulationArea.mouseDown && !simulationArea.selected) {

        this.startDragging();
        if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
            for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                simulationArea.multipleObjectSelections[i].startDragging();
            }
        }
        simulationArea.selected = this.clicked = this.hover;

        update |= this.clicked;
    } else {
        if (this.clicked) simulationArea.selected = false;
        this.clicked = false;
        this.wasClicked = false;
    }

    if (simulationArea.mouseDown && !this.wasClicked) {
        if (this.clicked) {
            this.wasClicked = true;
            if (this.click) this.click();
            if (simulationArea.shiftDown) {
                simulationArea.lastSelected = undefined;
                if (simulationArea.multipleObjectSelections.contains(this)) {
                    simulationArea.multipleObjectSelections.clean(this);
                } else {
                    simulationArea.multipleObjectSelections.push(this);
                }
            } else {
                simulationArea.lastSelected = this;
            }
        }
    }

    return update;
}

CircuitElement.prototype.fixDirection = function() {
    this.direction = fixDirection[this.direction] || this.direction;
    this.labelDirection = fixDirection[this.labelDirection] || this.labelDirection;
}

// The isHover method is used to check if the mouse is hovering over the object.
// Return Value: true if mouse is hovering over object else false
// NOT OVERRIDABLE
CircuitElement.prototype.isHover = function() {

    var mX = simulationArea.mouseXf - this.x;
    var mY = this.y - simulationArea.mouseYf;

    var rX = this.rightDimensionX;
    var lX = this.leftDimensionX;
    var uY = this.upDimensionY;
    var dY = this.downDimensionY;

    if (!this.directionFixed && !this.overrideDirectionRotation) {
        if (this.direction == "LEFT") {
            lX = this.rightDimensionX;
            rX = this.leftDimensionX
        } else if (this.direction == "DOWN") {
            lX = this.downDimensionY;
            rX = this.upDimensionY;
            uY = this.leftDimensionX;
            dY = this.rightDimensionX;
        } else if (this.direction == "UP") {
            lX = this.downDimensionY;
            rX = this.upDimensionY;
            dY = this.leftDimensionX;
            uY = this.rightDimensionX;
        }
    }

    return -lX <= mX && mX <= rX && -dY <= mY && mY <= uY;
};

CircuitElement.prototype.setLabel = function(label) {
    this.label = label || ""
}

CircuitElement.prototype.propagationDelayFixed = false;

//Method that draws the outline of the module and calls draw function on module Nodes.
//NOT OVERRIDABLE
CircuitElement.prototype.draw = function() {
    var ctx = simulationArea.context;
    this.checkHover();
    if (this.x * this.scope.scale + this.scope.ox < -this.rightDimensionX * this.scope.scale - 00 || this.x * this.scope.scale + this.scope.ox > width + this.leftDimensionX * this.scope.scale + 00 || this.y * this.scope.scale + this.scope.oy < -this.downDimensionY * this.scope.scale - 00 || this.y * this.scope.scale + this.scope.oy > height + 00 + this.upDimensionY * this.scope.scale) return;

    // Draws rectangle and highlights
    if (this.rectangleObject) {
        ctx.strokeStyle = "black";
        ctx.fillStyle = "white";
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, [this.direction, "RIGHT"][+this.directionFixed]);
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected == this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = "rgba(255, 255, 32,0.8)";
        ctx.fill();
        ctx.stroke();
    }
    if (this.label != "") {
        var rX = this.rightDimensionX;
        var lX = this.leftDimensionX;
        var uY = this.upDimensionY;
        var dY = this.downDimensionY;
        if (!this.directionFixed) {
            if (this.direction == "LEFT") {
                lX = this.rightDimensionX;
                rX = this.leftDimensionX
            } else if (this.direction == "DOWN") {
                lX = this.downDimensionY;
                rX = this.upDimensionY;
                uY = this.leftDimensionX;
                dY = this.rightDimensionX;
            } else if (this.direction == "UP") {
                lX = this.downDimensionY;
                rX = this.upDimensionY;
                dY = this.leftDimensionX;
                uY = this.rightDimensionX;
            }
        }

        if (this.labelDirection == "LEFT") {
            ctx.beginPath();
            ctx.textAlign = "right";
            ctx.fillStyle = "black";
            fillText(ctx, this.label, this.x - lX - 10, this.y + 5, 14);
            ctx.fill();
        } else if (this.labelDirection == "RIGHT") {
            ctx.beginPath();
            ctx.textAlign = "left";
            ctx.fillStyle = "black";
            fillText(ctx, this.label, this.x + rX + 10, this.y + 5, 14);
            ctx.fill();
        } else if (this.labelDirection == "UP") {
            ctx.beginPath();
            ctx.textAlign = "center";
            ctx.fillStyle = "black";
            fillText(ctx, this.label, this.x, this.y + 5 - uY - 10, 14);
            ctx.fill();
        } else if (this.labelDirection == "DOWN") {
            ctx.beginPath();
            ctx.textAlign = "center";
            ctx.fillStyle = "black";
            fillText(ctx, this.label, this.x, this.y + 5 + dY + 10, 14);
            ctx.fill();
        }
    }

    // calls the custom circuit design
    if (this.customDraw)
        this.customDraw();

    //draws nodes - Moved to renderCanvas
    // for (var i = 0; i < this.nodeList.length; i++)
    //     this.nodeList[i].draw();
}

//method to delete object
//OVERRIDE WITH CAUTION
CircuitElement.prototype.delete = function() {
    simulationArea.lastSelected = undefined;
    this.scope[this.objectType].clean(this); // CHECK IF THIS IS VALID
    if (this.deleteNodesWhenDeleted)
        this.deleteNodes();
    else
        for (var i = 0; i < this.nodeList.length; i++)
            if (this.nodeList[i].connections.length)
                this.nodeList[i].converToIntermediate();
            else
                this.nodeList[i].delete();
    this.deleted = true;
}

CircuitElement.prototype.cleanDelete = function() {
    this.deleteNodesWhenDeleted = true;
    this.delete();
}

CircuitElement.prototype.deleteNodes = function() {
    for (var i = 0; i < this.nodeList.length; i++)
        this.nodeList[i].delete();
}

//method to change direction
//OVERRIDE WITH CAUTION
CircuitElement.prototype.newDirection = function(dir) {
    if (this.direction == dir) return;
    // Leave this for now
    if (this.directionFixed && this.orientationFixed) return;
    else if (this.directionFixed) {
        this.newOrientation(dir);
        return; // Should it return ?
    }

    // if (obj.direction == undefined) return;
    this.direction = dir;
    for (var i = 0; i < this.nodeList.length; i++) {
        this.nodeList[i].refresh();
    }

}

CircuitElement.prototype.newLabelDirection = function(dir) {
    this.labelDirection = dir;
}

//Method to check if object can be resolved
//OVERRIDE if necessary
CircuitElement.prototype.isResolvable = function() {
    if (this.alwaysResolve) return true;
    for (var i = 0; i < this.nodeList.length; i++)
        if (this.nodeList[i].type == 0 && this.nodeList[i].value == undefined) return false;
    return true;
}

//Method to change object Bitwidth
//OVERRIDE if necessary
CircuitElement.prototype.newBitWidth = function(bitWidth) {
    if (this.fixedBitWidth) return;
    if (this.bitWidth == undefined) return;
    if (this.bitWidth < 1) return;
    this.bitWidth = bitWidth;
    for (var i = 0; i < this.nodeList.length; i++)
        this.nodeList[i].bitWidth = bitWidth;
}

//Method to change object delay
//OVERRIDE if necessary
CircuitElement.prototype.changePropagationDelay = function(delay) {
    if (this.propagationDelayFixed) return;
    if (delay == undefined) return;
    if (delay == "") return;
    delay = parseInt(delay, 10)
    if (delay < 0) return;
    this.propagationDelay = delay;
}

//Dummy resolve function
//OVERRIDE if necessary
CircuitElement.prototype.resolve = function() {

}

CircuitElement.prototype.processVerilog = function() {
    var output_count = 0;
    for (var i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type == NODE_OUTPUT) {
            this.nodeList[i].verilogLabel = this.nodeList[i].verilogLabel || (this.verilogLabel + "_" + (verilog.fixName(this.nodeList[i].label) || ("out_" + output_count)));
            if (this.objectType != "Input" && this.nodeList[i].connections.length > 0) {
                if (this.scope.verilogWireList[this.bitWidth] != undefined) {
                    if (!this.scope.verilogWireList[this.bitWidth].contains(this.nodeList[i].verilogLabel))
                        this.scope.verilogWireList[this.bitWidth].push(this.nodeList[i].verilogLabel);
                } else
                    this.scope.verilogWireList[this.bitWidth] = [this.nodeList[i].verilogLabel];
            }
            this.scope.stack.push(this.nodeList[i]);
            output_count++;
        }
    }
}

CircuitElement.prototype.isVerilogResolvable = function() {

    var backupValues = []
    for (var i = 0; i < this.nodeList.length; i++) {
        backupValues.push(this.nodeList[i].value);
        this.nodeList[i].value = undefined;
    }

    for (var i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].verilogLabel) {
            this.nodeList[i].value = 1;
        }
    }

    var res = this.isResolvable();

    for (var i = 0; i < this.nodeList.length; i++) {
        this.nodeList[i].value = backupValues[i];
    }

    return res;
}

CircuitElement.prototype.removePropagation = function() {
    for (var i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type == NODE_OUTPUT) {
            if (this.nodeList[i].value !== undefined) {
                this.nodeList[i].value = undefined;
                simulationArea.simulationQueue.add(this.nodeList[i]);
            }
        }
    }
}

CircuitElement.prototype.verilogName = function() {
    return this.verilogType || this.objectType;
}

CircuitElement.prototype.generateVerilog = function() {

    var inputs = [];
    var outputs = [];


    for (var i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type == NODE_INPUT) {
            inputs.push(this.nodeList[i]);
        } else {
            outputs.push(this.nodeList[i]);
        }
    }

    var list = outputs.concat(inputs);
    var res = this.verilogName() + " " + this.verilogLabel + " (" + list.map(function(x) {
        return x.verilogLabel
    }).join(",") + ");";

    return res;
}

function distance(x1, y1, x2, y2) {
    return Math.sqrt(Math.pow((x2 - x1), 2) + Math.pow((y2 - y1), 2));
}
