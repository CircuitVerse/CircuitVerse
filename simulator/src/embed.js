/* eslint-disable import/no-cycle */
// Helper functions for when circuit is embedded
import { scopeList, circuitProperty } from './circuit';
import simulationArea from './simulationArea';
import {
    scheduleUpdate, wireToBeCheckedSet, updateCanvasSet, gridUpdateSet,
} from './engine';
import { prevPropertyObjGet, prevPropertyObjSet } from './ux';
import { ZoomIn, ZoomOut } from './listeners';
import themeOptions from './themer/themes';
import updateThemeForStyle from './themer/themer';

circuitProperty.toggleFullScreen = toggleFullScreen;

$(document).ready(() => {
    const params = new URLSearchParams(window.location.search);
    const fullscreen = params.get('fullscreen');
    const clockTime = params.get('clock_time');
    const displayTitle = params.get('display_title');
    const zoomInOut = params.get('zoom_in_out');
    const selectedTheme = localStorage.getItem('theme');
    const embedTheme = params.get('theme');
    switch (embedTheme) {
    case 'default':
        updateThemeForStyle('Default Theme');
        break;
    case 'night-sky':
        updateThemeForStyle('Night Sky');
        break;
    case 'lite-born-spring':
        updateThemeForStyle('Lite-born Spring');
        break;
    case 'g-and-w':
        updateThemeForStyle('G&W');
        break;
    case 'high-contrast':
        updateThemeForStyle('High Contrast');
        break;
    case 'color-blind':
        updateThemeForStyle('Color Blind');
        break;
    default:
        updateThemeForStyle(selectedTheme);
    }
    // Clock feature

    if (fullscreen === 'false' && clockTime === 'false') {
        $('#clockProperty').css('display', 'none');
    }

    if (fullscreen !== 'false') {
        $('#clockProperty').append(
            "<input type='button' class='objectPropertyAttributeEmbed custom-btn--secondary embed-fullscreen-btn' name='toggleFullScreen' value='Full Screen'> </input>",
        );
    }

    if (clockTime !== 'false') {
        $('#clockProperty').append(
            `<div style='margin-top: 10px' ><label for='changeClockTime'>Time: </label><input class='objectPropertyAttributeEmbed' min='50' type='number' style='width:48px' step='10' name='changeClockTime' id='changeClockTime' value='${simulationArea.timePeriod}'></div>`,
        );
        $('#clockProperty').append(
            `<div style='margin-top: 10px' ><label for='changeClockEnable'>Clock:</label><label class='switch'> <input type='checkbox' ${
                ['', 'checked'][simulationArea.clockEnabled + 0]
            } class='objectPropertyAttributeEmbedChecked' name='changeClockEnable' id='changeClockEnable'> <span class='slider'></span> </label><div>`,
        );
    }

    // Zoom in out
    if (zoomInOut === 'false') {
        $('#zoom-in-out-embed').css('display', 'none');
    }

    // Display Title feature
    if (displayTitle === 'true') {
        $('#bottom_right_circuit_heading').css('display', 'block');
    }

    // Following codes need to be removed
    $('.objectPropertyAttributeEmbed').on('change keyup paste click', function () {
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) { prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet(); } else { circuitProperty[this.name](this.value); }
    });

    // Following codes need to be removed
    $('.objectPropertyAttributeEmbedChecked').on('change keyup paste click', function () {
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) { prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet(); } else { circuitProperty[this.name](this.checked); }
    });

    $('#zoom-in-embed').on('click', () => ZoomIn());

    $('#zoom-out-embed').on('click', () => ZoomOut());
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
