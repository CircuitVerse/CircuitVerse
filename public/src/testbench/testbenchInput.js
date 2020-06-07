import CircuitElement from '../circuitElement';
import simulationArea from '../simulationArea';
import {
    correctWidth, lineTo, moveTo, fillText,
} from '../canvasApi';
import Node, { findNode } from '../node';
import plotArea from '../plotArea';


/**
 * TestBench Input has a node for it's clock input.
 * this.testData - the data of all test cases.
 * Every testbench has a uniq identifier.
 * @class
 * @extends CircuitElement
 * @param {number} x - the x coord of TB
 * @param {number} y - the y coord of TB
 * @param {Scope=} scope - the circuit on which TB is drawn
 * @param {string} dir - direction
 * @param {string} identifier - id to identify tests
 * @param {JSON=} testData - input, output and number of tests
 * @category testbench
 */
export default class TB_Input extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', identifier, testData) {
        super(x, y, scope, dir, 1);
        this.objectType = 'TB_Input';
        this.scope.TB_Input.push(this);
        this.setIdentifier(identifier || 'Test1');
        this.testData = testData || { inputs: [], outputs: [], n: 0 };
        this.clockInp = new Node(0, 20, 0, this, 1);
        this.outputs = [];
        this.running = false; // if tests are undergo
        this.iteration = 0;
        this.setup();
    }

    /**
     * @memberof TB_Input
     * Takes iput when double clicked. For help on generation of input refer to TB_Input.helplink
     */
    dblclick() {
        this.testData = JSON.parse(prompt('Enter TestBench Json'));
        this.setup();
    }

    setDimensions() {
        this.leftDimensionX = 0;
        this.rightDimensionX = 120;

        this.upDimensionY = 0;
        this.downDimensionY = 40 + this.testData.inputs.length * 20;
    }

    /**
     * @memberof TB_Input
     * setups the Test by parsing through the testbench data.
     */
    setup() {
        this.iteration = 0;
        this.running = false;
        this.nodeList.clean(this.clockInp);
        this.deleteNodes();
        this.nodeList = [];
        this.nodeList.push(this.clockInp);
        this.testData = this.testData || { inputs: [], outputs: [], n: 0 };
        // this.clockInp = new Node(0,20, 0,this,1);

        this.setDimensions();

        this.prevClockState = 0;
        this.outputs = [];

        for (let i = 0; i < this.testData.inputs.length; i++) {
            this.outputs.push(new Node(this.rightDimensionX, 30 + i * 20, 1, this, this.testData.inputs[i].bitWidth, this.testData.inputs[i].label));
        }

        for (let i = 0; i < this.scope.TB_Output.length; i++) {
            if (this.scope.TB_Output[i].identifier == this.identifier) { this.scope.TB_Output[i].setup(); }
        }
    }

    /**
     * @memberof TB_Input
     * toggles state by simply negating this.running so that test cases stop
     */
    toggleState() {
        this.running = !this.running;
        this.prevClockState = 0;
    }

    /**
     * @memberof TB_Input
     * function to run from test case 0 again
     */
    resetIterations() {
        this.iteration = 0;
        this.prevClockState = 0;
    }

    /**
     * @memberof TB_Input
     * function to resolve the testbench input adds
     */
    resolve() {
        if (this.clockInp.value != this.prevClockState) {
            this.prevClockState = this.clockInp.value;
            if (this.clockInp.value == 1 && this.running) {
                if (this.iteration < this.testData.n) {
                    this.iteration++;
                } else {
                    this.running = false;
                }
            }
        }
        if (this.running && this.iteration) {
            for (let i = 0; i < this.testData.inputs.length; i++) {
                console.log(this.testData.inputs[i].values[this.iteration - 1]);
                this.outputs[i].value = parseInt(this.testData.inputs[i].values[this.iteration - 1], 2);
                simulationArea.simulationQueue.add(this.outputs[i]);
            }
        }
    }

    /**
     * @memberof TB_Input
     * was a function to plot values incase any flag used as output to this element
     */
    setPlotValue() {
        const time = plotArea.stopWatch.ElapsedMilliseconds;
        if (this.plotValues.length && this.plotValues[this.plotValues.length - 1][0] == time) { this.plotValues.pop(); }

        if (this.plotValues.length == 0) {
            this.plotValues.push([time, this.inp1.value]);
            return;
        }

        if (this.plotValues[this.plotValues.length - 1][1] == this.inp1.value) { return; }
        this.plotValues.push([time, this.inp1.value]);
    }

    customSave() {
        const data = {
            constructorParamaters: [this.direction, this.identifier, this.testData],
            nodes: {
                outputs: this.outputs.map(findNode),
                clockInp: findNode(this.clockInp),
            },
        };
        return data;
    }

    /**
     * This function is used to set a uniq identifier to every testbench
     * @memberof TB_Input
     */
    setIdentifier(id = '') {
        if (id.length == 0 || id == this.identifier) return;


        for (let i = 0; i < this.scope.TB_Output.length; i++) {
            this.scope.TB_Output[i].checkPairing();
        }


        for (let i = 0; i < this.scope.TB_Output.length; i++) {
            if (this.scope.TB_Output[i].identifier == this.identifier) { this.scope.TB_Output[i].identifier = id; }
        }

        this.identifier = id;

        this.checkPaired();
    }

    /**
     * Check if there is a output tester paired with input TB.
     * @memberof TB_Input
     */
    checkPaired() {
        for (let i = 0; i < this.scope.TB_Output.length; i++) {
            if (this.scope.TB_Output[i].identifier == this.identifier) { this.scope.TB_Output[i].checkPairing(); }
        }
    }

    delete() {
        super.delete();
        this.checkPaired();
    }

    customDraw() {
        const ctx = simulationArea.context;
        ctx.beginPath();
        ctx.strokeStyle = 'grey';
        ctx.fillStyle = '#fcfcfc';
        ctx.lineWidth = correctWidth(1);
        let xx = this.x;
        let yy = this.y;

        let xRotate = 0;
        let yRotate = 0;
        if (this.direction == 'LEFT') {
            xRotate = 0;
            yRotate = 0;
        } else if (this.direction == 'RIGHT') {
            xRotate = 120 - this.xSize;
            yRotate = 0;
        } else if (this.direction == 'UP') {
            xRotate = 60 - this.xSize / 2;
            yRotate = -20;
        } else {
            xRotate = 60 - this.xSize / 2;
            yRotate = 20;
        }

        ctx.beginPath();
        ctx.textAlign = 'center';
        ctx.fillStyle = 'black';
        fillText(ctx, `${this.identifier} [INPUT]`, xx + this.rightDimensionX / 2, yy + 14, 10);

        fillText(ctx, ['Not Running', 'Running'][+this.running], xx + this.rightDimensionX / 2, yy + 14 + 10 + 20 * this.testData.inputs.length, 10);
        fillText(ctx, `Case: ${this.iteration}`, xx + this.rightDimensionX / 2, yy + 14 + 20 + 20 * this.testData.inputs.length, 10);
        // fillText(ctx, "Case: "+this.iteration, xx  , yy + 20+14, 10);
        ctx.fill();


        ctx.font = '30px Georgia';
        ctx.textAlign = 'right';
        ctx.fillStyle = 'blue';
        ctx.beginPath();
        for (let i = 0; i < this.testData.inputs.length; i++) {
            // ctx.beginPath();
            fillText(ctx, this.testData.inputs[i].label, this.rightDimensionX - 5 + xx, 30 + i * 20 + yy + 4, 10);
        }

        ctx.fill();
        if (this.running && this.iteration) {
            ctx.font = '30px Georgia';
            ctx.textAlign = 'left';
            ctx.fillStyle = 'blue';
            ctx.beginPath();
            for (let i = 0; i < this.testData.inputs.length; i++) {
                fillText(ctx, this.testData.inputs[i].values[this.iteration - 1], 5 + xx, 30 + i * 20 + yy + 4, 10);
            }

            ctx.fill();
        }

        ctx.beginPath();
        ctx.strokeStyle = ('rgba(0,0,0,1)');
        ctx.lineWidth = correctWidth(3);
        xx = this.x;
        yy = this.y;
        // rect(ctx, xx - 20, yy - 20, 40, 40);
        moveTo(ctx, 0, 15, xx, yy, this.direction);
        lineTo(ctx, 5, 20, xx, yy, this.direction);
        lineTo(ctx, 0, 25, xx, yy, this.direction);

        ctx.stroke();
    }
}

TB_Input.prototype.tooltipText = 'Test Bench Input Selected';

/**
 * @memberof TB_Input
 * different algo for drawing center elements
 * @category testbench
 */
TB_Input.prototype.centerElement = true;

TB_Input.prototype.helplink = 'https://docs.circuitverse.org/#/testbench';

TB_Input.prototype.mutableProperties = {
    identifier: {
        name: 'TestBench Name:',
        type: 'text',
        maxlength: '10',
        func: 'setIdentifier',
    },
    iteration: {
        name: 'Reset Iterations',
        type: 'button',
        func: 'resetIterations',
    },
    toggleState: {
        name: 'Toggle State',
        type: 'button',
        func: 'toggleState',
    },
};
TB_Input.prototype.objectType = 'TB_Input';
