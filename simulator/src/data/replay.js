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

export function setInitialValues(scope) {
    fps = 1;
    porgressState = false;
    progressValue = 0;
    currFrame = 0;
    frames = scope.backups;
    count = frames.length;
    updateProgressBar();
}

function playInterval(scope) {
    console.log("playing from : " + currFrame);
    console.log(frames);
    play_interval = setInterval(() => {
        // make a temporary scope to load a frome
        console.log(currFrame);
        if(porgressState === true) {
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

export function stopReplay(scope) {
    console.log("stopReplay function");

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

function updateProgressBar() {
    console.log("updateProgressBar function");

    progressValue = (currFrame / count) * 100;
    $(".progress-bar").css('width', progressValue + '%');
}


// On clicking on progress bar to change frame
export function setProgressValue(val, scope) {
    console.log("setProgressValue function");
    
    progressValue = (val / $(".progress").width()) * 100;
    currFrame = Math.floor((progressValue * count) / 100);
    console.log("Progress % : " + progressValue + " || curr Frame : " + currFrame);

    updateProgressBar();
    clearInterval(play_interval);
    playInterval(scope);
}
		
export function buttonBackPress() {
    console.log("button back invoked.");
    fps = (fps > 1 ? fps - 1 : 1);
    console.log("current fps : " + fps);
}

export function buttonForwardPress() {
    console.log("button forward invoked.");
    fps = fps + 1;
    console.log("current fps : " + fps);
}

export function buttonRewindPress() {
    console.log("button rewind invoked.");
    fsp = (fps - 5 > 0 ? fps : 1);
}

export function buttonFastforwardPress() {
    console.log("button fast forward invoked.");
    fsp = (fps + 5);
}

export function buttonPlayPress(scope) {
    console.log("buttonPlayPress function");
    console.log("progressState :  " + porgressState);
    console.log("currentFrame :  " + currFrame);
    if(porgressState === false){
        porgressState = true;
        $("#button_play").removeClass('play-icon');
        $("#button_play").addClass('pause-icon');
        if (currFrame === 0) {
            replay(scope);
        }
    }
    else if(porgressState === true){
        porgressState = false;
        $("#button_play").removeClass('pause-icon');
        $("#button_play").addClass('play-icon')
    }
}

export function buttonStopPress(scope){
    console.log("button stop invoked.");  
    
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
