/**
 * Transition Renderer - Renders FSM transitions (arrows) on canvas
 * @category FSM Editor
 */

export default class TransitionRenderer {
  /**
   * Creates a transition renderer
   * @param {object} transitionData - Transition data from FSMModel
   * @param {object} fromState - Source state data
   * @param {object} toState - Target state data
   * @param {number} stateRadius - Radius of state circles
   */
  constructor(transitionData, fromState, toState, stateRadius = 30) {
    this.transitionData = transitionData;
    this.fromState = fromState;
    this.toState = toState;
    this.stateRadius = stateRadius;
    this.hitAreaWidth = 15; // Width of clickable area
  }

  /**
   * Draw the transition on canvas
   * @param {CanvasRenderingContext2D} ctx - Canvas context
   * @param {string} type - FSM type ('moore' or 'mealy')
   */
  draw(ctx, type) {
    const { fromStateId, toStateId, input, output, isSelected } = this.transitionData;

    // Check if it's a self-loop
    if (fromStateId === toStateId) {
      this.drawSelfLoop(ctx, input, output, type, isSelected);
    } else {
      this.drawNormalTransition(ctx, input, output, type, isSelected);
    }
  }

  /**
   * Draw a normal transition (between two different states)
   * @protected
   */
  drawNormalTransition(ctx, input, output, type, isSelected) {
    const { x: x1, y: y1 } = this.fromState;
    const { x: x2, y: y2 } = this.toState;

    // Calculate arrow start and end points (on circle circumference)
    const angle = Math.atan2(y2 - y1, x2 - x1);
    const startX = x1 + this.stateRadius * Math.cos(angle);
    const startY = y1 + this.stateRadius * Math.sin(angle);
    const endX = x2 - this.stateRadius * Math.cos(angle);
    const endY = y2 - this.stateRadius * Math.sin(angle);

    // Draw line
    ctx.strokeStyle = isSelected ? '#4CAF50' : '#333333';
    ctx.lineWidth = isSelected ? 3 : 2;
    ctx.beginPath();
    ctx.moveTo(startX, startY);
    ctx.lineTo(endX, endY);
    ctx.stroke();

    // Draw arrowhead
    this.drawArrowhead(ctx, endX, endY, angle, isSelected);

    // Draw label
    const midX = (startX + endX) / 2;
    const midY = (startY + endY) / 2;
    const offsetX = -Math.sin(angle) * 20;
    const offsetY = Math.cos(angle) * 20;

    ctx.fillStyle = isSelected ? '#4CAF50' : '#000000';
    ctx.font = '11px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    // Format label based on machine type
    const label = this.formatLabel(input, output, type);
    if (label) {
      ctx.fillText(label, midX + offsetX, midY + offsetY);
    }
  }

  /**
   * Draw a self-loop transition
   * @protected
   */
  drawSelfLoop(ctx, input, output, type, isSelected) {
    const { x, y } = this.fromState;
    const loopRadius = this.stateRadius + 25;
    const arcStartAngle = -Math.PI / 4;
    const arcEndAngle = Math.PI / 4;

    // Draw arc
    ctx.strokeStyle = isSelected ? '#4CAF50' : '#333333';
    ctx.lineWidth = isSelected ? 3 : 2;
    ctx.beginPath();
    ctx.arc(x, y - loopRadius, loopRadius, arcStartAngle, arcEndAngle, false);
    ctx.stroke();

    // Draw arrowhead at end
    const arrowAngle = Math.PI / 4;
    const arrowX = x + loopRadius * Math.sin(arrowAngle);
    const arrowY = y - loopRadius * Math.cos(arrowAngle);
    this.drawArrowhead(ctx, arrowX, arrowY, arrowAngle, isSelected);

    // Draw label
    ctx.fillStyle = isSelected ? '#4CAF50' : '#000000';
    ctx.font = '11px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const label = this.formatLabel(input, output, type);
    if (label) {
      ctx.fillText(label, x, y - loopRadius - 25);
    }
  }

  /**
   * Draw arrowhead
   * @protected
   */
  drawArrowhead(ctx, x, y, angle, isSelected) {
    const arrowSize = 12;
    const angle1 = angle + Math.PI / 6;
    const angle2 = angle - Math.PI / 6;

    ctx.fillStyle = isSelected ? '#4CAF50' : '#333333';
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x - arrowSize * Math.cos(angle1), y - arrowSize * Math.sin(angle1));
    ctx.lineTo(x - arrowSize * Math.cos(angle2), y - arrowSize * Math.sin(angle2));
    ctx.closePath();
    ctx.fill();
  }

  /**
   * Format transition label based on machine type
   * @protected
   */
  formatLabel(input, output, type) {
    if (type === 'mealy') {
      // Mealy: show "input/output"
      return `${input}/${output || ''}`.trim() || '';
    } else {
      // Moore: show only input
      return input || '';
    }
  }

  /**
   * Check if point is on this transition (within clickable area)
   * @param {number} px - Point X
   * @param {number} py - Point Y
   * @returns {boolean} True if point is on transition
   */
  contains(px, py) {
    const { fromStateId, toStateId } = this.transitionData;
    const { x: x1, y: y1 } = this.fromState;
    const { x: x2, y: y2 } = this.toState;

    if (fromStateId === toStateId) {
      // Self-loop: check distance to arc
      return this.pointOnArc(px, py, x1, y1, this.stateRadius + 25);
    } else {
      // Normal transition: check distance to line
      return this.pointOnLine(px, py, x1, y1, x2, y2);
    }
  }

  /**
   * Check if point is on line segment (with tolerance)
   * @protected
   */
  pointOnLine(px, py, x1, y1, x2, y2) {
    const dx = x2 - x1;
    const dy = y2 - y1;
    const len2 = dx * dx + dy * dy;
    if (len2 === 0) return Math.hypot(px - x1, py - y1) < this.hitAreaWidth;

    let t = Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / len2));
    const closestX = x1 + t * dx;
    const closestY = y1 + t * dy;

    return Math.hypot(px - closestX, py - closestY) < this.hitAreaWidth;
  }

  /**
   * Check if point is on arc
   * @protected
   */
  pointOnArc(px, py, cx, cy, radius) {
    const dist = Math.hypot(px - cx, py - cy);
    return Math.abs(dist - radius) < this.hitAreaWidth;
  }

  /**
   * Update transition data reference
   * @param {object} stateData - New state data
   * @param {string} type - 'from' or 'to'
   */
  updateStateReference(stateData, type) {
    if (type === 'from') {
      this.fromState = stateData;
    } else {
      this.toState = stateData;
    }
  }
}
