/* eslint-disable import/no-cycle */
// Helper functions for when circuit is embedded
import { scopeList, circuitProperty } from './circuit';
import simulationArea from './simulationArea';
import {
    scheduleUpdate, wireToBeCheckedSet, updateCanvasSet, gridUpdateSet,
} from './engine';


circuitProperty.toggleFullScreen = toggleFullScreen;
$(document).ready(() => {
    // Clock features
    $('#clockProperty').append("<label class=''> <input type='button' class='objectPropertyAttributeEmbed' name='toggleFullScreen' value='Fullscreen' style='font-size: 20px'> </input> </label></br>");
    $('#clockProperty').append(`Time: <input class='objectPropertyAttributeEmbed' min='50' type='number' style='width:48px' step='10' name='changeClockTime'  value='${simulationArea.timePeriod}'><br>`);
    $('#clockProperty').append(`Clock: <label class='switch'> <input type='checkbox' ${['', 'checked'][simulationArea.clockEnabled + 0]} class='objectPropertyAttributeEmbedChecked' name='changeClockEnable' > <span class='slider'></span> </label><br>`);

    // Following codes need to be removed
    $('.objectPropertyAttributeEmbed').on('change keyup paste click', function () {
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) { prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj; } else { circuitProperty[this.name](this.value); }
    });

    // Following codes need to be removed
    $('.objectPropertyAttributeEmbedChecked').on('change keyup paste click', function () {
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) { prevPropertyObj = simulationArea.lastSelected[this.name](this.value) || prevPropertyObj; } else { circuitProperty[this.name](this.checked); }
    });
});

// Full screen toggle helper function
function toggleFullScreen(value) {
    if (!getfullscreenelement()) {
        GoInFullscreen(document.documentElement);
    } else {
        GoOutFullscreen();
    }
}
// Center focus accordingly
function exitHandler() {
    setTimeout(() => {
        Object.keys(scopeList).forEach((id) => {
            scopeList[id].centerFocus(true);
        });
        gridUpdateSet(true);
        scheduleUpdate();
    }, 100);
}

function GoInFullscreen(element) {
    if (element.requestFullscreen) { element.requestFullscreen(); } else if (element.mozRequestFullScreen) { element.mozRequestFullScreen(); } else if (element.webkitRequestFullscreen) { element.webkitRequestFullscreen(); } else if (element.msRequestFullscreen) { element.msRequestFullscreen(); }
}

function GoOutFullscreen() {
    if (document.exitFullscreen) { document.exitFullscreen(); } else if (document.mozCancelFullScreen) { document.mozCancelFullScreen(); } else if (document.webkitExitFullscreen) { document.webkitExitFullscreen(); } else if (document.msExitFullscreen) { document.msExitFullscreen(); }
}

function getfullscreenelement() {
    return document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement;
}

// Full screen Listeners
if (document.addEventListener) {
    document.addEventListener('webkitfullscreenchange', exitHandler, false);
    document.addEventListener('mozfullscreenchange', exitHandler, false);
    document.addEventListener('fullscreenchange', exitHandler, false);
    document.addEventListener('MSFullscreenChange', exitHandler, false);
}
