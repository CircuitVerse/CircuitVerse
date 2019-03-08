/* 
 * Color TTY Component.
 * 
 * A 64*64 Display screen, Where user can write to any char position using its X and Y position.
 * To add a character to the display. Beside WRITE_PIN being HIGH(set to 1) there would be :
 * 1- data/ASCII (7 bits)       // 7 bits as Keyboard element indicated a 7-bit ASCII data output 
 * 2- Xpos (5 bits)
 * 3- Ypos (5 bits)
 * 4- forColor RGB(12 bits)     // Default: white(FFF) if not given
 * 5- backColor RGB(12 bits)    // Default: black(000) if not given
 * 6- reset/clear pin
 * 7- shift pins (2 bits) 
 * 
 * Currently the number of columns and rows is 32 and can't be changed by user,
 * But the code is written to allow future upgrades that allow the user to customize
 * the cols/rows to his needs while restricting col/row to 128 max and 32 min.
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
 * 1- making size(height and width) custom to user needs restricted using a max value. 
 * 2- giving o/p from the screen if the user clicks on some specific area(resembling a Yes/No/cancel dialog).
 * 3- shifting the contents of the data to one of the 4 directions.
 *    
 * Search for comments starting with CHECK and ASK
*/

// element constructor class
function ColorTTY(x, y, scope = globalScope, rows = 32, cols = 32){
    // Inherit default properties and methods of all circuit elements
    CircuitElement.call(this, x, y, scope, "RIGHT", 1);

    // To make user able to change size in the future, either the size or the resolution of the colors being 4bits each or 8bits
    this.xBitWidth = this.yBitWidth = 5;
    this.colorBitWidth = 4;

    /* Copied from TTY class
     * can be put in a seperate class TTYCircuitElement()
     * then make both TTY, ColorTTY inherit similar properties from this class to keep the Dry principle 
     */
    this.directionFixed = true;
    this.fixedBitWidth = true;
    this.cols = Math.min(128, Math.max(cols, Math.pow(2, this.xBitWidth)));    // changed from TTY class to restrict col/row to 128 max and 32 min
    this.rows = Math.min(128, Math.max(rows, Math.pow(2, this.yBitWidth)));    

    // increased min value to be 150 because there are more inputs to the ColorTTY
    this.elementWidth = Math.max(150, Math.ceil(this.cols / 2) * 20);
    this.elementHeight = Math.max(150, Math.ceil(this.rows * 15 / 20) * 20);
    this.setWidth(this.elementWidth / 2);
    this.setHeight(this.elementHeight / 2);

    // node configurations, all input pins are on the left side of the element seperated by 30 pixels each
    this.clockInp = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 10, 0, this, 1, "Clock");
    this.asciiInp = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 30, 0, this, 7,"Ascii Input");
    this.xPosition = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 50, 0, this, this.xBitWidth, "X-axis position");
    this.yPosition = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 80, 0, this, this.yBitWidth, "Y-axis position");
    this.foregroundColor = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 110, 0, this, this.colorBitWidth * 3, "Foreground color");
    this.backgroundColor = new Node(-this.elementWidth / 2, this.elementHeight / 2 - 140, 0, this, this.colorBitWidth * 3, "Background color");
    this.reset = new Node(30 - this.elementWidth / 2, this.elementHeight / 2, 0, this, 1,"Reset");
    this.en = new Node(10 - this.elementWidth / 2, this.elementHeight / 2, 0, this, 1,"Enable");
    this.shift = new Node(50 - this.elementWidth / 2, this.elementHeight / 2, 0, this, 2, "Shift");

    this.prevClockState = 0;

    /* this.buffer = {character: CHAR_DATA, foreground: FOREGROUND_COLOR, background: BackgroundCOLOR, position: PLACE_OF_CHAR}
     * this.screenCharacters = [{}, {}, ...]  
     * A 32*32 array of objects, where each object will be same as this.buffer without position key.
     * if value of any element is 'undefined', then the user hasn't assign it yet and It will be rendered as 
     * {data: 'space/no character', foreground: 'unnecessary as there is nothing written', background: '000'}
    */
    this.screenCharacters = new Array(this.cols * this.rows);
    this.buffer = {};
};

// class prototypes
ColorTTY.prototype = Object.create(CircuitElement.prototype);
ColorTTY.prototype.constructor = ColorTTY;
ColorTTY.prototype.tooltipText = "A 64*64 Display screen, Where user can write to any char position using its X and Y position and indicate a fore color and a background color.";

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
};

ColorTTY.prototype.isResolvable = function() {
    // copied from TTY. Didn't add forgroundColor/backgroundColor because they will be assigned default values if not provided
    if (this.reset.value == 1) return true;
    else if (this.en.value == 0||(this.en.connections.length&&this.en.value==undefined)) return false;
    else if (this.clockInp.value == undefined) return false;
    else if (this.asciiInp.value == undefined) return false;
    else if (this.xPosition.value == undefined) return false;
    else if (this.yPosition.value == undefined) return false;
    return true;
};

ColorTTY.prototype.resolve = function() {

    // Reset to default state if RESET pin is on or the enable pin is zero
    if (this.reset.value == 1) {
        this.screenCharacters = new Array(this.cols * this.rows);
        return;
    }
    
    if (this.en.value == 0) {
        this.buffer = {};
        return;
    }

    // clock is still the same, put changes in buffer in order to put them in the screenCharacters array on next clock pulse
    if (this.clockInp.value == this.prevClockState) {
        if (this.clockInp.value == 0 && this.legalInputValues() && this.asciiInp.value != undefined){
            this.buffer = {
                character: String.fromCharCode(this.asciiInp.value),
                foregroundColor: this.foregroundColor.value,
                backgroundColor: this.backgroundColor.value,
                position: this.xPosition * this.rows + this.yPosition
            };
        }
    // clock has changed
    } else if (this.clockInp.value != undefined) {
        if (this.clockInp.value == 1) {
            this.screenCharacters[this.buffer.position] = this.buffer;

            // Shifting the screen
            if (this.shift.value != undefined) this.shiftScreen(this.shift.value);

        } else if (this.clockInp.value == 0 && this.legalInputValues() && this.asciiInp.value != undefined) {
            this.buffer = {
                character: String.fromCharCode(this.asciiInp.value),
                foregroundColor: this.foregroundColor.value,
                backgroundColor: this.backgroundColor.value,
                position: this.xPosition * this.rows + this.yPosition
            };
        }
        this.prevClockState = this.clockInp.value;
    }

    // Future upgrades : OUTPUT values if a certain area is clicked, SEE: inside counter.prototype.resolve() , comments starting with Output
};

ColorTTY.prototype.customDraw = function() {
    var ctx = simulationArea.context;
    var xx = this.x;
    var yy = this.y;

    ctx.beginPath();
    ctx.strokeStyle = "lightgray";
    ctx.fillStyle = "black";
    ctx.lineWidth = correctWidth(3);

    ctx.fill();
    ctx.stroke();

    // customDraw() is where you add your changes to the UX, resolve() is where you calculate changes that will be executed here

};

ColorTTY.prototype.clearData = function(){
    this.screenCharacters = new Array(this.cols * this.rows);
    this.buffer = {};
}

ColorTTY.prototype.legalInputValues = function(){
    // return 1 if values of (xPosition AND yPosition AND forgroundColor AND backgroundColor) is whithin allowed limits
    return (this.xPosition.value >= 0 && this.xPosition.value <= Math.pow(2, this.xBitWidth))
            && (this.yPosition.value >= 0 && this.yPosition.value <= Math.pow(2, this.yBitWidth))
            && (this.foregroundColor.value >= 0 && this.foregroundColor.value <= Math.pow(2, this.colorBitWidth))
            && (this.backgroundColor.value >= 0 && this.backgroundColor.value <= Math.pow(2, this.colorBitWidth));
}

ColorTTY.prototype.shiftScreen = function(shiftCode) {
    if(shiftCode < 0 || shiftCode > 3) {
        showError("Check shift configurations!");
        return;
    }

    // shift down
    if(shiftCode == 0){
        // remove last line
        this.screenCharacters.splice((this.rows - 1) * this.cols);

        // make new empty line
        var newLine = new Array(this.cols);

        // add the empty line to the top
        this.screenCharacters.unshift(...newLine);

    // shift right
    }else if(shiftCode == 1){
        // for each row: delete the last element and place an undefined element in the beginning 
        var insertIndex = 0, deleteIndex = this.cols - 1;
        for(var i = 0; i < this.rows ; i++){
            this.screenCharacters.splice(deleteIndex, 1);
            var arrayFront = this.screenCharacters.slice(0, insertIndex);
            var arrayBack = this.screenCharacters.slice(insertIndex);
            this.screenCharacters = [...arrayFront, undefined, ...arrayBack]; 
            insertIndex +=  this.cols;
            deleteIndex += this.cols;  
        }

    // shift left
    }else if(shiftCode == 2){
        // for each row: delete the first element and place an undefined element at the end 
        var insertIndex = 0;
        for(var i = 0; i < this.rows ; i++){
            this.screenCharacters.splice(insertIndex, 1);
            var arrayFront = this.screenCharacters.slice(0, insertIndex);
            var arrayBack = this.screenCharacters.slice(insertIndex);
            this.screenCharacters = [...arrayFront, undefined, ...arrayBack]; 
            insertIndex +=  this.cols;
        }
        this.screenCharacters.splice(0, 1);
        this.screenCharacters.push(undefined);

    // shift up
    }else {
        // remove first line
        this.screenCharacters.splice(0, this.cols);

        // make new empty line
        var newLine = new Array(this.cols);

        // add the empty line to the bottom
        this.screenCharacters.push(...newLine);
    }
}