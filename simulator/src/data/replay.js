import { layoutModeGet } from '../layoutMode';
import Scope, { scopeList } from '../circuit';
import { loadScope } from './load';
import { updateRestrictedElementsInScope } from '../restrictedElementDiv';
import { forceResetNodesSet } from '../engine';
import { findDimensions } from '../canvasApi';
import simulationArea from '../simulationArea';

var play_interval;
var fps;
var porgressState;  // true for play & false for pause
var progressValue;
var currFrame;
var frames;
var count;

/**
 * Function called to replay a circuit
 * @param {Scope=} - the circuit in which we want to call replay
 * @category data
 * @exports replay
 */
export function replay(scope = globalScope) {
    if (layoutModeGet()) return;
    // center focus for replay
    // else for big circuits some part goes out of screen
    globalScope.centerFocus(false);
    // add backdrop to the unconcerned part
    // applyBackdrop();
    currFrame = 0;
    playInterval(scope);
}

// function to set the initial values of global variables
export function setInitialValues(scope) {
    fps = 1;
    porgressState = false;
    progressValue = 0;
    currFrame = 0;
    frames = scope.backups;
    count = frames.length;
    updateProgressBar();
}

// function to create a temporary scope, load circuit data
function updateDisplay(scope) {
    const tempScope = new Scope(scope.name);
    let loading = true;
    const replayData = frames[currFrame];
    loadScope(tempScope, JSON.parse(replayData));
    tempScope.id = scope.id;
    tempScope.name = scope.name;
    scopeList[scope.id] = tempScope;
    tempScope.ox = globalScope.ox;
    tempScope.oy = globalScope.oy;
    tempScope.scale = globalScope.scale;
    loading = false;
    globalScope = tempScope;
}
    
// function to play the replay
function playInterval(scope) {
    play_interval = setInterval(() => {
        // make a temporary scope to load a frome
        if(porgressState === true) {
            updateDisplay(scope);
            currFrame++;
            progressValue = (currFrame / count) * 100;
            updateProgressBar();
        }
        if (currFrame === count) {
            // We've played all frames.
            stopReplay(scope);
            porgressState = false;
        }
    }, 1000 / fps);
}

// function to stop playing the replay
export function stopReplay(scope) {
    $("#button_play").removeClass('pause-icon');
    $("#button_play").addClass('play-icon');
    clearInterval(play_interval);
    porgressState = false;
    currFrame = 0;
    progressValue = 0;
    globalScope = scope;
    globalScope.centerFocus(false);
    forceResetNodesSet(true);
    updateRestrictedElementsInScope();
}

// function to update progress bar with replay
function updateProgressBar() {
    progressValue = (currFrame / count) * 100;
    $(".progress-bar").css('width', progressValue + '%');
}

// function to calculate & change progressValue when clicked on progress bar
export function setProgressValue(val, scope) {
    progressValue = (val / $(".progress").width()) * 100;
    currFrame = Math.floor((progressValue * count) / 100);
    updateProgressBar();
    clearInterval(play_interval);
    updateDisplay(scope);
    playInterval(scope);
}

// button click handleres
export function buttonBackPress() {
    fps = (fps > 1 ? fps - 1 : 1);
}

export function buttonForwardPress() {
    fps = fps + 1;
}

export function buttonRewindPress() {
    fps = (fps - 5 > 0 ? fps : 1);
}

export function buttonFastforwardPress() {
    fps = (fps + 5);
}

export function buttonPlayPress(scope) {
    if(porgressState === false){
        porgressState = true;
        $("#button_play").removeClass('play-icon');
        $("#button_play").addClass('pause-icon');
        if (currFrame === 0) {
            replay(scope);
        }
    }
    else if(porgressState === true) {
        porgressState = false;
        $("#button_play").removeClass('pause-icon');
        $("#button_play").addClass('play-icon')
    }
}

export function buttonStopPress(scope){    
    porgressState = false;
    currFrame = scope.backups.length;
    progressValue = 100;
    updateProgressBar();
    stopReplay(scope);
}

/*
// function to apply backdrop to the rest of the screen
function applyBackdrop() {
    findDimensions();
    const minX = simulationArea.minWidth;
    const minY = simulationArea.minHeight;
    const maxX = simulationArea.maxWidth;
    const maxY = simulationArea.maxHeight;
    const backdropWidth = (maxX - minX) + 100;
    const backdropHeight = (maxY - minY) + 100;
    // having 50px left, right, top, down padding
    $('#blurPart').css({
        top: (minY + globalScope.oy - 50),
        left: (minX + globalScope.ox - 50),
        width: backdropWidth,
        height: backdropHeight,
    });
}
*/
