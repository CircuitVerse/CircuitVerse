var smartDropXX = 50;
var smartDropYY = 80;


$(document).ready(function() {

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

    $('.logixModules').mousedown(function() {
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
    $('.logixButton').click(function() {
        window[this.id]();
    });
    // var dummyCounter=0;


    var iconList = $('.icon');
    // //////console.log(iconList)
    for (var i = 0; i < iconList.length; i++) {
        //////console.log(iconList[i].id);
        $(iconList[i]).append('<img src="/img/' + iconList[i].id + '.svg"/>');
        $(iconList[i]).append('<p class="img__description">' + iconList[i].id +
            '</p>');
        // $(iconList[i]).hover()

    }
    $('.logixModules').hover(function() {
        if (!help[this.id]) return;
        $("#Help").addClass("show");
        $("#Help").empty();
        ////console.log("SHOWING")
        $("#Help").append(help[this.id]);
    }); // code goes in document ready fn only
    $('.logixModules').mouseleave(function() {
        $("#Help").removeClass("show");

    }); // code goes in document ready fn only


    // $('#saveAsImg').click(function(){
    //     saveAsImg();
    // });
    // $('#Save').click(function(){
    //     Save();
    // });
    // $('#moduleProperty').draggable();

}); // accordion

var help = {
    "Input": "Input ToolTip: Toggle the individual bits by clicking on them.",
    "Button": "Button ToolTip: High(1) when pressed and Low(0) when released.",
    "Power": "Power ToolTip: All bits are High(1).",
    "Ground": "Ground ToolTip: All bits are Low(0).",
    "ConstantVal": "Constant ToolTip: Bits are fixed. Double click element to change the bits.",
    "Stepper": "Stepper ToolTip: Increase/Decrease value by selecting the stepper and using +/- keys.",
    "Output": "Output ToolTip: Simple output element showing output in binary.",
    "RGBLed": "RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE.",
    "SquareRGBLed": "Square RGB Led ToolTip: RGB Led inputs 8 bit values for the colors RED, GREEN and BLUE.",
    "DigitalLed": "Digital Led ToolTip: Digital LED glows high when input is High(1).",
    "VariableLed": "Variable Led ToolTip: Variable LED inputs an 8 bit value and glows with a proportional intensity.",
    "HexDisplay": "Hex Display ToolTip: Inputs a 4 Bit Hex number and displays it.",
    "SevenSegDisplay": "Seven Display ToolTip: Consists of 7+1 single bit inputs.",
    "TTY": "TTY ToolTip: Console buffer",
    "Keyboard": "Keyboard ToolTip: Select the Keyboard and type into the buffer.",
    "Text": "Text ToolTip: Use this to document your circuit.",
    "Flag": "FLag ToolTip: Use this for debugging and plotting.",
    "Splitter": "Splitter ToolTip: Split multiBit Input into smaller bitwidths or vice versa.",
    "ALU": "ALU ToolTip: 0: A&B, 1:A|B, 2:A+B, 4:A&~B, 5:A|~B, 6:A-B, 7:SLT ",

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
        $('#moduleProperty-inner').append("<p>Clock Enabled : <label class='switch'> <input type='checkbox' " + ["","checked"][simulationArea.clockEnabled+0] + " class='objectPropertyAttributeChecked' name='changeClockEnable' > <span class='slider'></span> </label></p>");
        $('#moduleProperty-inner').append("<p>Lite Mode : <label class='switch'> <input type='checkbox' " + ["","checked"][lightMode+0] + " class='objectPropertyAttributeChecked' name='changeLightMode' > <span class='slider'></span> </label></p>");
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
            var s = $("<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' "+ ["","selected"][+(obj.labelDirection=="RIGHT")] +  " >RIGHT</option><option value='DOWN' "+ ["","selected"][+(obj.labelDirection=="DOWN")] +  " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'"+ ["","selected"][+(obj.labelDirection=="LEFT")] +  " >LEFT</option><option value='UP' " + "<option value='RIGHT'"+ ["","selected"][+(obj.labelDirection=="UP")] +  " >UP</option>"+"</select>");
            s.val(obj.labelDirection);
            $('#moduleProperty-inner').append("<p>Label Direction: " + $(s).prop('outerHTML') + "</p>");
        }


        if (!obj.directionFixed) {
            var s = $("<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "+ ["","selected"][+(obj.direction=="RIGHT")] +  " >RIGHT</option><option value='DOWN' "+ ["","selected"][+(obj.direction=="DOWN")] +  " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'"+ ["","selected"][+(obj.direction=="LEFT")] +  " >LEFT</option><option value='UP' " + "<option value='RIGHT'"+ ["","selected"][+(obj.direction=="UP")] +  " >UP</option>"+"</select>");
            $('#moduleProperty-inner').append("<p>Direction: " + $(s).prop('outerHTML') + "</p>");

        } else if (!obj.orientationFixed) {
            var s = $("<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "+ ["","selected"][+(obj.direction=="RIGHT")] +  " >RIGHT</option><option value='DOWN' "+ ["","selected"][+(obj.direction=="DOWN")] +  " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'"+ ["","selected"][+(obj.direction=="LEFT")] +  " >LEFT</option><option value='UP' " + "<option value='RIGHT'"+ ["","selected"][+(obj.direction=="UP")] +  " >UP</option>"+"</select>");
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
                    var s = "<p><button class='objectPropertyAttribute btn btn-primary btn-xs' type='button'  name='" + prop.func + "'>" +prop.name +"</button></p>";
                    $('#moduleProperty-inner').append(s);
                }

            }
        }
    }
    // $('#moduleProperty-toolTip').empty();
    // if(help[obj.objectType])$('#moduleProperty-toolTip').append(help[obj.objectType])
    if (obj && help[obj.objectType]) {
        $('#moduleProperty-inner').append('<p><button id="toolTipButton" class="btn btn-primary btn-xs" type="button" >Logix Tip</button></p>');
        // $('#moduleProperty-toolTip').append('<div class="collapse" id="collapseExample"><div class="card card-body">'+help[obj.objectType]+'</div></div>')

        $('#toolTipButton').hover(function() {
            if (!help[obj.objectType]) return;
            $("#Help").addClass("show");
            $("#Help").empty();
            ////console.log("SHOWING")
            $("#Help").append(help[obj.objectType]);
        }); // code goes in document ready fn only
        $('#toolTipButton').mouseleave(function() {
            $("#Help").removeClass("show");

        });
    }







    $(".objectPropertyAttribute").on("change keyup paste click", function() {
        // return;
        //////console.log(this.name+":"+this.value);


        scheduleUpdate();
        updateCanvas = true;
        wireToBeChecked = 1;
        if(simulationArea.lastSelected&&simulationArea.lastSelected[this.name])
            prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj;
        else
            window[this.name](this.value);
    })
    $(".objectPropertyAttributeChecked").on("change keyup paste click", function() {
        // return;
        //////console.log(this.name+":"+this.value);



        scheduleUpdate();
        updateCanvas = true;
        wireToBeChecked = 1;
        if(simulationArea.lastSelected&&simulationArea.lastSelected[this.name])
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
