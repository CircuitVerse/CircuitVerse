/* eslint-disable no-multi-assign */
/* eslint-disable no-bitwise */
/* eslint-disable */
import { scheduleUpdate } from './engine';
import simulationArea from './simulationArea';
import {
    fixDirection, fillText, correctWidth, rect2, oppositeDirection,
} from './canvasApi';
import { colors } from './themer/themer';
import { layoutModeGet, tempBuffer } from './layoutMode';
import { fillSubcircuitElements } from './ux';
import { generateNodeName } from './verilogHelpers';
import { generateSTDType, generatePortsIO, generateComponentHeader, removeDuplicateComponent, generateHeaderPortmap, generatePortMapIOS, generateSpacings, hasComponent, generatePortsIOPriorityEnc} from './helperVHDL';
import { scopeList } from './circuit';

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
    checkHover () {
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
        var mX = simulationArea.touch ? simulationArea.mouseDownX - this.x : simulationArea.mouseXf - this.x;
        var mY = simulationArea.touch ? this.y - simulationArea.mouseDownY : this.y - simulationArea.mouseYf;

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
     * Sets isValueUpstream for all output nodes of the
     * element.
     * */
    setOutputsUpstream(bool) {
        for (let i = 0; i < this.nodeList.length; i++) {
            if (this.nodeList[i].type === NODE_OUTPUT) {
                this.nodeList[i].isValueUpstream = bool;
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

    generateVHDL() {
        // // Example: and and_1(_out, _out, _Q[0]);
        const mux = this.scope.Multiplexer;
        const demux = this.scope.Demultiplexer;
        const decoder = this.scope.Decoder;
        const dlatch = this.scope.Dlatch;
        const dflipflop = this.scope.DflipFlop;
        const tflipflop = this.scope.TflipFlop;
        const jkflipflop = this.scope.JKflipFlop;
        const srflipflop = this.scope.SRflipFlop;
        const msb = this.scope.MSB;
        const lsb = this.scope.LSB;
        const priorityEncoder = this.scope.PriorityEncoder;
        let element = '';
        

        if(hasComponent(mux)){
            let objmux = []
            for(var i = 0; i < mux.length; i++){
                objmux = [...objmux, {
                    header: generateComponentHeader('Mux', `bit${mux[i].bitWidth}sel${mux[i].controlSignalSize}`),
                    portsin: generateSpacings(2) + generatePortsIO('in', mux[i].controlSignalSize),
                    stdin: generateSTDType('IN', mux[i].bitWidth) + ';\n',
                    portsel: generateSpacings(2) + generatePortsIO('sel', 0),
                    stdsel: generateSTDType('IN', mux[i].controlSignalSize) + ';\n',
                    portsout: generateSpacings(2) + generatePortsIO('x', 0),
                    stdout: generateSTDType('OUT', mux[i].bitWidth) + '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${mux[i].bitWidth}sel${mux[i].controlSignalSize}`
                }]
            }
            const muxFiltered = removeDuplicateComponent(objmux)
            muxFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsel + el.stdsel + el.portsout + el.stdout + el.end)
        }
        
        if(hasComponent(demux)){
            let objdemux = []
            for(var i = 0; i < demux.length; i++){
                objdemux = [...objdemux, {
                    header: generateComponentHeader('Demux', `bit${demux[i].bitWidth}sel${demux[i].controlSignalSize}`),
                    portsin: generateSpacings(2) + generatePortsIO('in0', 0),
                    stdin: generateSTDType('IN', demux[i].bitWidth) + ';\n',
                    portsel: generateSpacings(2) + generatePortsIO('sel', 0),
                    stdsel: generateSTDType('IN', demux[i].controlSignalSize)+ ';\n',
                    portsout: generateSpacings(2) + generatePortsIO('out', demux[i].controlSignalSize),
                    stdout: generateSTDType('OUT', demux[i].bitWidth)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${demux[i].bitWidth}sel${demux[i].controlSignalSize}`,
                    
                }]
            }
            const demuxFiltered = removeDuplicateComponent(objdemux)
            demuxFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsel + el.stdsel + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(decoder)){
            let objdecoder = []
            for(var i = 0; i < decoder.length; i++){
                objdecoder = [...objdecoder, 
                {
                    header: generateComponentHeader('Decoder', `bit${decoder[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('in0', 0),
                    stdin: generateSTDType('IN', decoder[i].bitWidth) + ';\n',
                    portsout: generateSpacings(2) + generatePortsIO('out', decoder[i].bitWidth),
                    stdout: generateSTDType('OUT', 1)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${decoder[i].bitWidth}`,
                }]
            }
            const decoderFiltered = removeDuplicateComponent(objdecoder)
            decoderFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(dlatch)){
            let objdlatch = []
            for(var i = 0; i < dlatch.length; i++){
                objdlatch = [...objdlatch, 
                {
                    header: generateComponentHeader('Dlatch', `bit${dlatch[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('in0', 0),
                    stdin: generateSTDType('IN', dlatch[i].bitWidth) + ';\n',
                    portsclock: generateSpacings(2) + generatePortsIO('clock', 0),
                    stdclock: generateSTDType('IN', 1) + ';\n',
                    portsout: generateSpacings(2) + generatePortsIO('q', 1),
                    stdout: generateSTDType('OUT', dlatch[i].bitWidth)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${dlatch[i].bitWidth}`,
                }]
            }
            const dlatchFiltered = removeDuplicateComponent(objdlatch)
            dlatchFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsclock + el.stdclock + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(dflipflop)){
            let objdflipflop = []
            for(var i = 0; i < dflipflop.length; i++){
                objdflipflop = [...objdflipflop, 
                {
                    header: generateComponentHeader('DFlipFlop', `bit${dflipflop[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('inp', 0),
                    stdin: generateSTDType('IN', dflipflop[i].bitWidth) + ';\n',
                    portsclock: generateSpacings(2) + generatePortsIO('clock', 0),
                    stdclock: generateSTDType('IN', 1) + ';',
                    
                    portsenable: hasComponent(dflipflop[i].en.connections) ? '\n' + generateSpacings(2) + generatePortsIO('enable', 0) : '',
                    stdenable: hasComponent(dflipflop[i].en.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsreset: hasComponent(dflipflop[i].reset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('reset', 0) : '',
                    stdreset: hasComponent(dflipflop[i].reset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portspreset: hasComponent(dflipflop[i].preset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('preset', 0) : '',
                    stdpreset: hasComponent(dflipflop[i].preset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsout: '\n' + generateSpacings(2) + generatePortsIO('q', 1),
                    stdout: generateSTDType('OUT', dflipflop[i].bitWidth)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${dflipflop[i].bitWidth}`,
                }]
            }
            const dflipflopFiltered = removeDuplicateComponent(objdflipflop)
            dflipflopFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsclock + el.stdclock + el.portsenable + el.stdenable + el.portsreset + el.stdreset + el.portspreset + el.stdpreset + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(tflipflop)){
            let objtflipflop = []
            for(var i = 0; i < tflipflop.length; i++){
                objtflipflop = [...objtflipflop, 
                {
                    header: generateComponentHeader('Tflipflop', `bit${tflipflop[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('inp', 0),
                    stdin: generateSTDType('IN', tflipflop[i].bitWidth) + ';\n',
                    portsclock: generateSpacings(2) + generatePortsIO('clock', 0),
                    stdclock: generateSTDType('IN', 1) + ';',
                    
                    portsenable: hasComponent(tflipflop[i].en.connections) ? '\n' + generateSpacings(2) + generatePortsIO('enable', 0) : '',
                    stdenable: hasComponent(tflipflop[i].en.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsreset: hasComponent(tflipflop[i].reset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('reset', 0) : '',
                    stdreset: hasComponent(tflipflop[i].reset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portspreset: hasComponent(tflipflop[i].preset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('preset', 0) : '',
                    stdpreset: hasComponent(tflipflop[i].preset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsout: '\n' + generateSpacings(2) + generatePortsIO('q', 1),
                    stdout: generateSTDType('OUT', tflipflop[i].bitWidth)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${tflipflop[i].bitWidth}`,
                }]
            }
            const tflipflopFiltered = removeDuplicateComponent(objtflipflop)
            tflipflopFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsclock + el.stdclock + el.portsenable + el.stdenable + el.portsreset + el.stdreset + el.portspreset + el.stdpreset + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(jkflipflop)){
            let objjkflipflop = []
            for(var i = 0; i < jkflipflop.length; i++){
                objjkflipflop = [...objjkflipflop, 
                {
                    header: generateComponentHeader('JKFlipFlop', `bit${jkflipflop[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('J, K', 0),
                    stdin: generateSTDType('IN', jkflipflop[i].bitWidth) + ';\n',
                    portsclock: generateSpacings(2) + generatePortsIO('clock', 0),
                    stdclock: generateSTDType('IN', 1) + ';',
                    
                    portsenable: hasComponent(jkflipflop[i].en.connections) ? '\n' + generateSpacings(2) + generatePortsIO('enable', 0) : '',
                    stdenable: hasComponent(jkflipflop[i].en.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsreset: hasComponent(jkflipflop[i].reset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('reset', 0) : '',
                    stdreset: hasComponent(jkflipflop[i].reset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portspreset: hasComponent(jkflipflop[i].preset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('preset', 0) : '',
                    stdpreset: hasComponent(jkflipflop[i].preset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsout: '\n' + generateSpacings(2) + generatePortsIO('q', 1),
                    stdout: generateSTDType('OUT', jkflipflop[i].bitWidth)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${jkflipflop[i].bitWidth}`,
                }]
            }
            const jkflipflopFiltered = removeDuplicateComponent(objjkflipflop)
            jkflipflopFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsclock + el.stdclock + el.portsenable + el.stdenable + el.portsreset + el.stdreset + el.portspreset + el.stdpreset + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(srflipflop)){
            let objsrflipflop = []
            for(var i = 0; i < srflipflop.length; i++){
                objsrflipflop = [...objsrflipflop, 
                {
                    header: generateComponentHeader('SRFlipFlop', `bit${srflipflop[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('S, R', 0),
                    stdin: generateSTDType('IN', srflipflop[i].bitWidth) + ';\n',
                    
                    portsenable: hasComponent(srflipflop[i].en.connections) ? '\n' + generateSpacings(2) + generatePortsIO('enable', 0) : '',
                    stdenable: hasComponent(srflipflop[i].en.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsreset: hasComponent(srflipflop[i].reset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('reset', 0) : '',
                    stdreset: hasComponent(srflipflop[i].reset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portspreset: hasComponent(srflipflop[i].preset.connections) ? '\n' + generateSpacings(2) + generatePortsIO('preset', 0) : '',
                    stdpreset: hasComponent(srflipflop[i].preset.connections) ? generateSTDType('IN', 1) + ';' : '',
                    
                    portsout: '\n' + generateSpacings(2) + generatePortsIO('q', 1),
                    stdout: generateSTDType('OUT', srflipflop[i].bitWidth)+ '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${srflipflop[i].bitWidth}`,
                }]
            }
            const srflipflopFiltered = removeDuplicateComponent(objsrflipflop)
            srflipflopFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portsenable + el.stdenable + el.portsreset + el.stdreset + el.portspreset + el.stdpreset + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(msb)){
            let objmsb = []
            for(var i = 0; i < msb.length; i++){
                objmsb = [...objmsb, 
                {
                    header: generateComponentHeader('MSB', `bit${msb[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('inp', 0),
                    stdin: generateSTDType('IN', msb[i].bitWidth) + ';\n',
                    portenabled: generateSpacings(2) + generatePortsIO('enabled', 0),
                    stdenabled: generateSTDType('OUT', 1) + ';\n',
                    portsout: generateSpacings(2) + generatePortsIO('out1', 0),
                    stdout: generateSTDType('OUT', msb[i].bitWidth) + '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${msb[i].bitWidth}`,
                }]
            }
            const msbFiltered = removeDuplicateComponent(objmsb)
            msbFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portenabled + el.stdenabled + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(lsb)){
            let objlsb = []
            for(var i = 0; i < lsb.length; i++){
                objlsb = [...objlsb, 
                {
                    header: generateComponentHeader('LSB', `bit${lsb[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('inp', 0),
                    stdin: generateSTDType('IN', lsb[i].bitWidth) + ';\n',
                    portenabled: generateSpacings(2) + generatePortsIO('enabled', 0),
                    stdenabled: generateSTDType('IN', 1) + ';\n',
                    portsout: generateSpacings(2) + generatePortsIO('out1', 0),
                    stdout: generateSTDType('OUT', lsb[i].bitWidth) + '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${lsb[i].bitWidth}`,
                }]
            }
            const lsbFiltered = removeDuplicateComponent(objlsb)
            lsbFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portenabled + el.stdenabled + el.portsout + el.stdout + el.end)
        }

        if(hasComponent(priorityEncoder)){
            let objpriorityEncoder = []
            for(var i = 0; i < priorityEncoder.length; i++){
                objpriorityEncoder = [...objpriorityEncoder, 
                {
                    header: generateComponentHeader('PriorityEncoder', `bit${priorityEncoder[i].bitWidth}`),
                    portsin: generateSpacings(2) + generatePortsIO('inp', priorityEncoder[i].bitWidth),
                    stdin: generateSTDType('IN', 1) + ';\n',
                    portenabled: generateSpacings(2) + generatePortsIO('enabled', 0),
                    stdenabled: generateSTDType('IN', 1) + ';\n',
                    portsout: generateSpacings(2) + generatePortsIOPriorityEnc('out', priorityEncoder[i].bitWidth),
                    stdout: generateSTDType('OUT', 1) + '\n',
                    end: generateSpacings(4) + ');\n  END COMPONENT;\n',
                    identificator: `bit${priorityEncoder[i].bitWidth}`,
                }]
            }
            const priorityEncoderFiltered = removeDuplicateComponent(objpriorityEncoder)
            priorityEncoderFiltered.forEach(el => element += el.header + el.portsin + el.stdin + el.portenabled + el.stdenabled + el.portsout + el.stdout + el.end)
        }
        return element
    }

    generatePortMapVHDL(){
            // // Example: and and_1(_out, _out, _Q[0]);
            const mux = this.scope.Multiplexer;
            const demux = this.scope.Demultiplexer;
            const decoder = this.scope.Decoder;
            const dlatch = this.scope.Dlatch;
            const dflipflop = this.scope.DflipFlop;
            const tflipflop = this.scope.TflipFlop;
            const jkflipflop = this.scope.JKflipFlop;
            const srflipflop = this.scope.SRflipFlop;
            const msb = this.scope.MSB;
            const lsb = this.scope.LSB;
            const priorityEncoder = this.scope.PriorityEncoder;
            let portmap = "\BEGIN\n";
            
            if(hasComponent(mux)){
                let objmux = []
                for(var i = 0; i < mux.length; i++){
                    objmux = [...objmux, 
                    {
                        header: generateHeaderPortmap('multiplexer', i, 'Mux', `bit${mux[i].bitWidth}sel${mux[i].controlSignalSize}`),
                        inputs: generatePortMapIOS('in', mux[i].inp) + ',\n',
                        sel: `    sel => ${mux[i].controlSignalInput.verilogLabel},\n`,
                        output: `    x => ${mux[i].output1.verilogLabel}`,
                        end: `\n  );\n`

                    }]
                }
                objmux.forEach(el => portmap += el.header + el.inputs + el.sel + el.output + el.end)
            }
    
            if(hasComponent(demux)){
                let objdemux = []
                for(var i = 0; i < demux.length; i++){
                    objdemux = [...objdemux, 
                    {
                        header: generateHeaderPortmap('demultiplexer', i, 'Demux', `bit${demux[i].bitWidth}sel${demux[i].controlSignalSize}`),
                        inputs: `    in0 => ${demux[i].input.verilogLabel},\n`,
                        sel: `    sel => ${demux[i].controlSignalInput.verilogLabel},\n`,
                        output: generatePortMapIOS('out', demux[i].output1),
                        end: `\n  );\n`
                    }]
                }
                objdemux.forEach(el => portmap += el.header + el.inputs + el.sel + el.output + el.end)
            }
            
            if(hasComponent(decoder)){
                let objdecoder = []
                for(var i = 0; i < decoder.length; i++){
                    objdecoder = [...objdecoder, 
                    {
                        header: generateHeaderPortmap('decoder', i, 'Decoder', `bit${decoder[i].bitWidth}`),
                        inputs: `    in0 => ${decoder[i].input.verilogLabel},\n`,
                        output: generatePortMapIOS('out', decoder[i].output1),
                        end: `\n  );\n`
                    }]
                }
                objdecoder.forEach(el => portmap += el.header + el.inputs + el.output + el.end)
            }

            if(hasComponent(dlatch)){
                let objdlatch = []
                for(var i = 0; i < dlatch.length; i++){
                    objdlatch = [...objdlatch, 
                    {
                        header: generateHeaderPortmap('dlatch', i, 'Dlatch', `bit${dlatch[i].bitWidth}`),
                        inputs: `    in0 => ${dlatch[i].dInp.verilogLabel},\n`,
                        clock: `    clock => ${dlatch[i].clockInp.verilogLabel},\n`,
                        output: `    q0 => ${dlatch[i].qOutput.verilogLabel}`,
                        notoutput: hasComponent(dlatch[i].qInvOutput.verilogLabel) ? `,\n    q1 => ${dlatch[i].qInvOutput.verilogLabel}\n` : '',
                        end: `\n  );\n`

                    }]
                }
                objdlatch.forEach(el => portmap += el.header + el.inputs + el.clock + el.output + el.notoutput + el.end)
            }

            if(hasComponent(dflipflop)){
                let objdflipflop = []
                for(var i = 0; i < dflipflop.length; i++){
                    objdflipflop = [...objdflipflop, 
                    {
                        header: generateHeaderPortmap('DFlipFlop', i, 'DFlipFlop', `bit${dflipflop[i].bitWidth}`),
                        inputs: `    inp => ${dflipflop[i].dInp.verilogLabel},\n`,
                        clock: `    clock => ${dflipflop[i].clockInp.verilogLabel},\n`,
                        reset: hasComponent(dflipflop[i].reset.connections) ? `    reset => ${dflipflop[i].reset.verilogLabel},\n` : '',
                        preset: hasComponent(dflipflop[i].preset.connections) ? `    preset => ${dflipflop[i].preset.verilogLabel},\n` : '',
                        enable: hasComponent(dflipflop[i].en.connections) ? `    enable => ${dflipflop[i].en.verilogLabel},\n` : '',
                        output: `    q0 => ${dflipflop[i].qOutput.verilogLabel}`,
                        notoutput: hasComponent(dflipflop[i].qInvOutput.verilogLabel) ? `,\n    q1 => ${dflipflop[i].qInvOutput.verilogLabel}\n` : '',
                        end: `\n  );\n`

                    }]
                }
                objdflipflop.forEach(el => portmap += el.header + el.inputs + el.clock + el.reset + el.preset + el.enable + el.output + el.notoutput + el.end)
            }

            if(hasComponent(tflipflop)){
                let objtflipflop = []
                for(var i = 0; i < tflipflop.length; i++){
                    objtflipflop = [...objtflipflop, 
                    {
                        header: generateHeaderPortmap('Tflipflop', i, 'Tflipflop', `bit${tflipflop[i].bitWidth}`),
                        inputs: `    inp => ${tflipflop[i].dInp.verilogLabel},\n`,
                        clock: `    clock => ${tflipflop[i].clockInp.verilogLabel},\n`,
                        reset: hasComponent(tflipflop[i].reset.connections) ? `    reset => ${tflipflop[i].reset.verilogLabel},\n` : '',
                        preset: hasComponent(tflipflop[i].preset.connections) ? `    preset => ${tflipflop[i].preset.verilogLabel},\n` : '',
                        enable: hasComponent(tflipflop[i].en.connections) ? `    enable => ${tflipflop[i].en.verilogLabel},\n` : '',
                        output: `    q0 => ${tflipflop[i].qOutput.verilogLabel}`,
                        notoutput: hasComponent(tflipflop[i].qInvOutput.verilogLabel) ? `,\n    q1 => ${tflipflop[i].qInvOutput.verilogLabel}\n` : '',
                        end: `\n  );\n`

                    }]
                }
                objtflipflop.forEach(el => portmap += el.header + el.inputs + el.clock + el.reset + el.preset + el.enable + el.output + el.notoutput + el.end)
            }

            if(hasComponent(jkflipflop)){
                let objjkflipflop = []
                for(var i = 0; i < jkflipflop.length; i++){
                    objjkflipflop = [...objjkflipflop, 
                    {
                        header: generateHeaderPortmap('JKFlipflop', i, 'JKFlipFlop', `bit${jkflipflop[i].bitWidth}`),
                        JInput: `    J => ${jkflipflop[i].J.verilogLabel},\n`,
                        KInput: `    K => ${jkflipflop[i].K.verilogLabel},\n`,
                        clock: `    clock => ${jkflipflop[i].clockInp.verilogLabel},\n`,
                        reset: hasComponent(jkflipflop[i].reset.connections) ? `    reset => ${jkflipflop[i].reset.verilogLabel},\n` : '',
                        preset: hasComponent(jkflipflop[i].preset.connections) ? `    preset => ${jkflipflop[i].preset.verilogLabel},\n` : '',
                        enable: hasComponent(jkflipflop[i].en.connections) ? `    enable => ${jkflipflop[i].en.verilogLabel},\n` : '',
                        output: `    q0 => ${jkflipflop[i].qOutput.verilogLabel}`,
                        notoutput: hasComponent(jkflipflop[i].qInvOutput.connections) ? `,\n    q1 => ${jkflipflop[i].qInvOutput.verilogLabel}\n` : '',
                        end: `\n  );\n`

                    }]
                    console.log(jkflipflop[i].qInvOutput)
                }
                objjkflipflop.forEach(el => portmap += el.header + el.JInput + el.KInput + el.clock + el.reset + el.preset + el.enable + el.output + el.notoutput + el.end)
            }

            if(hasComponent(srflipflop)){
                let objsrflipflop = []
                for(var i = 0; i < srflipflop.length; i++){
                    objsrflipflop = [...objsrflipflop, 
                    {
                        header: generateHeaderPortmap('SRFlipFlop', i, 'SRFlipFlop', `bit${srflipflop[i].bitWidth}`),
                        SInput: `    S => ${srflipflop[i].S.verilogLabel},\n`,
                        RInput: `    R => ${srflipflop[i].R.verilogLabel},\n`,
                        reset: hasComponent(srflipflop[i].reset.connections) ? `    reset => ${srflipflop[i].reset.verilogLabel},\n` : '',
                        preset: hasComponent(srflipflop[i].preset.connections) ? `    preset => ${srflipflop[i].preset.verilogLabel},\n` : '',
                        enable: hasComponent(srflipflop[i].en.connections) ? `    enable => ${srflipflop[i].en.verilogLabel},\n` : '',
                        output: `    q0 => ${srflipflop[i].qOutput.verilogLabel}`,
                        notoutput: hasComponent(srflipflop[i].qInvOutput.verilogLabel) ? `,\n    q1 => ${srflipflop[i].qInvOutput.verilogLabel}\n` : '',
                        end: `\n  );\n`

                    }]
                }
                objsrflipflop.forEach(el => portmap += el.header + el.SInput + el.RInput + el.reset + el.preset + el.enable + el.output + el.notoutput + el.end)
            }

            if(hasComponent(msb)){
                let objmsb = []
                for(var i = 0; i < msb.length; i++){
                    objmsb = [...objmsb, 
                    {
                        header: generateHeaderPortmap('MSB', i, 'MSB', `bit${msb[i].bitWidth}`),
                        input: `    inp => ${msb[i].inp1.verilogLabel},\n`,
                        enabled: `    enabled => ${msb[i].enable.verilogLabel},\n`,
                        output: `    out1 => ${msb[i].output1.verilogLabel}`,
                        end: `\n  );\n`

                    }]
                }
                objmsb.forEach(el => portmap += el.header + el.input + el.enabled + el.output + el.end)
            }

            if(hasComponent(lsb)){
                let objlsb = []
                for(var i = 0; i < lsb.length; i++){
                    objlsb = [...objlsb, 
                    {
                        header: generateHeaderPortmap('LSB', i, 'LSB', `bit${lsb[i].bitWidth}`),
                        input: `    inp => ${lsb[i].inp1.verilogLabel},\n`,
                        enabled: `    enabled => ${lsb[i].enable.verilogLabel},\n`,
                        output: `    out1 => ${lsb[i].output1.verilogLabel}`,
                        end: `\n  );\n`

                    }]
                }
                objlsb.forEach(el => portmap += el.header + el.input + el.enabled + el.output + el.end)
            }

            if(hasComponent(priorityEncoder)){
                let objpriorityEncoder = []
                let inputsArray = []
                let outputsArray = []
                let inputString = ''
                let outputString =''
                
                for(var i = 0; i < priorityEncoder.length; i++){
                    priorityEncoder[i].inp1.forEach((inp, idx) => {
                        inputsArray[idx] = `    inp${idx} => ${inp.verilogLabel}`
                    })
                    
                    priorityEncoder[i].output1.forEach((out, idx) => {
                        outputsArray[idx] = `    out${idx} => ${out.verilogLabel}`
                    })

                    inputString = inputsArray.join(',\n')
                    outputString = outputsArray.join(',\n')

                    objpriorityEncoder = [...objpriorityEncoder, 
                    {
                        header: generateHeaderPortmap('PriorityEncoder', i, 'PriorityEncoder', `bit${priorityEncoder[i].bitWidth}`),
                        input: inputString + ',\n',
                        enabled: `    enabled => ${priorityEncoder[i].enable.verilogLabel},\n`,
                        output: outputString,
                        end: `\n  );\n`

                    }]
                }

                inputsArray = []
                outputsArray = []
                objpriorityEncoder.forEach(el => portmap += el.header + el.input + el.enabled + el.output + el.end)
            }

            const BitSelectorObject = scopeList[Object.keys(scopeList)].BitSelector
            
            if(hasComponent(BitSelectorObject)) {
                let bitSelectorProcess = []
                portmap += `\n  PROCESS(`

                BitSelectorObject.forEach((el, index) => {
                    bitSelectorProcess[index] = `${el.inp1.verilogLabel}, ${el.bitSelectorInp.verilogLabel}`
                })

                portmap += bitSelectorProcess.join(',')
                portmap += `)\n    BEGIN\n`
            }
            return portmap
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
