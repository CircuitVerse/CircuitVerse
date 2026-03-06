/**
 * FSM Tool - Integrates FSM editor into CircuitVerse simulator
 * Provides toolbar button and canvas overlay for FSM design
 * @category FSM Editor
 */

/* eslint-disable import/no-cycle */
import FSMEditor from './modules/fsm/fsmEditor';

let fsmTool = {
  // Tool properties
  active: false,
  editor: null,
  container: null,
  canvas: null,
  toolbar: null,

  /**
   * Initialize FSM tool
   */
  init() {
    // Don't reinitialize
    if (this.canvas) return;

    // Create container
    this.container = document.createElement('div');
    this.container.id = 'fsmContainer';
    this.container.style.cssText = `
      display: none;
      position: fixed;
      top: 60px;
      left: 250px;
      right: 0;
      bottom: 0;
      background: white;
      border-left: 1px solid #ccc;
      z-index: 20;
      flex-direction: column;
    `;

    // Create toolbar
    this.toolbar = document.createElement('div');
    this.toolbar.style.cssText = `
      background: #f5f5f5;
      border-bottom: 1px solid #ddd;
      padding: 10px;
      display: flex;
      gap: 10px;
      align-items: center;
      flex-wrap: wrap;
    `;

    // Create canvas
    this.canvas = document.createElement('canvas');
    this.canvas.id = 'fsmCanvas';
    this.canvas.style.cssText = `
      flex: 1;
      display: block;
      cursor: crosshair;
    `;

    // Setup toolbar buttons
    this.setupToolbar();

    // Add to container
    this.container.appendChild(this.toolbar);
    this.container.appendChild(this.canvas);

    // Add to body
    document.body.appendChild(this.container);
  },

  /**
   * Setup toolbar buttons
   * @protected
   */
  setupToolbar() {
    const buttons = [
      { id: 'fsmModeSelect', text: 'Select', mode: 'select' },
      { id: 'fsmModeAdd', text: 'Add States', mode: 'add' },
      { id: 'fsmModeConnect', text: 'Connect', mode: 'connect' },
      { id: 'fsmExport', text: 'Export', action: 'export' },
      { id: 'fsmImport', text: 'Import', action: 'import' },
      { id: 'fsmClear', text: 'Clear', action: 'clear' },
      { id: 'fsmClose', text: 'Close', action: 'close' },
    ];

    buttons.forEach(config => {
      const button = document.createElement('button');
      button.id = config.id;
      button.textContent = config.text;
      button.className = 'fsm-toolbar-btn';
      button.style.cssText = `
        padding: 6px 12px;
        background: #2196F3;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
        transition: background 0.2s;
      `;

      button.addEventListener('mouseenter', () => {
        if (button.style.backgroundColor !== '#1565C0') {
          button.style.background = '#1976D2';
        }
      });
      button.addEventListener('mouseleave', () => {
        if (!button.dataset.active) {
          button.style.background = '#2196F3';
        }
      });

      if (config.mode) {
        button.addEventListener('click', () => this.setMode(config.mode, button));
      } else if (config.action) {
        button.addEventListener('click', () => this.handleAction(config.action));
      }

      this.toolbar.appendChild(button);
    });

    // Set initial mode
    const selectBtn = this.toolbar.querySelector('#fsmModeSelect');
    if (selectBtn) {
      setTimeout(() => this.setMode('select', selectBtn), 100);
    }
  },

  /**
   * Set mode and update button styling
   * @protected
   */
  setMode(mode, button) {
    if (!this.editor) return;

    // Update button states
    this.toolbar.querySelectorAll('[data-mode]').forEach(btn => {
      btn.dataset.active = 'false';
      btn.style.background = '#2196F3';
    });

    button.dataset.active = 'true';
    button.style.background = '#1565C0';
    button.dataset.mode = mode;

    // Update editor mode
    this.editor.setMode(mode);

    // Show hint
    const hints = {
      'select': 'Click to select, drag to move',
      'add': 'Click to add states',
      'connect': 'Click two states to create transition',
    };
    console.log('FSM Mode:', hints[mode]);
  },

  /**
   * Handle toolbar actions
   * @protected
   */
  handleAction(action) {
    if (!this.editor) return;

    switch (action) {
      case 'export':
        this.editor.downloadJSON();
        console.log('FSM exported');
        break;
      case 'import':
        this.showImportDialog();
        break;
      case 'clear':
        this.editor.clear();
        break;
      case 'close':
        this.close();
        break;
    }
  },

  /**
   * Show import dialog
   * @protected
   */
  showImportDialog() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.addEventListener('change', (e) => {
      if (e.target.files[0]) {
        this.editor.loadFromJSON(e.target.files[0]);
      }
    });
    input.click();
  },

  /**
   * Open FSM editor
   */
  open() {
    this.init();

    // Show container
    this.container.style.display = 'flex';
    this.active = true;

    // Wait for container to be visible before creating editor
    setTimeout(() => {
      // Set canvas size
      const rect = this.canvas.getBoundingClientRect();
      this.canvas.width = rect.width;
      this.canvas.height = rect.height;

      // Create editor if not exists
      if (!this.editor) {
        this.editor = new FSMEditor('fsmCanvas');
      } else {
        // Just render existing
        this.editor.render();
      }

      // Handle window resize
      window.addEventListener('resize', () => this.handleResize());
    }, 100);

    console.log('FSM editor opened');
  },

  /**
   * Close FSM editor
   */
  close() {
    if (this.container) {
      this.container.style.display = 'none';
    }
    this.active = false;
    console.log('FSM editor closed');
  },

  /**
   * Handle window resize
   * @protected
   */
  handleResize() {
    if (!this.editor || !this.active) return;

    const rect = this.canvas.getBoundingClientRect();
    this.canvas.width = rect.width;
    this.canvas.height = rect.height;
    this.editor.render();
  },

  /**
   * Check if FSM tool is active
   */
  isActive() {
    return this.active;
  },

  /**
   * Get current FSM data for saving with circuit
   */
  getCircuitData() {
    if (!this.editor) return null;
    return this.editor.export();
  },

  /**
   * Load FSM data from saved circuit
   */
  loadCircuitData(data) {
    if (!this.editor) return;
    this.editor.import(data);
  },
};

export default fsmTool;
