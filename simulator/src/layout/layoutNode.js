/* eslint-disable quotes */
/* eslint-disable semi */
import { drawCircle } from '../canvasApi';
import simulationArea from '../simulationArea';
import { tempBuffer } from '../layoutMode';

/**
 * @class
 * @param {number} x - x coord of node
 * @param {number} y - y coord of node
 * @param {strng} id - id for node
 * @param {string=} label - label for the node
 * @param {number} xx - parent x
 * @param {number} yy - parent y
 * @param {number} type - input or output node
 * @param {CircuitElement} parent  parent of the node
 * @category layout
 */
export default class LayoutNode {
  constructor (x, y, id, label = '', type, parent) {
    this.type = type;
    this.id = id;

    this.label = label;

    this.prevx = undefined;
    this.prevy = undefined;
    this.x = x; // Position of node wrt to parent
    this.y = y; // Position of node wrt to parent

    this.radius = 5;
    this.clicked = false;
    this.hover = false;
    this.wasClicked = false;
    this.prev = 'a';
    this.count = 0;
    this.parent = parent;
    this.objectType = "Layout Node";
  }

  absX () {
    return this.x;
  }

  absY () {
    return this.y;
  }

  update () {
    // Code copied from node.update() - Some code is redundant - needs to be removed

    if (this === simulationArea.hover) simulationArea.hover = undefined;
    this.hover = this.isHover();

    if (!simulationArea.touchMouseDown) {
      if (this.absX() !== this.prevx || this.absY() !== this.prevy) {
        // Store position before clicked
        this.prevx = this.absX();
        this.prevy = this.absY();
      }
    }

    if (this.hover) {
      simulationArea.hover = this;
    }

    if (simulationArea.touchMouseDown && ((this.hover && !simulationArea.selected) || simulationArea.lastSelected === this)) {
      simulationArea.selected = true;
      simulationArea.lastSelected = this;
      this.clicked = true;
    } else {
      this.clicked = false;
    }

    if (!this.wasClicked && this.clicked) {
      this.wasClicked = true;
      this.prev = 'a';
      simulationArea.lastSelected = this;
    } else if (this.wasClicked && this.clicked) {
      // Check if valid position and update accordingly
      if (tempBuffer.isAllowed(simulationArea.x, simulationArea.y) && !tempBuffer.isNodeAt(simulationArea.x, simulationArea.y)) {
        this.x = simulationArea.x;
        this.y = simulationArea.x;
      }
    }
  }

  /**
     * @memberof layoutNode
     * this function is used to draw the nodes
     */
  draw () {
    const ctx = simulationArea.context;
    drawCircle(ctx, this.absX(), this.absY(), 3, ['green', 'red'][+(simulationArea.lastSelected === this)]);
  }

  /**
     * @memberof layoutNode
     * this function is used to check if hover
     */
  isHover () {
    return this.absX() === simulationArea.x && this.absY() === simulationArea.y;
  }
}
