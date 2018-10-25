function constructNodeConnections(node, data) {
    for (var i = 0; i < data["connections"].length; i++)
        if (!node.connections.contains(node.scope.allNodes[data["connections"][i]])) node.connect(node.scope.allNodes[data["connections"][i]]);
}

//Fn to replace node by node @ index in global Node List - used when loading
function replace(node, index) {
    if (index == -1) {
        return node;
    }
    var scope = node.scope;
    var parent = node.parent;
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

//find Index of a node
function findNode(x) {
    return x.scope.allNodes.indexOf(x);
}

function loadNode(data, scope) {
    var n = new Node(data["x"], data["y"], data["type"], scope.root, data["bitWidth"], data["label"]);
}

//get Node in index x in scope and set parent
function extractNode(x, scope, parent) {
    var n = scope.allNodes[x];
    n.parent = parent;
    return n;
}

//output node=1
//input node=0
//intermediate node =2

NODE_OUTPUT = 1;
NODE_INPUT = 0;
NODE_INTERMEDIATE = 2;

function Node(x, y, type, parent, bitWidth = undefined, label = "") {

    // Should never raise, but just in case
    if(isNaN(x) || isNaN(y)){
        this.delete();
        showError("Fatal error occurred");
        return;
    }

    forceResetNodes = true;

    this.objectType = "Node";
    this.id = 'node' + uniqueIdCounter;
    uniqueIdCounter++;
    this.parent = parent;
    if (type != 2 && this.parent.nodeList !== undefined)
        this.parent.nodeList.push(this);

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
    this.connections = new Array();
    this.value = undefined;
    this.radius = 5;
    this.clicked = false;
    this.hover = false;
    this.wasClicked = false;
    this.scope = this.parent.scope;
    this.prev = 'a';
    this.count = 0;
    this.highlighted = false;

    //This fn is called during rotations and setup
    this.refresh();

    if (this.type == 2)
        this.parent.scope.nodes.push(this);

    this.parent.scope.allNodes.push(this);

    this.queueProperties = {
        inQueue: false,
        time: undefined,
        index: undefined,
    }

}

Node.prototype.propagationDelay = 0;
Node.prototype.subcircuitOverride = false;
Node.prototype.setLabel = function(label) {
    this.label = label; //|| "";
}


Node.prototype.converToIntermediate = function() {
    this.type = 2;
    this.x = this.absX();
    this.y = this.absY();
    this.parent = this.scope.root;
    this.scope.nodes.push(this);
}

Node.prototype.startDragging = function() {
    this.oldx = this.x;
    this.oldy = this.y;
}
Node.prototype.drag = function() {
    this.x = this.oldx + simulationArea.mouseX - simulationArea.mouseDownX;
    this.y = this.oldy + simulationArea.mouseY - simulationArea.mouseDownY;
}

Node.prototype.saveObject = function() {

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
    }
    for (var i = 0; i < this.connections.length; i++) {
        data["connections"].push(findNode(this.connections[i]));
    }
    return data;
}

Node.prototype.updateRotation = function() {
    var x, y;
    [x, y] = rotate(this.leftx, this.lefty, this.parent.direction);
    this.x = x;
    this.y = y;
}

Node.prototype.refresh = function() {

    this.updateRotation();
    for (var i = 0; i < this.connections.length; i++) {
        this.connections[i].connections.clean(this);
    }
    this.connections = [];

}

Node.prototype.absX = function() {
    return this.x + this.parent.x;
}
Node.prototype.absY = function() {
    return this.y + this.parent.y;
}

Node.prototype.updateScope = function(scope) {
    this.scope = scope;
    if (this.type == 2) this.parent = scope.root;

}

Node.prototype.isResolvable = function() {
    return this.value != undefined;
}

Node.prototype.reset = function() {
    this.value = undefined;
    this.highlighted = false;
}

Node.prototype.connect = function(n) {

    if (n == this) return;
    if (n.connections.contains(this)) return;
    var w = new Wire(this, n, this.parent.scope);
    this.connections.push(n);
    n.connections.push(this);

    updateCanvas = true;
    updateSimulation = true;
    scheduleUpdate();
}
Node.prototype.connectWireLess = function(n) {

    if (n == this) return;
    if (n.connections.contains(this)) return;
    this.connections.push(n);
    n.connections.push(this);

    updateCanvas = true;
    updateSimulation = true;
    scheduleUpdate();
}

Node.prototype.disconnectWireLess = function(n) {

    this.connections.clean(n);
    n.connections.clean(this);
}

Node.prototype.resolve = function() {

    // Remove Propogation of values (TriState)
    if (this.value == undefined) {


        for (var i = 0; i < this.connections.length; i++) {
            if (this.connections[i].value !== undefined) {
                this.connections[i].value = undefined;
                simulationArea.simulationQueue.add(this.connections[i]);

            }
        }

        if (this.type == NODE_INPUT) {
            if (this.parent.objectType == "Splitter") {
                this.parent.removePropogation();
            } else
            if (this.parent.isResolvable())
                simulationArea.simulationQueue.add(this.parent);
            else
                this.parent.removePropogation();


        }

        if (this.type == NODE_OUTPUT && !this.subcircuitOverride) {
            if (this.parent.isResolvable() && !this.parent.queueProperties.inQueue) {
                if (this.parent.objectType == "TriState") {
                    if (this.parent.state.value)
                        simulationArea.simulationQueue.add(this.parent);
                } else {
                    simulationArea.simulationQueue.add(this.parent);
                }

            }

        }

        return;
    }

    if (this.type == 0) {

        if (this.parent.isResolvable())
            simulationArea.simulationQueue.add(this.parent);

    }

    for (var i = 0; i < this.connections.length; i++) {

        let node = this.connections[i];

        if (node.value != this.value) {

            if (node.type == 1 && node.value != undefined && node.parent.objectType != "TriState" && !(node.subcircuitOverride && node.scope != this.scope)) {

                this.highlighted = true;
                node.highlighted = true;

                showError("Contention Error: " + this.value + " and " + node.value);
            } else if (node.bitWidth == this.bitWidth || node.type == 2) {

                if (node.parent.objectType == "TriState" && node.value != undefined && node.type == 1) {
                    if (node.parent.state.value)
                        simulationArea.contentionPending.push(node.parent);
                }

                node.bitWidth = this.bitWidth;
                node.value = this.value;
                simulationArea.simulationQueue.add(node);
            } else {
                this.highlighted = true;
                node.highlighted = true;
                showError("BitWidth Error: " + this.bitWidth + " and " + node.bitWidth);
            }
        }
    }

}

Node.prototype.checkHover = function() {
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
}

Node.prototype.draw = function() {

    if (this.type == 2) this.checkHover();

    var ctx = simulationArea.context;

    if (this.clicked) {
        if (this.prev == 'x') {
            drawLine(ctx, this.absX(), this.absY(), simulationArea.mouseX, this.absY(), "black", 3);
            drawLine(ctx, simulationArea.mouseX, this.absY(), simulationArea.mouseX, simulationArea.mouseY, "black", 3);
        } else if (this.prev == 'y') {
            drawLine(ctx, this.absX(), this.absY(), this.absX(), simulationArea.mouseY, "black", 3);
            drawLine(ctx, this.absX(), simulationArea.mouseY, simulationArea.mouseX, simulationArea.mouseY, "black", 3);
        } else {
            if (Math.abs(this.x + this.parent.x - simulationArea.mouseX) > Math.abs(this.y + this.parent.y - simulationArea.mouseY)) {
                drawLine(ctx, this.absX(), this.absY(), simulationArea.mouseX, this.absY(), "black", 3);
            } else {
                drawLine(ctx, this.absX(), this.absY(), this.absX(), simulationArea.mouseY, "black", 3);
            }
        }
    }

    var color = "black";
    if (this.bitWidth == 1) color = ["green", "lightgreen"][this.value];
    if (this.value == undefined) color = "red";
    if (this.type == 2)
        drawCircle(ctx, this.absX(), this.absY(), 3, color);
    else drawCircle(ctx, this.absX(), this.absY(), 3, "green");

    if (this.highlighted || simulationArea.lastSelected == this || (this.isHover() && !simulationArea.selected && !simulationArea.shiftDown) || simulationArea.multipleObjectSelections.contains(this)) {
        ctx.strokeStyle = "green";
        ctx.beginPath();
        ctx.lineWidth = 3;
        arc(ctx, this.x, this.y, 8, 0, Math.PI * 2, this.parent.x, this.parent.y, "RIGHT");
        ctx.closePath();
        ctx.stroke();
    }

    if (this.hover || (simulationArea.lastSelected == this)) {

        if (this.showHover || simulationArea.lastSelected == this) {
            canvasMessageData = {
                x: this.absX(),
                y: this.absY() - 15
            }
            if (this.type == 2) {
                var v = "X";
                if (this.value !== undefined)
                    v = this.value.toString(16);
                if (this.label.length) {
                    canvasMessageData.string = this.label + " : " + v;
                } else {
                    canvasMessageData.string = v;
                }
            } else if (this.label.length) {
                canvasMessageData.string = this.label;
            }
        } else {
            setTimeout(function() {
                if (simulationArea.hover) simulationArea.hover.showHover = true;
                canvasUpdate = true;
                renderCanvas(globalScope)
            }, 400);
        }
    }

}

Node.prototype.checkDeleted = function() {
    if (this.deleted) this.delete();
    if (this.connections.length == 0 && this.type == 2) this.delete();
}
Node.prototype.update = function() {

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
            } else if (this.connections.length == 1 && this.connections[0].absY() == simulationArea.mouseY && this.absY() == simulationArea.mouseY) {
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

        var x1, y1, x2, y2, flag = 0;
        var n1, n2;

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
                x1 = x
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

}

Node.prototype.delete = function() {
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
}

Node.prototype.isClicked = function() {
    return this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY;
}

Node.prototype.isHover = function() {
    return this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY;
}

Node.prototype.nodeConnect = function() {

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

}
Node.prototype.cleanDelete = Node.prototype.delete;
Node.prototype.processVerilog = function() {

    if (this.type == NODE_INPUT) {
        if (this.parent.isVerilogResolvable())
            this.scope.stack.push(this.parent);
    }

    for (var i = 0; i < this.connections.length; i++) {
        if (this.connections[i].verilogLabel != this.verilogLabel) {
            this.connections[i].verilogLabel = this.verilogLabel;
            this.scope.stack.push(this.connections[i]);
        }
    }
}



// Kept for archival purposes
// function oldNodeUpdate() {
//
//     if (!this.clicked && !simulationArea.mouseDown) {
//         var px = this.prevx;
//         var py = this.prevy;
//         this.prevx = this.absX();
//         this.prevy = this.absY();
//         if (this.absX() != px || this.absY() != py) {
//             updated = true;
//             this.nodeConnect();
//             return updated;
//         }
//     }
//
//     var updated = false;
//     if (!simulationArea.mouseDown) this.hover = false;
//     if ((this.clicked || !simulationArea.hover) && this.isHover()) {
//         this.hover = true;
//         simulationArea.hover = this;
//     } else if (!simulationArea.mouseDown && this.hover && this.isHover() == false) {
//         if (this.hover) simulationArea.hover = undefined;
//         this.hover = false;
//     }
//
//     if (simulationArea.mouseDown && (this.clicked)) {
//
//         if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
//             for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
//                 simulationArea.multipleObjectSelections[i].drag();
//             }
//         }
//
//         if (this.type == 2) {
//             if (this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY) {
//                 updated = false;
//                 this.prev = 'a';
//             } else if (this.connections.length == 1 && this.connections[0].absX() == simulationArea.mouseX && this.absX() == simulationArea.mouseX) {
//                 this.y = simulationArea.mouseY - this.parent.y;
//                 this.prev = 'a';
//                 updated = true;
//             } else if (this.connections.length == 1 && this.connections[0].absY() == simulationArea.mouseY && this.absY() == simulationArea.mouseY) {
//                 this.x = simulationArea.mouseX - this.parent.x;
//                 this.prev = 'a';
//                 updated = true;
//             }
//             if (this.connections.length == 1 && this.connections[0].absX() == this.absX() && this.connections[0].absY() == this.absY()) {
//                 this.connections[0].clicked = true;
//                 this.connections[0].wasClicked = true;
//                 this.delete();
//                 updated = true;
//             }
//         }
//         if (this.prev == 'a' && distance(simulationArea.mouseX, simulationArea.mouseY, this.absX(), this.absY()) >= 10) {
//             if (Math.abs(this.x + this.parent.x - simulationArea.mouseX) > Math.abs(this.y + this.parent.y - simulationArea.mouseY)) {
//                 this.prev = 'x';
//             } else {
//                 this.prev = 'y';
//             }
//         }
//     } else if (simulationArea.mouseDown && !simulationArea.selected) {
//         simulationArea.selected = this.clicked = this.hover;
//         updated |= this.clicked;
//         this.prev = 'a';
//     } else if (!simulationArea.mouseDown) {
//         if (this.clicked) simulationArea.selected = false;
//         this.clicked = false;
//         this.count = 0;
//     }
//
//     if (this.clicked && !this.wasClicked) {
//         this.wasClicked = true;
//         if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
//             for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
//                 simulationArea.multipleObjectSelections[i].startDragging();
//             }
//         }
//
//         if (this.type == 2) {
//             if (simulationArea.shiftDown) {
//                 simulationArea.lastSelected = undefined;
//                 if (simulationArea.multipleObjectSelections.contains(this)) {
//                     simulationArea.multipleObjectSelections.clean(this);
//                 } else {
//                     simulationArea.multipleObjectSelections.push(this);
//                 }
//             } else {
//                 simulationArea.lastSelected = this;
//             }
//         }
//     }
//
//     if (this.wasClicked && !this.clicked) {
//         this.wasClicked = false;
//
//         if (simulationArea.mouseX == this.absX() && simulationArea.mouseY == this.absY()) {
//             this.nodeConnect();
//             return updated;
//         }
//
//         var n, n1;
//         var x, y, x1, y1, flag = -1;
//         x1 = simulationArea.mouseX;
//         y1 = simulationArea.mouseY;
//         if (this.prev == 'x') {
//             x = x1;
//             y = this.absY();
//             flag = 0;
//         } else if (this.prev == 'y') {
//             y = y1;
//             x = this.absX();
//             flag = 1;
//         }
//         if (this.type == 'a') return; // this should never happen!!
//
//         for (var i = 0; i < this.parent.scope.allNodes.length; i++) {
//             if (x == this.parent.scope.allNodes[i].absX() && y == this.parent.scope.allNodes[i].absY()) {
//                 n = this.parent.scope.allNodes[i];
//                 this.connect(n);
//                 break;
//             }
//         }
//
//         if (n == undefined) {
//             n = new Node(x, y, 2, this.scope.root);
//             this.connect(n);
//             for (var i = 0; i < this.parent.scope.wires.length; i++) {
//                 if (this.parent.scope.wires[i].checkConvergence(n)) {
//                     this.parent.scope.wires[i].converge(n);
//                 }
//             }
//         }
//         this.prev = 'a';
//
//         if (flag == 0 && (this.y + this.parent.y - simulationArea.mouseY) != 0) {
//             y = y1;
//             flag = 2;
//         } else if ((this.x + this.parent.x - simulationArea.mouseX) != 0 && flag == 1) {
//             x = x1;
//             flag = 2;
//         }
//         if (flag == 2) {
//             for (var i = 0; i < this.parent.scope.allNodes.length; i++) {
//                 if (x == this.parent.scope.allNodes[i].absX() && y == this.parent.scope.allNodes[i].absY()) {
//                     n1 = this.parent.scope.allNodes[i];
//                     n.connect(n1);
//                     break;
//                 }
//             }
//             if (n1 == undefined) {
//                 n1 = new Node(x, y, 2, this.scope.root);
//                 n.connect(n1);
//                 for (var i = 0; i < this.parent.scope.wires.length; i++) {
//                     if (this.parent.scope.wires[i].checkConvergence(n1)) {
//                         this.parent.scope.wires[i].converge(n1);
//                     }
//                 }
//             }
//
//         }
//         updated = true;
//
//         if (simulationArea.lastSelected == this) simulationArea.lastSelected = undefined;
//     }
//
//     if (this.type == 2) {
//         if (this.connections.length == 2 && simulationArea.mouseDown == false) {
//             if ((this.connections[0].absX() == this.connections[1].absX()) || (this.connections[0].absY() == this.connections[1].absY())) {
//                 this.connections[0].connect(this.connections[1]);
//                 this.delete();
//             }
//         } else if (this.connections.length == 0) this.delete();
//     }
//
//     // if (this.clicked && this.type == 2 && simulationArea.lastSelected == undefined) simulationArea.lastSelected = this;
//     return updated;
//
//
//
// }
