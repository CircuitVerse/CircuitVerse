/* eslint-disable no-bitwise */
/* eslint-disable camelcase */
/* eslint-disable no-alert */
/* eslint-disable no-restricted-globals */
/* eslint-disable func-names */
/* eslint-disable no-param-reassign */
/* eslint-disable no-prototype-builtins */
/* eslint-disable no-return-assign */
/* eslint-disable no-extend-native */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
/**
 * width of the canvas
 * @type {number}
 */
let width;

/**
 * height of the canvas
 * @type {number}
 */
let height;

/**
 * Currently Focussed circuit/scope
 * @type {Scope}
 */
let globalScope;

/**
 * To be deprecated
 * @type {number}
 */
const uniqueIdCounter = 0;

/**
 * size of each division/ not used everywhere, to be deprecated
 * @type {number}
 */

const unit = 10;

/**
 * when node disconnects from another node
 * @type {number}
 */
const wireToBeChecked = 0;

/**
 * scheduleUpdate() will be called if true
 * @type {boolean}
 */
const willBeUpdated = false; // scheduleUpdate() will be called if true

/**
 * Flag for object selection
 * @type {boolean}
 */
const objectSelection = false; // Flag for object selection

/**
 * Flag for error detection
 * @type {boolean}
 */
let errorDetected = false;

/**
 * Global letiable for error messages
 * @type {?string}
 */

let prevErrorMessage;

/**
 * Global letiable for error messages
 * @type {?string}
 */
let prevShowMessage;

/**
 * Flag for updating position
 * @type {boolean}
 */
const updatePosition = true;
/**
 * Flag for updating simulation
 * @type {boolean}
 */
let updateSimulation = true;
/**
 * Flag for rendering
 * @type {boolean}
 */
let updateCanvas = true;

/**
 * Flag for updating grid
 * @type {boolean}
 */
const gridUpdate = true;
/**
 * Flag for updating subCircuits
 * @type {boolean}
 */
let updateSubcircuit = true;

/**
 * Flag - all assets are loaded
 * @type {boolean}
 */
const loading = false;

/**
 * devicePixelRatio, 2 for retina displays, 1 for low resolution displays
 * @type {number}
 */
let DPR = 1;

/**
 * Flag for project saved or not
 * @type {boolean}
 */
const projectSaved = true;

/**
 * To be deprecated
 * @type {boolean}
 */
let lightMode = false;

/**
 * Flag for mode
 * @type {boolean}
 */
const layoutMode = false;

/**
 * Flag to reset all Nodes
 * @type {boolean}
 */
let forceResetNodes = true;


// This list needs to be updated when new circuitselements are created

/**
 * simulation environment object - holds simulation canvas
 * @typedef {Object} simulationArea
 * @property {HTMLCanvasElement} canvas
 * @property {boolean} selected
 * @property {boolean} hover
 * @property {number} clockState
 * @property {boolean} clockEnabled
 * @property {undefined} lastSelected
 * @property {Array} stack
 * @property {number} prevScale
 * @property {number} oldx
 * @property {number} oldy
 * @property {Array} objectList
 * @property {number} maxHeight
 * @property {number} maxWidth
 * @property {number} minHeight
 * @property {number} minWidth
 * @property {Array} multipleObjectSelections
 * @property {Array} copyList - List of selected elements
 * @property {boolean} shiftDown - shift down or not
 * @property {boolean} controlDown - contol down or not
 * @property {number} timePeriod - time period
 * @property {number} mouseX - mouse x
 * @property {number} mouseY - mouse y
 * @property {number} mouseDownX - mouse click x
 * @property {number} mouseDownY - mouse click y
 * @property {Array} simulationQueue - simulation queue
 * @property {number} clickCount - number of clicks
 * @property {string} lock - locked or unlocked
 * @property {function} timer - timer
 * @property {function} setup - to setup the simulaton area
 * @property {function} changeClockTime - change clock time
 * @property {function} clear - clear the simulation area
 */
const simulationArea = {
    canvas: document.getElementById('simulationArea'),
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

    clickCount: 0, // double click
    lock: 'unlocked',
    timer() {
        ckickTimer = setTimeout(() => {
            simulationArea.clickCount = 0;
        }, 600);
    },

    setup() {
        this.canvas.width = width;
        this.canvas.height = height;
        this.simulationQueue = new EventQueue(10000);
        this.context = this.canvas.getContext('2d');
        simulationArea.changeClockTime(simulationArea.timePeriod);
        this.mouseDown = false;
    },
    changeClockTime(t) {
        if (t < 50) return;
        clearInterval(simulationArea.ClockInterval);
        t = t || prompt('Enter Time Period:');
        simulationArea.timePeriod = t;
        simulationArea.ClockInterval = setInterval(clockTick, t);
    },
    clear() {
        if (!this.context) return;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    },
};
changeClockTime = simulationArea.changeClockTime;

/**
 * Function to setup the sidebar. It draw icons in the sidebar
 * It also initializes som other useful lists which are helpful
 * while saving and loading project.
 */
function setupElementLists() {
    $('#menu').empty();

    window.circuitElementList = metadata.circuitElementList;
    window.annotationList = metadata.annotationList;
    window.inputList = metadata.inputList;
    window.subCircuitInputList = metadata.subCircuitInputList;
    window.moduleList = [...circuitElementList, ...annotationList];
    window.updateOrder = ['wires', ...circuitElementList, 'nodes', ...annotationList]; // Order of update
    window.renderOrder = [...(moduleList.slice().reverse()), 'wires', 'allNodes']; // Order of render

    /**
     * Helper funcion to create icons in the sidebar
     * @param {string} element - The name of the element whose icon has to created
     */
    function createIcon(element) {
        return `<div class="icon logixModules pointerCursor" id="${element}" >
            <img src= "/img/${element}.svg" >
            <p class="img__description">${element}</p>
        </div>`;
    }

    const { elementHierarchy } = metadata;
    for (category in elementHierarchy.keys()) {
        let htmlIcons = '';
        const categoryData = elementHierarchy[category];
        for (let i = 0; i < categoryData.length; i++) {
            const element = categoryData[i];
            htmlIcons += createIcon(element);
        }
        const accordionData = `<div class="panelHeader">${category}</div>
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
//     "JKflipFlop", "SRflipFlop", "DflipFlop", "TTY", "Keyboard", "Clock", "DigitalLed", "Stepper", "letiableLed", "RGBLed", "SquareRGBLed", "RGBLedMatrix", "Button", "Demultiplexer",
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

/**
 * Scope object for each circuit level, globalScope for outer level
 * @type {JSON}
 */
scopeList = {};


/**
 * Helper function to show error
 * @param {string} error -The error to be shown
 */
function showError(error) {
    errorDetected = true;
    // if error ha been shown return
    if (error === prevErrorMessage) return;
    prevErrorMessage = error;
    const id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append(`<div class='alert alert-danger' role='alert' id='${id}'> ${error}</div>`);
    setTimeout(() => {
        prevErrorMessage = undefined;
        $(`#${id}`).fadeOut();
    }, 1500);
}

/**
 * Helper function to show message
 * @param {string} mes -The message to be shown
 */
function showMessage(mes) {
    if (mes === prevShowMessage) return;
    prevShowMessage = mes;
    const id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append(`<div class='alert alert-success' role='alert' id='${id}'> ${mes}</div>`);
    setTimeout(() => {
        prevShowMessage = undefined;
        $(`#${id}`).fadeOut();
    }, 2500);
}

/**
 * Helper function to warn about restricted element on hover and to remove help
 */
function showRestricted() {
    $('#restrictedDiv').removeClass('display--none');
    // Show no help text for restricted elements
    $('#Help').removeClass('show');
    $('#restrictedDiv').html('The element has been restricted by mentor. Usage might lead to deduction in marks');
}

/**
 * helper function to hide the restricted elements div
 */
function hideRestricted() {
    $('#restrictedDiv').addClass('display--none');
}

/**
 * Function to update restricted elements list once
 * the teacher changes the restricted elements
 */
function updateRestrictedElementsList() {
    if (restrictedElements.length === 0) return;
    const { restrictedCircuitElementsUsed } = globalScope;
    let restrictedStr = '';
    restrictedCircuitElementsUsed.forEach((element) => {
        restrictedStr += `${element}, `;
    });
    if (restrictedStr === '') {
        restrictedStr = 'None';
    } else {
        restrictedStr = restrictedStr.slice(0, -2);
    }

    $('#restrictedElementsDiv--list').html(restrictedStr);
}

/**
 * Function to check if restricted element has been used
 * @param {Scope=} scope -The circuit on which we are checking ifrestricted element has been used
 */
function updateRestrictedElementsInScope(scope = globalScope) {
    // Do nothing if no restricted elements
    if (restrictedElements.length === 0) return;

    const restrictedElementsUsed = [];
    restrictedElements.forEach((element) => {
        if (scope[element].length > 0) {
            restrictedElementsUsed.push(element);
        }
    });

    scope.restrictedCircuitElementsUsed = restrictedElementsUsed;
    updateRestrictedElementsList();
}


/**
 * Helper function to open link in new tab
 * @param {string} url - link to be opened
 */
function openInNewTab(url) {
    const win = window.open(url, '_blank');
    win.focus();
}

// Following function need to be improved - remove mutability etc
// fn to remove elem in array
Array.prototype.clean = function (deleteValue) {
    for (let i = 0; i < this.length; i++) {
        if (this[i] === deleteValue) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
};

// Following function need to be improved
Array.prototype.extend = function (otherArray) {
    /* you should include a test to check whether otherArray really is an array */
    otherArray.forEach(function (v) {
        this.push(v);
    }, this);
};

// Following function need to be improved
// fn to check if an elem is in an array
Array.prototype.contains = function (value) {
    return this.indexOf(value) > -1;
};

/**
 * Helper function to return unique list
 * @param {Array} a - any array
 */
function uniq(a) {
    const seen = {};
    return a.filter((item) => (seen.hasOwnProperty(item) ? false : (seen[item] = true)));
}


// Base circuit class
// All circuits are stored in a scope

/**
 * Constructor for a circuit
 * @class
 * @param {string} name - name of the circuit
 * @param {number=} id - a random id for the circuit
 */
function Scope(name = 'localScope', id = undefined) {
    this.restrictedCircuitElementsUsed = [];
    this.id = id || Math.floor((Math.random() * 100000000000) + 1);
    this.CircuitElement = [];

    // root object for referring to main canvas - intermediate node uses this
    // eslint-disable-next-line no-use-before-define
    this.root = new CircuitElement(0, 0, this, 'RIGHT', 1);
    this.backups = [];
    this.timeStamp = new Date().getTime();

    this.ox = 0;
    this.oy = 0;
    this.scale = DPR;
    this.tunnelList = {};
    this.stack = [];

    this.name = name;
    this.pending = [];
    this.nodes = []; // intermediate nodes only
    this.allNodes = [];
    this.wires = [];

    // Creating arrays for other module elements
    for (let i = 0; i < moduleList.length; i++) {
        this[moduleList[i]] = [];
    }

    // Setting default layout
    this.layout = { // default position
        width: 100,
        height: 40,
        title_x: 50,
        title_y: 13,
        titleEnabled: true,
    };


    // FOR SOME UNKNOWN REASON, MAKING THE COPY OF THE LIST COMMON
    // TO ALL SCOPES EITHER BY PROTOTYPE OR JUST BY REFERNCE IS CAUSING ISSUES
    // The issue comes regarding copy/paste operation, after 5-6 operations it becomes slow for unknown reasons
    // CHANGE/ REMOVE WITH CAUTION
    // this.objects = ["wires", ...circuitElementList, "nodes", ...annotationList];
    // this.renderObjectOrder = [ ...(moduleList.slice().reverse()), "wires", "allNodes"];
}

/**
 * Resets all nodes recursively
 * @memberof Scope
 */
Scope.prototype.reset = function () {
    for (let i = 0; i < this.allNodes.length; i++) { this.allNodes[i].reset(); }
    for (let i = 0; i < this.Splitter.length; i++) {
        this.Splitter[i].reset();
    }
    for (let i = 0; i < this.SubCircuit.length; i++) {
        this.SubCircuit[i].reset();
    }
};

/**
 * Adds all inputs to simulationQueue
 * @memberof Scope
 */
Scope.prototype.addInputs = function () {
    for (let i = 0; i < inputList.length; i++) {
        for (let j = 0; j < this[inputList[i]].length; j++) {
            simulationArea.simulationQueue.add(this[inputList[i]][j], 0);
        }
    }

    for (let j = 0; j < this.SubCircuit.length; j++) { this.SubCircuit[j].addInputs(); }
};

/**
 * Ticks clocks recursively -- needs to be deprecated and synchronize all clocks with a global clock
 * @memberof Scope
 */
Scope.prototype.clockTick = function () {
    for (let i = 0; i < this.Clock.length; i++) { this.Clock[i].toggleState(); } // tick clock!
    for (let i = 0; i < this.SubCircuit.length; i++) { this.SubCircuit[i].localScope.clockTick(); } // tick clock!
};

/**
 * Checks if this circuit contains directly or indirectly scope with id
 * Recursive nature
 * @memberof Scope
 */
Scope.prototype.checkDependency = function (id) {
    if (id === this.id) return true;
    for (let i = 0; i < this.SubCircuit.length; i++) { if (this.SubCircuit[i].id === id) return true; }

    for (let i = 0; i < this.SubCircuit.length; i++) { if (scopeList[this.SubCircuit[i].id].checkDependency(id)) return true; }

    return false;
};

/**
 * Get dependency list - list of all circuits, this circuit depends on
 * @memberof Scope
 */
Scope.prototype.getDependencies = function () {
    const list = [];
    for (let i = 0; i < this.SubCircuit.length; i++) {
        list.push(this.SubCircuit[i].id);
        list.extend(scopeList[this.SubCircuit[i].id].getDependencies());
    }
    return uniq(list);
};

/**
 * helper function to reduce layout size
 * @memberof Scope
 */
Scope.prototype.fixLayout = function () {
    let maxY = 20;
    for (let i = 0; i < this.Input.length; i++) { maxY = Math.max(this.Input[i].layoutProperties.y, maxY); }
    for (let i = 0; i < this.Output.length; i++) { maxY = Math.max(this.Output[i].layoutProperties.y, maxY); }
    if (maxY !== this.layout.height) { this.layout.height = maxY + 10; }
};

/**
 * Function which centers the circuit to the correct zoom level
 * @memberof Scope
 */
Scope.prototype.centerFocus = function (zoomIn = true) {
    if (layoutMode) return;
    findDimensions(this);
    const minX = simulationArea.minWidth || 0;
    const minY = simulationArea.minHeight || 0;
    const maxX = simulationArea.maxWidth || 0;
    const maxY = simulationArea.maxHeight || 0;

    const reqWidth = maxX - minX + 150;
    const reqHeight = maxY - minY + 150;

    this.scale = Math.min(width / reqWidth, height / reqHeight);

    if (!zoomIn) { this.scale = Math.min(this.scale, DPR); }
    this.scale = Math.max(this.scale, DPR / 10);

    this.ox = (-minX) * this.scale + (width - (maxX - minX) * this.scale) / 2;
    this.oy = (-minY) * this.scale + (height - (maxY - minY) * this.scale) / 2;
};

/**
 * function to setup environment letiables like projectId and DPR
 */
function setupEnvironment() {
    projectId = generateId();
    updateSimulation = true;
    DPR = window.devicePixelRatio || 1;
    newCircuit('Main');

    data = {};
    // eslint-disable-next-line no-use-before-define
    resetup();
}

/**
 * The first function to be called to setup the whole simulator
 */
function setup() {
    setupElementLists();
    setupEnvironment();
    if (!embed) { setupUI(); }
    startListeners();

    // Load project data after 1 second - needs to be improved, delay needs to be eliminated
    setTimeout(() => {
        if (logix_project_id !== 0) {
            $('.loadingIcon').fadeIn();
            $.ajax({
                url: '/simulator/get_data',
                type: 'POST',
                beforeSend(xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                data: {
                    id: logix_project_id,
                },
                success(response) {
                    data = (response);

                    if (data) {
                        load(data);
                        simulationArea.changeClockTime(data.timePeriod || 500);
                    }
                    $('.loadingIcon').fadeOut();
                },
                failure() {
                    alert('Error: could not load ');
                    $('.loadingIcon').fadeOut();
                },
            });
        } else if (localStorage.getItem('recover_login') && userSignedIn) {
            // Restore unsaved data and save
            const data = JSON.parse(localStorage.getItem('recover_login'));
            load(data);
            localStorage.removeItem('recover');
            localStorage.removeItem('recover_login');
            save();
        } else if (localStorage.getItem('recover')) {
            // Restore unsaved data which didn't get saved due to error
            showMessage("We have detected that you did not save your last work. Don't worry we have recovered them. Access them using Project->Recover");
        }
    }, 1000);
}

/**
 * Helper function to recover unsaved data
 */
function recoverProject() {
    if (localStorage.getItem('recover')) {
        const data = JSON.parse(localStorage.getItem('recover'));
        if (confirm(`Would you like to recover: ${data.name}`)) {
            load(data);
        }
        localStorage.removeItem('recover');
    } else {
        showError('No recover project found');
    }
}


/**
 * to resize window and setup things
 */
function resetup() {
    DPR = window.devicePixelRatio || 1;
    if (lightMode) { DPR = 1; }
    width = document.getElementById('simulationArea').clientWidth * DPR;
    if (!embed) {
        height = (document.getElementById('simulation').clientHeight - document.getElementById('toolbar').clientHeight) * DPR;
    } else {
        height = (document.getElementById('simulation').clientHeight) * DPR;
    }

    // setup simulationArea
    // eslint-disable-next-line no-use-before-define
    backgroundArea.setup();
    if (!embed) plotArea.setup();
    simulationArea.setup();
    // update();
    dots();
    document.getElementById('backgroundArea').style.height = height / DPR + 100;
    document.getElementById('backgroundArea').style.width = width / DPR + 100;
    document.getElementById('canvasArea').style.height = height / DPR;
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    // eslint-disable-next-line no-use-before-define
    backgroundArea.canvas.width = width + 100 * DPR;
    // eslint-disable-next-line no-use-before-define
    backgroundArea.canvas.height = height + 100 * DPR;
    if (!embed) {
        plotArea.c.width = document.getElementById('plot').clientWidth;
        plotArea.c.height = document.getElementById('plot').clientHeight;
    }

    updateCanvas = true;
    update(); // INEFFICIENT, needs to be deprecated
    simulationArea.prevScale = 0;
    dots(false);
}

window.onresize = resetup; // listener
window.onorientationchange = resetup; // listener

// for mobiles
window.addEventListener('orientationchange', resetup); // listener

/**
 * Toggle light mode
 * @param {number} val - t be depriciated
 */
function changeLightMode(val) {
    if (!val && lightMode) {
        lightMode = false;
        DPR = window.devicePixelRatio || 1;
        globalScope.scale *= DPR;
    } else if (val && !lightMode) {
        lightMode = true;
        globalScope.scale /= DPR;
        DPR = 1;
        $('#miniMap').fadeOut('fast');
    }
    resetup();
}


/**
 * Object that holds data and objects of grid canvas
 * background area
 * @typedef {Object} backgroundArea
 * @property {HTMLCanvasElement} canvas
 * @property {function} setup - To setup backgoround are
 * @property {function} clear - To clear bg area
 */
let backgroundArea = {
    canvas: document.getElementById('backgroundArea'),
    setup() {
        this.canvas.width = width;
        this.canvas.height = height;
        this.context = this.canvas.getContext('2d');
        dots(false);
    },
    clear() {
        if (!this.context) return;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    },
};


// Kept for archival purposes - needs to be removed
//
// function copyPaste(copyList) {
//     if(copyList.length==0)return;
//     tempScope = new Scope(globalScope.name,globalScope.id);
//     let oldOx=globalScope.ox;
//     let oldOy=globalScope.oy;
//     let oldScale=globalScope.scale;
//     d = backUp(globalScope);
//     loadScope(tempScope, d);
//     scopeList[tempScope.id]=tempScope;
//     tempScope.backups=globalScope.backups;
//     for (let i = 0; i < updateOrder.length; i++){
//         let prevLength=globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
//         // if(globalScope[updateOrder[i]].length)////console.log("deleting, ",globalScope[updateOrder[i]]);
//         for (let j = 0; j < globalScope[updateOrder[i]].length; j++) {
//             let obj = globalScope[updateOrder[i]][j];
//             if (obj.objectType !== 'Wire') { //}&&obj.objectType!=='CircuitElement'){//}&&(obj.objectType!=='Node'||obj.type==2)){
//                 if (!copyList.contains(globalScope[updateOrder[i]][j])) {
//                     ////console.log("DELETE:", globalScope[updateOrder[i]][j]);
//                     globalScope[updateOrder[i]][j].cleanDelete();
//                 }
//             }
//
//             if(globalScope[updateOrder[i]].length!==prevLength){
//                 prevLength--;
//                 j--;
//             }
//         }
//     }
//
//     // updateSimulation = true;
//     // update(globalScope);
//     ////console.log("DEBUG1",globalScope.wires.length)
//     let prevLength=globalScope.wires.length;
//     for (let i = 0; i < globalScope.wires.length; i++) {
//         globalScope.wires[i].checkConnections();
//         if(globalScope.wires.length!==prevLength){
//             prevLength--;
//             i--;
//         }
//     }
//     ////console.log(globalScope.wires,globalScope.allNodes)
//     ////console.log("DEBUG2",globalScope.wires.length)
//     // update(globalScope);
//     // ////console.log(globalScope.wires.length)
//
//     let approxX=0;
//     let approxY=0;
//     for (let i = 0; i < copyList.length; i++) {
//         approxX+=copyList[i].x;
//         approxY+=copyList[i].y;
//     }
//     approxX/=copyList.length;
//     approxY/=copyList.length;
//
//     approxX=Math.round(approxX/10)*10
//     approxY=Math.round(approxY/10)*10
//     for (let i = 0; i < updateOrder.length; i++)
//         for (let j = 0; j < globalScope[updateOrder[i]].length; j++) {
//             let obj = globalScope[updateOrder[i]][j];
//             obj.updateScope(tempScope);
//         }
//
//
//     for (let i = 0; i < copyList.length; i++) {
//         // ////console.log(copyList[i]);
//         copyList[i].x += simulationArea.mouseX-approxX;
//         copyList[i].y += simulationArea.mouseY-approxY;
//
//     }
//
//
//     // for (let i = 0; i < globalScope.wires.length; i++) {
//     //     globalScope.wires[i].updateScope(tempScope);
//     // }
//
//     for (l in globalScope) {
//         if (globalScope[l] instanceof Array && l !== "objects") {
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

/**
 * Helper function to paste
 * @param {JSON} copyData - the data to be pasted
 */
function paste(copyData) {
    if (copyData === undefined) return;
    const data = JSON.parse(copyData);
    if (!data.logixClipBoardData) return;

    const currentScopeId = globalScope.id;
    for (let i = 0; i < data.scopes.length; i++) {
        if (scopeList[data.scopes[i].id] === undefined) {
            const scope = newCircuit(data.scopes[i].name, data.scopes[i].id);
            loadScope(scope, data.scopes[i]);
            scopeList[data.scopes[i].id] = scope;
        }
    }

    switchCircuit(currentScopeId);
    const tempScope = new Scope(globalScope.name, globalScope.id);
    const oldOx = globalScope.ox;
    const oldOy = globalScope.oy;
    const oldScale = globalScope.scale;
    loadScope(tempScope, data);

    let prevLength = tempScope.allNodes.length;
    for (let i = 0; i < tempScope.allNodes.length; i++) {
        tempScope.allNodes[i].checkDeleted();
        if (tempScope.allNodes.length !== prevLength) {
            prevLength--;
            i--;
        }
    }

    let approxX = 0;
    let approxY = 0;
    let count = 0;

    for (let i = 0; i < updateOrder.length; i++) {
        for (let j = 0; j < tempScope[updateOrder[i]].length; j++) {
            const obj = tempScope[updateOrder[i]][j];
            obj.updateScope(globalScope);
            if (obj.objectType !== 'Wire') {
                approxX += obj.x;
                approxY += obj.y;
                count++;
            }
        }
    }

    for (let j = 0; j < tempScope.CircuitElement.length; j++) {
        const obj = tempScope.CircuitElement[j];
        obj.updateScope(globalScope);
    }

    approxX /= count;
    approxY /= count;

    approxX = Math.round(approxX / 10) * 10;
    approxY = Math.round(approxY / 10) * 10;


    for (let i = 0; i < updateOrder.length; i++) {
        for (let j = 0; j < tempScope[updateOrder[i]].length; j++) {
            const obj = tempScope[updateOrder[i]][j];
            if (obj.objectType !== 'Wire') {
                obj.x += simulationArea.mouseX - approxX;
                obj.y += simulationArea.mouseY - approxY;
            }
        }
    }

    for (l in tempScope) {
        if (tempScope[l] instanceof Array && l !== 'objects' && l !== 'CircuitElement') {
            globalScope[l].extend(tempScope[l]);
        }
    }
    for (let i = 0; i < tempScope.Input.length; i++) {
        tempScope.Input[i].layoutProperties.y = get_next_position(0, globalScope);
        tempScope.Input[i].layoutProperties.id = generateId();
    }
    for (let i = 0; i < tempScope.Output.length; i++) {
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


    forceResetNodes = true;
}
/**
 * Helper function for cut
 * @param {JSON} copyList - The selected elements
 */
function cut(copyList) {
    if (copyList.length === 0) return;
    const tempScope = new Scope(globalScope.name, globalScope.id);
    const oldOx = globalScope.ox;
    const oldOy = globalScope.oy;
    const oldScale = globalScope.scale;
    d = backUp(globalScope);
    loadScope(tempScope, d);
    scopeList[tempScope.id] = tempScope;

    for (let i = 0; i < copyList.length; i++) {
        const obj = copyList[i];
        if (obj.objectType === 'Node') obj.objectType = 'allNodes';
        for (let j = 0; j < tempScope[obj.objectType].length; j++) {
            if (tempScope[obj.objectType][j].x === obj.x && tempScope[obj.objectType][j].y === obj.y && (obj.objectType !== 'Node' || obj.type === 2)) {
                tempScope[obj.objectType][j].delete();
                break;
            }
        }
    }
    tempScope.backups = globalScope.backups;
    for (let i = 0; i < updateOrder.length; i++) {
        let prevLength = globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
        for (let j = 0; j < globalScope[updateOrder[i]].length; j++) {
            const obj = globalScope[updateOrder[i]][j];
            if (obj.objectType !== 'Wire') { // }&&obj.objectType!=='CircuitElement'){//}&&(obj.objectType!=='Node'||obj.type==2)){
                if (!copyList.contains(globalScope[updateOrder[i]][j])) {
                    globalScope[updateOrder[i]][j].cleanDelete();
                }
            }

            if (globalScope[updateOrder[i]].length !== prevLength) {
                prevLength--;
                j--;
            }
        }
    }

    let prevLength = globalScope.wires.length;
    for (let i = 0; i < globalScope.wires.length; i++) {
        globalScope.wires[i].checkConnections();
        if (globalScope.wires.length !== prevLength) {
            prevLength--;
            i--;
        }
    }

    updateSimulation = true;

    let data = backUp(globalScope);
    data.logixClipBoardData = true;
    const dependencyList = globalScope.getDependencies();
    data.dependencies = {};
    for (dependency in dependencyList) { data.dependencies[dependency] = backUp(scopeList[dependency]); }
    data.logixClipBoardData = true;
    data = JSON.stringify(data);

    simulationArea.multipleObjectSelections = []; // copyList.slice();
    simulationArea.copyList = []; // copyList.slice();
    canvasUpdate = true;
    updateSimulation = true;
    globalScope = tempScope;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;
    forceResetNodes = true;
    // eslint-disable-next-line consistent-return
    return data;
}
/**
 * Helper function for copy
 * @param {JSON} copyList - The data to copied
 * @param {boolean} cutflag - flase if we want to copy
 */
function copy(copyList, cutflag = false) {
    if (copyList.length === 0) return;
    const tempScope = new Scope(globalScope.name, globalScope.id);
    const oldOx = globalScope.ox;
    const oldOy = globalScope.oy;
    const oldScale = globalScope.scale;
    const d = backUp(globalScope);

    loadScope(tempScope, d);
    scopeList[tempScope.id] = tempScope;

    if (cutflag) {
        for (let i = 0; i < copyList.length; i++) {
            const obj = copyList[i];
            if (obj.objectType === 'Node') obj.objectType = 'allNodes';
            for (let j = 0; j < tempScope[obj.objectType].length; j++) {
                if (tempScope[obj.objectType][j].x === obj.x && tempScope[obj.objectType][j].y === obj.y && (obj.objectType !== 'Node' || obj.type === 2)) {
                    tempScope[obj.objectType][j].delete();
                    break;
                }
            }
        }
    }
    tempScope.backups = globalScope.backups;
    for (let i = 0; i < updateOrder.length; i++) {
        let prevLength = globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
        for (let j = 0; j < globalScope[updateOrder[i]].length; j++) {
            const obj = globalScope[updateOrder[i]][j];
            if (obj.objectType !== 'Wire') { // }&&obj.objectType!=='CircuitElement'){//}&&(obj.objectType!=='Node'||obj.type==2)){
                if (!copyList.contains(globalScope[updateOrder[i]][j])) {
                    // //console.log("DELETE:", globalScope[updateOrder[i]][j]);
                    globalScope[updateOrder[i]][j].cleanDelete();
                }
            }

            if (globalScope[updateOrder[i]].length !== prevLength) {
                prevLength--;
                j--;
            }
        }
    }

    let prevLength = globalScope.wires.length;
    for (let i = 0; i < globalScope.wires.length; i++) {
        globalScope.wires[i].checkConnections();
        if (globalScope.wires.length !== prevLength) {
            prevLength--;
            i--;
        }
    }

    updateSimulation = true;

    let data = backUp(globalScope);
    data.scopes = [];
    const dependencyList = {};
    const requiredDependencies = globalScope.getDependencies();
    const completed = {};
    for (id in scopeList) { dependencyList[id] = scopeList[id].getDependencies(); }

    function saveScope(id) {
        if (completed[id]) return;
        for (let i = 0; i < dependencyList[id].length; i++) { saveScope(dependencyList[id][i]); }
        completed[id] = true;
        data.scopes.push(backUp(scopeList[id]));
    }

    for (let i = 0; i < requiredDependencies.length; i++) { saveScope(requiredDependencies[i]); }

    data.logixClipBoardData = true;
    data = JSON.stringify(data);

    simulationArea.multipleObjectSelections = []; // copyList.slice();
    simulationArea.copyList = []; // copyList.slice();
    canvasUpdate = true;
    updateSimulation = true;
    globalScope = tempScope;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;
    forceResetNodes = true;
    // needs to be fixed
    // eslint-disable-next-line consistent-return
    return data;
}

/**
 * Function selects all the elements from the scope
 */
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

/**
 * Base class for circuit elements.
 * @class
 * @param {number} x - x coordinate of the element
 * @param {number} y - y coordinate of the element
 * @param {Scope} scope - The circuit on which circuit element is being drawn
 * @param {string} dir - The direction of circuit element
 * @param {number} bitWidth - the number of bits per node.
 */
function CircuitElement(x, y, scope, dir, bitWidth) {
    // Data member initializations
    this.objectType = this.constructor.name;
    this.x = x;
    this.y = y;

    this.hover = false;
    if (this.x === undefined || this.y === undefined) {
        this.x = simulationArea.mouseX;
        this.y = simulationArea.mouseY;
        this.newElement = true;
        this.hover = true;
    }

    this.deleteNodesWhenDeleted = true; // FOR NOW - TO CHECK LATER

    this.nodeList = [];
    this.clicked = false;

    this.oldx = x;
    this.oldy = y;

    /**
     The following attributes help in setting the touch area bound. They are the distances from the center.
     Note they are all positive distances from center. They will automatically be rotated when direction is changed.
     To stop the rotation when direction is changed, check overrideDirectionRotation attribute.
     * */
    this.leftDimensionX = 10;
    this.rightDimensionX = 10;
    this.upDimensionY = 10;
    this.downDimensionY = 10;

    this.rectangleObject = true;
    this.label = '';
    this.scope = scope;

    this.scope[this.objectType].push(this);

    this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10) || 1;
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
    };
}

/**
 * Is the element resolvable
 * @memberof CircuitElement
 * @type {boolean}
 */
CircuitElement.prototype.alwaysResolve = false;
/**
 * propogation delay for the element
 * @memberof CircuitElement
 * @type {number}
 */
CircuitElement.prototype.propagationDelay = 100;

/**
 * Function to flip bits
 * @memberof CircuitElement
 * @param {number} val - the value of flipped bits
 * @returns {number} - The number of flipped bits
 */
CircuitElement.prototype.flipBits = function (val) {
    return ((~val >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
};

/**
 * Function to get absolute value of x coordinate of the element
 * @memberof CircuitElement
 * @param {number} x - value of x coordinate of the element
 * @return {number} - absolute value of x
 */
CircuitElement.prototype.absX = function () {
    return this.x;
};

/**
 * Function to get absolute value of y coordinate of the element
 * @memberof CircuitElement
 * @param {number} y - value of y coordinate of the element
 * @return {number} - absolute value of y
 */
CircuitElement.prototype.absY = function () {
    return this.y;
};

/**
 * Function to copy the circuit element obj to a new circuit element
 * @memberof CircuitElement
 * @param {CircuitElement} obj - element to be copied from
 */
CircuitElement.prototype.copyFrom = function (obj) {
    const properties = ['label', 'labelDirection'];
    for (let i = 0; i < properties.length; i++) {
        if (obj[properties[i]] !== undefined) { this[properties[i]] = obj[properties[i]]; }
    }
};

/* Methods to be Implemented for derivedClass
    saveObject(); //To generate JSON-safe data that can be loaded
    customDraw(); //This is to draw the custom design of the circuit(Optional)
    resolve(); // To execute digital logic(Optional)
    override isResolvable(); // custom logic for checking if module is ready
    override newDirection(dir) //To implement custom direction logic(Optional)
    newOrientation(dir) //To implement custom orientation logic(Optional) */

// Method definitions
/**
 * Function to update the scope when a new element is added.
 * @memberof CircuitElement
 * @param {Scope} scope - the circuit in which we add element
 */
CircuitElement.prototype.updateScope = function (scope) {
    this.scope = scope;
    for (let i = 0; i < this.nodeList.length; i++) { this.nodeList[i].scope = scope; }
};

/**
 * To generate JSON-safe data that can be loaded
 * @memberof CircuitElement
 * @return {JSON} - the data to be saved
 */
CircuitElement.prototype.saveObject = function () {
    const data = {
        x: this.x,
        y: this.y,
        objectType: this.objectType,
        label: this.label,
        direction: this.direction,
        labelDirection: this.labelDirection,
        propagationDelay: this.propagationDelay,
        customData: this.customSave(),
    };
    return data;
};

/**
 * Always overriden
 * @memberof CircuitElement
 * @return {JSON} - the data to be saved
 */
CircuitElement.prototype.customSave = function () {
    return {
        values: {},
        nodes: {},
        constructorParamaters: [],
    };
};

/**
 * check hover over the element
 * @memberof CircuitElement
 * @return {boolean}
 */
CircuitElement.prototype.checkHover = function () {
    if (simulationArea.mouseDown) return;
    for (let i = 0; i < this.nodeList.length; i++) {
        this.nodeList[i].checkHover();
    }
    if (!simulationArea.mouseDown) {
        if (simulationArea.hover === this) {
            this.hover = this.isHover();
            if (!this.hover) simulationArea.hover = undefined;
        } else if (!simulationArea.hover) {
            this.hover = this.isHover();
            if (this.hover) simulationArea.hover = this;
        } else {
            this.hover = false;
        }
    }
};

/**
 * This sets the width and height of the element if its rectangular
 * and the reference point is at the center of the object.
 * width and height define the X and Y distance from the center.
 * Effectively HALF the actual width and height.
 * NOT OVERRIDABLE
 * @memberof CircuitElement
 * @param {number} w - width
 * @param {number} h - height
 */
CircuitElement.prototype.setDimensions = function (w, h) {
    this.leftDimensionX = w;
    this.rightDimensionX = w;
    this.downDimensionY = h;
    this.upDimensionY = h;
};

/**
 * @memberof CircuitElement
 * @param {number} w -width
 */
CircuitElement.prototype.setWidth = function (w) {
    this.leftDimensionX = w;
    this.rightDimensionX = w;
};

/**
 * @memberof CircuitElement
 * @param {number} h -height
 */
CircuitElement.prototype.setHeight = function (h) {
    this.downDimensionY = h;
    this.upDimensionY = h;
};

/**
 * When true this.isHover() will not rotate bounds. To be used when bounds are set manually.
 * @memberof CircuitElement
 * @type {boolean}
 */
CircuitElement.prototype.overrideDirectionRotation = false;


/**
 * Helper Function to drag element to a new position
 * @memberof CircuitElement
 */
CircuitElement.prototype.startDragging = function () {
    this.oldx = this.x;
    this.oldy = this.y;
};

/**
 * Helper Function to drag element to a new position
 * @memberof CircuitElement
 */
CircuitElement.prototype.drag = function () {
    this.x = this.oldx + simulationArea.mouseX - simulationArea.mouseDownX;
    this.y = this.oldy + simulationArea.mouseY - simulationArea.mouseDownY;
};

/**
 * The update method is used to change the parameters of the object on mouse click and hover.
 * Return Value: true if state has changed else false
 * NOT OVERRIDABLE
 * @memberof CircuitElement
 */
CircuitElement.prototype.update = function () {
    let update = false;

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

    for (let i = 0; i < this.nodeList.length; i++) {
        update |= this.nodeList[i].update();
    }

    if (!simulationArea.hover || simulationArea.hover === this) { this.hover = this.isHover(); }

    if (!simulationArea.mouseDown) this.hover = false;


    if ((this.clicked || !simulationArea.hover) && this.isHover()) {
        this.hover = true;
        simulationArea.hover = this;
    } else if (!simulationArea.mouseDown && this.hover && this.isHover() === false) {
        if (this.hover) simulationArea.hover = undefined;
        this.hover = false;
    }

    if (simulationArea.mouseDown && (this.clicked)) {
        this.drag();
        if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
            for (let i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                simulationArea.multipleObjectSelections[i].drag();
            }
        }

        update |= true;
    } else if (simulationArea.mouseDown && !simulationArea.selected) {
        this.startDragging();
        if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
            for (let i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                simulationArea.multipleObjectSelections[i].startDragging();
            }
        }
        simulationArea.selected = this.hover;
        this.clicked = this.hover;

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

    // eslint-disable-next-line consistent-return
    return update;
};

/**
 * Helper Function to correct the direction of element
 * @memberof CircuitElement
 */
CircuitElement.prototype.fixDirection = function () {
    this.direction = fixDirection[this.direction] || this.direction;
    this.labelDirection = fixDirection[this.labelDirection] || this.labelDirection;
};

/**
 * The isHover method is used to check if the mouse is hovering over the object.
 * Return Value: true if mouse is hovering over object else false
 * NOT OVERRIDABLE
 * @memberof CircuitElement
 */
CircuitElement.prototype.isHover = function () {
    const mX = simulationArea.mouseXf - this.x;
    const mY = this.y - simulationArea.mouseYf;

    let rX = this.rightDimensionX;
    let lX = this.leftDimensionX;
    let uY = this.upDimensionY;
    let dY = this.downDimensionY;

    if (!this.directionFixed && !this.overrideDirectionRotation) {
        if (this.direction === 'LEFT') {
            lX = this.rightDimensionX;
            rX = this.leftDimensionX;
        } else if (this.direction === 'DOWN') {
            lX = this.downDimensionY;
            rX = this.upDimensionY;
            uY = this.leftDimensionX;
            dY = this.rightDimensionX;
        } else if (this.direction === 'UP') {
            lX = this.downDimensionY;
            rX = this.upDimensionY;
            dY = this.leftDimensionX;
            uY = this.rightDimensionX;
        }
    }

    return -lX <= mX && mX <= rX && -dY <= mY && mY <= uY;
};

/**
 * Helper Function to set label of an element.
 * @memberof CircuitElement
 * @param {string} label - the label for element
 */
CircuitElement.prototype.setLabel = function (label) {
    this.label = label || '';
};

/**
 * Documention is WIP
 * @memberof CircuitElement
 * @type {boolean}
 */
CircuitElement.prototype.propagationDelayFixed = false;

/**
 * Method that draws the outline of the module and calls draw function on module Nodes.
 * NOT OVERRIDABLE
 * @memberof CircuitElement
 */
CircuitElement.prototype.draw = function () {
    const ctx = simulationArea.context;
    this.checkHover();
    if (this.x * this.scope.scale + this.scope.ox < -this.rightDimensionX * this.scope.scale - 0 || this.x * this.scope.scale + this.scope.ox > width + this.leftDimensionX * this.scope.scale + 0 || this.y * this.scope.scale + this.scope.oy < -this.downDimensionY * this.scope.scale - 0 || this.y * this.scope.scale + this.scope.oy > height + 0 + this.upDimensionY * this.scope.scale) return;

    // Draws rectangle and highlights
    if (this.rectangleObject) {
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'white';
        ctx.lineWidth = correctWidth(3);
        ctx.beginPath();
        rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, [this.direction, 'RIGHT'][+this.directionFixed]);
        if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = 'rgba(255, 255, 32,0.8)';
        ctx.fill();
        ctx.stroke();
    }
    if (this.label !== '') {
        let rX = this.rightDimensionX;
        let lX = this.leftDimensionX;
        let uY = this.upDimensionY;
        let dY = this.downDimensionY;
        if (!this.directionFixed) {
            if (this.direction === 'LEFT') {
                lX = this.rightDimensionX;
                rX = this.leftDimensionX;
            } else if (this.direction === 'DOWN') {
                lX = this.downDimensionY;
                rX = this.upDimensionY;
                uY = this.leftDimensionX;
                dY = this.rightDimensionX;
            } else if (this.direction === 'UP') {
                lX = this.downDimensionY;
                rX = this.upDimensionY;
                dY = this.leftDimensionX;
                uY = this.rightDimensionX;
            }
        }

        if (this.labelDirection === 'LEFT') {
            ctx.beginPath();
            ctx.textAlign = 'right';
            ctx.fillStyle = 'black';
            fillText(ctx, this.label, this.x - lX - 10, this.y + 5, 14);
            ctx.fill();
        } else if (this.labelDirection === 'RIGHT') {
            ctx.beginPath();
            ctx.textAlign = 'left';
            ctx.fillStyle = 'black';
            fillText(ctx, this.label, this.x + rX + 10, this.y + 5, 14);
            ctx.fill();
        } else if (this.labelDirection === 'UP') {
            ctx.beginPath();
            ctx.textAlign = 'center';
            ctx.fillStyle = 'black';
            fillText(ctx, this.label, this.x, this.y + 5 - uY - 10, 14);
            ctx.fill();
        } else if (this.labelDirection === 'DOWN') {
            ctx.beginPath();
            ctx.textAlign = 'center';
            ctx.fillStyle = 'black';
            fillText(ctx, this.label, this.x, this.y + 5 + dY + 10, 14);
            ctx.fill();
        }
    }

    // calls the custom circuit design
    if (this.customDraw) { this.customDraw(); }

    // draws nodes - Moved to renderCanvas
    // for (let i = 0; i < this.nodeList.length; i++)
    //     this.nodeList[i].draw();
};

/**
 * method to delete object
 * OVERRIDE WITH CAUTION
 * @memberof CircuitElement
 */
CircuitElement.prototype.delete = function () {
    simulationArea.lastSelected = undefined;
    this.scope[this.objectType].clean(this); // CHECK IF THIS IS VALID
    if (this.deleteNodesWhenDeleted) { this.deleteNodes(); } else {
        for (let i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].connections.length) { this.nodeList[i].converToIntermediate(); } else { this.nodeList[i].delete(); }
        }
    }
    this.deleted = true;
};

/**
 * Helper Function to delete the element and all the node attached to it.
 * @memberof CircuitElement
 */
CircuitElement.prototype.cleanDelete = function () {
    this.deleteNodesWhenDeleted = true;
    this.delete();
};

/**
 * Helper Function to delete nodes on the circuit element.
 * @memberof CircuitElement
 */
CircuitElement.prototype.deleteNodes = function () {
    for (let i = 0; i < this.nodeList.length; i++) { this.nodeList[i].delete(); }
};

/**
 * method to change direction
 * OVERRIDE WITH CAUTION
 * @memberof CircuitElement
 * @param {string} dir - new direction
 */
CircuitElement.prototype.newDirection = function (dir) {
    if (this.direction === dir) return;
    // Leave this for now
    if (this.directionFixed && this.orientationFixed) return;
    if (this.directionFixed) {
        this.newOrientation(dir);
        return; // Should it return ?
    }

    // if (obj.direction === undefined) return;
    this.direction = dir;
    for (let i = 0; i < this.nodeList.length; i++) {
        this.nodeList[i].refresh();
    }
};
/**
 * Helper Function to change label direction of the element.
 * @memberof CircuitElement
 * @param {string} dir - new direction
 */
CircuitElement.prototype.newLabelDirection = function (dir) {
    this.labelDirection = dir;
};

/**
 * Method to check if object can be resolved
 * OVERRIDE if necessary
 * @memberof CircuitElement
 * @return {boolean}
 */
CircuitElement.prototype.isResolvable = function () {
    if (this.alwaysResolve) return true;
    for (let i = 0; i < this.nodeList.length; i++) { if (this.nodeList[i].type === 0 && this.nodeList[i].value === undefined) return false; }
    return true;
};

/**
 * Method to change object Bitwidth
 * OVERRIDE if necessary
 * @memberof CircuitElement
 * @param {number} bitWidth - new bitwidth
 */
CircuitElement.prototype.newBitWidth = function (bitWidth) {
    if (this.fixedBitWidth) return;
    if (this.bitWidth === undefined) return;
    if (this.bitWidth < 1) return;
    this.bitWidth = bitWidth;
    for (let i = 0; i < this.nodeList.length; i++) { this.nodeList[i].bitWidth = bitWidth; }
};

/**
 * Method to change object delay
 * OVERRIDE if necessary
 * @memberof CircuitElement
 * @param {number} delay - new delay
 */
CircuitElement.prototype.changePropagationDelay = function (delay) {
    if (this.propagationDelayFixed) return;
    if (delay === undefined) return;
    if (delay === '') return;
    delay = parseInt(delay, 10);
    if (delay < 0) return;
    this.propagationDelay = delay;
};

/**
 * Dummy resolve function
 * OVERRIDE if necessary
 * @memberof CircuitElement
 */
CircuitElement.prototype.resolve = function () {

};

/**
 * Helper Function to process verilog
 * @memberof CircuitElement
 */
CircuitElement.prototype.processVerilog = function () {
    let output_count = 0;
    for (let i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type === NODE_OUTPUT) {
            this.nodeList[i].verilogLabel = this.nodeList[i].verilogLabel || (`${this.verilogLabel}_${verilog.fixName(this.nodeList[i].label) || (`out_${output_count}`)}`);
            if (this.objectType !== 'Input' && this.nodeList[i].connections.length > 0) {
                if (this.scope.verilogWireList[this.bitWidth] !== undefined) {
                    if (!this.scope.verilogWireList[this.bitWidth].contains(this.nodeList[i].verilogLabel)) { this.scope.verilogWireList[this.bitWidth].push(this.nodeList[i].verilogLabel); }
                } else { this.scope.verilogWireList[this.bitWidth] = [this.nodeList[i].verilogLabel]; }
            }
            this.scope.stack.push(this.nodeList[i]);
            output_count++;
        }
    }
};

/**
 * Helper Function to check if verilog resolvable
 * @memberof CircuitElement
 * @return {boolean}
 */
CircuitElement.prototype.isVerilogResolvable = function () {
    const backupValues = [];
    for (let i = 0; i < this.nodeList.length; i++) {
        backupValues.push(this.nodeList[i].value);
        this.nodeList[i].value = undefined;
    }

    for (let i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].verilogLabel) {
            this.nodeList[i].value = 1;
        }
    }

    const res = this.isResolvable();

    for (let i = 0; i < this.nodeList.length; i++) {
        this.nodeList[i].value = backupValues[i];
    }

    return res;
};

/**
 * Helper Function to remove proporgation.
 * @memberof CircuitElement
 */
CircuitElement.prototype.removePropagation = function () {
    for (let i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type === NODE_OUTPUT) {
            if (this.nodeList[i].value !== undefined) {
                this.nodeList[i].value = undefined;
                simulationArea.simulationQueue.add(this.nodeList[i]);
            }
        }
    }
};

/**
 * Helper Function to name the verilog.
 * @memberof CircuitElement
 * @return {string}
 */
CircuitElement.prototype.verilogName = function () {
    return this.verilogType || this.objectType;
};

/**
 * Helper Function to generate verilog
 * @memberof CircuitElement
 * @return {JSON}
 */
CircuitElement.prototype.generateVerilog = function () {
    const inputs = [];
    const outputs = [];
    for (let i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type === NODE_INPUT) {
            inputs.push(this.nodeList[i]);
        } else {
            outputs.push(this.nodeList[i]);
        }
    }
    const list = outputs.concat(inputs);
    const res = `${this.verilogName()} ${this.verilogLabel} (${list.map((x) => x.verilogLabel).join(',')});`;
    return res;
};

/**
 * Function to find eucledian distance between x1,y1 to x2,y2
 * @param {number} x1 - x coordinate of point 1
 * @param {number} y1 - y coordinate of point 1
 * @param {number} x2 - x coordinate of point 2
 * @param {number} y2 - y coordinate of point 2
 */
function distance(x1, y1, x2, y2) {
    return Math.sqrt(((x2 - x1) ** 2) + ((y2 - y1) ** 2));
}

/**
 * function to report and issue
 */
// Report An issue ---------------------------------------->START

(function () {
    let message = '';
    let valid = false;
    $('#issuetext').on('input', () => {
        message = $('#issuetext').val().trim();
        valid = message.length > 0;
        $('#report').attr('disabled', !valid);
    });

    $('#report').click(() => {
        message += `\nURL: ${window.location.href}`;
        message += '\nUser Id: <%= user_signed_in? ? " #{current_user.id.to_s} : #{current_user.name}" : "Guest user" %>';
        postUserIssue(message);
        $('#issuetext').hide();
        $('#report').hide();
        $('#report-label').hide();
    });

    $('.issue').on('hide.bs.modal', (e) => {
        $('#report').attr('disabled', true);
        $('#result').html('');
        $('#issuetext').show();
        $('#issuetext').val('');
        $('#report').show();
        $('#report-label').show();
    });
}());

// Report An issue ---------------------------------------->END
