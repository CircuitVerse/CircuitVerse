import { drawCircle } from '../canvasApi'
import { simulationArea } from '../simulationArea'
import { tempBuffer } from '../layoutMode'
import CircuitElement from '../circuitElement'

/**
 * @category layout
 */
export default class LayoutNode {
    x: number
    y: number
    prevx: number | undefined
    prevy: number | undefined
    radius: number
    clicked: boolean
    hover: boolean
    wasClicked: boolean
    prev: string
    count: number
    objectType: string
    type: number
    id: string
    label: string
    parent: CircuitElement
    constructor(x: number, y: number, id: string, label = '', type: number, parent: CircuitElement) {
        this.type = type
        this.id = id

        this.label = label

        this.prevx = undefined
        this.prevy = undefined
        this.x = x // Position of node wrt to parent
        this.y = y // Position of node wrt to parent

        this.radius = 5
        this.clicked = false
        this.hover = false
        this.wasClicked = false
        this.prev = 'a'
        this.count = 0
        this.parent = parent
        this.objectType = 'Layout Node'
    }

    absX() {
        return this.x
    }

    absY() {
        return this.y
    }

    update() {
        // Code copied from node.update() - Some code is redundant - needs to be removed

        if (this === simulationArea.hover) simulationArea.hover = undefined
        this.hover = this.isHover()

        if (!simulationArea.mouseDown) {
            if (this.absX() !== this.prevx || this.absY() !== this.prevy) {
                // Store position before clicked
                this.prevx = this.absX()
                this.prevy = this.absY()
            }
        }

        if (this.hover) {
            simulationArea.hover = this
        }

        if (
            simulationArea.mouseDown &&
            ((this.hover && !simulationArea.selected) ||
                simulationArea.lastSelected === this)
        ) {
            simulationArea.selected = true
            simulationArea.lastSelected = this
            this.clicked = true
        } else {
            this.clicked = false
        }

        if (!this.wasClicked && this.clicked) {
            this.wasClicked = true
            this.prev = 'a'
            simulationArea.lastSelected = this
        } else if (this.wasClicked && this.clicked) {
            // Check if valid position and update accordingly
            if (
                tempBuffer.isAllowed(
                    simulationArea.mouseX,
                    simulationArea.mouseY
                ) &&
                !tempBuffer.isNodeAt(
                    simulationArea.mouseX,
                    simulationArea.mouseY
                )
            ) {
                this.x = simulationArea.mouseX
                this.y = simulationArea.mouseY
            }
        }
    }

    /**
     * @memberof layoutNode
     * this function is used to draw the nodes
     */
    draw() {
        var ctx = simulationArea.context
        drawCircle(
            ctx,
            this.absX(),
            this.absY(),
            3,
            ['green', 'red'][+(simulationArea.lastSelected === this)]
        )
    }

    /**
     * @memberof layoutNode
     * this function is used to check if hover
     */
    isHover() {
        return (
            this.absX() === simulationArea.mouseX &&
            this.absY() === simulationArea.mouseY
        )
    }
}
