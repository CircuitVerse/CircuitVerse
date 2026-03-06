/**
 * FSM Data Model - Manages the finite state machine data structure
 * @category FSM Editor
 *
 * Responsibilities:
 * - Store and manage states
 * - Store and manage transitions
 * - Provide factory methods for creating states and transitions
 * - Validate FSM integrity
 * - Support both Moore and Mealy machine types
 */

export default class FSMModel {
  /**
   * Creates a new FSM Model instance
   * @param {string} type - FSM type: 'moore' or 'mealy' (default: 'mealy')
   */
  constructor(type = 'mealy') {
    // Validate machine type
    if (!['moore', 'mealy'].includes(type.toLowerCase())) {
      throw new Error('FSM type must be "moore" or "mealy"');
    }

    this.type = type.toLowerCase();
    this.states = new Map();           // Store states by ID: Map<id, stateData>
    this.transitions = [];             // Array of transitions
    this.nextStateId = 1;              // Counter for unique state IDs
    this.nextTransitionId = 1;         // Counter for unique transition IDs
    this.selectedStateId = null;       // Currently selected state ID
    this.listeners = [];               // Event listeners for model changes
  }

  /**
   * Create a new state and add it to the FSM
   * @param {number} x - X coordinate of the state
   * @param {number} y - Y coordinate of the state
   * @param {string} label - State label
   * @param {string} output - Output (for Moore machines) or null
   * @returns {object} The created state
   */
  createState(x, y, label = '', output = null) {
    const id = this.nextStateId++;

    const state = {
      id,
      x,
      y,
      label: label || `State${id}`,
      output,
      isSelected: false,
    };

    this.states.set(id, state);
    this.notifyListeners('stateAdded', { id, state });
    return state;
  }

  /**
   * Create a new transition and add it to the FSM
   * @param {number} fromStateId - Source state ID
   * @param {number} toStateId - Target state ID
   * @param {string} input - Input label
   * @param {string} output - Output label (for Mealy machines)
   * @returns {object} The created transition
   */
  createTransition(fromStateId, toStateId, input = '', output = null) {
    // Validate states exist
    if (!this.states.has(fromStateId) || !this.states.has(toStateId)) {
      throw new Error('Invalid state IDs for transition');
    }

    const id = this.nextTransitionId++;
    const transition = {
      id,
      fromStateId,
      toStateId,
      input: input || '',
      output: output || (this.type === 'moore' ? null : ''),
      isSelected: false,
    };

    this.transitions.push(transition);
    this.notifyListeners('transitionAdded', { id, transition });
    return transition;
  }

  /**
   * Delete a state and its associated transitions
   * @param {number} stateId - ID of state to delete
   */
  deleteState(stateId) {
    if (!this.states.has(stateId)) return false;

    // Remove state
    this.states.delete(stateId);

    // Remove transitions connected to this state
    this.transitions = this.transitions.filter(t => {
      const shouldRemove = t.fromStateId === stateId || t.toStateId === stateId;
      if (shouldRemove) {
        this.notifyListeners('transitionDeleted', { id: t.id });
      }
      return !shouldRemove;
    });

    this.notifyListeners('stateDeleted', { id: stateId });
    return true;
  }

  /**
   * Delete a transition
   * @param {number} transitionId - ID of transition to delete
   */
  deleteTransition(transitionId) {
    const index = this.transitions.findIndex(t => t.id === transitionId);
    if (index === -1) return false;

    this.transitions.splice(index, 1);
    this.notifyListeners('transitionDeleted', { id: transitionId });
    return true;
  }

  /**
   * Get a state by ID
   * @param {number} stateId - State ID
   * @returns {object|null} State data or null if not found
   */
  getState(stateId) {
    return this.states.get(stateId) || null;
  }

  /**
   * Get all transitions from a specific state
   * @param {number} fromStateId - Source state ID
   * @returns {array} Array of transitions
   */
  getTransitionsFrom(fromStateId) {
    return this.transitions.filter(t => t.fromStateId === fromStateId);
  }

  /**
   * Get all transitions to a specific state
   * @param {number} toStateId - Target state ID
   * @returns {array} Array of transitions
   */
  getTransitionsTo(toStateId) {
    return this.transitions.filter(t => t.toStateId === toStateId);
  }

  /**
   * Get transition between two states
   * @param {number} fromStateId - Source state ID
   * @param {number} toStateId - Target state ID
   * @returns {object|null} Transition or null
   */
  getTransitionBetween(fromStateId, toStateId) {
    return this.transitions.find(t => t.fromStateId === fromStateId && t.toStateId === toStateId) || null;
  }

  /**
   * Update a state's properties
   * @param {number} stateId - State ID
   * @param {object} updates - Properties to update
   */
  updateState(stateId, updates) {
    const state = this.states.get(stateId);
    if (!state) return false;

    Object.assign(state, updates);
    this.notifyListeners('stateUpdated', { id: stateId, state });
    return true;
  }

  /**
   * Update a transition's properties
   * @param {number} transitionId - Transition ID
   * @param {object} updates - Properties to update
   */
  updateTransition(transitionId, updates) {
    const transition = this.transitions.find(t => t.id === transitionId);
    if (!transition) return false;

    Object.assign(transition, updates);
    this.notifyListeners('transitionUpdated', { id: transitionId, transition });
    return true;
  }

  /**
   * Validate FSM integrity
   * @returns {object} Validation result { isValid, errors }
   */
  validate() {
    const errors = [];

    // Check if FSM has at least one state
    if (this.states.size === 0) {
      errors.push('FSM must have at least one state');
    }

    // Check all transitions point to valid states
    for (const transition of this.transitions) {
      if (!this.states.has(transition.fromStateId)) {
        errors.push(`Transition ${transition.id} has invalid source state`);
      }
      if (!this.states.has(transition.toStateId)) {
        errors.push(`Transition ${transition.id} has invalid target state`);
      }
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  /**
   * Export FSM to JSON
   * @returns {object} JSON-serializable FSM data
   */
  export() {
    return {
      type: this.type,
      states: Array.from(this.states.values()),
      transitions: this.transitions,
    };
  }

  /**
   * Import FSM from JSON
   * @param {object} data - FSM data to import
   */
  import(data) {
    if (!data || typeof data !== 'object') {
      throw new Error('Invalid FSM data');
    }

    this.type = data.type || 'mealy';
    this.states = new Map();
    this.transitions = [];
    this.nextStateId = 1;
    this.nextTransitionId = 1;

    // Import states
    if (Array.isArray(data.states)) {
      data.states.forEach(state => {
        this.states.set(state.id, { ...state });
        this.nextStateId = Math.max(this.nextStateId, state.id + 1);
      });
    }

    // Import transitions
    if (Array.isArray(data.transitions)) {
      this.transitions = data.transitions.map(t => ({ ...t }));
      this.transitions.forEach(t => {
        this.nextTransitionId = Math.max(this.nextTransitionId, t.id + 1);
      });
    }

    this.notifyListeners('imported', {});
  }

  /**
   * Register an event listener
   * @param {function} callback - Function to call on model changes
   */
  on(callback) {
    if (typeof callback === 'function') {
      this.listeners.push(callback);
    }
  }

  /**
   * Remove an event listener
   * @param {function} callback - Function to remove
   */
  off(callback) {
    const index = this.listeners.indexOf(callback);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * Notify all listeners of a model change
   * @param {string} event - Event type
   * @param {object} data - Event data
   * @protected
   */
  notifyListeners(event, data) {
    this.listeners.forEach(callback => {
      try {
        callback(event, data);
      } catch (e) {
        console.error('Event listener error:', e);
      }
    });
  }

  /**
   * Clear all FSM data
   */
  clear() {
    this.states.clear();
    this.transitions = [];
    this.nextStateId = 1;
    this.nextTransitionId = 1;
    this.selectedStateId = null;
    this.notifyListeners('cleared', {});
  }
}
