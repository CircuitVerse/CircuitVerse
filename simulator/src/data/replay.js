/**
 * Function to replay circuit
 * @param {Scope=} scope - The circuit on which replay is called
 * @category data
 */
import { layoutModeGet } from "../layoutMode";
import Scope, { scopeList } from "../circuit";
import { loadScope } from "./load";
import { updateRestrictedElementsInScope } from "../restrictedElementDiv";
import { forceResetNodesSet } from "../engine";

/**
 * Function called to replay a circuit
 * @param {Scope=} - the circuit in which we want to call replay
 * @category data
 * @exports replay
 */
export default function replay(scope = globalScope) {
  console.log(scope);
  if (layoutModeGet()) return;
  console.log("replay called");
  const backupOx = globalScope.ox;
  const backupOy = globalScope.oy;
  const backupScale = globalScope.scale;
  globalScope.ox = 0;
  globalScope.oy = 0;

  console.log(scope.backups);
  var frames = scope.backups;
  var count = frames.length;
  console.log(frames);
  console.log(count);

  var fps = 1;
  var i = 0;
  var myInterval = setInterval(function () {
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
    console.log("frame : " + i);
    if (i == count) {
      // We've played all frames.
      console.log("all displayed");
      clearInterval(myInterval);
      globalScope = scope;
      forceResetNodesSet(true);
      updateRestrictedElementsInScope();
    }
  }, 1000 / fps);
}
