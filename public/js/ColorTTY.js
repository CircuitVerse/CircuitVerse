/* 
 * Color TTY Component.
 * 
 * A variable size Display screen, user can write to any char position using its X and Y indicies.
 * The screen has a default size of 8 rows * 32 columns, Which can be updated by user.
 * To add a character to the display. Beside WRITE_PIN being HIGH(set to 1) there would be :
 * 1- data/ASCII (7 bits)       
 * 2- Xpos (3 bits by default)
 * 3- Ypos (5 bits by default)
 * 4- forColor RGB(12 bits)     
 * 5- backColor RGB(12 bits)    // Default: black(000) if not given
 * 6- reset/clear pin
 * 7- shift pins (2 bits) 
 * 
 * The contents of the ColorTTY can be reset to zero by setting the RESET pin 1 or 
 * or by selecting the component and pressing the "Reset" button in the properties window.
 * 
 * Shifting configurations:
 * 00 --> shift down one line
 * 01 --> shift right one line
 * 10 --> shift left one line
 * 11 --> shift up one line
 * 
 * Future upgrades:
 * 1- making size(height and width) custom to user needs restricted using a max value.  -- DONE
 * 2- shifting the contents of the data to one of the 4 directions.                     -- DONE
 * 3- giving o/p from the screen if the user clicks on some specific area(resembling a Yes/No/cancel dialog).
 * 4- choose between a set of Fonts.
 * 
*/
function ColorTTY(x, y, scope = globalScope, dimensions = [8, 32, 4]){
    // es6 --> let [rows, cols, colors] = dimensions;
    var rows = dimensions[0], cols = dimensions[1], colors = dimensions[2];
    CircuitElement.call(this, x, y, scope, "RIGHT", 1);
    this.checkLegalDimensions(rows, cols, colors);       // ASK: The instance isn't made yet, Right? I want to make sure the class instance isn't added to the UI until this test is passed ok

    this.cols = Math.min(128, cols);
    this.rows = Math.min(128, rows);  
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.xBitWidth = rows / 2;
    this.yBitWidth = cols / 2;
    this.colorBitWidth = colors;
    this.characterHeight = 2;               // unit is simulationArea squares
    this.characterWidth = 1;

    // '+2' adds 1 square padding in each direction
    this.elementWidth = ((this.characterWidth * this.cols) + 2) * 10;
    this.elementHeight = ((this.characterHeight * this.rows) + 2) * 10;
    this.configureNodes(this.elementHeight / 2, this.elementWidth / 2);
    this.setWidth(this.elementWidth / 2);
    this.setHeight(this.elementHeight / 2);
    this.screenCharacters = new Array(this.cols * this.rows);
    this.buffer = {};
    this.prevClockState = 0;
}
ColorTTY.prototype = Object.create(CircuitElement.prototype);
ColorTTY.prototype.constructor = ColorTTY;
ColorTTY.prototype.tooltipText = "A variable dimensions color Display Screen";
ColorTTY.prototype.mutableProperties = {
    "rows": {
        name: "Rows",
        type: "number",
        max: "128",
        min: "8",
        func: "changeNumberOfRows",
    },
    "columns": {
        name: "Columns",
        type: "number",
        max: "128",
        min: "8",
        func: "changeNumberOfColumns",
    },
    "reset": {
        name: "Reset",
        type: "button",
        func: "clearData",
    },
}
ColorTTY.prototype.customSave = function(){
    var data = {
        nodes: {
            clockInp: findNode(this.clockInp),
            asciiInp: findNode(this.asciiInp),
            xPosition: findNode(this.xPosition),
            yPosition: findNode(this.yPosition),
            foregroundColor: findNode(this.foregroundColor),
            backgroundColor: findNode(this.backgroundColor),
            reset: findNode(this.reset),
            en: findNode(this.en),
            shift: findNode(this.shift)
        }
        // ASK : IF NECESSARY should we add the data displayed, backcolors and forecolors to be able to load them later 
    }
    return data;
}
ColorTTY.prototype.isResolvable = function() {
    // Ask : Didn't add forgroundColor/backgroundColor because they will be assigned default values if not provided
    if (this.reset.value == 1) return true;
    else if (this.en.value == 0||(this.en.connections.length&&this.en.value==undefined)) return false;
    else if (this.clockInp.value == undefined || this.asciiInp.value == undefined
            || this.xPosition.value == undefined || this.yPosition.value == undefined ){
                return false;
            } 
    return true;
}
ColorTTY.prototype.resolve = function() {
    // Reset to default state if RESET pin is on or the enable pin is zero
    if (this.reset.value == 1) {
        this.clearData();
        return;
    }
    
    if (this.en.value == 0) {
        this.buffer = {};
        return;
    }

    // clock is still the same, put changes in buffer in order to put them in the screenCharacters array on next clock pulse
    if (this.clockInp.value == this.prevClockState) {
        if (this.clockInp.value == 0 && this.asciiInp.value != undefined){
            this.buffer = this.bufferFill();
        }
    // clock has changed
    } else if (this.clockInp.value != undefined) {
        if (this.clockInp.value == 1) {
            this.screenCharacters[this.buffer.position] = this.buffer;

            // Shifting the screen
            if (this.shift.value != undefined) this.shiftScreen(this.shift.value);

        } else if (this.clockInp.value == 0 && this.asciiInp.value != undefined) {
            this.buffer = this.bufferFill();
        }
        this.prevClockState = this.clockInp.value;
    }

    // Future upgrades : OUTPUT values if a certain area is clicked, SEE: inside counter.prototype.resolve() , comments starting with Output
}
ColorTTY.prototype.customDraw = function() {
    var ctx = simulationArea.context, xx = this.x, yy = this.y;
    this.drawDefaultBackground(ctx, '#000', xx, yy);

    for(var c = 0; c < this.screenCharacters.length; c++) {
        if (this.screenCharacters[c] !== undefined){
            var row = this.getRowUsingIndex(c),
                newXRelativePoint = xx + this.elementWidth/2,
                newYRelativePoint = yy + this.elementHeight/2,
                xBackgroundOffset = (this.characterWidth * 10 * (this.cols - (c % this.cols))) + 10,
                yBackgroundOffset = (this.characterHeight * 10 * (this.rows - row) + 8),
                xCharacterOffset = (this.characterWidth * 10 * (this.cols - (c % this.cols))) + 5,
                yCharacterOffset = (this.characterHeight * 10 * (this.rows - row) - 7);
            
            // make a rectangle according to index
            ctx.beginPath();
            ctx.rect(newXRelativePoint - xBackgroundOffset, newYRelativePoint - yBackgroundOffset, this.characterWidth * 10, this.characterHeight * 10);
            ctx.fillStyle = this.screenCharacters[c].background;
            ctx.fill();

            // put a colored character according to index
            ctx.beginPath();
            ctx.fillStyle = this.screenCharacters[c].foreground;    
            ctx.textAlign = "center";
            fillText(ctx, this.screenCharacters[c].character, newXRelativePoint - xCharacterOffset, newYRelativePoint - yCharacterOffset, 19, 'ColorTTY');
            ctx.fill();
        }
    }
    this.drawClock(ctx, xx, yy);
}
ColorTTY.prototype.shiftScreen = function(shiftCode) {
    if(shiftCode < 0 || shiftCode > 3) {
        showError("Check shift configurations!");
        return;
    }

    if(shiftCode == 0){
        // remove last line, inser new line at the start
        this.screenCharacters.splice((this.rows - 1) * this.cols);
        var newLine = new Array(this.cols);
        this.screenCharacters.unshift(...newLine);

    }else if(shiftCode == 1){
        // for each row: delete the last element and place an undefined element in the beginning 
        this.leftAndRightShift('r');

    }else if(shiftCode == 2){
        // for each row: delete the first element and place an undefined element at the end 
        this.leftAndRightShift('l');

    }else {
        // remove first line, insert at the bottom
        this.screenCharacters.splice(0, this.cols);
        var newLine = new Array(this.cols);
        this.screenCharacters.push(...newLine);
    }
}
ColorTTY.prototype.changeNumberOfRows = function(value){
    // changing height will cause the loss of data
    value = parseInt(value);
    if (!isNaN(value) && this.rows != value && value >= 8 && value <= 128 && value % 2 == 0) {
        this.rows = value;
        this.xBitWidth = value / 2;
        this.elementHeight = ((this.characterHeight * this.rows) + 2) * 10;
        this.configureNodes(this.elementHeight / 2, this.elementWidth / 2);
        this.setHeight(this.elementHeight / 2);
        this.screenCharacters = new Array(this.cols * this.rows);
    }
}
ColorTTY.prototype.changeNumberOfColumns = function(value){
    // changing width will cause the loss of data
    value = parseInt(value);
    if (!isNaN(value) && this.cols != value && value >= 8 && value <= 128 && value % 2 == 0) {
        this.cols = value;
        this.ybitWidth = value / 2;
        this.elementWidth = ((this.characterWidth * this.cols) + 2) * 10;
        this.configureNodes(this.elementHeight / 2, this.elementWidth / 2);
        this.setWidth(this.elementWidth / 2);
        this.screenCharacters = new Array(this.cols * this.rows);
    }
}
ColorTTY.prototype.getRowUsingIndex = function(index){
    var numberOfRows = 0;
    while(index + 1 - this.cols > 0){
        index -= this.cols;
        numberOfRows++;
    }
    return numberOfRows;
}
ColorTTY.prototype.convertToHexColor = function(str, colorBitWidth){
    var hexColor = '', firstConstant = 0, secondConstant = 4;
    for(var i = 0; i < colorBitWidth; i++){
        var tmp = str.slice(firstConstant, secondConstant);
        hexColor += parseInt(tmp, 2).toString(16).toUpperCase();
        firstConstant += 4;
        secondConstant += 4;
    }
    return '#' + hexColor;
}
ColorTTY.prototype.clearData = function(){
    this.screenCharacters = new Array(this.cols * this.rows);
}
ColorTTY.prototype.bufferFill = function(){
    return {
        character: String.fromCharCode(this.asciiInp.value),
        foregroundColor: this.convertToHexColor(this.foregroundColor.value, this.colorBitWidth),
        backgroundColor: this.convertToHexColor(this.backgroundColor.value, this.colorBitWidth),
        position: parseInt(this.xPosition, 2) * this.rows + parseInt(this.yPosition, 2)
    };
}
ColorTTY.prototype.configureNodes = function(halfHeight, halfWidth){
    this.clockInp = new Node(-1 * halfWidth, halfHeight - 10, 0, this, 1, "Clock");
    this.asciiInp = new Node(-1 * halfWidth, halfHeight - 30, 0, this, 7,"Ascii Input");
    this.xPosition = new Node(-1 * halfWidth, halfHeight - 50, 0, this, this.xBitWidth, "X-axis position");
    this.yPosition = new Node(-1 * halfWidth, halfHeight - 80, 0, this, this.yBitWidth, "Y-axis position");
    this.foregroundColor = new Node(-1 * halfWidth, halfHeight - 110, 0, this, this.colorBitWidth * 3, "Foreground color");
    this.backgroundColor = new Node(-1 * halfWidth, halfHeight - 140, 0, this, this.colorBitWidth * 3, "Background color");
    this.reset = new Node(30 - halfWidth, halfHeight, 0, this, 1,"Reset");
    this.en = new Node(10 - halfWidth, halfHeight, 0, this, 1,"Enable");
    this.shift = new Node(50 - halfWidth, halfHeight, 0, this, 2, "Shift");
}
ColorTTY.prototype.drawClock = function(ctx, xx, yy){
        ctx.beginPath();
        moveTo(ctx, -1 * this.elementWidth / 2, (this.elementHeight / 2) - 5, xx, yy, this.direction); 
        lineTo(ctx, (-1 * this.elementWidth / 2) + 5, (this.elementHeight / 2) - 10, xx, yy, this.direction);
        lineTo(ctx, -1 * this.elementWidth / 2, (this.elementHeight / 2) - 15, xx, yy, this.direction);
        ctx.stroke();
}
ColorTTY.prototype.drawDefaultBackground = function(ctx, defaultColor, xx, yy){
    // '-10' represent the padding square at the start
    // '+2' represent a padding to include the bottom part of small characters such as 'g' and 'y'.
    ctx.beginPath();
    ctx.rect(xx - (this.elementWidth/2 - 10), yy - (this.elementHeight/2 - 10) + 2, (this.characterWidth * 10) * this.cols, (this.characterHeight * 10) * this.rows);
    ctx.fillStyle = defaultColor;
    ctx.fill();
}
ColorTTY.prototype.checkLegalDimensions = function(rows, cols, colors){
    if(rows % 2 != 0 || cols % 2 != 0)  showError('rows and columns must be multiples of 2!');
    else if (rows <= 4 || cols <= 4)    showError('Minimum value for rows or columns is 8!');
    if(colors % 4 != 0 && colors < 8)   showError('Check the bitWidth of Colors');
}
ColorTTY.prototype.leftAndRightShift = function(code){
    var insertIndex = 0, deleteIndex = this.cols - 1;
    for(var i = 0; i < this.rows ; i++){
        if(code == 'r'){
            this.screenCharacters.splice(deleteIndex, 1);
        }else if(code == 'l'){
            this.screenCharacters.splice(insertIndex, 1);
        }
        var arrayFront = this.screenCharacters.slice(0, insertIndex);
        var arrayBack = this.screenCharacters.slice(insertIndex);
        this.screenCharacters = [...arrayFront, undefined, ...arrayBack]; 
        insertIndex +=  this.cols;
        deleteIndex += this.cols;  
    }
    if(code == 'l'){
        this.screenCharacters.splice(0, 1);
        this.screenCharacters.push(undefined);
    }
}

/* 
    TODO:
    1- make svg more beautiful.                                              -- DONE
    2- find out why zooming in/out doesn't update the ctx.rect() method. (because of absolute lengths)
    3- find the bug inside the char positioning.                             -- DONE
    4- make the color positioning approach the same as the char positioning. -- DONE
    5- refactor some of the large functions.                                 -- DONE
    6- add mutable width and height/ reset button to properties UI.          -- DONE but not tested
*/


