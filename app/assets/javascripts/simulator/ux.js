var smartDropXX = 50;
var smartDropYY = 80;

// Object stores the position of context menu
var ctxPos = {
    x: 0,
    y: 0,
    visible: false,
};

// Function hides the context menu
function hideContextMenu() {
    var el = document.getElementById('contextMenu');
    el.style = 'opacity:0;';
    setTimeout(() => {
        el.style = 'visibility:hidden;';
        ctxPos.visible = false;
    }, 200); // Hide after 2 sec
}

// Function displays context menu
function showContextMenu() {
    if (layoutMode) return false; // Hide context menu when it is in Layout Mode
    $('#contextMenu').css({
        visibility: 'visible',
        opacity: 1,
        top: `${ctxPos.y}px`,
        left: `${ctxPos.x}px`,
    });
    ctxPos.visible = true;
    return false;
}

// Function is called when context item is clicked
// eslint-disable-next-line no-unused-vars
function menuItemClicked(id) {
    hideContextMenu();

    if (id === 0) {
        document.execCommand('copy');
    } else if (id === 1) {
        document.execCommand('cut');
    } else if (id === 2) {
        // document.execCommand('paste'); it is restricted to sove this problem we use dataPasted variable
        paste(localStorage.getItem('clipboardData'));
    } else if (id === 3) {
        delete_selected();
    } else if (id === 4) {
        undo();
        undo();
    } else if (id === 5) {
        newCircuit();
    } else if (id === 6) {
        createSubCircuitPrompt();
    } else if (id === 7) {
        globalScope.centerFocus(false);
    }
}

function setupUI() {
    var ctxEl = document.getElementById('contextMenu');
    document.addEventListener('mousedown', (e) => {
        // Check if mouse is not inside the context menu and menu is visible
        if (!((e.clientX >= ctxPos.x && e.clientX <= ctxPos.x + ctxEl.offsetWidth)
        && (e.clientY >= ctxPos.y && e.clientY <= ctxPos.y + ctxEl.offsetHeight))
        && (ctxPos.visible && e.which !== 3)) {
            hideContextMenu();
        }

        // Change the position of context whenever mouse is clicked
        ctxPos.x = e.clientX;
        ctxPos.y = e.clientY;
    });
    document.getElementById('canvasArea').oncontextmenu = showContextMenu;

    $("#sideBar").resizable({
        handles: 'e',
        // minWidth:270,
    });
    $("#menu").accordion({
        collapsible: true,
        active: false,
        heightStyle: "content"
    });
    // $( "#plot" ).resizable({
    // handles: 'n',
    //     // minHeight:200,
    // });

    $('.logixModules').mousedown(function () {
        //////console.log(smartDropXX,smartDropYY);
        if (simulationArea.lastSelected && simulationArea.lastSelected.newElement) simulationArea.lastSelected.delete();
        var obj = new window[this.id](); //(simulationArea.mouseX,simulationArea.mouseY);
        simulationArea.lastSelected = obj;
        // simulationArea.lastSelected=obj;
        // simulationArea.mouseDown=true;
        smartDropXX += 70;
        if (smartDropXX / globalScope.scale > width) {
            smartDropXX = 50;
            smartDropYY += 80;
        }
    });
    $('.logixButton').click(function () {
        window[this.id]();
    });
    // var dummyCounter=0;


    $('.logixModules').hover(function () {
        // Tooltip can be statically defined in the prototype.
        var tooltipText = window[this.id].prototype.tooltipText;
        if (!tooltipText) return;
        $("#Help").addClass("show");
        $("#Help").empty();
        ////console.log("SHOWING")
        $("#Help").append(tooltipText);
    }); // code goes in document ready fn only
    $('.logixModules').mouseleave(function () {
        $("#Help").removeClass("show");

    }); // code goes in document ready fn only


    // $('#saveAsImg').click(function(){
    //     saveAsImg();
    // });
    // $('#Save').click(function(){
    //     Save();
    // });
    // $('#moduleProperty').draggable();

}


var prevPropertyObj = undefined;

function showProperties(obj) {
    if (obj == prevPropertyObj) return;
    hideProperties();

    prevPropertyObj = obj;
    if (simulationArea.lastSelected === undefined || simulationArea.lastSelected.objectType == "Wire" || simulationArea.lastSelected.objectType == "CircuitElement" || simulationArea.lastSelected.objectType == "Node") {
        $('#moduleProperty').show();
        $('#moduleProperty-inner').append("<div id='moduleProperty-header'>" + "Project Properties" + "</div>");
        $('#moduleProperty-inner').append("<p>Project : <input class='objectPropertyAttribute' type='text'  name='setProjectName'  value='" + (projectName || "Untitled") + "'></p>");
        $('#moduleProperty-inner').append("<p>Circuit : <input class='objectPropertyAttribute' type='text'  name='changeCircuitName'  value='" + (globalScope.name || "Untitled") + "'></p>");
        $('#moduleProperty-inner').append("<p>Clock Time : <input class='objectPropertyAttribute' min='50' type='number' style='width:100px' step='10' name='changeClockTime'  value='" + (simulationArea.timePeriod) + "'>ms</p>");
        $('#moduleProperty-inner').append("<p>Clock Enabled : <label class='switch'> <input type='checkbox' " + ["", "checked"][simulationArea.clockEnabled + 0] + " class='objectPropertyAttributeChecked' name='changeClockEnable' > <span class='slider'></span> </label></p>");
        $('#moduleProperty-inner').append("<p>Lite Mode : <label class='switch'> <input type='checkbox' " + ["", "checked"][lightMode + 0] + " class='objectPropertyAttributeChecked' name='changeLightMode' > <span class='slider'></span> </label></p>");
        // $('#moduleProperty-inner').append("<p>  ");
        $('#moduleProperty-inner').append("<p><button type='button' class='objectPropertyAttributeChecked btn btn-danger btn-xs' name='deleteCurrentCircuit' >Delete Circuit</button>  <button type='button' class='objectPropertyAttributeChecked btn btn-primary btn-xs' name='toggleLayoutMode' >Edit layout</button> </p>");
    } else {
        $('#moduleProperty').show();

        $('#moduleProperty-inner').append("<div id='moduleProperty-header'>" + obj.objectType + "</div>");
        // $('#moduleProperty').append("<input type='range' name='points' min='1' max='32' value="+obj.bitWidth+">");
        if (!obj.fixedBitWidth)
            $('#moduleProperty-inner').append("<p>BitWidth: <input class='objectPropertyAttribute' type='number'  name='newBitWidth' min='1' max='32' value=" + obj.bitWidth + "></p>");

        if (obj.changeInputSize)
            $('#moduleProperty-inner').append("<p>Input Size: <input class='objectPropertyAttribute' type='number'  name='changeInputSize' min='2' max='10' value=" + obj.inputSize + "></p>");

        if (!obj.propagationDelayFixed)
            $('#moduleProperty-inner').append("<p>Delay: <input class='objectPropertyAttribute' type='number'  name='changePropagationDelay' min='0' max='100000' value=" + obj.propagationDelay + "></p>");


        $('#moduleProperty-inner').append("<p>Label: <input class='objectPropertyAttribute' type='text'  name='setLabel'  value='" + escapeHtml(obj.label) + "'></p>");


        if (!obj.labelDirectionFixed) {
            var s = $("<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' " + ["", "selected"][+(obj.labelDirection == "RIGHT")] + " >RIGHT</option><option value='DOWN' " + ["", "selected"][+(obj.labelDirection == "DOWN")] + " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'" + ["", "selected"][+(obj.labelDirection == "LEFT")] + " >LEFT</option><option value='UP' " + "<option value='RIGHT'" + ["", "selected"][+(obj.labelDirection == "UP")] + " >UP</option>" + "</select>");
            s.val(obj.labelDirection);
            $('#moduleProperty-inner').append("<p>Label Direction: " + $(s).prop('outerHTML') + "</p>");
        }


        if (!obj.directionFixed) {
            var s = $("<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' " + ["", "selected"][+(obj.direction == "RIGHT")] + " >RIGHT</option><option value='DOWN' " + ["", "selected"][+(obj.direction == "DOWN")] + " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'" + ["", "selected"][+(obj.direction == "LEFT")] + " >LEFT</option><option value='UP' " + "<option value='RIGHT'" + ["", "selected"][+(obj.direction == "UP")] + " >UP</option>" + "</select>");
            $('#moduleProperty-inner').append("<p>Direction: " + $(s).prop('outerHTML') + "</p>");

        } else if (!obj.orientationFixed) {
            var s = $("<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' " + ["", "selected"][+(obj.direction == "RIGHT")] + " >RIGHT</option><option value='DOWN' " + ["", "selected"][+(obj.direction == "DOWN")] + " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'" + ["", "selected"][+(obj.direction == "LEFT")] + " >LEFT</option><option value='UP' " + "<option value='RIGHT'" + ["", "selected"][+(obj.direction == "UP")] + " >UP</option>" + "</select>");
            $('#moduleProperty-inner').append("<p>Orientation: " + $(s).prop('outerHTML') + "</p>");
        }

        if (obj.mutableProperties) {
            for (attr in obj.mutableProperties) {
                var prop = obj.mutableProperties[attr];
                if (obj.mutableProperties[attr].type == "number") {
                    var s = "<p>" + prop.name + "<input class='objectPropertyAttribute' type='number'  name='" + prop.func + "' min='" + (prop.min || 0) + "' max='" + (prop.max || 200) + "' value=" + obj[attr] + "></p>";
                    $('#moduleProperty-inner').append(s);
                }
                else if (obj.mutableProperties[attr].type == "text") {
                    var s = "<p>" + prop.name + "<input class='objectPropertyAttribute' type='text'  name='" + prop.func + "' maxlength='" + (prop.maxlength || 200) + "' value=" + obj[attr] + "></p>";
                    $('#moduleProperty-inner').append(s);
                }
                else if (obj.mutableProperties[attr].type == "button") {
                    var s = "<p><button class='objectPropertyAttribute btn btn-primary btn-xs' type='button'  name='" + prop.func + "'>" + prop.name + "</button></p>";
                    $('#moduleProperty-inner').append(s);
                }

            }
        }
    }

    // Tooltip can be defined in the prototype or the object itself, in addition to help map.
    var tooltipText = obj && (obj.tooltipText);
    if (tooltipText) {
        $('#moduleProperty-inner').append('<p><button id="toolTipButton" class="btn btn-primary btn-xs" type="button" >CircuitVerse Tip</button></p>');
        $('#toolTipButton').hover(function () {
            $("#Help").addClass("show");
            $("#Help").empty();
            ////console.log("SHOWING")
            $("#Help").append(tooltipText);
        }); // code goes in document ready fn only
        $('#toolTipButton').mouseleave(function () {
            $("#Help").removeClass("show");
        });
    }







    $(".objectPropertyAttribute").on("change keyup paste click", function () {
        // return;
        //////console.log(this.name+":"+this.value);


        scheduleUpdate();
        updateCanvas = true;
        wireToBeChecked = 1;
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name])
            prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj;
        else
            window[this.name](this.value);
    })
    $(".objectPropertyAttributeChecked").on("change keyup paste click", function () {
        // return;
        //////console.log(this.name+":"+this.value);



        scheduleUpdate();
        updateCanvas = true;
        wireToBeChecked = 1;
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name])
            prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj;
        else
            window[this.name](this.checked);
    })
}


function hideProperties() {
    $('#moduleProperty-inner').empty();
    $('#moduleProperty').hide();
    prevPropertyObj = undefined;
    $(".objectPropertyAttribute").unbind("change keyup paste click");
}

function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
