function RGBLedMatrix(x, y, scope = globalScope, rows = 8, columns = 8, ledSize = 2, showGrid = true, colors = []) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 8);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.rectangleObject = true;
    this.alwaysResolve = true;
    this.labelDirection = 'UP';
    this.leftDimensionX = 0;
    this.upDimensionY = 0;
    this.rowNodes = [];
    this.columnNodes = [];
    this.colors = colors;
    this.showGrid = showGrid;
    this.changeSize(rows, columns, ledSize, false);
}
RGBLedMatrix.prototype = Object.create(CircuitElement.prototype);
RGBLedMatrix.prototype.constructor = RGBLedMatrix;
RGBLedMatrix.prototype.tooltipText = 'RGB Led Matrix';

// Limit the size of the matrix otherwise the simulation starts to lag.
RGBLedMatrix.prototype.maxRows = 128;
RGBLedMatrix.prototype.maxColumns = 128;

// Let the user choose between 3 sizes of LEDs: small, medium and large.
RGBLedMatrix.prototype.maxLedSize = 3;

RGBLedMatrix.prototype.mutableProperties = {
    rows: {
        name: 'Rows',
        type: 'number',
        max: RGBLedMatrix.prototype.maxRows,
        min: 1,
        func: 'changeRows',
    },
    columns: {
        name: 'Columns',
        type: 'number',
        max: RGBLedMatrix.prototype.maxColumns,
        min: 1,
        func: 'changeColumns',
    },
    ledSize: {
        name: 'LED Size',
        type: 'number',
        max: RGBLedMatrix.prototype.maxLedSize,
        min: 1,
        func: 'changeLedSize',
    },
    showGrid: {
        name: 'Toggle Grid',
        type: 'button',
        max: RGBLedMatrix.prototype.maxLedSize,
        min: 1,
        func: 'toggleGrid',
    },
}
RGBLedMatrix.prototype.toggleGrid = function () {
    this.showGrid = !this.showGrid;
}
RGBLedMatrix.prototype.changeRows = function (rows) {
    this.changeSize(rows, this.columns, this.ledSize, true);
};
RGBLedMatrix.prototype.changeColumns = function (columns) {
    this.changeSize(this.rows, columns, this.ledSize, true);
};
RGBLedMatrix.prototype.changeLedSize = function (ledSize) {
    this.changeSize(this.rows, this.columns, ledSize, true);
};
RGBLedMatrix.prototype.changeSize = function (rows, columns, ledSize, move) {
    rows = parseInt(rows, 10);
    if (isNaN(rows) || rows < 0 || rows > this.maxRows) return;

    columns = parseInt(columns, 10);
    if (isNaN(columns) || columns < 0 || columns > this.maxColumns) return;

    ledSize = parseInt(ledSize, 10);
    if (isNaN(ledSize) || ledSize < 0 || ledSize > this.maxLedSize) return;

    // The size of an individual LED, in canvas units.
    var ledWidth = 10 * ledSize;
    var ledHeight = 10 * ledSize;

    // The size of the LED matrix, in canvas units.
    var gridWidth = ledWidth * columns;
    var gridHeight = ledHeight * rows;

    // We need to position the element in the 10x10 grid.
    // Depending on the size of the leds we need to add different paddings so position correctly.
    var padding = ledSize % 2 ? 5 : 10;

    // The dimentions of the element, in canvas units.
    var halfWidth = gridWidth / 2 + padding;
    var halfHeigth = gridHeight / 2 + padding;

    // Move the element in order to keep the position of the nodes stable so wires don't break.
    if (move) {
        this.x -= this.leftDimensionX - halfWidth;
        this.y -= this.upDimensionY - halfHeigth;
    }

    // Update the dimensions of the element.
    this.setDimensions(halfWidth, halfHeigth);

    // Offset of the nodes in relation to the element's center.
    var nodePadding = [10, 20, 20][ledSize - 1];
    var nodeOffsetX = nodePadding - halfWidth;
    var nodeOffsetY = nodePadding - halfHeigth;

    // When the led size changes it is better to delete all nodes to break connected the wires.
    // Otherwise, wires can end up connected in unexpected ways.
    var resetAllNodes = ledSize != this.ledSize;

    // Delete unused row nodes, reposition remaining nodes and add new nodes.
    this.rowNodes.splice(resetAllNodes ? 0 : rows).forEach(node => node.delete());
    this.rowNodes.forEach((node, i) => {
        node.x = node.leftx = -halfWidth;
        node.y = node.lefty = i * ledHeight + nodeOffsetY;
    });
    while (this.rowNodes.length < rows) {
        this.rowNodes.push(new Node(-halfWidth, this.rowNodes.length * ledHeight + nodeOffsetY, NODE_INPUT, this, 1, "R" + this.rowNodes.length));
    }

    // Delete unused column nodes, reposition remaining nodes and add new nodes.
    this.columnNodes.splice(resetAllNodes ? 0 : columns).forEach(node => node.delete());
    this.columnNodes.forEach((node, i) => {
        node.x = node.leftx = i * ledWidth + nodeOffsetX;
        node.y = node.lefty = -halfHeigth;
    });
    while (this.columnNodes.length < columns) {
        this.columnNodes.push(new Node(this.columnNodes.length * ledWidth + nodeOffsetX, -halfHeigth, NODE_INPUT, this, 24, "C" + this.columnNodes.length));
    }

    // Delete unused color storage and add storage for new rows.
    this.colors.splice(rows);
    this.colors.forEach(c => c.splice(columns));
    while (this.colors.length < rows) {
        this.colors.push([]);
    }

    // Store the new values
    this.rows = rows;
    this.columns = columns;
    this.ledSize = ledSize;

    return this;
}
RGBLedMatrix.prototype.customSave = function () {
    // Save the size of the LED matrix.
    // Unlike a read LED matrix, we also persist the color of each pixel.
    // This allows circuit preview to show the colors at the time the simulation was saved.
    return {
        constructorParamaters: [this.rows, this.columns, this.ledSize, this.showGrid, this.colors],
        nodes: {
            rowNodes: this.rowNodes.map(findNode),
            columnNodes: this.columnNodes.map(findNode),
        },
    }
}
RGBLedMatrix.prototype.resolve = function () {
    // Store the color of each pixel where the row is enabled and the column has a value.
    // Unlike a real LED matrix, we will not 'fade-out' a LED if it is not receiving input.
    for (var row = 0; row < this.rows; row++) {
        if (this.rowNodes[row].value === 1) {
            for (var column = 0; column < this.columns; column++) {
                if (this.columnNodes[column].value !== undefined) {
                    this.colors[row][column] = this.columnNodes[column].value;
                }
            }
        }
    }
}
RGBLedMatrix.prototype.customDraw = function () {
    var ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;
    var dir = this.direction;
    var ledWidth = 10 * this.ledSize;
    var ledHeight = 10 * this.ledSize;
    var top = this.rowNodes[0].y - ledHeight / 2;
    var left = this.columnNodes[0].x - ledWidth / 2;
    var width = this.columns * ledWidth;
    var height = this.rows * ledHeight;
    var bottom = top + height;
    var right = left + width;

    ctx.beginPath();
    ctx.strokeStyle = '#323232';
    ctx.fillStyle = 'black';
    ctx.lineWidth = correctWidth(1);
    rect2(ctx, left, top, width, height, xx, yy, dir);
    ctx.fill();
    ctx.stroke();

    var [w, h] = rotate(ledWidth * globalScope.scale, ledHeight * globalScope.scale, dir);
    var xoffset = Math.round(globalScope.ox + xx * globalScope.scale);
    var yoffset = Math.round(globalScope.oy + yy * globalScope.scale);
    for (var row = 0, y = top; y < bottom; row++ , y += ledHeight) {
        for (var column = 0, x = left; x < right; column++ , x += ledWidth) {
            var color = this.colors[row][column] || 0;
            ctx.beginPath();
            ctx.fillStyle = 'rgb(' + ((color & 0xFF0000) >> 16) + ',' + ((color & 0xFF00) >> 8) + ',' + (color & 0xFF) + ')';

            [x1, y1] = rotate(x, y, dir);
            x1 = x1 * globalScope.scale;
            y1 = y1 * globalScope.scale;
            ctx.rect(xoffset + x1, yoffset + y1, w, h);

            ctx.fill();
        }
    }

    if (this.showGrid) {
        ctx.beginPath();
        ctx.strokeStyle = '#323232';
        ctx.lineWidth = correctWidth(1);
        for (var x = left + ledWidth; x < right; x += ledWidth) {
            moveTo(ctx, x, top, xx, yy, dir);
            lineTo(ctx, x, bottom, xx, yy, dir);
        }
        for (var y = top + ledHeight; y < bottom; y += ledHeight) {
            moveTo(ctx, left, y, xx, yy, dir);
            lineTo(ctx, right, y, xx, yy, dir);
        }
        ctx.stroke();
    }
}
