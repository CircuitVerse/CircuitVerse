/* eslint-disable import/no-cycle */
/**
 * Function to restore copy from backup
 * @param {Scope=} scope - The circuit on which redo is called
 * @category data
 */
import { layoutModeGet } from '../layoutMode';
import Scope, { scopeList } from '../circuit';
import { loadScope } from './load';
import { updateRestrictedElementsInScope } from '../restrictedElementDiv';
import { forceResetNodesSet } from '../engine';
/**
 * Function called to generate a prompt to save an image
 * @param {Scope=} - the circuit in which we want to call redo
 * @category data
 * @exports redo
 */
export default function redo(scope = globalScope) {
    if (layoutModeGet()) return;
    if (scope.history.length === 0) return;
    const backupOx = globalScope.ox;
    const backupOy = globalScope.oy;
    const backupScale = globalScope.scale;
    globalScope.ox = 0;
    globalScope.oy = 0;
    const tempScope = new Scope(scope.name);
    loading = true;
    const redoData = scope.history.pop();
    scope.backups.push(redoData);
    loadScope(tempScope, JSON.parse(redoData));
    tempScope.backups = scope.backups;
    tempScope.history = scope.history;
    tempScope.id = scope.id;
    tempScope.name = scope.name;
    tempScope.testbenchData = scope.testbenchData;
    scopeList[scope.id] = tempScope;
    globalScope = tempScope;
    globalScope.ox = backupOx;
    globalScope.oy = backupOy;
    globalScope.scale = backupScale;
    loading = false;
    forceResetNodesSet(true);

    // Updated restricted elements
    updateRestrictedElementsInScope();
}
// for html file
