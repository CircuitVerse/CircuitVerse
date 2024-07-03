import CircuitElement from '../circuitElement'
import simulationArea from '../simulationArea'
import { correctWidth, fillText } from '../canvasApi'
import Node, { findNode } from '../node'

// helper function to convert decimal to binary
function dec2bin(dec, bitWidth = undefined) {
    // only for positive nos
    var bin = dec.toString(2)
    if (bitWidth == undefined) return bin
    return '0'.repeat(bitWidth - bin.length) + bin
}

/**
 * TestBench Output has a node for it's  input which is
 * compared to desired output according tp testData of
 * input TB Every TB_output has a uniq identifier matching
 * it's TB_Input
 * @class
 * @extends CircuitElement
 * @param {number} x - the x coord of TB
 * @param {number} y - the y coord of TB
 * @param {Scope=} scope - the circuit on which TB is drawn
 * @param {string} dir - direction
 * @param {string} identifier - id to identify tests
 * @category testbench
 */

export default class TB_Output extends CircuitElement {
    constructor(x, y, scope = globalScope, dir = 'RIGHT', identifier) {
        super(x, y, scope, dir, 1)
        this.objectType = 'TB_Output'
        this.scope.TB_Output.push(this)
        this.setIdentifier(identifier || 'Test1')
        this.inputs = []
        this.testBenchInput = undefined

        this.setup()
    }

    setDimensions() {
        this.leftDimensionX = 0
        this.rightDimensionX = 160
        this.upDimensionY = 0
        this.downDimensionY = 40
        if (this.testBenchInput) {
            this.downDimensionY =
                40 + this.testBenchInput.testData.outputs.length * 20
        }
    }

    setup() {
        this.deleteNodes() // deletes all nodes whenever setup is called.
        this.nodeList = []

        this.inputs = []
        this.testBenchInput = undefined
        // find it's pair input
        for (var i = 0; i < this.scope.TB_Input.length; i++) {
            if (this.scope.TB_Input[i].identifier == this.identifier) {
                this.testBenchInput = this.scope.TB_Input[i]
                break
            }
        }

        this.setDimensions()

        if (this.testBenchInput) {
            for (
                var i = 0;
                i < this.testBenchInput.testData.outputs.length;
                i++
            ) {
                this.inputs.push(
                    new Node(
                        0,
                        30 + i * 20,
                        NODE_INPUT,
                        this,
                        this.testBenchInput.testData.outputs[i].bitWidth,
                        this.testBenchInput.testData.outputs[i].label
                    )
                )
            }
        }
    }

    customSave() {
        var data = {
            constructorParamaters: [this.direction, this.identifier],
            nodes: {
                inputs: this.inputs.map(findNode),
            },
        }
        return data
    }

    /**
     * @memberof TB_output
     * set identifier for this testbench
     */
    setIdentifier(id = '') {
        if (id.length == 0 || id == this.identifier) return
        this.identifier = id
        this.setup()
    }

    /**
     * @memberof TB_output
     * Function to check if the input for this TB exist
     */
    checkPairing(id = '') {
        if (this.testBenchInput) {
            if (
                this.testBenchInput.deleted ||
                this.testBenchInput.identifier != this.identifier
            ) {
                this.setup()
            }
        } else {
            this.setup()
        }
    }

    customDraw() {
        var ctx = simulationArea.context
        ctx.beginPath()
        ctx.strokeStyle = 'grey'
        ctx.fillStyle = '#fcfcfc'
        ctx.lineWidth = correctWidth(1)
        var xx = this.x
        var yy = this.y

        var xRotate = 0
        var yRotate = 0
        if (this.direction == 'LEFT') {
            xRotate = 0
            yRotate = 0
        } else if (this.direction == 'RIGHT') {
            xRotate = 120 - this.xSize
            yRotate = 0
        } else if (this.direction == 'UP') {
            xRotate = 60 - this.xSize / 2
            yRotate = -20
        } else {
            xRotate = 60 - this.xSize / 2
            yRotate = 20
        }

        ctx.beginPath()
        ctx.textAlign = 'center'
        ctx.fillStyle = 'black'
        fillText(
            ctx,
            `${this.identifier} [OUTPUT]`,
            xx + this.rightDimensionX / 2,
            yy + 14,
            10
        )
        fillText(
            ctx,
            ['Unpaired', 'Paired'][+(this.testBenchInput != undefined)],
            xx + this.rightDimensionX / 2,
            yy + this.downDimensionY - 5,
            10
        )
        ctx.fill()

        if (this.testBenchInput) {
            ctx.beginPath()
            ctx.font = '30px Raleway'
            ctx.textAlign = 'left'
            ctx.fillStyle = 'blue'
            for (
                var i = 0;
                i < this.testBenchInput.testData.outputs.length;
                i++
            ) {
                fillText(
                    ctx,
                    this.testBenchInput.testData.outputs[i].label,
                    5 + xx,
                    30 + i * 20 + yy + 4,
                    10
                )
            }
            ctx.fill()

            if (this.testBenchInput.running && this.testBenchInput.iteration) {
                ctx.beginPath()
                ctx.font = '30px Raleway'
                ctx.textAlign = 'right'
                ctx.fillStyle = 'blue'
                ctx.beginPath()
                for (
                    var i = 0;
                    i < this.testBenchInput.testData.outputs.length;
                    i++
                ) {
                    fillText(
                        ctx,
                        this.testBenchInput.testData.outputs[i].values[
                            this.testBenchInput.iteration - 1
                        ],
                        xx + this.rightDimensionX - 5,
                        30 + i * 20 + yy + 4,
                        10
                    )
                }

                ctx.fill()
            }

            if (this.testBenchInput.running && this.testBenchInput.iteration) {
                ctx.beginPath()
                ctx.font = '30px Raleway'
                ctx.textAlign = 'center'
                ctx.fillStyle = 'blue'

                for (
                    var i = 0;
                    i < this.testBenchInput.testData.outputs.length;
                    i++
                ) {
                    if (this.inputs[i].value != undefined) {
                        ctx.beginPath()
                        if (
                            this.testBenchInput.testData.outputs[i].values[
                                this.testBenchInput.iteration - 1
                            ] == 'x' ||
                            parseInt(
                                this.testBenchInput.testData.outputs[i].values[
                                    this.testBenchInput.iteration - 1
                                ],
                                2
                            ) == this.inputs[i].value
                        ) {
                            ctx.fillStyle = 'green'
                        } else {
                            ctx.fillStyle = 'red'
                        }
                        fillText(
                            ctx,
                            dec2bin(
                                this.inputs[i].value,
                                this.inputs[i].bitWidth
                            ),
                            xx + this.rightDimensionX / 2,
                            30 + i * 20 + yy + 4,
                            10
                        )
                        ctx.fill()
                    } else {
                        ctx.beginPath()
                        if (
                            this.testBenchInput.testData.outputs[i].values[
                                this.testBenchInput.iteration - 1
                            ] == 'x'
                        ) {
                            ctx.fillStyle = 'green'
                        } else {
                            ctx.fillStyle = 'red'
                        }
                        fillText(
                            ctx,
                            'X',
                            xx + this.rightDimensionX / 2,
                            30 + i * 20 + yy + 4,
                            10
                        )
                        ctx.fill()
                    }
                }
            }
        }
    }
}

TB_Output.prototype.tooltipText = 'Test Bench Output Selected'
TB_Output.prototype.helplink = 'https://docs.circuitverse.org/#/chapter7/3testcircuits'
TB_Output.prototype.centerElement = true
TB_Output.prototype.mutableProperties = {
    identifier: {
        name: 'TestBench Name:',
        type: 'text',
        maxlength: '10',
        func: 'setIdentifier',
    },
}
TB_Output.prototype.objectType = 'TB_Output'
