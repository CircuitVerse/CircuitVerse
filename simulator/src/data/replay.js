import { layoutModeGet } from '../layoutMode';
import Scope, { scopeList } from '../circuit';
import { loadScope } from './load';
import { updateRestrictedElementsInScope } from '../restrictedElementDiv';
import { forceResetNodesSet } from '../engine';
import { findDimensions } from '../canvasApi';
import simulationArea from '../simulationArea';

var myInterval;
var fps = 1;
var porgressState = 'stop';
var progressValue = 50;

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
    const backupOx = globalScope.ox;
    const backupOy = globalScope.oy;
    const backupScale = globalScope.scale;
    var frames = scope.backups;
    var count = frames.length;
    
    var i = 0;
    myInterval = setInterval(() => {
        // make a temporary scope to load a frome
        const tempScope = new Scope(scope.name);
        loading = true;
        const replayData = frames[i];
        loadScope(tempScope, JSON.parse(replayData));
        tempScope.id = scope.id;
        tempScope.name = scope.name;
        scopeList[scope.id] = tempScope;
        tempScope.ox = backupOx;
        tempScope.oy = backupOy;
        tempScope.scale = backupScale;
        loading = false;
        globalScope = tempScope;
        globalScope.ox = backupOx;
        globalScope.oy = backupOy;
        globalScope.scale = backupScale;
        i++;
        if (i === count) {
            // We've played all frames.
            stopReplay(scope);
            porgressState = 'stop';
        }
    }, 1000 / fps);
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
    clearInterval(myInterval);
    globalScope = scope;
    globalScope.centerFocus(false);
    forceResetNodesSet(true);
    updateRestrictedElementsInScope();
}

// Helper functions to replay
export function setProgressValue(val) {
    console.log("setting player progress");

    progressValue = (val / $(".progress").width()) * 100;
    console.log("Progress % : " + progressValue);

    $(".progress-bar").css('width', progressValue + '%');

    // now update the canvas....
    var currFrame = Math.floor((progressValue * globalScope.backups.length) / 100);
    console.log("Frame to display : " + currFrame);
    // load currFrame in the canvas
}
		
export function buttonBackPress() {
    console.log("button back invoked.");
    fsp = (fps > 1 ? fps - 1 : 1);
}

export function buttonForwardPress() {
    console.log("button forward invoked.");
    fsp = fps + 1;
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
    if(porgressState == 'stop'){
        porgressState = 'play';
        $("#button_play").addClass("btn-outline-secondary");
        $("#button_play i").attr('class', "fa fa-pause");
        replay(scope);
    }
    else if(porgressState == 'play' || porgressState == 'resume'){
        porgressState = 'pause';
        $("#button_play i").attr('class', "fa fa-play");
        // have to find a logic to pause
    }
    else if(porgressState == 'pause'){
        porgressState = 'resume';
        $("#button_play i").attr('class', "fa fa-pause");
        // cancle the pause replay
    }
    console.log("button play pressed, play was "+porgressState);
}

export function buttonStopPress(){
    porgressState = 'stop';
    $("#button_play").removeClass('btn-outline-secondary');
    $("#button_play i").attr('class', "fa fa-play");
    console.log("button stop invoked.");    
    stopReplay(scope);
}