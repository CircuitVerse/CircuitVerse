import { projectSavedSet } from './project'
import { moduleList, updateOrder } from '../metadata'
import { Scope, Node, BackupData } from '../types/Scope'

declare const globalScope: Scope;

/* eslint-disable no-param-reassign */
function extract(obj: Node): object {
    return obj.saveObject()
}

// Check if there is anything to backup - to be deprecated
/**
 * Check if backup is available
 * @param {Scope} scope
 * @return {boolean}
 * @category data
 */
export function checkIfBackup(scope: Scope): boolean {
    for (let i = 0; i < updateOrder.length; i++) {
        const property = scope[updateOrder[i]];
        if (Array.isArray(property) && property.length) {
            return true;
        }
    }
    return false;
}


export function backUp(scope: Scope = globalScope): BackupData {
    const data: BackupData = {
        layout: scope.layout,
        verilogMetadata: scope.verilogMetadata,
        allNodes: scope.allNodes.map(extract),
        testbenchData: scope.testbenchData,
        id: scope.id,
        name: scope.name,
        restrictedCircuitElementsUsed: scope.restrictedCircuitElementsUsed,
        nodes: scope.nodes.map((node: Node) => scope.allNodes.indexOf(node)),   
    }

    // Storing details of all module objects
    for (let i = 0; i < moduleList.length; i++) {
        const moduleProperty = scope[moduleList[i]];
        if (Array.isArray(moduleProperty) && moduleProperty.length) {
            data[moduleList[i]] = moduleProperty.map(extract);
        }
    }
    
    // Disconnection of subcircuits are needed because these are the connections between nodes
    // in current scope and those in the subcircuit's scope
    for (let i = 0; i < scope.SubCircuit.length; i++) {
        scope.SubCircuit[i].removeConnections()
    }
    // Restoring the connections
    for (let i = 0; i < scope.SubCircuit.length; i++) {
        scope.SubCircuit[i].makeConnections()
    }

    return data
}

export function scheduleBackup(scope: Scope = globalScope): string {
    const backup = JSON.stringify(backUp(scope))
    if (
        scope.backups.length === 0 ||
        scope.backups[scope.backups.length - 1] !== backup
    ) {
        scope.backups.push(backup)
        scope.history = []
        scope.timeStamp = new Date().getTime()
        projectSavedSet(false)
    }

    return backup
}