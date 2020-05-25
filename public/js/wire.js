//wire object
function Wire(node1, node2, scope) {
    this.objectType = "Wire";
    this.node1 = node1;
    this.scope = scope;
    this.node2 = node2;
    this.type = "horizontal";
    this.updateData();
    this.scope.wires.push(this);
    forceResetNodes=true;
}

//if data changes
// get the terminals of the wires
Wire.prototype.updateData = function() {

    this.x1 = this.node1.absX();
    this.y1 = this.node1.absY();
    this.x2 = this.node2.absX();
    this.y2 = this.node2.absY();
    if (this.x1 == this.x2) this.type = "vertical";
}

Wire.prototype.updateScope=function(scope){
    this.scope=scope;
    this.checkConnections();
}

//to check if nodes are disconnected
Wire.prototype.checkConnections = function() {
    var check = this.node1.deleted||this.node2.deleted||!this.node1.connections.contains(this.node2) || !this.node2.connections.contains(this.node1);
    if (check) this.delete();
    return check;
}


Wire.prototype.update = function() {

    if(embed)return;

    if(this.node1.absX()==this.node2.absX()){
        this.x1=this.x2=this.node1.absX();
        this.type="vertical";
    }
    else if(this.node1.absY()==this.node2.absY()){
        this.y1=this.y2=this.node1.absY();
        this.type="horizontal";
    }

    var updated = false;
    if (wireToBeChecked && this.checkConnections()) {
        this.delete();
        return;
    } // SLOW , REMOVE

    // select a wire
    if (simulationArea.shiftDown==false&&simulationArea.mouseDown == true && simulationArea.selected == false && this.checkWithin(simulationArea.mouseDownX, simulationArea.mouseDownY)) {
        simulationArea.selected = true;
        simulationArea.lastSelected = this;
        updated = true;
    }

    // double click on a wire to place a node
    else if(simulationArea.mouseDown && simulationArea.lastSelected==this&& !this.checkWithin(simulationArea.mouseX, simulationArea.mouseY)){
        // lets move this wiree ! 
       if(this.node1.type == NODE_INTERMEDIATE && this.node2.type == NODE_INTERMEDIATE) {
            if(this.type=="horizontal"){
                this.node1.y= simulationArea.mouseY
                this.node2.y= simulationArea.mouseY
            } else if(this.type=="vertical"){
                this.node1.x= simulationArea.mouseX
                this.node2.x= simulationArea.mouseX
            }
        }
        // var n = new Node(simulationArea.mouseDownX, simulationArea.mouseDownY, 2, this.scope.root);
        // n.clicked = true;
       
        // n.wasClicked = true;
        // simulationArea.lastSelected=n;
        // this.converge(n);
    }
    if (simulationArea.lastSelected == this) {
        
    }

    if (this.node1.deleted || this.node2.deleted){
        this.delete();
        return;
    } //if either of the nodes are deleted

    //NODE POSITION when we move a  COMPONENT to make lines drawen  horzontally or vertically  
    if (simulationArea.mouseDown == false) {
        if (this.type == "horizontal") {
            if (this.node1.absY() != this.y1) {
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
        } else if (this.type == "vertical") {
            
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
}
Wire.prototype.draw = function() {

// for calculating min-max Width,min-max Height

    ctx = simulationArea.context;

    var color;
    if (simulationArea.lastSelected == this)
        color = "blue";
    else if (this.node1.value == undefined||this.node2.value == undefined)
        color = "red";
    else if (this.node1.bitWidth == 1)
        color = ["red", "DarkGreen", "Lime"][this.node1.value + 1];
    else
        color = "black";
    drawLine(ctx, this.node1.absX(), this.node1.absY(), this.node2.absX(), this.node2.absY(), color, 3);

}

// checks if node lies on wire
Wire.prototype.checkConvergence = function(n) {
    return this.checkWithin(n.absX(), n.absY());
}
// fn checks if coordinate lies on wire
Wire.prototype.checkWithin = function(x, y) {
    if ((this.type == "horizontal") && (this.node1.absX() < this.node2.absX()) && (x > this.node1.absX()) && (x < this.node2.absX()) && (y === this.node2.absY()))
        return true;
    else if ((this.type == "horizontal") && (this.node1.absX() > this.node2.absX()) && (x < this.node1.absX()) && (x > this.node2.absX()) && (y === this.node2.absY()))
        return true;
    else if ((this.type == 'vertical') && (this.node1.absY() < this.node2.absY()) && (y > this.node1.absY()) && (y < this.node2.absY()) && (x === this.node2.absX()))
        return true;
    else if ((this.type == 'vertical') && (this.node1.absY() > this.node2.absY()) && (y < this.node1.absY()) && (y > this.node2.absY()) && (x === this.node2.absX()))
        return true
    return false;

}

//add intermediate node between these 2 nodes
Wire.prototype.converge = function(n) {
    this.node1.connect(n);
    this.node2.connect(n);
    this.delete();
}


Wire.prototype.delete = function() {
	forceResetNodes=true;
    updateSimulation = true;
    this.node1.connections.clean(this.node2);
    this.node2.connections.clean(this.node1);
    this.scope.wires.clean(this);
    this.node1.checkDeleted();
    this.node2.checkDeleted();
}
