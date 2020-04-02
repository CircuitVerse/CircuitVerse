// Engine.js
// Core of the simulation and rendering algorithm

var totalObjects = 0;

// Function to check for any UI update, it is throttled by time
function scheduleUpdate(count = 0, time = 100, fn) {

    if (lightMode) time *= 5;

    if (count && !layoutMode) { // Force update
        update();
        for (var i = 0; i < count; i++)
            setTimeout(update, 10 + 50 * i);
    }

    if (willBeUpdated) return; // Throttling

    willBeUpdated = true;

    if (layoutMode) {
        setTimeout(layoutUpdate, time); // Update layout, different algorithm
        return;
    }

    // Call a function before update ..
    if (fn)
        setTimeout(function() {
            fn();
            update();
        }, time);
    else setTimeout(update, time);

}

// fn that calls update on everything else. If any change is there, it resolves the circuit and draws it again

function update(scope = globalScope, updateEverything = false) {

    willBeUpdated = false;
    if (loading == true || layoutMode) return;

    var updated = false;
    simulationArea.hover = undefined;

    // Update wires
    if (wireToBeChecked || updateEverything) {
        if (wireToBeChecked == 2) wireToBeChecked = 0; // this required due to timing issues
        else wireToBeChecked++;
        // WHY IS THIS REQUIRED ???? we are checking inside wire ALSO
        var prevLength = scope.wires.length;
        for (var i = 0; i < scope.wires.length; i++) {
            scope.wires[i].checkConnections();
            if (scope.wires.length != prevLength) {
                prevLength--;
                i--;
            }
        }
        scheduleUpdate();
    }

    // Update subcircuits
    if (updateSubcircuit || updateEverything) {
        for (var i = 0; i < scope.SubCircuit.length; i++)
            scope.SubCircuit[i].reset();
        updateSubcircuit = false;
    }

    // Update UI position
    if (updatePosition || updateEverything) {
        for (var i = 0; i < updateOrder.length; i++)
            for (var j = 0; j < scope[updateOrder[i]].length; j++) {
                updated |= scope[updateOrder[i]][j].update();
            }
    }

    // Updates multiple objectselections and panes window
    if (updatePosition || updateEverything) {
        updateSelectionsAndPane(scope);
    }

    // Update MiniMap
    if (!embed && simulationArea.mouseDown && simulationArea.lastSelected && simulationArea.lastSelected != globalScope.root) {
        if (!lightMode)
            $('#miniMap').fadeOut('fast');
    }

    // Run simulation
    if (updateSimulation) {
        play();
    }

    // Show properties of selected element
    if (!embed && prevPropertyObj != simulationArea.lastSelected) {
        if (simulationArea.lastSelected && simulationArea.lastSelected.objectType !== "Wire") {
            showProperties(simulationArea.lastSelected);
        } else {
            // hideProperties();
        }
    }

    //Draw, render everything
    if (updateCanvas) {
        renderCanvas(scope);
    }
    updateSimulation = updateCanvas = updatePosition = false;

}

// Function to find dimensions of the current circuit
function findDimensions(scope = globalScope) {
    totalObjects = 0;
    simulationArea.minWidth = undefined;
    simulationArea.maxWidth = undefined;
    simulationArea.minHeight = undefined;
    simulationArea.maxHeight = undefined;
    for (var i = 0; i < updateOrder.length; i++) {
        if (updateOrder[i] !== 'wires')
            for (var j = 0; j < scope[updateOrder[i]].length; j++) {

                totalObjects += 1;
                var obj = scope[updateOrder[i]][j];
                if (totalObjects == 1) {
                    simulationArea.minWidth = obj.absX();
                    simulationArea.minHeight = obj.absY();
                    simulationArea.maxWidth = obj.absX();
                    simulationArea.maxHeight = obj.absY();
                }
                if (obj.objectType != 'Node') {
                    if (obj.y - obj.upDimensionY < simulationArea.minHeight)
                        simulationArea.minHeight = obj.y - obj.upDimensionY;
                    if (obj.y + obj.downDimensionY > simulationArea.maxHeight)
                        simulationArea.maxHeight = obj.y + obj.downDimensionY;
                    if (obj.x - obj.leftDimensionX < simulationArea.minWidth)
                        simulationArea.minWidth = obj.x - obj.leftDimensionX;
                    if (obj.x + obj.rightDimensionX > simulationArea.maxWidth)
                        simulationArea.maxWidth = obj.x + obj.rightDimensionX;
                } else {
                    if (obj.absY() < simulationArea.minHeight)
                        simulationArea.minHeight = obj.absY();
                    if (obj.absY() > simulationArea.maxHeight)
                        simulationArea.maxHeight = obj.absY();
                    if (obj.absX() < simulationArea.minWidth)
                        simulationArea.minWidth = obj.absX();
                    if (obj.absX() > simulationArea.maxWidth)
                        simulationArea.maxWidth = obj.absX();
                }

            }

    }
    simulationArea.objectList = updateOrder;

}

// Function to move multiple objects and panes window
function updateSelectionsAndPane(scope = globalScope) {

    if (!simulationArea.selected && simulationArea.mouseDown) {

        simulationArea.selected = true;
        simulationArea.lastSelected = scope.root;
        simulationArea.hover = scope.root;

        // Selecting multiple objects
        if (simulationArea.shiftDown) {
            objectSelection = true;
        } else {
            if (!embed) {
                findDimensions(scope);
                miniMapArea.setup();
                $('#miniMap').show();
            }
        }
    } else if (simulationArea.lastSelected == scope.root && simulationArea.mouseDown) {

        //pane canvas
        if (!objectSelection) {
            globalScope.ox = (simulationArea.mouseRawX - simulationArea.mouseDownRawX) + simulationArea.oldx;
            globalScope.oy = (simulationArea.mouseRawY - simulationArea.mouseDownRawY) + simulationArea.oldy;
            globalScope.ox = Math.round(globalScope.ox);
            globalScope.oy = Math.round(globalScope.oy);
            gridUpdate = true;
            if (!embed && !lightMode) miniMapArea.setup();
        } else {

        }


    } else if (simulationArea.lastSelected == scope.root) {

        // Select multiple objects

        simulationArea.lastSelected = undefined;
        simulationArea.selected = false;
        simulationArea.hover = undefined;

        if (objectSelection) {
            objectSelection = false;
            var x1 = simulationArea.mouseDownX;
            var x2 = simulationArea.mouseX;
            var y1 = simulationArea.mouseDownY;
            var y2 = simulationArea.mouseY;

            // Sort points
            if (x1 > x2) {
                var temp = x1;
                x1 = x2;
                x2 = temp;
            }
            if (y1 > y2) {
                var temp = y1;
                y1 = y2;
                y2 = temp;
            }

            // Select the objects, push them into a list
            for (var i = 0; i < updateOrder.length; i++) {
                for (var j = 0; j < scope[updateOrder[i]].length; j++) {
                    var obj = scope[updateOrder[i]][j];
                    if (simulationArea.multipleObjectSelections.contains(obj)) continue;
                    var x, y;
                    if (obj.objectType == "Node") {
                        x = obj.absX();
                        y = obj.absY();
                    } else if (obj.objectType != "Wire") {
                        x = obj.x;
                        y = obj.y;
                    } else {
                        continue;
                    }
                    if (x > x1 && x < x2 && y > y1 && y < y2) {
                        simulationArea.multipleObjectSelections.push(obj);
                    }
                }
            }
        }
    }
}

// Function to render Canvas according th renderupdate order
function renderCanvas(scope) {

    if (layoutMode) { // Different Algorithm
        return;
    }

    var ctx = simulationArea.context;

    // Reset canvas
    simulationArea.clear();

    // Update Grid
    if (gridUpdate) {
        gridUpdate = false;
        dots();
    }

    canvasMessageData = undefined; //  Globally set in draw fn ()

    // Render objects
    for (var i = 0; i < renderOrder.length; i++)
        for (var j = 0; j < scope[renderOrder[i]].length; j++)
            scope[renderOrder[i]][j].draw();

    // Show any message

    if (canvasMessageData) {
        canvasMessage(ctx, canvasMessageData.string, canvasMessageData.x, canvasMessageData.y)
    }

    // If multiple object selections are going on, show selected area
    if (objectSelection) {
        ctx.beginPath();
        ctx.lineWidth = 2;
        ctx.strokeStyle = "black"
        ctx.fillStyle = "rgba(0,0,0,0.1)"
        rect2(ctx, simulationArea.mouseDownX, simulationArea.mouseDownY, simulationArea.mouseX - simulationArea.mouseDownX, simulationArea.mouseY - simulationArea.mouseDownY, 0, 0, "RIGHT");
        ctx.stroke();
        ctx.fill();
    }
    if (simulationArea.hover != undefined) {
        simulationArea.canvas.style.cursor = "pointer";
    } else if (createNode) {
        simulationArea.canvas.style.cursor = 'grabbing';
    } else {
        simulationArea.canvas.style.cursor = 'default';
    }

}

//Main fn that resolves circuit using event driven simulation
function play(scope = globalScope, resetNodes = false) {

    if (errorDetected) return; // Don't simulate until error is fixed

    if (loading == true) return; // Don't simulate until loaded

    if (!embed) plotArea.stopWatch.Stop(); // Waveform thing

    // Reset Nodes if required
    if (resetNodes || forceResetNodes) {
        scope.reset();
        simulationArea.simulationQueue.reset();
        forceResetNodes = false;
    }

    // Temporarily kept for for future uses
    // else{
    //     // clearBuses(scope);
    //     for(var i=0;i<scope.TriState.length;i++) {
    //         // console.log("HIT2",i);
    //         scope.TriState[i].removePropagation();
    //     }
    // }

    // Add subcircuits if they can be resolved -- needs to be removed/ deprecated
    for (var i = 0; i < scope.SubCircuit.length; i++) {
        if (scope.SubCircuit[i].isResolvable()) simulationArea.simulationQueue.add(scope.SubCircuit[i]);
    }

    // To store list of circuitselements that have shown contention but kept temporarily
    // Mainly to resolve tristate bus issues
    simulationArea.contentionPending = [];

    // add inputs to the simulation queue
    scope.addInputs();

    var stepCount = 0;
    var elem = undefined

    while (!simulationArea.simulationQueue.isEmpty()) {
        if (errorDetected) {
            simulationArea.simulationQueue.reset();
            return;
        }

        elem = simulationArea.simulationQueue.pop();
        elem.resolve();
        stepCount++;

        if (stepCount > 1000000) { // Cyclic or infinite Circuit Detection
            showError("Simulation Stack limit exceeded: maybe due to cyclic paths or contention");
            errorDetected = true;
            forceResetNodes = true
        }
    }

    // Check for TriState Contentions
    if (simulationArea.contentionPending.length) {
        console.log(simulationArea.contentionPending)
        showError("Contention at TriState");
        forceResetNodes = true
        errorDetected = true;
    }

    // Setting Flag Values
    for (var i = 0; i < scope.Flag.length; i++)
        scope.Flag[i].setPlotValue();

}
