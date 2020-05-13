/**
 * @module node
 */
/**
 * Constructs all the connections of Node node
 * @param {Node} node - node to be constructed
 * @param {JSON} data - the saved data which is used to load
 */
function constructNodeConnections(node, data) {
    for (let i = 0; i < data.connections.length; i++) { 
        if (!node.connections.contains(node.scope.allNodes[data.connections[i]])) 
            node.connect(node.scope.allNodes[data.connections[i]]); 
    }
}

/**
 * Fn to replace node by node @ index in global Node List - used when loading
 * @param {Node} node - node to be replaced
 * @param {number} index - index of node to be replaced
 */
function replace(node, index) {
    if (index == -1) {
        return node;
    }
    var { scope } = node;
    var { parent } = node;
    parent.nodeList.clean(node);
    node.delete();
    node = scope.allNodes[index];
    node.parent = parent;
    parent.nodeList.push(node);
    node.updateRotation();
    return node;
}

function extractBits(num, start, end) {
    return (num << (32 - end)) >>> (32 - (end - start + 1));
}

function bin2dec(binString) {
    return parseInt(binString, 2);
}

function dec2bin(dec, bitWidth = undefined) {
    // only for positive nos
    var bin = (dec).toString(2);
    if (bitWidth == undefined) return bin;
    return '0'.repeat(bitWidth - bin.length) + bin;
}

/**
 * find Index of a node
 * @param {Node} x - Node to be dound
 */
function findNode(x) {
    return x.scope.allNodes.indexOf(x);
}

/**
 * function makes a node according to data providede
 * @param {JSON} data - the data used to load a Project
 * @param {Scope} scope - scope to which node has to be loaded
 */
function loadNode(data, scope) {
    var n = new Node(data.x, data.y, data.type, scope.root, data.bitWidth, data.label);
}

/**
 * get Node in index x in scope and set parent
 * @param {Node} x - the desired node
 * @param {Scope} scope - the scope
 * @param {CircuitElement} parent - The parent of node
 */
function extractNode(x, scope, parent) {
    var n = scope.allNodes[x];
    n.parent = parent;
    return n;
}

// output node=1
// input node=0
// intermediate node =2

NODE_INPUT = 0;
NODE_OUTPUT = 1;
NODE_INTERMEDIATE = 2;

/**
 * This class is responsible for all the Nodes.Nodes are connected using Wires
 * Nodes are of 3 types;
 * NODE_INPUT = 0;
 * NODE_OUTPUT = 1;
 * NODE_INTERMEDIATE = 2;
 * @class
 * @memberof module:node
 * @param {number} x - x coord of Node
 * @param {number} y - y coord of Node
 * @param {number} type - type of node
 * @param {CircuitElement} parent - parent element
 * @param {?number} bitWidth - the bits of node in input and output nodes
 * @param {string=} label - label for a node
 */
function Node(x, y, type, parent, bitWidth = undefined, label = '') {
    // Should never raise, but just in case of any error during loading
    if (isNaN(x) || isNaN(y)) {
        this.delete();
        showError('Fatal error occurred');
        return;
    }
    forceResetNodes = true;
    this.objectType = 'Node';
    // every node has to uniq
    this.id = `node${uniqueIdCounter}`;
    uniqueIdCounter++;
    this.parent = parent;
    if (type != 2 && this.parent.nodeList !== undefined) { this.parent.nodeList.push(this); }

    if (bitWidth == undefined) {
        this.bitWidth = parent.bitWidth;
    } else {
        this.bitWidth = bitWidth;
    }
    this.label = label;
    this.prevx = undefined;
    this.prevy = undefined;
    this.leftx = x;
    this.lefty = y;
    this.x = x;
    this.y = y;

    this.type = type;
    this.connections = new Array(); // all the nodes it is connected to.
    this.value = undefined;
    this.radius = 5;
    this.clicked = false;
    this.hover = false;
    this.wasClicked = false;
    this.scope = this.parent.scope;
    this.prev = 'a';
    this.count = 0;
    this.highlighted = false;

    // This fn is called during rotations and setup
    this.refresh();

    if (this.type == 2) { this.parent.scope.nodes.push(this); }

    this.parent.scope.allNodes.push(this);

    this.queueProperties = {
        inQueue: false,
        time: undefined,
        index: undefined,
    };
}

/**
 * @memberof Node
 * delay in adding node to simulation queue
 */
Node.prototype.propagationDelay = 0;

/**
 * @memberof Node
 * WIP
 */
Node.prototype.subcircuitOverride = false;

/**
 * @memberof Node
 * Function to set label
 */
Node.prototype.setLabel = function (label) {
    this.label = label; // || "";
};

/**
 * @memberof Node
 * function to convert a node to intermediate node
 */
Node.prototype.converToIntermediate = function () {
    this.type = 2;
    this.x = this.absX();
    this.y = this.absY();
    this.parent = this.scope.root;
    this.scope.nodes.push(this);
};

/**
 * @memberof Node
 * Helper fuction to move a node. Sets up some variable which help in changing node.
 */
Node.prototype.startDragging = function () {
    this.oldx = this.x;
    this.oldy = this.y;
};

/**
 * @memberof Node
 * Helper fuction to move a node.
 */
Node.prototype.drag = function () {
    this.x = this.oldx + simulationArea.mouseX - simulationArea.mouseDownX;
    this.y = this.oldy + simulationArea.mouseY - simulationArea.mouseDownY;
};

/**
 * @memberof Node
 * Funciton for saving a node
 */
Node.prototype.saveObject = function () {
    if (this.type == 2) {
        this.leftx = this.x;
        this.lefty = this.y;
    }
    var data = {
        x: this.leftx,
        y: this.lefty,
        type: this.type,
        bitWidth: this.bitWidth,
        label: this.label,
        connections: [],
    };
    for (var i = 0; i < this.connections.length; i++) {
        data.connections.push(findNode(this.connections[i]));
    }
    return data;
};

/**
 * @memberof Node
 * helper function to help rotating parent
 */
Node.prototype.updateRotation = function () {
    var x; var
        y;
    [x, y] = rotate(this.leftx, this.lefty, this.parent.direction);
    this.x = x;
    this.y = y;
};

/**
 * @memberof Node
 * Refreshes a node after roation of parent
 */
Node.prototype.refresh = function () {
    this.updateRotation();
    for (var i = 0; i < this.connections.length; i++) {
        this.connections[i].connections.clean(this);
    }
    this.connections = [];
};

/**
 * @memberof Node
 * gives absolute x position of the node
 */
Node.prototype.absX = function () {
    return this.x + this.parent.x;
};

/**
 * @memberof Node
 * gives absolute y position of the node
 */
Node.prototype.absY = function () {
    return this.y + this.parent.y;
};

/**
 * @memberof Node
 * update the scope of a node
 */
Node.prototype.updateScope = function (scope) {
    this.scope = scope;
    if (this.type == 2) this.parent = scope.root;
};

/**
 * @memberof Node
 * return true if node is connected or not connected but false if undefined.
 */
Node.prototype.isResolvable = function () {
    return this.value != undefined;
};

/**
 * @memberof Node
 * function used to reset the nodes
 */
Node.prototype.reset = function () {
    this.value = undefined;
    this.highlighted = false;
};

/**
 * @memberof Node
 * function to connect two nodes.
 */
Node.prototype.connect = function (n) {
    if (n == this) return;
    if (n.connections.contains(this)) return;
    var w = new Wire(this, n, this.parent.scope);
    this.connections.push(n);
    n.connections.push(this);

    updateCanvas = true;
    updateSimulation = true;
    scheduleUpdate();
};

/**
 * @memberof Node
 * connects but doesnt draw the wire between nodes
 */
Node.prototype.connectWireLess = function (n) {
    if (n == this) return;
    if (n.connections.contains(this)) return;
    this.connections.push(n);
    n.connections.push(this);

    updateCanvas = true;
    updateSimulation = true;
    scheduleUpdate();
};

/**
 * @memberof Node
 * disconnecting two nodes connected wirelessly
 */
Node.prototype.disconnectWireLess = function (n) {
    this.connections.clean(n);
    n.connections.clean(this);
};

/**
 * @memberof Node
 * function to resolve a node
 */
Node.prototype.resolve = function () {
    // Remove Propogation of values (TriState)
    if (this.value == undefined) {
        for (var i = 0; i < this.connections.length; i++) {
            if (this.connections[i].value !== undefined) {
                this.connections[i].value = undefined;
                simulationArea.simulationQueue.add(this.connections[i]);
            }
        }

        if (this.type == NODE_INPUT) {
            if (this.parent.objectType == 'Splitter') {
                this.parent.removePropagation();
            } else
            if (this.parent.isResolvable()) { simulationArea.simulationQueue.add(this.parent); } else { this.parent.removePropagation(); }
        }

        if (this.type == NODE_OUTPUT && !this.subcircuitOverride) {
            if (this.parent.isResolvable() && !this.parent.queueProperties.inQueue) {
                if (this.parent.objectType == 'TriState') {
                    if (this.parent.state.value) { simulationArea.simulationQueue.add(this.parent); }
                } else {
                    simulationArea.simulationQueue.add(this.parent);
                }
            }
        }

        return;
    }

    if (this.type == 0) {
        if (this.parent.isResolvable()) { simulationArea.simulationQueue.add(this.parent); }
    }

    for (var i = 0; i < this.connections.length; i++) {
        const node = this.connections[i];

        if (node.value != this.value) {
            if (node.type == 1 && node.value != undefined && node.parent.objectType != 'TriState' && !(node.subcircuitOverride && node.scope != this.scope)) {
                this.highlighted = true;
                node.highlighted = true;

                showError(`Contention Error: ${  this.value  } and ${  node.value}`);
            } else if (node.bitWidth == this.bitWidth || node.type == 2) {
                if (node.parent.objectType == 'TriState' && node.value != undefined && node.type == 1) {
                    if (node.parent.state.value) { simulationArea.contentionPending.push(node.parent); }
                }

                node.bitWidth = this.bitWidth;
                node.value = this.value;
                simulationArea.simulationQueue.add(node);
            } else {
                this.highlighted = true;
                node.highlighted = true;
                showError(`BitWidth Error: ${  this.bitWidth  } and ${  node.bitWidth}`);
            }
        }
    }
};

/**
 * @memberof Node
 * this function checks if hover over the node
 */
Node.prototype.checkHover = function () {
    if (!simulationArea.mouseDown) {
        if (simulationArea.hover == this) {
            this.hover = this.isHover();
            if (!this.hover) {
                simulationArea.hover = undefined;
                this.showHover = false;
            }
        } else if (!simulationArea.hover) {
            this.hover = this.isHover();
            if (this.hover) {
                simulationArea.hover = this;
            } else {
                this.showHover = false;
            }
        } else {
            this.hover = false;
            this.showHover = false;
        }
    }
};

/**
 * @memberof Node
 * this function draw a node
 */
Node.prototype.draw = function () {
    if (this.type == 2) this.checkHover();

    var ctx = simulationArea.context;

    if (this.clicked) {
        if (this.prev == 'x') {
            drawLine(ctx, this.absX(), this.absY(), simulationArea.mouseX, this.absY(), 'black', 3);
            drawLine(ctx, simulationArea.mouseX, this.absY(), simulationArea.mouseX, simulationArea.mouseY, 'black', 3);
        } else if (this.prev == 'y') {
            drawLine(ctx, this.absX(), this.absY(), this.absX(), simulationArea.mouseY, 'black', 3);
            drawLine(ctx, this.absX(), simulationArea.mouseY, simulationArea.mouseX, simulationArea.mouseY, 'black', 3);
        } else if (Math.abs(this.x + this.parent.x - simulationArea.mouseX) > Math.abs(this.y + this.parent.y - simulationArea.mouseY)) {
            drawLine(ctx, this.absX(), this.absY(), simulationArea.mouseX, this.absY(), 'black', 3);
        } else {
            drawLine(ctx, this.absX(), this.absY(), this.absX(), simulationArea.mouseY, 'black', 3);
        }
    }

    var color = 'black';
    if (this.bitWidth == 1) color = ['green', 'lightgreen'][this.value];
    if (this.value == undefined) color = 'red';
    if (this.type == 2) { drawCircle(ctx, this.absX(), this.absY(), 3, color); } else drawCircle(ctx, this.absX(), this.absY(), 3, 'green');

    if (this.highlighted || simulationArea.lastSelected == this || (this.isHover() && !simulationArea.selected && !simulationArea.shiftDown) || simulationArea.multipleObjectSelections.contains(this)) {
        ctx.strokeStyle = 'green';
        ctx.beginPath();
        ctx.lineWidth = 3;
        arc(ctx, this.x, this.y, 8, 0, Math.PI * 2, this.parent.x, this.parent.y, 'RIGHT');
        ctx.closePath();
        ctx.stroke();
    }

    if (this.hover || (simulationArea.lastSelected == this)) {
        if (this.showHover || simulationArea.lastSelected == this) {
            canvasMessageData = {
                x: this.absX(),
                y: this.absY() - 15,
            };
            if (this.type == 2) {
                var v = 'X';
                if (this.value !== undefined) { v = this.value.toString(16); }
                if (this.label.length) {
                    canvasMessageData.string = `${this.label } : ${v}`;
                } else {
                    canvasMessageData.string = v;
                }
            } else if (this.label.length) {
                canvasMessageData.string = this.label;
            }
        } else {
            setTimeout(() => {
                if (simulationArea.hover) simulationArea.hover.showHover = true;
                canvasUpdate = true;
                renderCanvas(globalScope);
            }, 400);
        }
    }
};

/**
 * @memberof Node
 * checks if a node has been deleted
 */
Node.prototype.checkDeleted = function () {
    if (this.deleted) this.delete();
    if (this.connections.length == 0 && this.type == 2) this.delete();
};

/**
 * @memberof Node
 * used to update nodes if there is a event like click or hover on the node.
 * many booleans are used to check if certain properties are to be updated.
 */
Node.prototype.update = function () {
    if (embed) return;

    if (this == simulationArea.hover) simulationArea.hover = undefined;
    this.hover = this.isHover();

    if (!simulationArea.mouseDown) {
        if (this.absX() != this.prevx || this.absY() != this.prevy) { // Connect to any node
            this.prevx = this.absX();
            this.prevy = this.absY();
            this.nodeConnect();
        }
    }

    if (this.hover) {
        simulationArea.hover = this;
    }

    if (simulationArea.mouseDown && ((this.hover && !simulationArea.selected) || simulationArea.lastSelected == this)) {
        simulationArea.selected = true;
        simulationArea.lastSelected = this;
        this.clicked = true;
    } else {
        this.clicked = false;
    }

    if (!this.wasClicked && this.clicked) {
        this.wasClicked = true;
        this.prev = 'a';
        if (this.type == 2) {
            if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
                for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                    simulationArea.multipleObjectSelections[i].startDragging();
                }
            }

            if (simulationArea.shiftDown) {
                simulationArea.lastSelected = undefined;
                if (simulationArea.multipleObjectSelections.contains(this)) {
                    simulationArea.multipleObjectSelections.clean(this);
                } else {
                    simulationArea.multipleObjectSelections.push(this);
                }
            } else {
                simulationArea.lastSelected = this;
            }
        }
    } else if (this.wasClicked && this.clicked) {
        if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
            for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                simulationArea.multipleObjectSelections[i].drag();
            }
        }
        if (this.type == 2) {
            if (this.connections.length == 1 && this.connections[0].absX() == simulationArea.mouseX && this.absX() == simulationArea.mouseX) {
                this.y = simulationArea.mouseY - this.parent.y;
                this.prev = 'a';
                return;
            } if (this.connections.length == 1 && this.connections[0].absY() == simulationArea.mouseY && this.absY() == simulationArea.mouseY) {
                this.x = simulationArea.mouseX - this.parent.x;
                this.prev = 'a';
                return;
            }
            if (this.connections.length == 1 && this.connections[0].absX() == this.absX() && this.connections[0].absY() == this.absY()) {
                this.connections[0].clicked = true;
                this.connections[0].wasClicked = true;
                simulationArea.lastSelected = this.connections[0];
                this.delete();
                return;
            }
        }

        if (this.prev == 'a' && distance(simulationArea.mouseX, simulationArea.mouseY, this.absX(), this.absY()) >= 10) {
            if (Math.abs(this.x + this.parent.x - simulationArea.mouseX) > Math.abs(this.y + this.parent.y - simulationArea.mouseY)) {
                this.prev = 'x';
            } else {
                this.prev = 'y';
            }
        } else if (this.prev == 'x' && this.absY() == simulationArea.mouseY) {
            this.prev = 'a';
        } else if (this.prev == 'y' && this.absX() == simulationArea.mouseX) {
            this.prev = 'a';
        }
    } else if (this.wasClicked && !this.clicked) {
        this.wasClicked = false;

        if (simulationArea.mouseX == this.absX() && simulationArea.mouseY == this.absY()) {
            return; // no new node situation
        }

        var x1; var y1; var x2; var y2; var 
flag = 0;
        var n1; var 
n2;

        // (x,y) present node, (x1,y1) node 1 , (x2,y2) node 2
        // n1 - node 1, n2 - node 2
        // node 1 may or may not be there
        // flag = 0  - node 2 only
        // flag = 1  - node 1 and node 2
        x2 = simulationArea.mouseX;
        y2 = simulationArea.mouseY;
        x = this.absX();
        y = this.absY();

        if (x != x2 && y != y2) {
            // Rare Exception Cases
            if (this.prev == 'a' && distance(simulationArea.mouseX, simulationArea.mouseY, this.absX(), this.absY()) >= 10) {
                if (Math.abs(this.x + this.parent.x - simulationArea.mouseX) > Math.abs(this.y + this.parent.y - simulationArea.mouseY)) {
                    this.prev = 'x';
                } else {
                    this.prev = 'y';
                }
            }

            flag = 1;
            if (this.prev == 'x') {
                x1 = x2;
                y1 = y;
            } else if (this.prev == 'y') {
                y1 = y2;
                x1 = x;
            }
        }

        if (flag == 1) {
            for (var i = 0; i < this.parent.scope.allNodes.length; i++) {
                if (x1 == this.parent.scope.allNodes[i].absX() && y1 == this.parent.scope.allNodes[i].absY()) {
                    n1 = this.parent.scope.allNodes[i];

                    break;
                }
            }

            if (n1 == undefined) {
                n1 = new Node(x1, y1, 2, this.scope.root);
                for (var i = 0; i < this.parent.scope.wires.length; i++) {
                    if (this.parent.scope.wires[i].checkConvergence(n1)) {
                        this.parent.scope.wires[i].converge(n1);
                        break;
                    }
                }
            }
            this.connect(n1);
        }

        for (var i = 0; i < this.parent.scope.allNodes.length; i++) {
            if (x2 == this.parent.scope.allNodes[i].absX() && y2 == this.parent.scope.allNodes[i].absY()) {
                n2 = this.parent.scope.allNodes[i];
                break;
            }
        }

        if (n2 == undefined) {
            n2 = new Node(x2, y2, 2, this.scope.root);
            for (var i = 0; i < this.parent.scope.wires.length; i++) {
                if (this.parent.scope.wires[i].checkConvergence(n2)) {
                    this.parent.scope.wires[i].converge(n2);
                    break;
                }
            }
        }
        if (flag == 0) this.connect(n2);
        else n1.connect(n2);
        if (simulationArea.lastSelected == this) simulationArea.lastSelected = n2;
    }

    if (this.type == 2 && simulationArea.mouseDown == false) {
        if (this.connections.length == 2) {
            if ((this.connections[0].absX() == this.connections[1].absX()) || (this.connections[0].absY() == this.connections[1].absY())) {
                this.connections[0].connect(this.connections[1]);
                this.delete();
            }
        } else if (this.connections.length == 0) this.delete();
    }
};

/**
 * @memberof Node
 * function delete a node
 */
Node.prototype.delete = function () {
    updateSimulation = true;
    this.deleted = true;
    this.parent.scope.allNodes.clean(this);
    this.parent.scope.nodes.clean(this);

    this.parent.scope.root.nodeList.clean(this); // Hope this works! - Can cause bugs

    if (simulationArea.lastSelected == this) simulationArea.lastSelected = undefined;
    for (var i = 0; i < this.connections.length; i++) {
        this.connections[i].connections.clean(this);
        this.connections[i].checkDeleted();
    }
    wireToBeChecked = true;
    forceResetNodes = true;
    scheduleUpdate();
};

Node.prototype.isClicked = function () {
    return this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY;
};

Node.prototype.isHover = function () {
    return this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY;
};

/**
 * @memberof Node
 * checks for all nodes in scope if there is a node with same x and y postion.
 */
Node.prototype.nodeConnect = function () {
    var x = this.absX();
    var y = this.absY();
    var n;

    for (var i = 0; i < this.parent.scope.allNodes.length; i++) {
        if (this != this.parent.scope.allNodes[i] && x == this.parent.scope.allNodes[i].absX() && y == this.parent.scope.allNodes[i].absY()) {
            n = this.parent.scope.allNodes[i];
            if (this.type == 2) {
                for (var j = 0; j < this.connections.length; j++) {
                    n.connect(this.connections[j]);
                }
                this.delete();
            } else {
                this.connect(n);
            }

            break;
        }
    }

    if (n == undefined) {
        for (var i = 0; i < this.parent.scope.wires.length; i++) {
            if (this.parent.scope.wires[i].checkConvergence(this)) {
                var n = this;
                if (this.type != 2) {
                    n = new Node(this.absX(), this.absY(), 2, this.scope.root);
                    this.connect(n);
                }
                this.parent.scope.wires[i].converge(n);
                break;
            }
        }
    }
};

Node.prototype.cleanDelete = Node.prototype.delete;

/**
 * @memberof Node
 * if input nodde: it resolves the parent
 * else: it adds all the nodes onto the stack
 * and they are processed to generate verilog
 */
Node.prototype.processVerilog = function () {
    if (this.type == NODE_INPUT) {
        if (this.parent.isVerilogResolvable()) { this.scope.stack.push(this.parent); }
    }

    for (var i = 0; i < this.connections.length; i++) {
        if (this.connections[i].verilogLabel != this.verilogLabel) {
            this.connections[i].verilogLabel = this.verilogLabel;
            this.scope.stack.push(this.connections[i]);
        }
    }
};

