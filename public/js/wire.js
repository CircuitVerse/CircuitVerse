/* eslint-disable func-names */
/**
 * @module wire
*/
/**
 * Wire - To connect two nodes.
 * @class
 * @memberof module:wire
 * @param {Node} node1
 * @param {Node} node2
 * @param {Scope} scope - The circuit in which wire has to be drawn
 */
function Wire(node1, node2, scope) {
    this.objectType = 'Wire';
    this.node1 = node1;
    this.scope = scope;
    this.node2 = node2;
    this.type = 'horizontal';

    this.updateData();
    this.scope.wires.push(this);
    forceResetNodes = true;
}

// if data changes
/**
 * @memberof Wire
 * to change postion of node wires
 */
Wire.prototype.updateData = function () {
    this.x1 = this.node1.absX();
    this.y1 = this.node1.absY();
    this.x2 = this.node2.absX();
    this.y2 = this.node2.absY();
    if (this.x1 == this.x2) this.type = 'vertical';
};

/**
 * @memberof Wire
 * fn to reset scope In case wires
 * are moved from one scope to another
 */
Wire.prototype.updateScope = function (scope) {
    this.scope = scope;
    this.checkConnections();
};

/**
 * @memberof Wire
 * fn to check if nodes are disconnected
 * or deleted
 * @return {boolean}
 */
Wire.prototype.checkConnections = function () {
    var check = this.node1.deleted || this.node2.deleted || !this.node1.connections.contains(this.node2) || !this.node2.connections.contains(this.node1);
    if (check) this.delete();
    return check;
};


/**
 * @memberof Wire
 * fn to update the wire's UI and info
 * or deleted
 */
Wire.prototype.update = function () {
    if (embed) return;
    // no intermediary node will be drawn in following cases
    if (this.node1.absX() == this.node2.absX()) {
        this.x1 = this.x2 = this.node1.absX();
        this.type = 'vertical';
    } else if (this.node1.absY() == this.node2.absY()) {
        this.y1 = this.y2 = this.node1.absY();
        this.type = 'horizontal';
    }

    var updated = false;
    if (wireToBeChecked && this.checkConnections()) {
        this.delete();
        return;
    } // SLOW , REMOVE
    if (simulationArea.shiftDown == false && simulationArea.mouseDown == true && simulationArea.selected == false && this.checkWithin(simulationArea.mouseDownX, simulationArea.mouseDownY)) {
        simulationArea.selected = true;
        simulationArea.lastSelected = this;
        updated = true;
    } else if (simulationArea.mouseDown && simulationArea.lastSelected == this && !this.checkWithin(simulationArea.mouseX, simulationArea.mouseY)) {
        // lets move this wiree (idea: maybe wirrreee) !
        if (this.node1.type == NODE_INTERMEDIATE && this.node2.type == NODE_INTERMEDIATE) {
            if (this.type == 'horizontal') {
                this.node1.y = simulationArea.mouseY;
                this.node2.y = simulationArea.mouseY;
            } else if (this.type == 'vertical') {
                this.node1.x = simulationArea.mouseX;
                this.node2.x = simulationArea.mouseX;
            }
        }
        // var n = new Node(simulationArea.mouseDownX, simulationArea.mouseDownY, 2, this.scope.root);
        // n.clicked = true;

        // n.wasClicked = true;
        // simulationArea.lastSelected=n;
        // this.converge(n);
    }
    if (simulationArea.lastSelected == this) {
        // idea: empty?
    }

    if (this.node1.deleted || this.node2.deleted) {
        this.delete();
        return;
    } // if either of the nodes are deleted
    // below lines check that the wire remains straight and if it doesnt a connecting node is added in between the two nodes
    if (simulationArea.mouseDown == false) {
        if (this.node1.absY() != this.y1) {
            if (this.type == 'horizontal') {
                // if(this.checkConnections()){this.delete();return;}
                var n = new Node(this.node1.absX(), this.y1, 2, this.scope.root);
                this.converge(n);
                updated = true;
            } else if (this.node2.absY() != this.y2) {
                // if(this.checkConnections()){this.delete();return;}
                var n = new Node(this.node2.absX(), this.y2, 2, this.scope.root);
                this.converge(n);
                updated = true;
            }
        } else if (this.type == 'vertical') {
            if (this.node1.absX() != this.x1) {
                // if(this.checkConnections()){this.delete();return;}
                var n = new Node(this.x1, this.node1.absY(), 2, this.scope.root);
                this.converge(n);
                updated = true;
            } else if (this.node2.absX() != this.x2) {
                // if(this.checkConnections()){this.delete();return;}
                var n = new Node(this.x2, this.node2.absY(), 2, this.scope.root);
                this.converge(n);
                updated = true;
            }
        }
    }
    return updated;
};
/**
 * @memberof Wire
 * helper fn to draw the wire and setting it's color.
 */
Wire.prototype.draw = function () {
    // for calculating min-max Width,min-max Height

    ctx = simulationArea.context;

    var color;
    if (simulationArea.lastSelected == this) { color = 'blue'; } else if (this.node1.value == undefined || this.node2.value == undefined) { color = 'red'; } else if (this.node1.bitWidth == 1) { color = ['red', 'DarkGreen', 'Lime'][this.node1.value + 1]; } else { color = 'black'; }
    drawLine(ctx, this.node1.absX(), this.node1.absY(), this.node2.absX(), this.node2.absY(), color, 3);
};

/**
 * checks if node lies on wire
 * @memberof Wire
 * @param {Node} n - the node to be checked on wire
 */
Wire.prototype.checkConvergence = function (n) {
    return this.checkWithin(n.absX(), n.absY());
};
/**
 * @memberof Wire
 * fn checks if coordinate lies on wire
 * @param {number} x
 * @param {number} y
 */
Wire.prototype.checkWithin = function (x, y) {
    if ((this.type == 'horizontal') && (this.node1.absX() < this.node2.absX()) && (x > this.node1.absX()) && (x < this.node2.absX()) && (y === this.node2.absY())) { return true; }
    if ((this.type == 'horizontal') && (this.node1.absX() > this.node2.absX()) && (x < this.node1.absX()) && (x > this.node2.absX()) && (y === this.node2.absY())) { return true; }
    if ((this.type == 'vertical') && (this.node1.absY() < this.node2.absY()) && (y > this.node1.absY()) && (y < this.node2.absY()) && (x === this.node2.absX())) { return true; }
    if ((this.type == 'vertical') && (this.node1.absY() > this.node2.absY()) && (y < this.node1.absY()) && (y > this.node2.absY()) && (x === this.node2.absX())) { return true; }
    return false;
};

/**
 * @memberof Wire
 * add intermediate node between these 2 nodes
 * @param {Node} n - Node to be added between two nodes of wire
 */
Wire.prototype.converge = function (n) {
    this.node1.connect(n);
    this.node2.connect(n);
    this.delete();
};

/**
 * @memberof Wire
 * Funciton to delte a wire
 */
Wire.prototype.delete = function () {
    forceResetNodes = true;
    updateSimulation = true;
    this.node1.connections.clean(this.node2);
    this.node2.connections.clean(this.node1);
    this.scope.wires.clean(this);
    this.node1.checkDeleted();
    this.node2.checkDeleted();
};
