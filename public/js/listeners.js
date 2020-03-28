// Most Listeners are stored here

function startListeners() {

// startListeners function -----------------------------------> START
    document.addEventListener('cut'  , handleCut);
    document.addEventListener('copy' , handleCopy);
    document.addEventListener('paste', handlePast);

    window.addEventListener('keyup'    , handleKeyUp);
    window.addEventListener('keydown'  , handleKeyDowm)
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup'  , onMouseUp);

    document.getElementById("simulationArea").addEventListener('mousedown'     , handleMouseDown );
    document.getElementById("simulationArea").addEventListener('mouseup'       , handleMouseUP );
    document.getElementById("simulationArea").addEventListener('dblclick'      , handleDoubleClick);
    document.getElementById("simulationArea").addEventListener('mousewheel'    , handleMouseScroll);
    document.getElementById("simulationArea").addEventListener('DOMMouseScroll', handleMouseScroll);
// startListeners function -----------------------------------> END

    hoverRestrictedElements()
}



// EventListenerHANDLERS -----------------------------------> start

//***MOUSE-START***
// onMouse UP at window
function onMouseUp(e) {

    if (!lightMode) {
        lastMiniMapShown = new Date().getTime();
        setTimeout(removeMiniMap, 2000);
    }

    errorDetected    = false;
    updateSimulation = true;
    updatePosition   = true;
    updateCanvas     = true;
    gridUpdate       = true;
    wireToBeChecked  = true;

    scheduleUpdate(1);
    simulationArea.mouseDown = false;

    for (var i = 0; i < 2; i++) {
        updatePosition  = true;
        wireToBeChecked = true;
        update();
    }
    errorDetected    = false;
    updateSimulation = true;
    updatePosition   = true;
    updateCanvas     = true;
    gridUpdate       = true;
    wireToBeChecked  = true;

    scheduleUpdate(1);
    var rect = simulationArea.canvas.getBoundingClientRect();

    if (!(simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height)) {
        smartDropXX = simulationArea.mouseX + 100; //Math.round(((simulationArea.mouseRawX - globalScope.ox+100) / globalScope.scale) / unit) * unit;
        smartDropYY = simulationArea.mouseY - 50; //Math.round(((simulationArea.mouseRawY - globalScope.oy+100) / globalScope.scale) / unit) * unit;
    }
}

// Mouse Down
function handleMouseDown (e) {
    $("input").blur();

    errorDetected               = false;
    updateSimulation            = true;
    updatePosition              = true;
    updateCanvas                = true;
    simulationArea.lastSelected = undefined;
    simulationArea.selected     = false;
    simulationArea.hover        = undefined;
    var rect = simulationArea.canvas.getBoundingClientRect();
    simulationArea.mouseDownRawX = (e.clientX - rect.left) * DPR;
    simulationArea.mouseDownRawY = (e.clientY - rect.top) * DPR;
    simulationArea.mouseDownX = Math.round(((simulationArea.mouseDownRawX - globalScope.ox) / globalScope.scale) / unit) * unit;
    simulationArea.mouseDownY = Math.round(((simulationArea.mouseDownRawY - globalScope.oy) / globalScope.scale) / unit) * unit;
    simulationArea.mouseDown = true;
    simulationArea.oldx = globalScope.ox;
    simulationArea.oldy = globalScope.oy;

    e.preventDefault();
    scheduleBackup();
    scheduleUpdate(1);
    $('.dropdown.open').removeClass('open');
}

// Mouse UP at SIMULATOR
function handleMouseUP(e) {
    if (simulationArea.lastSelected) simulationArea.lastSelected.newElement = false;
    /*
    handling restricted circuit elements
    */

    if(simulationArea.lastSelected && restrictedElements.includes(simulationArea.lastSelected.objectType)
        && !globalScope.restrictedCircuitElementsUsed.includes(simulationArea.lastSelected.objectType)) {
        globalScope.restrictedCircuitElementsUsed.push(simulationArea.lastSelected.objectType);
        updateRestrictedElementsList();
    }
}

// Mouse Move
function onMouseMove(e) {

    var rect = simulationArea.canvas.getBoundingClientRect();
    simulationArea.mouseRawX = (e.clientX - rect.left) * DPR;
    simulationArea.mouseRawY = (e.clientY - rect.top) * DPR;
    simulationArea.mouseXf = (simulationArea.mouseRawX - globalScope.ox) / globalScope.scale;
    simulationArea.mouseYf = (simulationArea.mouseRawY - globalScope.oy) / globalScope.scale;
    simulationArea.mouseX = Math.round(simulationArea.mouseXf / unit) * unit;
    simulationArea.mouseY = Math.round(simulationArea.mouseYf / unit) * unit;

    updateCanvas = true;

    if (simulationArea.lastSelected && (simulationArea.mouseDown || simulationArea.lastSelected.newElement)) {
        updateCanvas = true;
        var fn;

        if (simulationArea.lastSelected == globalScope.root) {
            fn = function() {
                updateSelectionsAndPane();
            }
        } else {
            fn = function() {
                if (simulationArea.lastSelected)
                    simulationArea.lastSelected.update();
            };
        }
        scheduleUpdate(0, 20, fn);
    } else {
        scheduleUpdate(0, 200);
    }
}

// Double Click
function handleDoubleClick (e) {
    scheduleUpdate(2);
    if (simulationArea.lastSelected && simulationArea.lastSelected.dblclick !== undefined) {
        simulationArea.lastSelected.dblclick();
    }
    if (!simulationArea.shiftDown) {
        simulationArea.multipleObjectSelections = [];
    }
}

// Scroll
function handleMouseScroll(event) {
    updateCanvas = true;
    event.preventDefault()
  
    var deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
    let direction =  deltaY > 0 ? 1 : -1
    handleZoom(direction)      

    updateCanvas = true;
    if(layoutMode)layoutUpdate();
    else update(); // Schedule update not working, this is INEFFICIENT
}

// ***MOUSE-END***



// ***KEYBOAED-START***
// Key Up
function handleKeyUp(e) {
    scheduleUpdate(1);
    simulationArea.shiftDown = e.shiftKey;


    if (e.keyCode == 16) 
        simulationArea.shiftDown = false;
    
    if (e.key == "Meta" || e.key == "Control") 
        simulationArea.controlDown = false;

    // select multi buttom (m)
    if (e.keyCode == 69) 
        simulationArea.shiftDown = false;
    
//***************** SHIF ***************** 
    if (e.keyCode == 16) {
        simulationArea.shiftDown = false;
    }
    if (e.key == "Meta" || e.key == "Control") {
        simulationArea.controlDown = false;
    }
    if ( (e.key == "e" || e.key == "E")) {
        simulationArea.shiftDown = false;
    }


}

// Key DOWM
function handleKeyDowm (e) {
    // If mouse is focusing on input element, then override any action
    // if($(':focus').length){
    //     return;
    // }


    if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) {
        return;
    } else {
        // HACK TO REMOVE FOCUS ON PROPERTIES
        if (document.activeElement.type == "number") {
            hideProperties();
            showProperties(simulationArea.lastSelected)
        }
    }

    errorDetected    = false;
    updateSimulation = true;
    updatePosition   = true;
    simulationArea.shiftDown = e.shiftKey;
   
    if (e.key == "Meta" || e.key == "Control") {
        simulationArea.controlDown = true;
    }


//CTRL+= or +     zoom in (+)
    if (simulationArea.controlDown&&(e.keyCode == 187 || e.keyCode == 171) || e.keyCode == 107) {
        e.preventDefault();
        handleZoom(1)
    }

 //CTRL+- or -    zoom out (-)
    if ( simulationArea.controlDown&&(e.keyCode == 189 || e.keyCode == 173) || e.keyCode == 109) {
        e.preventDefault();
        handleZoom(-1)       

    }

    if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) return;

    scheduleUpdate(1);
    updateCanvas = true;
    wireToBeChecked = 1;

    if(simulationArea.lastSelected){
        if (simulationArea.lastSelected.keyDown&&(e.key.toString().length == 1 || e.key.toString() == "Backspace")) {

            simulationArea.lastSelected.keyDown(e.key.toString());
            return;
        }

        if (simulationArea.lastSelected.keyDown2&&(e.key.toString().length == 1)) {
            simulationArea.lastSelected.keyDown2(e.key.toString());
            return;
        }

        if (simulationArea.lastSelected.keyDown3&&(e.key.toString() != "Backspace" && e.key.toString() != "Delete")) {
            simulationArea.lastSelected.keyDown3(e.key.toString());
            return;
        }
    }

// Shift key

    if (e.keyCode == 16) {
        handleSelectMulti()
        e.preventDefault();
    }

//backspace or delete    deleteSelected
    if (e.keyCode == 8 || e.keyCode == 46) {
        delete_selected();
        e.preventDefault();
    }

// CTRL+z    undo
    if (simulationArea.controlDown && e.key.charCodeAt(0) == 122){
        undo();
        e.preventDefault();
    }

//CTRL+S    Detect online save shortcut ()
    if (simulationArea.controlDown && e.keyCode == 83 && !simulationArea.shiftDown) {
        save();
        e.preventDefault();
    }
//CTRL+SHIFT+S    Detect offline save shortcut ()
    if (simulationArea.controlDown && e.keyCode == 83 && simulationArea.shiftDown) {
        saveOffline();
        e.preventDefault();
    }

// CTRL+a    selectAll
    if (simulationArea.controlDown && (e.keyCode == 65 || e.keyCode == 97)) {
        handleSelectAll();
        e.preventDefault();
    }

// f2 or q    changeBitWidth
    if ((e.keyCode == 113 || e.keyCode == 81) && simulationArea.lastSelected != undefined){
        handleChangeBitWidth()
        e.preventDefault();
    }

// t     changeClockTime
    if (e.keyCode == 84){
        handleChangeClockTime()
        e.preventDefault();
    }

// e     SelectMultibleElements when mousedowm
    if (e.keyCode == 69){
        handleSelectMulti()
        e.preventDefault();
    }

// c    Copy
    if (e.keyCode == 67){
        handleCopy()
        e.preventDefault();
    }
    
// x    Cut
    if (e.keyCode == 88){
        handleCut()
        e.preventDefault();
    }

// v    past
    if (e.keyCode == 86){
        handlePast()
        e.preventDefault();
    }
    
    // directions Handler ---------------------------->START
    function getDirection(){
        switch (e.keyCode) {
            case 37:
            case 65:
                e.preventDefault();
                return "LEFT";

            case 38:
            case 87:
                e.preventDefault();
                return "UP";

            case 39:
            case 68:
                e.preventDefault();
                return "RIGHT";

            case 40:
            case 83:
                e.preventDefault();
                return "DOWN";

            default:
                return false
        }
    }
    if (simulationArea.lastSelected != undefined) {
        let direction = getDirection(e)
        if (direction){
            simulationArea.lastSelected.newDirection(direction);
        }
    }
    // directions Handler ---------------------------->END

    if ((e.keyCode == 113 || e.keyCode == 81) && simulationArea.lastSelected != undefined) {
        if (simulationArea.lastSelected.bitWidth !== undefined)
            simulationArea.lastSelected.newBitWidth(parseInt(prompt("Enter new bitWidth"), 10));
    }

    if (simulationArea.controlDown && (e.key == "T" || e.key == "t")) {
        // e.preventDefault(); //browsers normally open a new tab
        simulationArea.changeClockTime(prompt("Enter Time:"));
    }

    if ( (e.key == "e" || e.key == "E")) {
        // Will be refactored later
        simulationArea.shiftDown = true;
    }

}
// ***KEYBOAED-END***



// ***window-Start***
// CUT
function handleCut() {
    simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
    if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
        simulationArea.copyList.push(simulationArea.lastSelected);
    }

    var textToPutOnClipboard = copy(simulationArea.copyList, true);

    // Updated restricted elements
    updateRestrictedElementsInScope();

    if(textToPutOnClipboard!=undefined){
        localStorage.setItem('clipboardData', textToPutOnClipboard);
    }

}
// COPY
function handleCopy() {
    simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
    if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
        simulationArea.copyList.push(simulationArea.lastSelected);
    }

    var textToPutOnClipboard = copy(simulationArea.copyList);

    // Updated restricted elements
    updateRestrictedElementsInScope();

    if(textToPutOnClipboard!=undefined){
        localStorage.setItem('clipboardData', textToPutOnClipboard);
    }   

}
// PAST
function handlePast() {
    var data =  localStorage.getItem('clipboardData');
    paste(data);

    // Updated restricted elements
    updateRestrictedElementsInScope();
}
// ***window-END***

// EventListenerHANDLERS -----------------------------------> end



/** 
 * Zoom handler
 * @param {it's value is 1 for zoom in  or -1 for zoom out  } direction  
 */
function zoom(direction){
    if ( globalScope.scale > 0.5 * DPR && globalScope.scale < 4 * DPR){
        changeScale(direction * .1 * DPR);
        // This Fix zoom issue
        gridUpdate = true;
    }
}


// HELPERS----------------------------------->START

function handleChangeClockTime(){
    simulationArea.changeClockTime(prompt("Enter Time:"));
}

//   Zoom handler , direction is either 1 or -1 
function handleZoom(direction){
    if ( globalScope.scale > 0.5 * DPR && globalScope.scale < 4 * DPR){
        changeScale(direction * .1 * DPR);
        // This Fix zoom issue
        gridUpdate = true;
    }
}

// Function selects all the elements from the scope
function handleSelectMulti (){
    simulationArea.shiftDown = true;
    if (simulationArea.lastSelected && !simulationArea.lastSelected.keyDown && simulationArea.lastSelected.objectType != "Wire" && simulationArea.lastSelected.objectType != "CircuitElement" && !simulationArea.multipleObjectSelections.contains(simulationArea.lastSelected)) {
        simulationArea.multipleObjectSelections.push(simulationArea.lastSelected);
    }
}

function handleChangeBitWidth(){
    if (simulationArea.lastSelected.bitWidth !== undefined)
    simulationArea.lastSelected.newBitWidth(parseInt(prompt("Enter new bitWidth"), 10));
}

function handleSelectAll(scope = globalScope) {
    circuitElementList.forEach((val, _, __) => {
        if (scope.hasOwnProperty(val)) {
            simulationArea.multipleObjectSelections.push(...scope[val]);
        }
    });

    if (scope.nodes) {
        simulationArea.multipleObjectSelections.push(...scope.nodes);
    }
}

function removeMiniMap() {
    if (lightMode) return;

    if (simulationArea.lastSelected == globalScope.root && simulationArea.mouseDown) return;
    if (lastMiniMapShown + 2000 >= new Date().getTime()) {
        setTimeout(removeMiniMap, lastMiniMapShown + 2000 - new Date().getTime());
        return;
    }
    $('#miniMap').fadeOut('fast');
}

function delete_selected(){
    $("input").blur();
    hideProperties();
    if (simulationArea.lastSelected && !(simulationArea.lastSelected.objectType == "Node" && simulationArea.lastSelected.type != 2)) simulationArea.lastSelected.delete();
    for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
        if (!(simulationArea.multipleObjectSelections[i].objectType == "Node" && simulationArea.multipleObjectSelections[i].type != 2)) simulationArea.multipleObjectSelections[i].cleanDelete();
    }
    simulationArea.multipleObjectSelections = [];

    // Updated restricted elements
    updateRestrictedElementsInScope();
}

function hoverRestrictedElements(){
    restrictedElements.forEach((element) => {
        $(`#${element}`).mouseover(() => {
            showRestricted();
        });
        
        $(`#${element}`).mouseout(() => {
            hideRestricted();
        })
    });
}

var isIe = (navigator.userAgent.toLowerCase().indexOf("msie") != -1 ||
    navigator.userAgent.toLowerCase().indexOf("trident") != -1);

// HELPERS----------------------------------->END
