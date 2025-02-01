import { projectSavedSet } from './project';
import { moduleList, updateOrder } from '../metadata'; 

declare global {
    var globalScope: Scope;
}



interface Scope {
    SubCircuit: { removeConnections: () => void; makeConnections: () => void }[];
    layout: any;
    verilogMetadata: any;
    allNodes: { saveObject: () => any }[];
    testbenchData: any;
    id: string;
    name: string;
    restrictedCircuitElementsUsed: any;
    nodes: any[];
    backups: string[];
    history: any[];
    timeStamp: number;
    [key: string]: any;
}

function extract(obj: { saveObject: () => any }): any {
    return obj.saveObject();
}

/**
 * Check if backup is available
 * @param {Scope} scope
 * @return {boolean}
 * @category data
 */
export function checkIfBackup(scope: Scope): boolean {
    for (let i = 0; i < updateOrder.length; i++) {
        if (scope[updateOrder[i]]?.length) return true;
    }
    return false;
}

export function backUp(scope: Scope = globalScope): any { 
    // Disconnection of subcircuits are needed because these are the connections between nodes
    // in current scope and those in the subcircuit's scope
    for (let i = 0; i < scope.SubCircuit.length; i++) {
        scope.SubCircuit[i].removeConnections();
    }

    const data: any = {
        layout: scope.layout,
        verilogMetadata: scope.verilogMetadata,
        allNodes: scope.allNodes.map(extract),
        testbenchData: scope.testbenchData,
        id: scope.id,
        name: scope.name,
	// Adding restricted circuit elements used in the save data
        restrictedCircuitElementsUsed: scope.restrictedCircuitElementsUsed,
        nodes: scope.nodes.map(node => scope.allNodes.indexOf(node)),
    };

    // Storing details of all module objects
    for (let i = 0; i < moduleList.length; i++) {
        if (scope[moduleList[i]]?.length) {
            data[moduleList[i]] = scope[moduleList[i]].map(extract);
        }
    }

    for (let i = 0; i < scope.SubCircuit.length; i++) {
        scope.SubCircuit[i].makeConnections();
    }

    return data;
}


export function scheduleBackup(scope: Scope = globalScope): string {
    const backup = JSON.stringify(backUp(scope));
    if (
        scope.backups.length === 0 ||
        scope.backups[scope.backups.length - 1] !== backup
    ) {
        scope.backups.push(backup);
        scope.history = [];
        scope.timeStamp = new Date().getTime();
        projectSavedSet(false);
    }

    return backup;
}

