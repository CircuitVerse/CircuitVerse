/* eslint-disable import/no-cycle */
/**
 * Function to restore copy from backup
 * @param {Scope=} scope - The circuit on which undo is called
 * @category data
 */
import { layoutModeGet } from '../layoutMode';
import Scope, { scopeList } from '../circuit';
import { loadScope } from './load';
import { updateRestrictedElementsInScope } from '../restrictedElementDiv';
import { forceResetNodesSet } from '../engine';

/**
 * Function called to generate a prompt to save an image
 * @param {Scope=} - the circuit in which we want to call undo
 * @category data
 * @exports undo
 */
export default function undo(scope = globalScope) {
    if (layoutModeGet()) return;
    if (scope.backups.length === 0) return;
    const backupOx = globalScope.ox;
    const backupOy = globalScope.oy;
    const backupScale = globalScope.scale;
    globalScope.ox = 0;
    globalScope.oy = 0;
    const tempScope = new Scope(scope.name);
    loading = true;
    loadScope(tempScope, JSON.parse(scope.backups.pop()));
    tempScope.backups = scope.backups;
    tempScope.id = scope.id;
    tempScope.name = scope.name;
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
