// Layout.js - all subcircuit layout related code is here

// Function to toggle between layoutMode and normal Mode
function toggleLayoutMode() {
    if (layoutMode) {
        layoutMode = false;
        temp_buffer = undefined;
        $("#layoutDialog").fadeOut();
        $('#subcircuitMenu').empty();
        $('#subcircuitMenu').css('display', 'none');
        $('#menu').css('display', 'block');
        globalScope.centerFocus(false);
        dots();

    } else {
        layoutMode = true;
        $("#layoutDialog").fadeIn();
        $('#menu').css('display', 'none');
        $('#subcircuitMenu').css('display', 'block');
        fillSubcircuitElements();
        
        globalScope.ox = 0;
        globalScope.oy = 0;
        globalScope.scale = DPR * 1.3;
        dots();

        temp_buffer = new layout_buffer();
        $("#toggleLayoutTitle")[0].checked=temp_buffer.layout.titleEnabled;
    }
    hideProperties();
    update(globalScope, true)
    scheduleUpdate();
}

// Update UI, positions of inputs and outputs
function layoutUpdate(scope = globalScope) {
    if (!layoutMode) return;
    willBeUpdated = false;
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        temp_buffer.Input[i].update()
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        temp_buffer.Output[i].update()
    }

    for(let i = 0; i < circuitElementList.length; i++){
        if (!window[circuitElementList[i]].prototype.canShowInSubcircuit) continue;

        let elementName = circuitElementList[i];

        for(let j = 0; j < globalScope[elementName].length; j++){

            if (globalScope[elementName][j].subcircuitMetadata.showInSubcircuit) {
                globalScope[elementName][j].layoutUpdate();
            }
           
        }
    }

    paneLayout(scope);
    renderLayout(scope);
}

function paneLayout(scope = globalScope){
    if (!simulationArea.selected && simulationArea.mouseDown) {

        simulationArea.selected = true;
        simulationArea.lastSelected = scope.root;
        simulationArea.hover = scope.root;

    } else if (simulationArea.lastSelected == scope.root && simulationArea.mouseDown) {

        //pane canvas
        if (!objectSelection) {
            globalScope.ox = (simulationArea.mouseRawX - simulationArea.mouseDownRawX) + simulationArea.oldx;
            globalScope.oy = (simulationArea.mouseRawY - simulationArea.mouseDownRawY) + simulationArea.oldy;
            globalScope.ox = Math.round(globalScope.ox);
            globalScope.oy = Math.round(globalScope.oy);
            gridUpdate = true;
            if (!embed && !lightMode) miniMapArea.setup();
        } else {

        }


    } else if (simulationArea.lastSelected == scope.root) {

        // Select multiple objects

        simulationArea.lastSelected = undefined;
        simulationArea.selected = false;
        simulationArea.hover = undefined;


    }
}


// Buffer object to store changes
function layout_buffer(scope = globalScope) {

    var w = Math.round((width / globalScope.scale) * 0.01) * 10; // 10% width of screen in layoutMode
    var h = Math.round((height / globalScope.scale) * 0.01) * 10; // 10% height of screen in layoutMode

    globalScope.ox = w;
    globalScope.oy = h;

    // Assign layout if exist or create new one
    this.layout = Object.assign({}, scope.layout); //Object.create(scope.layout);

    // Push Input Nodes
    this.Input = [];
    for (var i = 0; i < scope.Input.length; i++)
        this.Input.push(new layoutNode(scope.Input[i].layoutProperties.x, scope.Input[i].layoutProperties.y, scope.Input[i].layoutProperties.id, scope.Input[i].label, scope.Input[i].type, scope.Input[i]))

    // Push Output Nodes
    this.Output = [];
    for (var i = 0; i < scope.Output.length; i++)
        this.Output.push(new layoutNode(scope.Output[i].layoutProperties.x, scope.Output[i].layoutProperties.y, scope.Output[i].layoutProperties.id, scope.Output[i].label, scope.Output[i].type, scope.Output[i]))
}

// Check if position is on the boundaries of subcircuit
layout_buffer.prototype.isAllowed = function(x, y) {
    if (x < 0 || x > this.layout.width || y < 0 || y > this.layout.height) return false;
    if (x > 0 && x < this.layout.width && y > 0 && y < this.layout.height) return false;

    if ((x == 0 && y == 0) || (x == 0 && y == this.layout.height) || (x == this.layout.width && y == 0) || (x == this.layout.width && y == this.layout.height)) return false;

    return true;
}

// Check if node is already at a position
layout_buffer.prototype.isNodeAt = function(x, y) {
    for (var i = 0; i < this.Input.length; i++)
        if (this.Input[i].x == x && this.Input[i].y == y) return true;
    for (var i = 0; i < this.Output.length; i++)
        if (this.Output[i].x == x && this.Output[i].y == y) return true;
    return false;
}

// Function to render layout on screen
//                   COMMENTED TO PRESERVE FROM CHANGES WHILE TESTING
/* function renderLayout(scope = globalScope) {
    if (!layoutMode) return;

    var xx = temp_buffer.xx;
    var yy = temp_buffer.yy;

    var ctx = simulationArea.context;
    simulationArea.clear();

    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);

    // Draw base rectangle
    ctx.beginPath();
    rect2(ctx, 0, 0, temp_buffer.layout.width, temp_buffer.layout.height, xx, yy, "RIGHT");
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    if(temp_buffer.layout.titleEnabled){
        fillText(ctx, scope.name, temp_buffer.layout.title_x + xx, yy + temp_buffer.layout.title_y, 11);
    }

    // Draw labels
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (!temp_buffer.Input[i].label) continue;
        var info = determine_label(temp_buffer.Input[i].x, temp_buffer.Input[i].y, scope);
        ctx.textAlign = info[0];
        fillText(ctx, temp_buffer.Input[i].label, temp_buffer.Input[i].x + info[1] + xx, yy + temp_buffer.Input[i].y + info[2], 12);
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (!temp_buffer.Output[i].label) continue;
        var info = determine_label(temp_buffer.Output[i].x, temp_buffer.Output[i].y, scope);
        ctx.textAlign = info[0];
        fillText(ctx, temp_buffer.Output[i].label, temp_buffer.Output[i].x + info[1] + xx, yy + temp_buffer.Output[i].y + info[2], 12);
    }
    ctx.fill();

    // Draw points
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        temp_buffer.Input[i].draw()
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        temp_buffer.Output[i].draw()
    }

    if (gridUpdate) {
        gridUpdate = false;
        dots();
    }

} */
function renderLayout(scope = globalScope) {
    if (!layoutMode) return;

    var ctx = simulationArea.context;
    simulationArea.clear();

    ctx.strokeStyle = "black";
    ctx.fillStyle = "white";
    ctx.lineWidth = correctWidth(3);

    // Draw base rectangle
    ctx.beginPath();
    rect2(ctx, 0, 0, temp_buffer.layout.width, temp_buffer.layout.height, 0, 0, "RIGHT");
    ctx.fill();
    ctx.stroke();

    ctx.beginPath();
    ctx.textAlign = "center";
    ctx.fillStyle = "black";
    if(temp_buffer.layout.titleEnabled){
        fillText(ctx, scope.name, temp_buffer.layout.title_x, temp_buffer.layout.title_y, 11);
    }

    // Draw labels
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (!temp_buffer.Input[i].label) continue;
        var info = determine_label(temp_buffer.Input[i].x, temp_buffer.Input[i].y, scope);
        ctx.textAlign = info[0];
        fillText(ctx, temp_buffer.Input[i].label, temp_buffer.Input[i].x + info[1] + xx, yy + temp_buffer.Input[i].y + info[2], 12);
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (!temp_buffer.Output[i].label) continue;
        var info = determine_label(temp_buffer.Output[i].x, temp_buffer.Output[i].y, scope);
        ctx.textAlign = info[0];
        fillText(ctx, temp_buffer.Output[i].label, temp_buffer.Output[i].x + info[1] + xx, yy + temp_buffer.Output[i].y + info[2], 12);
    }
    ctx.fill();

    // Draw points
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        temp_buffer.Input[i].draw()
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        temp_buffer.Output[i].draw()
    }

    if (gridUpdate) {
        gridUpdate = false;
        dots();
    }
    
    // Render objects
    
    for(let i = 0; i < circuitElementList.length; i++){
        if (!window[circuitElementList[i]].prototype.canShowInSubcircuit) continue;

        let elementName = circuitElementList[i];

        for(let j = 0; j < globalScope[elementName].length; j++){

            if (globalScope[elementName][j].subcircuitMetadata.showInSubcircuit) {
                globalScope[elementName][j].layoutDraw();
            }
           
        }
    }
}

// Helper function to reset all nodes to original default positions
function layoutResetNodes() {
    temp_buffer.layout.width = 100;
    temp_buffer.layout.height = Math.max(temp_buffer.Input.length, temp_buffer.Output.length) * 20 + 20;
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        temp_buffer.Input[i].x = 0;
        temp_buffer.Input[i].y = i * 20 + 20;
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        temp_buffer.Output[i].x = temp_buffer.layout.width;
        temp_buffer.Output[i].y = i * 20 + 20;
    }
}

// Increase width, and move all nodes
function increaseLayoutWidth() {
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (temp_buffer.Input[i].x == temp_buffer.layout.width)
            temp_buffer.Input[i].x += 10;
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (temp_buffer.Output[i].x == temp_buffer.layout.width)
            temp_buffer.Output[i].x += 10;
    }
    temp_buffer.layout.width += 10;
}

// Increase Height, and move all nodes
function increaseLayoutHeight() {
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (temp_buffer.Input[i].y == temp_buffer.layout.height)
            temp_buffer.Input[i].y += 10;
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (temp_buffer.Output[i].y == temp_buffer.layout.height)
            temp_buffer.Output[i].y += 10;
    }
    temp_buffer.layout.height += 10;
}

// Decrease Width, and move all nodes, check if space is there
function decreaseLayoutWidth() {

    if (temp_buffer.layout.width < 30) return;
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (temp_buffer.Input[i].x == temp_buffer.layout.width - 10) {
            showMessage("No space. Move or delete some nodes to make space.");
            return;
        }

    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (temp_buffer.Output[i].x == temp_buffer.layout.width - 10) {
            showMessage("No space. Move or delete some nodes to make space.");
            return;
        }
    }

    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (temp_buffer.Input[i].x == temp_buffer.layout.width)
            temp_buffer.Input[i].x -= 10;
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (temp_buffer.Output[i].x == temp_buffer.layout.width)
            temp_buffer.Output[i].x -= 10;
    }
    temp_buffer.layout.width -= 10;
}

// Decrease Height, and move all nodes, check if space is there
function decreaseLayoutHeight() {

    if (temp_buffer.layout.height < 30) return;
    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (temp_buffer.Input[i].y == temp_buffer.layout.height - 10) {
            showMessage("No space. Move or delete some nodes to make space.");
            return;
        }

    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (temp_buffer.Output[i].y == temp_buffer.layout.height - 10) {
            showMessage("No space. Move or delete some nodes to make space.");
            return;
        }
    }

    for (var i = 0; i < temp_buffer.Input.length; i++) {
        if (temp_buffer.Input[i].y == temp_buffer.layout.height)
            temp_buffer.Input[i].y -= 10;
    }
    for (var i = 0; i < temp_buffer.Output.length; i++) {
        if (temp_buffer.Output[i].y == temp_buffer.layout.height)
            temp_buffer.Output[i].y -= 10;
    }
    temp_buffer.layout.height -= 10;
}

// Helper functions to move the titles
function layoutTitleUp() {
    temp_buffer.layout.title_y -= 5;
}

function layoutTitleDown() {
    temp_buffer.layout.title_y += 5;
}

function layoutTitleRight() {
    temp_buffer.layout.title_x += 5;
}

function layoutTitleLeft() {
    temp_buffer.layout.title_x -= 5;
}

function toggleLayoutTitle(){
    temp_buffer.layout.titleEnabled=!temp_buffer.layout.titleEnabled;
}

function layoutNode(x, y, id, label = "", type, parent) {

    this.type = type;
    this.id = id

    this.label = label;

    this.prevx = undefined;
    this.prevy = undefined;
    this.x = x; // Position of node wrt to parent
    this.y = y; // Position of node wrt to parent

    this.radius = 5;
    this.clicked = false;
    this.hover = false;
    this.wasClicked = false;
    this.prev = 'a';
    this.count = 0;
    this.parent = parent;

}

layoutNode.prototype.absX = function() {
    return this.x;
}
layoutNode.prototype.absY = function() {
    return this.y;
}

layoutNode.prototype.update = function() {

    // Code copied from node.update() - Some code is redundant - needs to be removed

    if (this == simulationArea.hover) simulationArea.hover = undefined;
    this.hover = this.isHover();

    if (!simulationArea.mouseDown) {
        if (this.absX() != this.prevx || this.absY() != this.prevy) {
            // Store position before clicked
            this.prevx = this.absX();
            this.prevy = this.absY();
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
        simulationArea.lastSelected = this;

    } else if (this.wasClicked && this.clicked) {
        // Check if valid position and update accordingly
        if (temp_buffer.isAllowed(simulationArea.mouseX, simulationArea.mouseY) && !temp_buffer.isNodeAt(simulationArea.mouseX, simulationArea.mouseY)) {
            this.x = simulationArea.mouseX;
            this.y = simulationArea.mouseY;
        }
    }

}

layoutNode.prototype.draw = function() {
    var ctx = simulationArea.context;
    drawCircle(ctx, this.absX(), this.absY(), 3, ["green", "red"][+(simulationArea.lastSelected == this)]);
}

layoutNode.prototype.isHover = function() {
    return this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY;
}

// Helper function to determine alignment and position of nodes for rendering
function determine_label(x, y) {
    if (x == 0) return ["left", 5, 5]
    if (x == temp_buffer.layout.width) return ["right", -5, 5]
    if (y == 0) return ["center", 0, 13]
    return ["center", 0, -6]
}

function cancelLayout() {
    if (layoutMode) {
        toggleLayoutMode();
    }
}


// Store all data into layout and exit
function saveLayout() {
    if (layoutMode) {
        for (var i = 0; i < temp_buffer.Input.length; i++) {
            temp_buffer.Input[i].parent.layoutProperties.x = temp_buffer.Input[i].x;
            temp_buffer.Input[i].parent.layoutProperties.y = temp_buffer.Input[i].y;
        }
        for (var i = 0; i < temp_buffer.Output.length; i++) {
            temp_buffer.Output[i].parent.layoutProperties.x = temp_buffer.Output[i].x;
            temp_buffer.Output[i].parent.layoutProperties.y = temp_buffer.Output[i].y;
        }
        globalScope.layout = Object.assign({}, temp_buffer.layout);
        toggleLayoutMode();
    }
}
