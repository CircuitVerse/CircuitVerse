// Temporarily kept - to be deleted

var totalObjects = 0;

function scheduleUpdate(count = 0, time = 100, fn) {
    // return;
    // //////console.log(willBeUpdated,updateSimulation,);
    if (lightMode) time *= 5;

    if (count && !layoutMode) {
        for (var i = 0; i < count; i++)
            setTimeout(update, 10 + 50 * i);
    }
    if (willBeUpdated) return;

    willBeUpdated = true;
    // if (simulationArea.mouseDown)
    if (layoutMode) {
        setTimeout(layoutUpdate, time);
        return;
    }

    if (fn)
        setTimeout(function() {
            fn();
            update();
        }, time);
    else setTimeout(update, time);
    // else
    //     setTimeout(update, 100);


}


// fn that calls update on everything else. If any change is there, it resolves the circuit and draws it again
// fn to change scale (zoom) - It also shifts origin so that the position
//of the object in focus doent changeB


function update(scope = globalScope, updateEverything = false) {
    willBeUpdated = false;
    if (loading == true || layoutMode) return;
    // //////console.log("UPDATE");

    var updated = false;
    simulationArea.hover = undefined;
    // wireToBeChecked=true;
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

    if (updateSubcircuit || updateEverything) {
        for (var i = 0; i < scope.SubCircuit.length; i++)
            scope.SubCircuit[i].reset();
        updateSubcircuit = false;
    }



    if (updatePosition || updateEverything) {
        //////console.log("updatePosition");
        for (var i = 0; i < updateOrder.length; i++)
            for (var j = 0; j < scope[updateOrder[i]].length; j++) {
                updated |= scope[updateOrder[i]][j].update();
            }
    }

    // updateSimulation |= updated;
    if (updatePosition) {

    }

    if (updatePosition || updateEverything) {
        updateSelectionsAndPane(scope);
    }
    if (!embed && simulationArea.mouseDown && simulationArea.lastSelected && simulationArea.lastSelected != globalScope.root) {
        if (!lightMode)
            $('#miniMap').fadeOut('fast');
    }

    if (updateSimulation) {
        play();
    }

    if (!embed && prevPropertyObj != simulationArea.lastSelected) {
        if (simulationArea.lastSelected && simulationArea.lastSelected.objectType !== "Wire") {
            showProperties(simulationArea.lastSelected);
            //////console.log("yo");
        } else {
            // hideProperties();
        }
    }



    //Draw
    if (updateCanvas) {
        renderCanvas(scope);
    }
    // if (updateSimulation||update) scheduleUpdate();
    updateSimulation = updateCanvas = updatePosition = false;
    // if(updated){
    //     updatePosition=true;
    //     updateCanvas=true;
    //     scheduleUpdate();
    // }
}

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

function updateSelectionsAndPane(scope = globalScope) {
    //////console.log("updateSelectionsAndPane");

    if (!simulationArea.selected && simulationArea.mouseDown) {
        //mouse click NOT on object

        simulationArea.selected = true;
        simulationArea.lastSelected = scope.root;
        simulationArea.hover = scope.root;

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
        simulationArea.lastSelected = undefined;
        simulationArea.selected = false;
        simulationArea.hover = undefined;
        if (objectSelection) {
            objectSelection = false;
            var x1 = simulationArea.mouseDownX;
            var x2 = simulationArea.mouseX;
            var y1 = simulationArea.mouseDownY;
            var y2 = simulationArea.mouseY;
            // simulationArea.multipleObjectSelections=[];
            // //////console.log(x1,x2,y1,y2);
            // [x1,x2]=[x1,x2].sort();
            // [y1,y2]=[y1,y2].sort();
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
            // //////console.log(x1,x2,y1,y2);
            for (var i = 0; i < updateOrder.length; i++) {
                for (var j = 0; j < scope[updateOrder[i]].length; j++) {
                    var obj = scope[updateOrder[i]][j];
                    // //////console.log(obj);
                    if (simulationArea.multipleObjectSelections.contains(obj)) continue;
                    var x, y;
                    if (obj.objectType == "Node") {
                        x = obj.absX();
                        y = obj.absY();
                    } else if (obj.objectType != "Wire") {
                        x = obj.x;
                        y = obj.y;
                    } else {
                        // //////console.log(obj);
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


function renderCanvas(scope) {

    if (layoutMode) {
        return;
    }

    var ctx = simulationArea.context;
    simulationArea.clear();
    if (gridUpdate) {
        gridUpdate = false;
        dots();
    }
    // dots(); // draw dots
    canvasMessageData = undefined;
    for (var i = 0; i < renderOrder.length; i++)
        for (var j = 0; j < scope[renderOrder[i]].length; j++)
            scope[renderOrder[i]][j].draw();

    if (canvasMessageData) {
        canvasMessage(ctx, canvasMessageData.string, canvasMessageData.x, canvasMessageData.y)
    }
    if (objectSelection) {

        ctx.beginPath();
        ctx.lineWidth = 2;
        ctx.strokeStyle = "black"
        ctx.fillStyle = "rgba(0,0,0,0.1)"
        rect2(ctx, simulationArea.mouseDownX, simulationArea.mouseDownY, simulationArea.mouseX - simulationArea.mouseDownX, simulationArea.mouseY - simulationArea.mouseDownY, 0, 0, "RIGHT");
        ctx.stroke();
        ctx.fill();
    }
}

//Main fn that resolves circuit
function play(scope = globalScope, resetNodes = false) {
    // throw("ERROR");
    //////console.log("play");
    if (errorDetected) return;

    // //////console.log("simulation");
    if (loading == true) return;

    if (!embed) plotArea.stopWatch.Stop();

    // scope.stack=[];
    scope.pending = [];

    scope.queue = new PriorityQueue({
        comparator: function(a, b) {
            return a.priority - b.priority;
        }
    });


    if (resetNodes || forceResetNodes) {
        forceResetNodes = false;
        for (var i = 0; i < scope.allNodes.length; i++)
            scope.allNodes[i].reset();
    } else {
        // clearBuses(scope);
        for (var i = 0; i < scope.TriState.length; i++) {
            // console.log("HIT2",i);
            scope.TriState[i].removePropogation();
        }
    }


    for (var i = 0; i < scope.SubCircuit.length; i++) {
        if (scope.SubCircuit[i].isResolvable()) scope.queue.queue(scope.SubCircuit[i]);
    }

    // for (var i = 0; i < scope.FlipFlop.length; i++) {
    //     scope.queue.queue(scope.FlipFlop[i]);
    // }

    for (var i = 0; i < inputList.length; i++) {
        for (var j = 0; j < scope[inputList[i]].length; j++) {
            scope.queue.queue(scope[inputList[i]][j]);
        }
    }





    // console.log(scope.stack);
    var stepCount = 0;
    var elem = undefined


    while (scope.queue.length || scope.pending.length) {
        // if(stepCount%100==0)console.log(scope.stack);
        if (errorDetected) return;
        if (scope.queue.length) {
            elem = scope.queue.dequeue();
            // if(elem.objectType=="TriState"){
            //     // elem.removePropogation();
            //     scope.pending.push(elem);
            //     continue;
            // }
        } else
            elem = scope.pending.pop();
        // console.log("resolving:",elem)
        // scope.pending.clean(this);
        // scope.stack.clean(this);
        elem.resolve();
        stepCount++;
        if (stepCount > 1000) {
            // console.log(elem)
            showError("Simulation Stack limit exceeded: maybe due to cyclic paths or contention");
            return;
        }
    }

    for (var i = 0; i < scope.Flag.length; i++)
        scope.Flag[i].setPlotValue();
    // for (var i = 0; i < scope.SubCircuit.length; i++) {
    //     if(!scope.SubCircuit[i].isResolvable())
    //         {
    //             scope.queue.queue(scope.SubCircuit[i]);
    //             while (scope.stack.length) {
    //                 if(errorDetected)return;
    //                 var elem = scope.stack.pop();
    //                 elem.resolve();
    //                 stepCount++;
    //                 if (stepCount > 1000) {
    //                     showError("Simulation Stack limit exceeded: maybe due to cyclic paths or contention");
    //                     return;
    //                 }
    //             }
    //         }
    // }

}


function clearBuses(scope = globalScope) {

    scope.stack = [];
    scope.pending = [];



    for (var i = 0; i < scope.TriState.length; i++) {
        console.log("HIT2", i);
        scope.TriState[i].removePropogation();
    }
    for (var i = 0; i < scope.Clock.length; i++) {
        console.log("HIT2", i);
        scope.Clock[i].removePropogation();
    }

    // console.log(scope.stack);
    var stepCount = 0;
    var elem = undefined


    while (scope.stack.length || scope.pending.length) {
        // if(stepCount%100==0)console.log(scope.stack);
        if (errorDetected) return;
        if (scope.stack.length) {
            elem = scope.stack.pop();
            // if(elem.objectType=="TriState"){
            //     // elem.removePropogation();
            //     scope.pending.push(elem);
            //     continue;
            // }
        } else
            elem = scope.pending.pop();

        // scope.pending.clean(this);
        // scope.stack.clean(this);
        elem.resolve();
        stepCount++;
        if (stepCount > 1000) {
            // console.log(elem)
            showError("BUS ERROR: Contention");
            return;
        }
    }


}
