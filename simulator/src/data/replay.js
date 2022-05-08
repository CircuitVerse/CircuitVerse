import { layoutModeGet } from '../layoutMode';
import Scope, { scopeList } from '../circuit';
import { loadScope } from './load';
import { updateRestrictedElementsInScope } from '../restrictedElementDiv';
import { forceResetNodesSet } from '../engine';
import { findDimensions } from '../canvasApi';
import simulationArea from '../simulationArea';

var play_interval;
var fps = 1;
var porgressState = 'stop';
var progressValue = 0;
var currFrame = 0;
var frames;
var count;

/**
 * Function called to replay a circuit
 * @param {Scope=} - the circuit in which we want to call replay
 * @category data
 * @exports replay
 */
export function replay(scope = globalScope) {
    console.log("starting replay");
    if (layoutModeGet()) return;

    // center focus for replay
    // else for big circuits some part goes out of screen
    globalScope.centerFocus(false);

    // add backdrop to the unconcerned part
    // applyBackdrop();

    frames = scope.backups;
    count = frames.length;

    currFrame = 0;
    playInterval(scope);
}


function playInterval(scope) {
    play_interval = setInterval(() => {
        // make a temporary scope to load a frome
        console.log(currFrame);
        if(porgressState == 'play' || porgressState == 'resume') {
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
            porgressState = 'stop';
        }
    }, 1000 / fps);
}

function pauseInterval() {
    
}

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

export function stopReplay(scope) {
    console.log("stoppig replay");
    $("#button_play").removeClass('pause-icon');
    $("#button_play").addClass('play-icon');
    porgressState = 'stop';
    clearInterval(play_interval);
    globalScope = scope;
    globalScope.centerFocus(false);
    forceResetNodesSet(true);
    updateRestrictedElementsInScope();
}

function updateProgressBar() {
    progressValue = (currFrame / count) * 100;
    $(".progress-bar").css('width', progressValue + '%');
}


// Helper functions to replay
export function setProgressValue(val) {
    console.log("setting player progress");
    porgressState = 'pause';
    
    progressValue = (val / $(".progress").width()) * 100;
    currFrame = Math.floor((progressValue * count) / 100);
    console.log("Progress % : " + progressValue + " || curr Frame : " + currFrame);
    updateProgressBar();

    porgressState = 'play';
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
    console.log(porgressState);
    if(porgressState == 'stop'){
        porgressState = 'play';
        $("#button_play").removeClass('play-icon');
        $("#button_play").addClass('pause-icon');
        replay(scope);
    }
    else if(porgressState == 'play' || porgressState == 'resume'){
        porgressState = 'pause';
        $("#button_play").removeClass('play-icon');
        $("#button_play").addClass('pause-icon')

        // have to find a logic to pause
    }
    else if(porgressState == 'pause'){
        porgressState = 'resume';

        $("#button_play").removeClass('pause-icon');
        $("#button_play").addClass('play-icon')
        // cancle the pause replay
    }
    console.log("button play pressed, play was "+porgressState);
}

export function buttonStopPress(scope){
    porgressState = 'stop';
    $("#button_play").removeClass('btn-outline-secondary');
    console.log("button stop invoked.");    

    currFrame = scope.backups.length;
    progressValue = 100;
    updateProgressBar();

    stopReplay(scope);
}