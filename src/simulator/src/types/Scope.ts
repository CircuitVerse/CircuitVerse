export interface Node {
    saveObject: () => object;
}

export interface SubCircuit {
    removeConnections: () => void;
    makeConnections: () => void;
}

export interface Scope {
    layout: string;
    verilogMetadata: string;
    allNodes: Node[];
    testbenchData: string;
    id: string;
    name: string;
    restrictedCircuitElementsUsed: boolean;
    nodes: Node[];
    SubCircuit: SubCircuit[];
    backups: string[];
    history: string[];
    timeStamp: number;
    [key: string]: unknown; 
}

export interface BackupData {
    layout: string;
    verilogMetadata: string;
    allNodes: object[];  
    testbenchData: string;
    id: string;
    name: string;
    restrictedCircuitElementsUsed: boolean;
    nodes: number[];
    [key: string]: unknown; 
}