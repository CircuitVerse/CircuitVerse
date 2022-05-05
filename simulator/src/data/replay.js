import { layoutModeGet } from "../layoutMode";
import Scope, { scopeList } from "../circuit";
import { loadScope } from "./load";
import { updateRestrictedElementsInScope } from "../restrictedElementDiv";
import { forceResetNodesSet } from "../engine";
import { findDimensions } from "../canvasApi";
import simulationArea from "../simulationArea";


var myInterval;


function applyBackdrop() {
  findDimensions();
  const minX = simulationArea.minWidth;
  const minY = simulationArea.minHeight;
  const maxX = simulationArea.maxWidth;
  const maxY = simulationArea.maxHeight;
  let width = (maxX - minX) + 100;
  let height = (maxY - minY) + 100;
  $('#blurPart').css({'top': (minY + globalScope.oy - 50), 'left' : (minX + globalScope.ox - 50), 'width' : width, 'height' : height});
}

export function stopReplay(scope) {
  clearInterval(myInterval);
  globalScope = scope;
  globalScope.centerFocus(false);
  forceResetNodesSet(true);
  updateRestrictedElementsInScope();
}

/**
 * Function called to replay a circuit
 * @param {Scope=} - the circuit in which we want to call replay
 * @category data
 * @exports replay
 */
export function replay(scope = globalScope) {
  if (layoutModeGet()) return;
  // center focus for replay - 
  // else for big circuits some part goes out of screen
  globalScope.centerFocus(false);
  // add backdrop to the unconcerned part
  applyBackdrop();
  const backupOx = globalScope.ox;
  const backupOy = globalScope.oy;
  const backupScale = globalScope.scale;
  var frames = scope.backups;
  var count = frames.length;
  var fps = 1;
  var i = 0;
  myInterval = setInterval(function () {
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
    if (i == count) {
      // We've played all frames.
      stopReplay(scope);
    }
  }, 1000 / fps);
}
