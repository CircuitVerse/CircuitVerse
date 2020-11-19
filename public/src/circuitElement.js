/* eslint-disable no-multi-assign */
/* eslint-disable no-bitwise */
import { scheduleUpdate } from './engine';
import simulationArea from './simulationArea';
import {
    fixDirection, fillText, correctWidth, rect2, oppositeDirection,
} from './canvasApi';
import { colors } from './themer/themer';
import { layoutModeGet, tempBuffer } from './layoutMode';
import { fillSubcircuitElements } from './ux';
import { generateNodeName } from './verilogHelpers';

/**
 * Base class for circuit elements.
 * @param {number} x - x coordinate of the element
 * @param {number} y - y coordinate of the element
 * @param {Scope} scope - The circuit on which circuit element is being drawn
 * @param {string} dir - The direction of circuit element
 * @param {number} bitWidth - the number of bits per node.
 * @category circuitElement
 */
export default class CircuitElement {
    constructor(x, y, scope, dir, bitWidth) {
        // Data member initializations
        this.x = x;
        this.y = y;
        this.hover = false;
        if (this.x === undefined || this.y === undefined) {
            this.x = simulationArea.mouseX;
            this.y = simulationArea.mouseY;
            this.newElement = true;
            this.hover = true;
        }
        this.deleteNodesWhenDeleted = true; // FOR NOW - TO CHECK LATER
        this.nodeList = [];
        this.clicked = false;

        this.oldx = x;
        this.oldy = y;

        // The following attributes help in setting the touch area bound. They are the distances from the center.
        // Note they are all positive distances from center. They will automatically be rotated when direction is changed.
        // To stop the rotation when direction is changed, check overrideDirectionRotation attribute.
        this.leftDimensionX = 10;
        this.rightDimensionX = 10;
        this.upDimensionY = 10;
        this.downDimensionY = 10;

        this.label = '';
        this.scope = scope;
        this.baseSetup();

        this.bitWidth = bitWidth || parseInt(prompt('Enter bitWidth'), 10) || 1;
        this.direction = dir;
        this.directionFixed = false;
        this.labelDirectionFixed = false;
        this.labelDirection = oppositeDirection[dir];
        this.orientationFixed = true;
        this.fixedBitWidth = false;

        scheduleUpdate();

        this.queueProperties = {
            inQueue: false,
            time: undefined,
            index: undefined,
        };

        if (this.canShowInSubcircuit) {
        this.subcircuitMetadata = {
            showInSubcircuit: false, // if canShowInSubcircuit == true, showInSubcircuit determines wheter the user has added the element in the subcircuit
            showLabelInSubcircuit: true, // determines whether the label of the element is to be showin the subcircuit
            labelDirection: this.labelDirection, // determines the direction of the label of the element in the subcircuit
            // coordinates of the element in the subcircuit relative to the subcircuit
            x : 0,
            y : 0
        }
    }
    }

    /**
     * Function to flip bits
     * @param {number} val - the value of flipped bits
     * @returns {number} - The number of flipped bits
     */
    flipBits(val) {
        return ((~val >>> 0) << (32 - this.bitWidth)) >>> (32 - this.bitWidth);
    }

    /**
     * Function to get absolute value of x coordinate of the element
     * @param {number} x - value of x coordinate of the element
     * @return {number} - absolute value of x
     */
    absX() {
        return this.x;
    }

    /**
     * Function to get absolute value of y coordinate of the element
     * @param {number} y - value of y coordinate of the element
     * @return {number} - absolute value of y
     */
    absY() {
        return this.y;
    }

    /**
     * adds the element to scopeList
     */
    baseSetup() {
        this.scope[this.objectType].push(this);
    }

    /**
     * Function to copy the circuit element obj to a new circuit element
     * @param {CircuitElement} obj - element to be copied from
     */
    copyFrom(obj) {
        var properties = ['label', 'labelDirection'];
        for (let i = 0; i < properties.length; i++) {
            if (obj[properties[i]] !== undefined) { this[properties[i]] = obj[properties[i]]; }
        }
    }

    /** Methods to be Implemented for derivedClass
    * saveObject(); //To generate JSON-safe data that can be loaded
    * customDraw(); //This is to draw the custom design of the circuit(Optional)
    * resolve(); // To execute digital logic(Optional)
    * override isResolvable(); // custom logic for checking if module is ready
    * override newDirection(dir) //To implement custom direction logic(Optional)
    * newOrientation(dir) //To implement custom orientation logic(Optional)
    */

    // Method definitions

    /**
     * Function to update the scope when a new element is added.
     * @param {Scope} scope - the circuit in which we add element
     */
    updateScope(scope) {
        this.scope = scope;
        for (let i = 0; i < this.nodeList.length; i++) { this.nodeList[i].scope = scope; }
    }

    /**
    * To generate JSON-safe data that can be loaded
    * @memberof CircuitElement
    * @return {JSON} - the data to be saved
    */
    saveObject() {
        var data = {
            x: this.x,
            y: this.y,
            objectType: this.objectType,
            label: this.label,
            direction: this.direction,
            labelDirection: this.labelDirection,
            propagationDelay: this.propagationDelay,
            customData: this.customSave(),
        };

        if(this.canShowInSubcircuit) data.subcircuitMetadata = this.subcircuitMetadata;
        return data;
    }

    /**
    * Always overriden
    * @memberof CircuitElement
    * @return {JSON} - the data to be saved
    */
    // eslint-disable-next-line class-methods-use-this
    customSave() {
        return {
            values: {},
            nodes: {},
            constructorParamaters: [],
        };
    }

    /**
     * check hover over the element
     * @return {boolean}
     */
    checkHover() {
        if (simulationArea.mouseDown) return;
        for (let i = 0; i < this.nodeList.length; i++) {
            this.nodeList[i].checkHover();
        }
        if (!simulationArea.mouseDown) {
            if (simulationArea.hover === this) {
                this.hover = this.isHover();
                if (!this.hover) simulationArea.hover = undefined;
            } else if (!simulationArea.hover) {
                this.hover = this.isHover();
                if (this.hover) simulationArea.hover = this;
            } else {
                this.hover = false;
            }
        }
    }


    /**
     * This sets the width and height of the element if its rectangular
     * and the reference point is at the center of the object.
     * width and height define the X and Y distance from the center.
     * Effectively HALF the actual width and height.
     * NOT OVERRIDABLE
     * @param {number} w - width
     * @param {number} h - height
     */
    setDimensions(width, height) {
        this.leftDimensionX = this.rightDimensionX = width;
        this.downDimensionY = this.upDimensionY = height;
    }

    /**
    * @memberof CircuitElement
    * @param {number} w -width
    */
    setWidth(width) {
        this.leftDimensionX = this.rightDimensionX = width;
    }

    /**
     * @param {number} h -height
     */
    setHeight(height) {
        this.downDimensionY = this.upDimensionY = height;
    }

    /**
     * Helper Function to drag element to a new position
     */
    startDragging() {
        if(!layoutModeGet()){
            this.oldx = this.x;
            this.oldy = this.y;
        }
        else{
            this.oldx = this.subcircuitMetadata.x;
            this.oldy = this.subcircuitMetadata.y;
        }
    }

    /**
    * Helper Function to drag element to a new position
    * @memberof CircuitElement
    */
    drag() {
        if(!layoutModeGet()){
            this.x = this.oldx + simulationArea.mouseX - simulationArea.mouseDownX;
            this.y = this.oldy + simulationArea.mouseY - simulationArea.mouseDownY;
        }
        else{
            this.subcircuitMetadata.x = this.oldx + simulationArea.mouseX - simulationArea.mouseDownX;
            this.subcircuitMetadata.y = this.oldy + simulationArea.mouseY - simulationArea.mouseDownY;
        }
    }

    /**
     * The update method is used to change the parameters of the object on mouse click and hover.
     * Return Value: true if state has changed else false
     * NOT OVERRIDABLE
     */
    update() {
        if (layoutModeGet()) {
            return this.layoutUpdate();
        }
        let update = false;

        update |= this.newElement;
        if (this.newElement) {
            if (this.centerElement) {
                this.x = Math.round((simulationArea.mouseX - (this.rightDimensionX - this.leftDimensionX) / 2) / 10) * 10;
                this.y = Math.round((simulationArea.mouseY - (this.downDimensionY - this.upDimensionY) / 2) / 10) * 10;
            } else {
                this.x = simulationArea.mouseX;
                this.y = simulationArea.mouseY;
            }

            if (simulationArea.mouseDown) {
                this.newElement = false;
                simulationArea.lastSelected = this;
            } else return update;
        }

        for (let i = 0; i < this.nodeList.length; i++) {
            update |= this.nodeList[i].update();
        }

        if (!simulationArea.hover || simulationArea.hover === this) { this.hover = this.isHover(); }

        if (!simulationArea.mouseDown) this.hover = false;


        if ((this.clicked || !simulationArea.hover) && this.isHover()) {
            this.hover = true;
            simulationArea.hover = this;
        } else if (!simulationArea.mouseDown && this.hover && this.isHover() === false) {
            if (this.hover) simulationArea.hover = undefined;
            this.hover = false;
        }

        if (simulationArea.mouseDown && (this.clicked)) {
            this.drag();
            if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
                for (let i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                    simulationArea.multipleObjectSelections[i].drag();
                }
            }

            update |= true;
        } else if (simulationArea.mouseDown && !simulationArea.selected) {
            this.startDragging();
            if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.contains(this)) {
                for (let i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
                    simulationArea.multipleObjectSelections[i].startDragging();
                }
            }
            simulationArea.selected = this.clicked = this.hover;

            update |= this.clicked;
        } else {
            if (this.clicked) simulationArea.selected = false;
            this.clicked = false;
            this.wasClicked = false;
            // If this is SubCircuit, then call releaseClick to recursively release clicks on each subcircuit object
            if(this.objectType == "SubCircuit") this.releaseClick();
        }

        if (simulationArea.mouseDown && !this.wasClicked) {
            if (this.clicked) {
                this.wasClicked = true;
                if (this.click) this.click();
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
        }

        return update;
    }

    /**
     * Used to update the state of the elements inside the subcircuit in layout mode
     * Return Value: true if the state has changed, false otherwise
    **/

    layoutUpdate() {
        var update = false;
        update |= this.newElement;
        if (this.newElement) {
            this.subcircuitMetadata.x = simulationArea.mouseX;
            this.subcircuitMetadata.y = simulationArea.mouseY;

            if (simulationArea.mouseDown) {
                this.newElement = false;
                simulationArea.lastSelected = this;
            } else return;
        }

        if (!simulationArea.hover || simulationArea.hover == this)
            this.hover = this.isHover();

        if ((this.clicked || !simulationArea.hover) && this.isHover()) {
            this.hover = true;
            simulationArea.hover = this;
        } else if (!simulationArea.mouseDown && this.hover && this.isHover() == false) {
            if (this.hover) simulationArea.hover = undefined;
            this.hover = false;
        }

        if (simulationArea.mouseDown && (this.clicked)) {
            this.drag();
            update |= true;
        } else if (simulationArea.mouseDown && !simulationArea.selected) {
            this.startDragging();
            simulationArea.selected = this.clicked = this.hover;
            update |= this.clicked;
        } else {
            if (this.clicked) simulationArea.selected = false;
            this.clicked = false;
            this.wasClicked = false;
        }

        if (simulationArea.mouseDown && !this.wasClicked) {
            if (this.clicked) {
                this.wasClicked = true;
                simulationArea.lastSelected = this;
            }
        }

        if (!this.clicked && !this.newElement) {
            let x = this.subcircuitMetadata.x;
            let y = this.subcircuitMetadata.y; 
            let yy = tempBuffer.layout.height;
            let xx = tempBuffer.layout.width;

            let rX = this.layoutProperties.rightDimensionX;
            let lX = this.layoutProperties.leftDimensionX;
            let uY = this.layoutProperties.upDimensionY;
            let dY = this.layoutProperties.downDimensionY;

            if (lX <= x && x + rX <= xx && y >= uY && y + dY <= yy)
                return;

            this.subcircuitMetadata.showInSubcircuit = false;
            fillSubcircuitElements();
        }

        return update;
    }

    /**
     * Helper Function to correct the direction of element
     */
    fixDirection() {
        this.direction = fixDirection[this.direction] || this.direction;
        this.labelDirection = fixDirection[this.labelDirection] || this.labelDirection;
    }

    /**
     * The isHover method is used to check if the mouse is hovering over the object.
     * Return Value: true if mouse is hovering over object else false
     * NOT OVERRIDABLE
    */
    isHover() {
        var mX = simulationArea.mouseXf - this.x;
        var mY = this.y - simulationArea.mouseYf;

        var rX = this.rightDimensionX;
        var lX = this.leftDimensionX;
        var uY = this.upDimensionY;
        var dY = this.downDimensionY;

        if (layoutModeGet()) {
            var mX = simulationArea.mouseXf - this.subcircuitMetadata.x;
            var mY = this.subcircuitMetadata.y - simulationArea.mouseYf;

            var rX = this.layoutProperties.rightDimensionX;
            var lX = this.layoutProperties.leftDimensionX;
            var uY = this.layoutProperties.upDimensionY;
            var dY = this.layoutProperties.downDimensionY;
       }

        if (!this.directionFixed && !this.overrideDirectionRotation) {
            if (this.direction === 'LEFT') {
                lX = this.rightDimensionX;
                rX = this.leftDimensionX;
            } else if (this.direction === 'DOWN') {
                lX = this.downDimensionY;
                rX = this.upDimensionY;
                uY = this.leftDimensionX;
                dY = this.rightDimensionX;
            } else if (this.direction === 'UP') {
                lX = this.downDimensionY;
                rX = this.upDimensionY;
                dY = this.leftDimensionX;
                uY = this.rightDimensionX;
            }
        }

        return -lX <= mX && mX <= rX && -dY <= mY && mY <= uY;
    }

    isSubcircuitHover(xoffset = 0, yoffset = 0) {
        var mX = simulationArea.mouseXf - this.subcircuitMetadata.x - xoffset;
        var mY = yoffset + this.subcircuitMetadata.y - simulationArea.mouseYf;

        var rX = this.layoutProperties.rightDimensionX;
        var lX = this.layoutProperties.leftDimensionX;
        var uY = this.layoutProperties.upDimensionY;
        var dY = this.layoutProperties.downDimensionY;
       
        return -lX <= mX && mX <= rX && -dY <= mY && mY <= uY;
    }

    /**
    * Helper Function to set label of an element.
    * @memberof CircuitElement
    * @param {string} label - the label for element
    */
    setLabel(label) {
        this.label = label || '';
    }

    /**
     * Method that draws the outline of the module and calls draw function on module Nodes.
     * NOT OVERRIDABLE
     */
    draw() {
        //        
        var ctx = simulationArea.context;
        this.checkHover();

        if (this.x * this.scope.scale + this.scope.ox < -this.rightDimensionX * this.scope.scale - 0 || this.x * this.scope.scale + this.scope.ox > width + this.leftDimensionX * this.scope.scale + 0 || this.y * this.scope.scale + this.scope.oy < -this.downDimensionY * this.scope.scale - 0 || this.y * this.scope.scale + this.scope.oy > height + 0 + this.upDimensionY * this.scope.scale) return;

        // Draws rectangle and highlights
        if (this.rectangleObject) {
            ctx.strokeStyle = colors['stroke'];
            ctx.fillStyle = colors['fill'];
            ctx.lineWidth = correctWidth(3);
            ctx.beginPath();
            rect2(ctx, -this.leftDimensionX, -this.upDimensionY, this.leftDimensionX + this.rightDimensionX, this.upDimensionY + this.downDimensionY, this.x, this.y, [this.direction, 'RIGHT'][+this.directionFixed]);
            if ((this.hover && !simulationArea.shiftDown) || simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) ctx.fillStyle = colors["hover_select"];
            ctx.fill();
            ctx.stroke();
        }
        if (this.label !== '') {
            var rX = this.rightDimensionX;
            var lX = this.leftDimensionX;
            var uY = this.upDimensionY;
            var dY = this.downDimensionY;
            if (!this.directionFixed) {
                if (this.direction === 'LEFT') {
                    lX = this.rightDimensionX;
                    rX = this.leftDimensionX;
                } else if (this.direction === 'DOWN') {
                    lX = this.downDimensionY;
                    rX = this.upDimensionY;
                    uY = this.leftDimensionX;
                    dY = this.rightDimensionX;
                } else if (this.direction === 'UP') {
                    lX = this.downDimensionY;
                    rX = this.upDimensionY;
                    dY = this.leftDimensionX;
                    uY = this.rightDimensionX;
                }
            }

            if (this.labelDirection === 'LEFT') {
                ctx.beginPath();
                ctx.textAlign = 'right';
                ctx.fillStyle = colors['text'];
                fillText(ctx, this.label, this.x - lX - 10, this.y + 5, 14);
                ctx.fill();
            } else if (this.labelDirection === 'RIGHT') {
                ctx.beginPath();
                ctx.textAlign = 'left';
                ctx.fillStyle = colors['text'];
                fillText(ctx, this.label, this.x + rX + 10, this.y + 5, 14);
                ctx.fill();
            } else if (this.labelDirection === 'UP') {
                ctx.beginPath();
                ctx.textAlign = 'center';
                ctx.fillStyle = colors['text'];
                fillText(ctx, this.label, this.x, this.y + 5 - uY - 10, 14);
                ctx.fill();
            } else if (this.labelDirection === 'DOWN') {
                ctx.beginPath();
                ctx.textAlign = 'center';
                ctx.fillStyle = colors['text'];
                fillText(ctx, this.label, this.x, this.y + 5 + dY + 10, 14);
                ctx.fill();
            }
        }

        // calls the custom circuit design
        if (this.customDraw) { this.customDraw(); }

        // draws nodes - Moved to renderCanvas
        // for (let i = 0; i < this.nodeList.length; i++)
        //     this.nodeList[i].draw();
    }

    /**
        Draws element in layout mode (inside the subcircuit)
        @param {number} xOffset - x position of the subcircuit
        @param {number} yOffset - y position of the subcircuit 

        Called by subcirucit.js/customDraw() - for drawing as a part of another circuit
        and layoutMode.js/renderLayout() -  for drawing in layoutMode
    **/
    drawLayoutMode(xOffset = 0, yOffset = 0){
        var ctx = simulationArea.context;
        if(layoutModeGet()) {
            this.checkHover();
        }
        if (this.subcircuitMetadata.x * this.scope.scale + this.scope.ox < -this.layoutProperties.rightDimensionX * this.scope.scale  || this.subcircuitMetadata.x * this.scope.scale + this.scope.ox > width + this.layoutProperties.leftDimensionX * this.scope.scale  || this.subcircuitMetadata.y * this.scope.scale + this.scope.oy < -this.layoutProperties.downDimensionY * this.scope.scale  || this.subcircuitMetadata.y * this.scope.scale + this.scope.oy > height + this.layoutProperties.upDimensionY * this.scope.scale) return;

        if (this.subcircuitMetadata.showLabelInSubcircuit) {
            var rX = this.layoutProperties.rightDimensionX;
            var lX = this.layoutProperties.leftDimensionX;
            var uY = this.layoutProperties.upDimensionY;
            var dY = this.layoutProperties.downDimensionY;

            // this.subcircuitMetadata.labelDirection
            if (this.subcircuitMetadata.labelDirection == "LEFT") {
                ctx.beginPath();
                ctx.textAlign = "right";
                ctx.fillStyle = "black";
                fillText(ctx, this.label, this.subcircuitMetadata.x + xOffset - lX - 10, this.subcircuitMetadata.y + yOffset + 5, 10);
                ctx.fill();
            } else if (this.subcircuitMetadata.labelDirection == "RIGHT") {
                ctx.beginPath();
                ctx.textAlign = "left";
                ctx.fillStyle = "black";
                fillText(ctx, this.label, this.subcircuitMetadata.x + xOffset + rX + 10, this.subcircuitMetadata.y + yOffset + 5, 10);
                ctx.fill();
            } else if (this.subcircuitMetadata.labelDirection == "UP") {
                ctx.beginPath();
                ctx.textAlign = "center";
                ctx.fillStyle = "black";
                fillText(ctx, this.label, this.subcircuitMetadata.x + xOffset, this.subcircuitMetadata.y + yOffset + 5 - uY - 10, 10);
                ctx.fill();
            } else if (this.subcircuitMetadata.labelDirection == "DOWN") {
                ctx.beginPath();
                ctx.textAlign = "center";
                ctx.fillStyle = "black";
                fillText(ctx, this.label, this.subcircuitMetadata.x + xOffset, this.subcircuitMetadata.y + yOffset + 5 + dY + 10, 10);
                ctx.fill();
            }
        }
        // calls the subcircuitDraw function in the element to draw it to canvas
        this.subcircuitDraw(xOffset, yOffset);
    }

    // method to delete object
    // OVERRIDE WITH CAUTION
    delete() {
        simulationArea.lastSelected = undefined;
        this.scope[this.objectType].clean(this); // CHECK IF THIS IS VALID
        if (this.deleteNodesWhenDeleted) { this.deleteNodes(); } else {
            for (let i = 0; i < this.nodeList.length; i++) {
                if (this.nodeList[i].connections.length) { this.nodeList[i].converToIntermediate(); } else { this.nodeList[i].delete(); }
            }
        }
        this.deleted = true;
    }

    /**
    * method to delete object
    * OVERRIDE WITH CAUTION
    * @memberof CircuitElement
    */
    cleanDelete() {
        this.deleteNodesWhenDeleted = true;
        this.delete();
    }

    /**
     * Helper Function to delete the element and all the node attached to it.
     */
    deleteNodes() {
        for (let i = 0; i < this.nodeList.length; i++) { this.nodeList[i].delete(); }
    }

    /**
     * method to change direction
     * OVERRIDE WITH CAUTION
     * @param {string} dir - new direction
     */
    newDirection(dir) {
        if (this.direction === dir) return;
        // Leave this for now
        if (this.directionFixed && this.orientationFixed) return;
        if (this.directionFixed) {
            this.newOrientation(dir);
            return; // Should it return ?
        }

        // if (obj.direction === undefined) return;
        this.direction = dir;
        for (let i = 0; i < this.nodeList.length; i++) {
            this.nodeList[i].refresh();
        }
    }

    /**
    * Helper Function to change label direction of the element.
    * @memberof CircuitElement
    * @param {string} dir - new direction
    */
    newLabelDirection(dir) {
        if(layoutModeGet()) this.subcircuitMetadata.labelDirection = dir;
        else this.labelDirection = dir;
    }

    /**
     * Method to check if object can be resolved
     * OVERRIDE if necessary
     * @return {boolean}
     */
    isResolvable() {
        if (this.alwaysResolve) return true;
        for (let i = 0; i < this.nodeList.length; i++) { if (this.nodeList[i].type === 0 && this.nodeList[i].value === undefined) return false; }
        return true;
    }


    /**
     * Method to change object Bitwidth
     * OVERRIDE if necessary
     * @param {number} bitWidth - new bitwidth
     */
    newBitWidth(bitWidth) {
        if (this.fixedBitWidth) return;
        if (this.bitWidth === undefined) return;
        if (this.bitWidth < 1) return;
        this.bitWidth = bitWidth;
        for (let i = 0; i < this.nodeList.length; i++) { this.nodeList[i].bitWidth = bitWidth; }
    }

    /**
     * Method to change object delay
     * OVERRIDE if necessary
     * @param {number} delay - new delay
     */
    changePropagationDelay(delay) {
        if (this.propagationDelayFixed) return;
        if (delay === undefined) return;
        if (delay === '') return;
        var tmpDelay = parseInt(delay, 10);
        if (tmpDelay < 0) return;
        this.propagationDelay = tmpDelay;
    }

    /**
    * Dummy resolve function
    * OVERRIDE if necessary
    */
    resolve() {

    }

    /**
    * Helper Function to process verilog
    */
   processVerilog(){
        // Output count used to sanitize output
        var output_total = 0;
        for (var i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].type == NODE_OUTPUT && this.nodeList[i].connections.length > 0)
            output_total++;
        }

        var output_count = 0;
        for (var i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].type == NODE_OUTPUT) {
                if (this.objectType != "Input" && this.objectType != "Clock" && this.nodeList[i].connections.length > 0) {
                    this.nodeList[i].verilogLabel =
                        generateNodeName(this.nodeList[i], output_count, output_total);

                    if (!this.scope.verilogWireList[this.nodeList[i].bitWidth].contains(this.nodeList[i].verilogLabel))
                        this.scope.verilogWireList[this.nodeList[i].bitWidth].push(this.nodeList[i].verilogLabel);
                    output_count++;
                }
                this.scope.stack.push(this.nodeList[i]);
            }
        }
    }

    /**
    * Helper Function to check if verilog resolvable
    * @return {boolean}
    */
    isVerilogResolvable() {
        var backupValues = [];
        for (let i = 0; i < this.nodeList.length; i++) {
            backupValues.push(this.nodeList[i].value);
            this.nodeList[i].value = undefined;
        }

        for (let i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].verilogLabel) {
                this.nodeList[i].value = 1;
            }
        }

        var res = this.isResolvable();

        for (let i = 0; i < this.nodeList.length; i++) {
            this.nodeList[i].value = backupValues[i];
        }

        return res;
    }

    /**
    * Helper Function to remove proporgation.
    */
    removePropagation() {
        for (let i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].type === NODE_OUTPUT) {
                if (this.nodeList[i].value !== undefined) {
                    this.nodeList[i].value = undefined;
                    simulationArea.simulationQueue.add(this.nodeList[i]);
                }
            }
        }
    }

    /**
    * Helper Function to name the verilog.
    * @return {string}
    */
    verilogName() {
        return this.verilogType || this.objectType;
    }

    verilogBaseType() {
        return this.verilogName();
    }

    verilogParametrizedType() {
        var type = this.verilogBaseType();
        // Suffix bitwidth for multi-bit inputs
        // Example: DflipFlop #(2) DflipFlop_0
        if (this.bitWidth != undefined && this.bitWidth > 1)
            type += " #(" + this.bitWidth + ")";
        return type
    }

    /**
    * Helper Function to generate verilog
    * @return {JSON}
    */
    generateVerilog() {
        // Example: and and_1(_out, _out, _Q[0]);
        var inputs = [];
        var outputs = [];

        for (var i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].type == NODE_INPUT) {
                inputs.push(this.nodeList[i]);
            } else {
                if (this.nodeList[i].connections.length > 0)
                    outputs.push(this.nodeList[i]);
                else
                    outputs.push(""); // Don't create a wire
            }
        }

        var list = outputs.concat(inputs);
        var res = this.verilogParametrizedType();
        var moduleParams = list.map(x => x.verilogLabel).join(", ");
        res += ` ${this.verilogLabel}(${moduleParams});`;
        return res;
    }

    /**
     * Toggles the visibility of the labels of subcircuit elements. Called by event handlers in ux.js
    **/
    toggleLabelInLayoutMode(){
        this.subcircuitMetadata.showLabelInSubcircuit = !this.subcircuitMetadata.showLabelInSubcircuit;
    }

}

CircuitElement.prototype.alwaysResolve = false;
CircuitElement.prototype.propagationDelay = 10;
CircuitElement.prototype.tooltip = undefined;
CircuitElement.prototype.propagationDelayFixed = false;
CircuitElement.prototype.rectangleObject = true;
CircuitElement.prototype.objectType = 'CircuitElement';
CircuitElement.prototype.canShowInSubcircuit = false; // determines whether the element is supported to be shown inside a subcircuit
CircuitElement.prototype.subcircuitMetadata = {}; // stores the coordinates and stuff for the elements in the subcircuit
CircuitElement.prototype.layoutProperties = {
    rightDimensionX : 5,
    leftDimensionX : 5,
    upDimensionY : 5,
    downDimensionY: 5
};
CircuitElement.prototype.subcircuitMutableProperties = {
    "label": {
        name: "label: ",
        type: "text",
        func: "setLabel"
    },
    "show label": {
        name: "show label ",
        type: "checkbox",
        func: "toggleLabelInLayoutMode"
    }
};
