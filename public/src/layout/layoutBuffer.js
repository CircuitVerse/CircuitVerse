import LayoutNode from './layoutNode';
/**
 * Buffer object to store changes so that you can reset changes
 * @class
 * @param {Scope=} scope
 * @category layout
 */
export default class LayoutBuffer {
    constructor(scope = globalScope) {

        var w = 300 * DPR;
        var h = 50 * DPR;

        globalScope.ox = w;
        globalScope.oy = h;

        // Assign layout if exist or create new one
        this.layout = { ...scope.layout }; // Object.create(scope.layout);

        // Push Input Nodes
        this.Input = [];
        for (let i = 0; i < scope.Input.length; i++)
            this.Input.push(new LayoutNode(scope.Input[i].layoutProperties.x, scope.Input[i].layoutProperties.y, scope.Input[i].layoutProperties.id, scope.Input[i].label, scope.Input[i].type, scope.Input[i]));

        // Push Output Nodes
        this.Output = [];
        for (let i = 0; i < scope.Output.length; i++)
            this.Output.push(new LayoutNode(scope.Output[i].layoutProperties.x, scope.Output[i].layoutProperties.y, scope.Output[i].layoutProperties.id, scope.Output[i].label, scope.Output[i].type, scope.Output[i]));
        
        // holds subcircuit elements
        this.subElements = []
    }

    /**
     * @memberof layoutBuffer
     * Check if position is on the boundaries of subcircuit
     * if the desired width and heiht is allowed
     */
    isAllowed(x, y) {
        if (x < 0 || x > this.layout.width || y < 0 || y > this.layout.height) return false;
        if (x > 0 && x < this.layout.width && y > 0 && y < this.layout.height) return false;

        if ((x === 0 && y === 0) || (x === 0 && y === this.layout.height) || (x === this.layout.width && y === 0) || (x === this.layout.width && y === this.layout.height)) return false;

        return true;
    }

    /**
     * @memberof layoutBuffer
     * Check if node is already at a position
     * Function is called while decreasing height to
     * check if it is possible without moving other node
     */
    isNodeAt(x, y) {
        for (let i = 0; i < this.Input.length; i++) { if (this.Input[i].x === x && this.Input[i].y === y) return true; }
        for (let i = 0; i < this.Output.length; i++) { if (this.Output[i].x === x && this.Output[i].y === y) return true; }
        return false;
    }
}
