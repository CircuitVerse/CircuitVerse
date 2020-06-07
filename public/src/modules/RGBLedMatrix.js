import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import {
    correctWidth, rect2, rotate, lineTo, moveTo,
} from '../canvasApi';

/**
 * @class
 * RGBLedMatrix
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} rows - number of rows
 * @param {number=} cols - number of columns.
 * @category modules
 */
export default class RGBLedMatrix extends CircuitElement {
    constructor(
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
        super(x, y, scope, 'RIGHT', 8);
        /* this is done in this.baseSetup() now
        this.scope['RGBLedMatrix'].push(this);
        */
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

    toggleGrid() {
        this.showGrid = !this.showGrid;
    }

    changeRows(rows) {
        this.changeSize(rows, this.columns, this.ledSize, true);
    }

    changeColumns(columns) {
        this.changeSize(this.rows, columns, this.ledSize, true);
    }

    changeLedSize(ledSize) {
        this.changeSize(this.rows, this.columns, ledSize, true);
    }

    changeSize(rows, columns, ledSize, move) {
        rows = parseInt(rows, 10);
        if (isNaN(rows) || rows < 0 || rows > this.maxRows) return;

        columns = parseInt(columns, 10);
        if (isNaN(columns) || columns < 0 || columns > this.maxColumns) return;

        ledSize = parseInt(ledSize, 10);
        if (isNaN(ledSize) || ledSize < 0 || ledSize > this.maxLedSize) return;

        // The size of an individual LED, in canvas units.
        const ledWidth = 10 * ledSize;
        const ledHeight = 10 * ledSize;

        // The size of the LED matrix, in canvas units.
        const gridWidth = ledWidth * columns;
        const gridHeight = ledHeight * rows;

        // We need to position the element in the 10x10 grid.
        // Depending on the size of the leds we need to add different paddings so position correctly.
        const padding = ledSize % 2 ? 5 : 10;

        // The dimensions of the element, in canvas units.
        const halfWidth = gridWidth / 2 + padding;
        const halfHeight = gridHeight / 2 + padding;

        // Move the element in order to keep the position of the nodes stable so wires don't break.
        if (move) {
            this.x -= this.leftDimensionX - halfWidth;
            this.y -= this.upDimensionY - halfHeight;
        }

        // Update the dimensions of the element.
        this.setDimensions(halfWidth, halfHeight);

        // Offset of the nodes in relation to the element's center.
        const nodePadding = [10, 20, 20][ledSize - 1];
        const nodeOffsetX = nodePadding - halfWidth;
        const nodeOffsetY = nodePadding - halfHeight;

        // When the led size changes it is better to delete all nodes to break connected the wires.
        // Otherwise, wires can end up connected in unexpected ways.
        const resetAllNodes = ledSize != this.ledSize;

        // Delete unused row-enable nodes, reposition remaining nodes and add new nodes.
        this.rowEnableNodes.splice(resetAllNodes ? 0 : rows).forEach((node) => node.delete());
        this.rowEnableNodes.forEach((node, i) => {
            node.x = node.leftx = -halfWidth;
            node.y = node.lefty = i * ledHeight + nodeOffsetY;
        });
        while (this.rowEnableNodes.length < rows) {
            this.rowEnableNodes.push(new Node(-halfWidth, this.rowEnableNodes.length * ledHeight + nodeOffsetY, NODE_INPUT, this, 1, `R${this.rowEnableNodes.length}`));
        }

        // Delete unused column-enable nodes, reposition remaining nodes and add new nodes.
        this.columnEnableNodes.splice(resetAllNodes ? 0 : columns).forEach((node) => node.delete());
        this.columnEnableNodes.forEach((node, i) => {
            node.x = node.leftx = i * ledWidth + nodeOffsetX;
            node.y = node.lefty = halfHeight;
        });
        while (this.columnEnableNodes.length < columns) {
            this.columnEnableNodes.push(new Node(this.columnEnableNodes.length * ledWidth + nodeOffsetX, halfHeight, NODE_INPUT, this, 1, `C${this.columnEnableNodes.length}`));
        }

        // Delete unused column color nodes, reposition remaining nodes and add new nodes.
        this.columnColorNodes.splice(resetAllNodes ? 0 : columns).forEach((node) => node.delete());
        this.columnColorNodes.forEach((node, i) => {
            node.x = node.leftx = i * ledWidth + nodeOffsetX;
            node.y = node.lefty = -halfHeight;
        });
        while (this.columnColorNodes.length < columns) {
            this.columnColorNodes.push(new Node(this.columnColorNodes.length * ledWidth + nodeOffsetX, -halfHeight, NODE_INPUT, this, 24, `CLR${this.columnColorNodes.length}`));
        }

        // Delete unused color storage and add storage for new rows.
        this.colors.splice(rows);
        this.colors.forEach((c) => c.splice(columns));
        while (this.colors.length < rows) {
            this.colors.push([]);
        }

        // Reposition the single-pixel nodes
        this.rowNode.bitWidth = Math.ceil(Math.log2(rows));
        this.rowNode.label = `ROW (${this.rowNode.bitWidth} bits)`;
        this.columnNode.bitWidth = Math.ceil(Math.log2(columns));
        this.columnNode.label = `COLUMN (${this.columnNode.bitWidth} bits)`;
        const singlePixelNodePadding = rows > 1 ? nodeOffsetY : nodeOffsetY - 10;
        const singlePixelNodeDistance = (rows <= 2) ? 10 : ledHeight;
        [this.colorNode, this.rowNode, this.columnNode].forEach((node, i) => {
            node.x = node.leftx = halfWidth;
            node.y = node.lefty = i * singlePixelNodeDistance + singlePixelNodePadding;
        });

        // Store the new values
        this.rows = rows;
        this.columns = columns;
        this.ledSize = ledSize;

        return this;
    }

    customSave() {
        // Save the size of the LED matrix.
        // Unlike a read LED matrix, we also persist the color of each pixel.
        // This allows circuit preview to show the colors at the time the simulation was saved.
        return {
            constructorParamaters: [{
                rows: this.rows,
                columns: this.columns,
                ledSize: this.ledSize,
                showGrid: this.showGrid,
                colors: this.colors,
            }],
            nodes: {
                rowEnableNodes: this.rowEnableNodes.map(findNode),
                columnEnableNodes: this.columnEnableNodes.map(findNode),
                columnColorNodes: this.columnColorNodes.map(findNode),
                colorNode: findNode(this.colorNode),
                rowNode: findNode(this.rowNode),
                columnNode: findNode(this.columnNode),
            },
        };
    }

    resolve() {
        const colorValue = this.colorNode.value;
        const hasColorValue = colorValue != undefined;

        const { rows } = this;
        const { columns } = this;
        const { rowEnableNodes } = this;
        const { columnEnableNodes } = this;
        const { columnColorNodes } = this;
        const { colors } = this;

        for (let row = 0; row < rows; row++) {
            if (rowEnableNodes[row].value === 1) {
                for (let column = 0; column < columns; column++) {
                    // Method 1: set pixel by rowEnable + columnColor pins
                    const columnColor = columnColorNodes[column].value;
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
        const hasRowNodeValue = this.rowNode.value != undefined || rows == 1;
        const hasColumnNodeValue = this.columnNode.value != undefined || columns == 1;
        if (hasColorValue && hasRowNodeValue && hasColumnNodeValue) {
            const rowNodeValue = this.rowNode.value || 0;
            const columnNodeValue = this.columnNode.value || 0;
            if (rowNodeValue < rows && columnNodeValue < columns) {
                colors[rowNodeValue][columnNodeValue] = colorValue;
            }
        }
    }

    customDraw() {
        const ctx = simulationArea.context;
        const { rows } = this;
        const { columns } = this;
        const { colors } = this;
        const xx = this.x;
        const yy = this.y;
        const dir = this.direction;
        const ledWidth = 10 * this.ledSize;
        const ledHeight = 10 * this.ledSize;
        const top = this.rowEnableNodes[0].y - ledHeight / 2;
        const left = this.columnColorNodes[0].x - ledWidth / 2;
        const width = this.columns * ledWidth;
        const height = this.rows * ledHeight;
        const bottom = top + height;
        const right = left + width;

        const [w, h] = rotate(ledWidth * globalScope.scale, ledHeight * globalScope.scale, dir);
        const xoffset = Math.round(globalScope.ox + xx * globalScope.scale);
        const yoffset = Math.round(globalScope.oy + yy * globalScope.scale);
        for (let row = 0; row < rows; row++) {
            for (let column = 0; column < columns; column++) {
                const color = colors[row][column] || 0;
                ctx.beginPath();
                ctx.fillStyle = `rgb(${(color & 0xFF0000) >> 16},${(color & 0xFF00) >> 8},${color & 0xFF})`;
                let x1; let
                    y1;
                [x1, y1] = rotate(left + column * ledWidth, top + row * ledHeight, dir);
                x1 *= globalScope.scale;
                y1 *= globalScope.scale;
                ctx.rect(xoffset + x1, yoffset + y1, w, h);
                ctx.fill();
            }
        }

        if (this.showGrid) {
            ctx.beginPath();
            ctx.strokeStyle = '#323232';
            ctx.lineWidth = correctWidth(1);
            rect2(ctx, left, top, width, height, xx, yy, dir);
            for (let x = left + ledWidth; x < right; x += ledWidth) {
                moveTo(ctx, x, top, xx, yy, dir);
                lineTo(ctx, x, bottom, xx, yy, dir);
            }
            for (let y = top + ledHeight; y < bottom; y += ledHeight) {
                moveTo(ctx, left, y, xx, yy, dir);
                lineTo(ctx, right, y, xx, yy, dir);
            }
            ctx.stroke();
        }
    }
}

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
}; RGBLedMatrix.prototype.objectType = 'RGBLedMatrix';
