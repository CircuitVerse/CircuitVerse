/**
 * FSM Editor Integration Tests
 * Test suite to verify FSM editor works correctly with CircuitVerse
 * @category FSM Editor
 */

/* eslint-disable no-console */
/* eslint-disable no-undef */

/**
 * Manual Testing Checklist
 * Run these tests in the browser console after CircuitVerse loads
 */

console.log('FSM Editor Integration Tests');
console.log('============================');

// Test 1: Check FSM Tool is accessible
function testFSMToolLoaded() {
    console.log('\n[Test 1] Checking FSM Tool is loaded...');
    try {
        if (typeof fsmTool !== 'undefined') {
            console.log('✓ fsmTool is globally accessible');
            return true;
        } else {
            console.error('✗ fsmTool not found');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 2: Check toolbar button exists
function testToolbarButton() {
    console.log('\n[Test 2] Checking FSM button in toolbar...');
    try {
        const btn = document.getElementById('openFSMEditor');
        if (btn) {
            console.log('✓ FSM button found in DOM');
            return true;
        } else {
            console.error('✗ FSM button not found');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 3: Check fsmTool methods
function testFSMToolMethods() {
    console.log('\n[Test 3] Checking fsmTool methods...');
    try {
        const methods = ['open', 'close', 'isActive', 'getCircuitData', 'loadCircuitData'];
        const hasMethods = methods.every(m => typeof fsmTool[m] === 'function');
        if (hasMethods) {
            console.log('✓ All required methods exist:', methods.join(', '));
            return true;
        } else {
            console.error('✗ Some methods missing');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 4: Open FSM editor
function testOpenFSMEditor() {
    console.log('\n[Test 4] Opening FSM editor...');
    try {
        logixFunction.openFSMEditor();
        setTimeout(() => {
            const container = document.getElementById('fsmContainer');
            if (container && container.style.display !== 'none') {
                console.log('✓ FSM editor opened successfully');
                console.log('✓ Container is visible');
            } else {
                console.error('✗ Container not visible');
            }
        }, 500);
        return true;
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 5: Check FSM editor instance
function testFSMEditorInstance() {
    console.log('\n[Test 5] Checking FSM editor instance...');
    try {
        if (fsmTool.editor) {
            console.log('✓ FSM editor instance created');
            console.log('  - Model states:', fsmTool.editor.model.states.size);
            console.log('  - Transitions:', fsmTool.editor.model.transitions.length);
            console.log('  - Mode:', fsmTool.editor.mode);
            return true;
        } else {
            console.error('✗ FSM editor not initialized');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 6: Create test state
function testCreateState() {
    console.log('\n[Test 6] Creating test state...');
    try {
        if (!fsmTool.editor) {
            console.error('✗ FSM editor not initialized');
            return false;
        }

        const state = fsmTool.editor.model.createState(200, 200, 'TestState1', 'output1');
        if (state && state.id) {
            console.log('✓ State created successfully');
            console.log('  - ID:', state.id);
            console.log('  - Label:', state.label);
            console.log('  - Position:', `(${state.x}, ${state.y})`);
            return true;
        } else {
            console.error('✗ Failed to create state');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 7: Create second state
function testCreateSecondState() {
    console.log('\n[Test 7] Creating second state...');
    try {
        if (!fsmTool.editor) {
            console.error('✗ FSM editor not initialized');
            return false;
        }

        const state = fsmTool.editor.model.createState(400, 200, 'TestState2', 'output2');
        if (state && state.id) {
            console.log('✓ Second state created successfully');
            console.log('  - ID:', state.id);
            console.log('  - Total states:', fsmTool.editor.model.states.size);
            return true;
        } else {
            console.error('✗ Failed to create state');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 8: Create transition
function testCreateTransition() {
    console.log('\n[Test 8] Creating transition...');
    try {
        if (!fsmTool.editor || fsmTool.editor.model.states.size < 2) {
            console.error('✗ Need at least 2 states');
            return false;
        }

        const states = Array.from(fsmTool.editor.model.states.keys());
        const transition = fsmTool.editor.model.createTransition(
            states[0],
            states[1],
            'input_signal',
            'output_signal'
        );

        if (transition && transition.id) {
            console.log('✓ Transition created successfully');
            console.log('  - ID:', transition.id);
            console.log('  - From:', transition.fromStateId, '→ To:', transition.toStateId);
            console.log('  - Input/Output:', `${transition.input}/${transition.output}`);
            console.log('  - Total transitions:', fsmTool.editor.model.transitions.length);
            return true;
        } else {
            console.error('✗ Failed to create transition');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 9: Export FSM to JSON
function testExportFSM() {
    console.log('\n[Test 9] Exporting FSM to JSON...');
    try {
        if (!fsmTool.editor) {
            console.error('✗ FSM editor not initialized');
            return false;
        }

        const data = fsmTool.editor.export();
        if (data && data.states && data.transitions) {
            console.log('✓ FSM exported successfully');
            console.log('  - Type:', data.type);
            console.log('  - States:', data.states.length);
            console.log('  - Transitions:', data.transitions.length);
            console.log('  - JSON Size:', JSON.stringify(data).length, 'bytes');
            console.log('  - Exported data:', data);
            return true;
        } else {
            console.error('✗ Export failed');
            return false;
        }
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 10: Validate FSM
function testValidateFSM() {
    console.log('\n[Test 10] Validating FSM...');
    try {
        if (!fsmTool.editor) {
            console.error('✗ FSM editor not initialized');
            return false;
        }

        const result = fsmTool.editor.model.validate();
        console.log('✓ Validation complete');
        console.log('  - Is Valid:', result.isValid);
        console.log('  - Errors:', result.errors.length > 0 ? result.errors : 'None');
        return result.isValid;
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 11: Mode switching
function testModeSwitching() {
    console.log('\n[Test 11] Testing mode switching...');
    try {
        if (!fsmTool.editor) {
            console.error('✗ FSM editor not initialized');
            return false;
        }

        const modes = ['select', 'add', 'connect'];
        let allSuccess = true;

        modes.forEach(mode => {
            fsmTool.editor.setMode(mode);
            if (fsmTool.editor.mode === mode) {
                console.log(`  ✓ Mode '${mode}' set correctly`);
            } else {
                console.error(`  ✗ Mode '${mode}' failed`);
                allSuccess = false;
            }
        });

        return allSuccess;
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Test 12: Close FSM editor
function testCloseFSMEditor() {
    console.log('\n[Test 12] Closing FSM editor...');
    try {
        fsmTool.close();
        setTimeout(() => {
            const container = document.getElementById('fsmContainer');
            if (container && container.style.display === 'none') {
                console.log('✓ FSM editor closed successfully');
            } else {
                console.error('✗ Container still visible');
            }
        }, 300);
        return true;
    } catch (e) {
        console.error('✗ Error:', e.message);
        return false;
    }
}

// Run all tests
function runAllTests() {
    console.log('Starting comprehensive test suite...\n');

    const results = [];
    results.push({ name: 'FSM Tool Loaded', pass: testFSMToolLoaded() });
    results.push({ name: 'Toolbar Button Exists', pass: testToolbarButton() });
    results.push({ name: 'FSM Tool Methods', pass: testFSMToolMethods() });
    results.push({ name: 'Open FSM Editor', pass: testOpenFSMEditor() });

    // Wait for editor to open before running tests
    setTimeout(() => {
        results.push({ name: 'FSM Editor Instance', pass: testFSMEditorInstance() });
        results.push({ name: 'Create State', pass: testCreateState() });
        results.push({ name: 'Create Second State', pass: testCreateSecondState() });
        results.push({ name: 'Create Transition', pass: testCreateTransition() });
        results.push({ name: 'Export FSM', pass: testExportFSM() });
        results.push({ name: 'Validate FSM', pass: testValidateFSM() });
        results.push({ name: 'Mode Switching', pass: testModeSwitching() });

        // Print summary
        printTestSummary(results);
    }, 1000);
}

// Print test summary
function printTestSummary(results) {
    console.log('\n============================');
    console.log('TEST SUMMARY');
    console.log('============================\n');

    results.forEach(result => {
        const icon = result.pass ? '✓' : '✗';
        const color = result.pass ? 'color: green' : 'color: red';
        console.log(`%c${icon} ${result.name}`, color);
    });

    const passed = results.filter(r => r.pass).length;
    const total = results.length;
    console.log(`\nTotal: ${passed}/${total} tests passed`);

    if (passed === total) {
        console.log('%c✓ All tests PASSED!', 'color: green; font-weight: bold; font-size: 14px');
    } else {
        console.log(`%c✗ ${total - passed} test(s) FAILED`, 'color: red; font-weight: bold; font-size: 14px');
    }
}

// Export for use
window.FSMTesting = {
    runAll: runAllTests,
    testToolLoaded: testFSMToolLoaded,
    testButton: testToolbarButton,
    testMethods: testFSMToolMethods,
    testOpen: testOpenFSMEditor,
    testInstance: testFSMEditorInstance,
    testCreateState,
    testCreateSecondState,
    testCreateTransition,
    testExport: testExportFSM,
    testValidate: testValidateFSM,
    testModeSwitching,
    testClose: testCloseFSMEditor,
};

console.log('\nTo run tests, use: FSMTesting.runAll()');
console.log('To run specific test, use: FSMTesting.testOpen(), etc.\n');
