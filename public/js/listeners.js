// Most Listeners are stored here


function startListeners() {
    window.addEventListener('keyup', function(e) {
        scheduleUpdate(1);
        simulationArea.shiftDown = e.shiftKey;
        if (e.keyCode == 16) {
            simulationArea.shiftDown = false;
        }
        if (e.key == "Meta" || e.key == "Control") {
            simulationArea.controlDown = false;
        }
    });
    document.getElementById("simulationArea").addEventListener('mousedown', function(e) {

        $("input").blur();

        errorDetected = false;
        updateSimulation = true;
        updatePosition = true;
        updateCanvas = true;

        simulationArea.lastSelected = undefined;
        simulationArea.selected = false;
        simulationArea.hover = undefined;
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
    });
    document.getElementById("simulationArea").addEventListener('mouseup', function(e) {
        if (simulationArea.lastSelected) simulationArea.lastSelected.newElement = false;
    });
    window.addEventListener('mousemove', onMouseMove);



    window.addEventListener('keydown', function(e) {

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

        errorDetected = false;
        updateSimulation = true;
        updatePosition = true;
        simulationArea.shiftDown = e.shiftKey;

        // zoom in (+)
        if (e.key == "Meta" || e.key == "Control") {
            simulationArea.controlDown = true;
        }

        if (simulationArea.controlDown && (e.keyCode == 187 || e.keyCode == 171)) {
            e.preventDefault();
            if (globalScope.scale < 4 * DPR) {
                changeScale(.1 * DPR);
            }
        }
        // zoom out (-)
        if (simulationArea.controlDown && (e.keyCode == 189 || e.keyCode == 173)) {
            e.preventDefault();
            if (globalScope.scale > 0.5 * DPR) {
                changeScale(-.1 * DPR);
            }
        }

        if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) return;

        scheduleUpdate(1);
        updateCanvas = true;
        wireToBeChecked = 1;

        // Needs to be deprecated, moved to more recent listeners
        if (simulationArea.controlDown && (e.key == "C" || e.key == "c")) {
            //    simulationArea.copyList=simulationArea.multipleObjectSelections.slice();
            //    if(simulationArea.lastSelected&&simulationArea.lastSelected!==simulationArea.root&&!simulationArea.copyList.contains(simulationArea.lastSelected)){
            //        simulationArea.copyList.push(simulationArea.lastSelected);
            //    }
            //    copy(simulationArea.copyList);
        }
        if (simulationArea.controlDown && (e.key == "V" || e.key == "v")) {
            //    paste(simulationArea.copyData);
        }

        if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown) {
            if (e.key.toString().length == 1 || e.key.toString() == "Backspace") {
                simulationArea.lastSelected.keyDown(e.key.toString());
                return;
            }

        }

        if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown2) {
            if (e.key.toString().length == 1) {
                simulationArea.lastSelected.keyDown2(e.key.toString());
                return;
            }

        }

        if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown3) {
            if (e.key.toString() != "Backspace" && e.key.toString() != "Delete") {
                simulationArea.lastSelected.keyDown3(e.key.toString());
                return;
            }

        }

        if (e.keyCode == 16) {
            simulationArea.shiftDown = true;
            if (simulationArea.lastSelected && !simulationArea.lastSelected.keyDown && simulationArea.lastSelected.objectType != "Wire" && simulationArea.lastSelected.objectType != "CircuitElement" && !simulationArea.multipleObjectSelections.contains(simulationArea.lastSelected)) {
                simulationArea.multipleObjectSelections.push(simulationArea.lastSelected);
            }
        }

        if (e.keyCode == 8 || e.key == "Delete") {
            delete_selected();
        }

        if (simulationArea.controlDown && e.key.charCodeAt(0) == 122) { // detect the special CTRL-Z code
            undo();
        }

        // Detect online save shortcut (CTRL+S)
        if (simulationArea.controlDown && e.keyCode == 83 && !simulationArea.shiftDown) {
            save();
            e.preventDefault();
        }
         // Detect offline save shortcut (CTRL+SHIFT+S)
        if (simulationArea.controlDown && e.keyCode == 83 && simulationArea.shiftDown) {
            saveOffline();
            e.preventDefault();
        }

        //change direction fns
        if ((e.keyCode == 37 || e.keyCode == 65)&& simulationArea.lastSelected != undefined) {
            simulationArea.lastSelected.newDirection("LEFT");
        }
        if ((e.keyCode == 38 || e.keyCode == 87) && simulationArea.lastSelected != undefined) {
            simulationArea.lastSelected.newDirection("UP");
        }
        if ((e.keyCode == 39 || e.keyCode == 68) && simulationArea.lastSelected != undefined) {
            simulationArea.lastSelected.newDirection("RIGHT");
        }
        if ((e.keyCode == 40 || e.keyCode == 83) && simulationArea.lastSelected != undefined) {
            simulationArea.lastSelected.newDirection("DOWN");
        }
        if ((e.keyCode == 113 || e.keyCode == 81) && simulationArea.lastSelected != undefined) {
            if (simulationArea.lastSelected.bitWidth !== undefined)
                simulationArea.lastSelected.newBitWidth(parseInt(prompt("Enter new bitWidth"), 10));
        }
        if (simulationArea.controlDown && (e.key == "T" || e.key == "t")) {
            // e.preventDefault(); //browsers normally open a new tab
            simulationArea.changeClockTime(prompt("Enter Time:"));
        }
        if ((e.keyCode == 108 || e.keyCode == 76) && simulationArea.lastSelected != undefined) {
            if (simulationArea.lastSelected.setLabel !== undefined)
                simulationArea.lastSelected.setLabel();
        }
    })

    document.getElementById("simulationArea").addEventListener('dblclick', function(e) {
        scheduleUpdate(2);
        if (simulationArea.lastSelected && simulationArea.lastSelected.dblclick !== undefined) {
            simulationArea.lastSelected.dblclick();
        }
        if (!simulationArea.shiftDown) {
            simulationArea.multipleObjectSelections = [];
        }
    });

    window.addEventListener('mouseup', onMouseUp);



    document.getElementById("simulationArea").addEventListener('mousewheel', MouseScroll);
    document.getElementById("simulationArea").addEventListener('DOMMouseScroll', MouseScroll);

    function MouseScroll(event) {
        updateCanvas = true;

        event.preventDefault()
        var deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
        var scrolledUp = deltaY < 0;
        var scrolledDown = deltaY > 0;

        if (event.ctrlKey) {
            if (scrolledUp && globalScope.scale > 0.5 * DPR) {
                changeScale(-.1 * DPR);
            }
            if (scrolledDown && globalScope.scale < 4 * DPR) {
                changeScale(.1 * DPR);
            }
        } else {
            if (scrolledUp && globalScope.scale < 4 * DPR) {
                changeScale(.1 * DPR);
            }
            if (scrolledDown && globalScope.scale > 0.5 * DPR) {
                changeScale(-.1 * DPR);
            }
        }

        updateCanvas = true;
        gridUpdate = true;
        if(layoutMode)layoutUpdate();
        else update(); // Schedule update not working, this is INEFFICENT
    }

    document.addEventListener('cut', function(e) {
        simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
        if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
            simulationArea.copyList.push(simulationArea.lastSelected);
        }


        var textToPutOnClipboard = copy(simulationArea.copyList, true);
        e.preventDefault();
        if(textToPutOnClipboard==undefined)
            return;
        if (isIe) {
            window.clipboardData.setData('Text', textToPutOnClipboard);
        } else {
            e.clipboardData.setData('text/plain', textToPutOnClipboard);
        }

    });

    document.addEventListener('copy', function(e) {
        simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
        if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
            simulationArea.copyList.push(simulationArea.lastSelected);
        }

        var textToPutOnClipboard = copy(simulationArea.copyList);
        e.preventDefault();
        if(textToPutOnClipboard==undefined)
            return;
        if (isIe) {
            window.clipboardData.setData('Text', textToPutOnClipboard);
        } else {
            e.clipboardData.setData('text/plain', textToPutOnClipboard);
        }

    });

    document.addEventListener('paste', function(e) {
        var data;
        if (isIe) {
            data = window.clipboardData.getData('Text');
        } else {
            data = e.clipboardData.getData('text/plain');
        }

        paste(data);
        e.preventDefault();
    });

}

var isIe = (navigator.userAgent.toLowerCase().indexOf("msie") != -1 ||
    navigator.userAgent.toLowerCase().indexOf("trident") != -1);


function removeMiniMap() {
    if (lightMode) return;

    if (simulationArea.lastSelected == globalScope.root && simulationArea.mouseDown) return;
    if (lastMiniMapShown + 2000 >= new Date().getTime()) {
        setTimeout(removeMiniMap, lastMiniMapShown + 2000 - new Date().getTime());
        return;
    }
    $('#miniMap').fadeOut('fast');

}


function onMouseMove(e) {

    var rect = simulationArea.canvas.getBoundingClientRect();
    simulationArea.mouseRawX = (e.clientX - rect.left) * DPR;
    simulationArea.mouseRawY = (e.clientY - rect.top) * DPR;

    simulationArea.mouseX = Math.round(((simulationArea.mouseRawX - globalScope.ox) / globalScope.scale) / unit) * unit;
    simulationArea.mouseY = Math.round(((simulationArea.mouseRawY - globalScope.oy) / globalScope.scale) / unit) * unit;

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

function onMouseUp(e) {

    if (!lightMode) {
        lastMiniMapShown = new Date().getTime();
        setTimeout(removeMiniMap, 2000);
    }

    errorDetected = false;
    updateSimulation = true;
    updatePosition = true;
    updateCanvas = true;
    gridUpdate = true;
    wireToBeChecked = true;

    scheduleUpdate(1);
    simulationArea.mouseDown = false;

    for (var i = 0; i < 2; i++) {
        updatePosition = true;
        wireToBeChecked = true;
        update();
    }
    errorDetected = false;
    updateSimulation = true;
    updatePosition = true;
    updateCanvas = true;
    gridUpdate = true;
    wireToBeChecked = true;

    scheduleUpdate(1);
    var rect = simulationArea.canvas.getBoundingClientRect();

    if (!(simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height)) {
        smartDropXX = simulationArea.mouseX + 100; //Math.round(((simulationArea.mouseRawX - globalScope.ox+100) / globalScope.scale) / unit) * unit;
        smartDropYY = simulationArea.mouseY - 50; //Math.round(((simulationArea.mouseRawY - globalScope.oy+100) / globalScope.scale) / unit) * unit;
    }

}

function delete_selected(){

    $("input").blur();
    hideProperties();
    if (simulationArea.lastSelected && !(simulationArea.lastSelected.objectType == "Node" && simulationArea.lastSelected.type != 2)) simulationArea.lastSelected.delete();
    for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
        if (!(simulationArea.multipleObjectSelections[i].objectType == "Node" && simulationArea.multipleObjectSelections[i].type != 2)) simulationArea.multipleObjectSelections[i].cleanDelete();
    }
    simulationArea.multipleObjectSelections = [];
}
