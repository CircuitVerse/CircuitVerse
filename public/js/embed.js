// Helper functions for when circuit is embedded

$(document).ready(function() {

    // Clock features
    $('#clockProperty').append("<label class=''> <input type='button' class='objectPropertyAttribute' name='toggleFullScreen' value='Fullscreen' style='font-size: 20px'> </input> </label></br>");
    $('#clockProperty').append("Time: <input class='objectPropertyAttribute' min='50' type='number' style='width:48px' step='10' name='changeClockTime'  value='" + (simulationArea.timePeriod) + "'><br>");
    $('#clockProperty').append("Clock: <label class='switch'> <input type='checkbox' " + ["", "checked"][simulationArea.clockEnabled + 0] + " class='objectPropertyAttributeChecked' name='changeClockEnable' > <span class='slider'></span> </label><br>");

    // Following codes need to be removed
    $(".objectPropertyAttribute").on("change keyup paste click", function() {
        scheduleUpdate();
        updateCanvas = true;
        wireToBeChecked = 1;
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name])
            prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj;
        else
            window[this.name](this.value);
    })

    // Following codes need to be removed
    $(".objectPropertyAttributeChecked").on("change keyup paste click", function() {
        scheduleUpdate();
        updateCanvas = true;
        wireToBeChecked = 1;
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name])
            prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj;
        else
            window[this.name](this.checked);
    })
})

// Full screen toggle helper function
function toggleFullScreen(value) {
    if (!getfullscreenelement())
        GoInFullscreen(document.documentElement)
    else
        GoOutFullscreen();

}

// Full screen Listeners
if (document.addEventListener) {
    document.addEventListener('webkitfullscreenchange', exitHandler, false);
    document.addEventListener('mozfullscreenchange', exitHandler, false);
    document.addEventListener('fullscreenchange', exitHandler, false);
    document.addEventListener('MSFullscreenChange', exitHandler, false);
}

// Center focus accordingly
function exitHandler() {
    setTimeout(function() {
        for (id in scopeList)
            scopeList[id].centerFocus(true);
        gridUpdate = true;
        scheduleUpdate();
    }, 100)
}

function GoInFullscreen(element) {
    if (element.requestFullscreen)
        element.requestFullscreen();
    else if (element.mozRequestFullScreen)
        element.mozRequestFullScreen();
    else if (element.webkitRequestFullscreen)
        element.webkitRequestFullscreen();
    else if (element.msRequestFullscreen)
        element.msRequestFullscreen();
}

function GoOutFullscreen() {
    if (document.exitFullscreen)
        document.exitFullscreen();
    else if (document.mozCancelFullScreen)
        document.mozCancelFullScreen();
    else if (document.webkitExitFullscreen)
        document.webkitExitFullscreen();
    else if (document.msExitFullscreen)
        document.msExitFullscreen();
}

function getfullscreenelement() {
    return document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement
}
