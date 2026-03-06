/**
 * State Renderer - Renders individual FSM states on canvas
 * @category FSM Editor
 */

export default class StateRenderer {
  /**
   * Creates a state renderer
   * @param {object} stateData - State data from FSMModel
   */
  constructor(stateData) {
    this.stateData = stateData;
    this.radius = 30;
  }

  /**
   * Draw the state on canvas
   * @param {CanvasRenderingContext2D} ctx - Canvas context
   * @param {string} type - FSM type ('moore' or 'mealy')
   */
  draw(ctx, type) {
    const { x, y, label, output, isSelected } = this.stateData;

    // Draw state circle
    ctx.fillStyle = isSelected ? '#4CAF50' : '#2196F3';
    ctx.strokeStyle = isSelected ? '#2E7D32' : '#1976D2';
    ctx.lineWidth = isSelected ? 3 : 2;

    ctx.beginPath();
    ctx.arc(x, y, this.radius, 0, 2 * Math.PI);
    ctx.fill();
    ctx.stroke();

    // Draw label
    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 12px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    if (type === 'moore' && output) {
      // Moore machine: output inside state circle (bottom)
      ctx.fillText(label, x, y - 10);
      ctx.font = '10px Arial';
      ctx.fillStyle = '#FFEB3B';
      ctx.fillText(output, x, y + 10);
    } else {
      // Standard display
      ctx.font = 'bold 12px Arial';
      ctx.fillText(label, x, y);
    }
  }

  /**
   * Check if point is inside this state
   * @param {number} px - Point X
   * @param {number} py - Point Y
   * @returns {boolean} True if point is inside state
   */
  contains(px, py) {
    const dx = px - this.stateData.x;
    const dy = py - this.stateData.y;
    return Math.sqrt(dx * dx + dy * dy) <= this.radius;
  }

  /**
   * Move state to new position
   * @param {number} x - New X coordinate
   * @param {number} y - New Y coordinate
   */
  moveTo(x, y) {
    this.stateData.x = x;
    this.stateData.y = y;
  }

  /**
   * Get state radius
   * @returns {number} Radius in pixels
   */
  getRadius() {
    return this.radius;
  }
}
