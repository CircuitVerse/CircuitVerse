/**
 * Panel Visibility Manager for CircuitVerse
 * Handles hiding/showing panels to reduce canvas clutter
 */

// Panel visibility state
const panelVisibility = {
    circuitElements: true,
    timingDiagram: true,
    properties: true
};

// Panel selectors
const panels = {
    circuitElements: '.modules.ce-panel.elementPanel',
    timingDiagram: '.timing-diagram-panel',
    properties: '.moduleProperty.properties-panel'
};

// Icon selectors
const icons = {
    circuitElements: '#circuitElementsIcon',
    timingDiagram: '#timingDiagramIcon',
    properties: '#propertiesIcon'
};

/**
 * Initialize panel visibility functionality
 */
export function initializePanelVisibility() {
    // Load saved state from localStorage
    loadPanelState();
    
    // Apply initial state
    applyPanelState();
    
    // Bind event listeners
    bindEventListeners();
    
    // Save state on panel changes
    observePanelChanges();
}

/**
 * Load panel visibility state from localStorage
 */
function loadPanelState() {
    try {
        const saved = localStorage.getItem('circuitverse_panel_visibility');
        if (saved) {
            Object.assign(panelVisibility, JSON.parse(saved));
        }
    } catch (error) {
        console.warn('Could not load panel visibility state:', error);
    }
}

/**
 * Save panel visibility state to localStorage
 */
function savePanelState() {
    try {
        localStorage.setItem('circuitverse_panel_visibility', JSON.stringify(panelVisibility));
    } catch (error) {
        console.warn('Could not save panel visibility state:', error);
    }
}

/**
 * Apply current panel visibility state
 */
function applyPanelState() {
    Object.keys(panelVisibility).forEach(panelName => {
        const panel = $(panels[panelName]);
        const icon = $(icons[panelName]);
        
        if (panelVisibility[panelName]) {
            panel.show();
            icon.removeClass('fa-eye-slash').addClass('fa-eye');
        } else {
            panel.hide();
            icon.removeClass('fa-eye').addClass('fa-eye-slash');
        }
    });
}

/**
 * Bind event listeners for View menu options
 */
function bindEventListeners() {
    // Toggle individual panels
    $('#toggleCircuitElements').on('click', function(e) {
        e.preventDefault();
        togglePanel('circuitElements');
    });
    
    $('#toggleTimingDiagram').on('click', function(e) {
        e.preventDefault();
        togglePanel('timingDiagram');
    });
    
    $('#toggleProperties').on('click', function(e) {
        e.preventDefault();
        togglePanel('properties');
    });
    
    // Show/Hide all panels
    $('#showAllPanels').on('click', function(e) {
        e.preventDefault();
        showAllPanels();
    });
    
    $('#hideAllPanels').on('click', function(e) {
        e.preventDefault();
        hideAllPanels();
    });
    
    // Keyboard shortcuts
    $(document).on('keydown', function(e) {
        // Ctrl+Shift+E: Toggle Circuit Elements
        if (e.ctrlKey && e.shiftKey && e.key === 'E') {
            e.preventDefault();
            togglePanel('circuitElements');
        }
        // Ctrl+Shift+T: Toggle Timing Diagram
        if (e.ctrlKey && e.shiftKey && e.key === 'T') {
            e.preventDefault();
            togglePanel('timingDiagram');
        }
        // Ctrl+Shift+P: Toggle Properties
        if (e.ctrlKey && e.shiftKey && e.key === 'P') {
            e.preventDefault();
            togglePanel('properties');
        }
        // Ctrl+Shift+A: Show All Panels
        if (e.ctrlKey && e.shiftKey && e.key === 'A') {
            e.preventDefault();
            showAllPanels();
        }
        // Ctrl+Shift+H: Hide All Panels
        if (e.ctrlKey && e.shiftKey && e.key === 'H') {
            e.preventDefault();
            hideAllPanels();
        }
    });
}

/**
 * Toggle a specific panel's visibility
 */
function togglePanel(panelName) {
    panelVisibility[panelName] = !panelVisibility[panelName];
    
    const panel = $(panels[panelName]);
    const icon = $(icons[panelName]);
    
    if (panelVisibility[panelName]) {
        panel.fadeIn(200);
        icon.removeClass('fa-eye-slash').addClass('fa-eye');
    } else {
        panel.fadeOut(200);
        icon.removeClass('fa-eye').addClass('fa-eye-slash');
    }
    
    savePanelState();
    updateMenuStates();
    
    // Trigger custom event for other components
    $(document).trigger('panelVisibilityChanged', {
        panel: panelName,
        visible: panelVisibility[panelName]
    });
}

/**
 * Show all panels
 */
function showAllPanels() {
    Object.keys(panelVisibility).forEach(panelName => {
        panelVisibility[panelName] = true;
    });
    
    applyPanelState();
    savePanelState();
    updateMenuStates();
    
    $(document).trigger('allPanelsShown');
}

/**
 * Hide all panels
 */
function hideAllPanels() {
    Object.keys(panelVisibility).forEach(panelName => {
        panelVisibility[panelName] = false;
    });
    
    applyPanelState();
    savePanelState();
    updateMenuStates();
    
    $(document).trigger('allPanelsHidden');
}

/**
 * Update menu states to reflect current panel visibility
 */
function updateMenuStates() {
    Object.keys(panelVisibility).forEach(panelName => {
        const icon = $(icons[panelName]);
        if (panelVisibility[panelName]) {
            icon.removeClass('fa-eye-slash').addClass('fa-eye');
        } else {
            icon.removeClass('fa-eye').addClass('fa-eye-slash');
        }
    });
}

/**
 * Observe panel changes to sync with manual interactions
 */
function observePanelChanges() {
    // Observe manual panel minimize/maximize
    $('.minimize, .maximize').on('click', function() {
        const panel = $(this).closest('.draggable-panel');
        const panelName = getPanelName(panel);
        
        if (panelName) {
            // Check if panel is being minimized
            setTimeout(() => {
                const isVisible = panel.is(':visible');
                panelVisibility[panelName] = isVisible;
                savePanelState();
                updateMenuStates();
            }, 100);
        }
    });
}

/**
 * Get panel name from jQuery element
 */
function getPanelName(panelElement) {
    if (panelElement.hasClass('ce-panel') || panelElement.hasClass('elementPanel')) {
        return 'circuitElements';
    }
    if (panelElement.hasClass('timing-diagram-panel')) {
        return 'timingDiagram';
    }
    if (panelElement.hasClass('moduleProperty') || panelElement.hasClass('properties-panel')) {
        return 'properties';
    }
    return null;
}

/**
 * Get current panel visibility state
 */
export function getPanelVisibility() {
    return { ...panelVisibility };
}

/**
 * Set panel visibility state
 */
export function setPanelVisibility(state) {
    Object.assign(panelVisibility, state);
    applyPanelState();
    savePanelState();
}

/**
 * Check if any panels are visible
 */
export function hasVisiblePanels() {
    return Object.values(panelVisibility).some(visible => visible);
}

/**
 * Get count of visible panels
 */
export function getVisiblePanelCount() {
    return Object.values(panelVisibility).filter(visible => visible).length;
}

/**
 * Reset panel visibility to default
 */
export function resetPanelVisibility() {
    panelVisibility.circuitElements = true;
    panelVisibility.timingDiagram = true;
    panelVisibility.properties = true;
    
    applyPanelState();
    savePanelState();
    
    $(document).trigger('panelVisibilityReset');
}

// Auto-initialize when DOM is ready
$(document).ready(function() {
    if (typeof window !== 'undefined' && window.location.pathname.includes('/simulator')) {
        initializePanelVisibility();
    }
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initializePanelVisibility,
        getPanelVisibility,
        setPanelVisibility,
        hasVisiblePanels,
        getVisiblePanelCount,
        resetPanelVisibility
    };
}
