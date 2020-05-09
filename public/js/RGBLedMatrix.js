function RGBLedMatrix(
    x,
    y,
    scope = globalScope,
    {
        rows = 8,
        columns = 8,
        ledSize = 2,
        showGrid = true,
        colors = [],
    } = {},
) {
    CircuitElement.call(this, x, y, scope, 'RIGHT', 8);
    this.fixedBitWidth = true;
    this.directionFixed = true;
    this.rectangleObject = true;
    this.alwaysResolve = true;
    this.labelDirection = 'UP';
    this.leftDimensionX = 0;
    this.upDimensionY = 0;

    // These pins provide bulk-editing of the colors
    this.rowEnableNodes = []; // 1-bit pin for each row, on the left side.
    this.columnEnableNodes = []; // 1-bit pin for each column, on the bottom.
    this.columnColorNodes = []; // 24-bit pin for each column, on the top.

    // These pins provide single-pixel editing; these are on the right side.
    this.colorNode = new Node(0, -10, NODE_INPUT, this, 24, 'COLOR');
    this.rowNode = new Node(0, 0, NODE_INPUT, this, 1, 'ROW');
    this.columnNode = new Node(0, 10, NODE_INPUT, this, 1, 'COLUMN');

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
};
RGBLedMatrix.prototype.toggleGrid = function () {
    this.showGrid = !this.showGrid;
};
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

    // The dimensions of the element, in canvas units.
    var halfWidth = gridWidth / 2 + padding;
    var halfHeight = gridHeight / 2 + padding;

    // Move the element in order to keep the position of the nodes stable so wires don't break.
    if (move) {
        this.x -= this.leftDimensionX - halfWidth;
        this.y -= this.upDimensionY - halfHeight;
    }

    // Update the dimensions of the element.
    this.setDimensions(halfWidth, halfHeight);

    // Offset of the nodes in relation to the element's center.
    var nodePadding = [10, 20, 20][ledSize - 1];
    var nodeOffsetX = nodePadding - halfWidth;
    var nodeOffsetY = nodePadding - halfHeight;

    // When the led size changes it is better to delete all nodes to break connected the wires.
    // Otherwise, wires can end up connected in unexpected ways.
    var resetAllNodes = ledSize != this.ledSize;

    // Delete unused row-enable nodes, reposition remaining nodes and add new nodes.
    this.rowEnableNodes.splice(resetAllNodes ? 0 : rows).forEach(node => node.delete());
    this.rowEnableNodes.forEach((node, i) => {
        node.x = node.leftx = -halfWidth;
        node.y = node.lefty = i * ledHeight + nodeOffsetY;
    });
    while (this.rowEnableNodes.length < rows) {
        this.rowEnableNodes.push(new Node(-halfWidth, this.rowEnableNodes.length * ledHeight + nodeOffsetY, NODE_INPUT, this, 1, 'R' + this.rowEnableNodes.length));
    }

    // Delete unused column-enable nodes, reposition remaining nodes and add new nodes.
    this.columnEnableNodes.splice(resetAllNodes ? 0 : columns).forEach(node => node.delete());
    this.columnEnableNodes.forEach((node, i) => {
        node.x = node.leftx = i * ledWidth + nodeOffsetX;
        node.y = node.lefty = halfHeight;
    });
    while (this.columnEnableNodes.length < columns) {
        this.columnEnableNodes.push(new Node(this.columnEnableNodes.length * ledWidth + nodeOffsetX, halfHeight, NODE_INPUT, this, 1, 'C' + this.columnEnableNodes.length));
    }

    // Delete unused column color nodes, reposition remaining nodes and add new nodes.
    this.columnColorNodes.splice(resetAllNodes ? 0 : columns).forEach(node => node.delete());
    this.columnColorNodes.forEach((node, i) => {
        node.x = node.leftx = i * ledWidth + nodeOffsetX;
        node.y = node.lefty = -halfHeight;
    });
    while (this.columnColorNodes.length < columns) {
        this.columnColorNodes.push(new Node(this.columnColorNodes.length * ledWidth + nodeOffsetX, -halfHeight, NODE_INPUT, this, 24, 'CLR' + this.columnColorNodes.length));
    }

    // Delete unused color storage and add storage for new rows.
    this.colors.splice(rows);
    this.colors.forEach(c => c.splice(columns));
    while (this.colors.length < rows) {
        this.colors.push([]);
    }

    // Reposition the single-pixel nodes
    this.rowNode.bitWidth = Math.ceil(Math.log2(rows));
    this.rowNode.label = 'ROW (' + this.rowNode.bitWidth + ' bits)';
    this.columnNode.bitWidth = Math.ceil(Math.log2(columns));
    this.columnNode.label = 'COLUMN (' + this.columnNode.bitWidth + ' bits)';
    var singlePixelNodePadding = rows > 1 ? nodeOffsetY : nodeOffsetY - 10;
    var singlePixelNodeDistance = (rows <= 2) ? 10 : ledHeight;
    [this.colorNode, this.rowNode, this.columnNode].forEach((node, i) => {
        node.x = node.leftx = halfWidth;
        node.y = node.lefty = i * singlePixelNodeDistance + singlePixelNodePadding;
    });

    // Store the new values
    this.rows = rows;
    this.columns = columns;
    this.ledSize = ledSize;

    return this;
};
RGBLedMatrix.prototype.customSave = function () {
    // Save the size of the LED matrix.
    // Unlike a read LED matrix, we also persist the color of each pixel.
    // This allows circuit preview to show the colors at the time the simulation was saved.
    return {
        constructorParamaters: [{
            rows: this.rows,
            columns: this.columns,
            ledSize: this.ledSize,
            showGrid: this.showGrid,
            colors: this.colors
        }],
        nodes: {
            rowEnableNodes: this.rowEnableNodes.map(findNode),
            columnEnableNodes: this.columnEnableNodes.map(findNode),
            columnColorNodes: this.columnColorNodes.map(findNode),
            colorNode: findNode(this.colorNode),
            rowNode: findNode(this.rowNode),
            columnNode: findNode(this.columnNode),
        },
    }
};
RGBLedMatrix.prototype.resolve = function () {
    var colorValue = this.colorNode.value;
    var hasColorValue = colorValue != undefined;

    var rows = this.rows;
    var columns = this.columns;
    var rowEnableNodes = this.rowEnableNodes;
    var columnEnableNodes = this.columnEnableNodes;
    var columnColorNodes = this.columnColorNodes;
    var colors = this.colors;

    for (var row = 0; row < rows; row++) {
        if (rowEnableNodes[row].value === 1) {
            for (var column = 0; column < columns; column++) {
                // Method 1: set pixel by rowEnable + columnColor pins
                var columnColor = columnColorNodes[column].value;
                if (columnColor !== undefined) {
                    colors[row][column] = columnColor;
                }

                // Method 2: set pixel by rowEnable + columnEnable + color pins
                if (hasColorValue && columnEnableNodes[column].value === 1) {
                    colors[row][column] = colorValue;
                }
            }
        }
    }

    // Method 3: set pixel by write + pixel index + color pins.
    var hasRowNodeValue = this.rowNode.value != undefined || rows == 1;
    var hasColumnNodeValue = this.columnNode.value != undefined || columns == 1;
    if (hasColorValue && hasRowNodeValue && hasColumnNodeValue) {
        var rowNodeValue = this.rowNode.value || 0;
        var columnNodeValue = this.columnNode.value || 0;
        if (rowNodeValue < rows && columnNodeValue < columns) {
            colors[rowNodeValue][columnNodeValue] = colorValue;
        }
    }
};
RGBLedMatrix.prototype.customDraw = function () {
    var ctx = simulationArea.context;
    var rows = this.rows;
    var columns = this.columns;
    var colors = this.colors;
    var xx = this.x;
    var yy = this.y;
    var dir = this.direction;
    var ledWidth = 10 * this.ledSize;
    var ledHeight = 10 * this.ledSize;
    var top = this.rowEnableNodes[0].y - ledHeight / 2;
    var left = this.columnColorNodes[0].x - ledWidth / 2;
    var width = this.columns * ledWidth;
    var height = this.rows * ledHeight;
    var bottom = top + height;
    var right = left + width;

    var [w, h] = rotate(ledWidth * globalScope.scale, ledHeight * globalScope.scale, dir);
    var xoffset = Math.round(globalScope.ox + xx * globalScope.scale);
    var yoffset = Math.round(globalScope.oy + yy * globalScope.scale);
    for (var row = 0; row < rows; row++) {
        for (var column = 0; column < columns; column++) {
            var color = colors[row][column] || 0;
            ctx.beginPath();
            ctx.fillStyle = 'rgb(' + ((color & 0xFF0000) >> 16) + ',' + ((color & 0xFF00) >> 8) + ',' + (color & 0xFF) + ')';

            [x1, y1] = rotate(left + column * ledWidth, top + row * ledHeight, dir);
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
        rect2(ctx, left, top, width, height, xx, yy, dir);
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
};
