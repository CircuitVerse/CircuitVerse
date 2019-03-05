function layoutIndicator(x, y, id, label = "", xx, yy, type, parent) {

    this.type = type;
    this.id = id

    this.xx = xx; // Position of parent
    this.yy = yy; // Position of parent
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
layoutIndicator.prototype.isAllowed = function (x, y, layout) {
    if (x < 0 || x > layout.width || y < 0 || y > layout.height) return false;
    if (x > 0 && x < layout.width && y > 0 && y < layout.height) return true;
    if ((x == 0 && y == 0) || (x == 0 && y == layout.height) || (x == layout.width && y == 0) || (x == layout.width && y == layout.height)) return false;

    return true;
}
layoutIndicator.prototype.absX = function () {
    return this.x + this.xx;
}
layoutIndicator.prototype.absY = function () {
    return this.y + this.yy
}

layoutIndicator.prototype.update = function () {

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
        if (this.isAllowed(simulationArea.mouseX - this.xx, simulationArea.mouseY - this.yy, temp_buffer.layout) && !temp_buffer.isNodeAt(simulationArea.mouseX - this.xx, simulationArea.mouseY - this.yy)) {
            this.x = simulationArea.mouseX - this.xx;
            this.y = simulationArea.mouseY - this.yy;
        }
    }

}

layoutIndicator.prototype.draw = function () {
    var ctx = simulationArea.context;
    drawCircle(ctx, this.absX(), this.absY(), 5, ["green", "red"][+(simulationArea.lastSelected == this)]);
}

layoutIndicator.prototype.isHover = function () {
    return this.absX() == simulationArea.mouseX && this.absY() == simulationArea.mouseY;
}
