<template>
    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- TabsBar -->
    <div id="tabsBar" class="noSelect pointerCursor">
        <button class="logixButton" id="createNewCircuitScope" onclick="">
            &#43;
        </button>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Verilog Code Editor -->
    <div
        title="Export Verilog"
        id="verilog-export-code-window-div"
        style="display: none"
    >
        <textarea id="verilog-export-code-window"></textarea>
    </div>
    <div id="code-window" class="code-window">
        <textarea id="codeTextArea"></textarea>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Circuit Elements Panel -->
    <div
        class="modules noSelect defaultCursor ce-panel elementPanel draggable-panel draggable-panel-css"
        id="guide_1"
    >
        <div class="panel-header">
            Circuit Elements
            <span class="fas fa-minus-square minimize"></span>
            <span class="fas fa-external-link-square-alt maximize"></span>
        </div>
        <div class="panel-body" id="testid">
            <div style="position: relative">
                <input
                    type="text"
                    class="search-input"
                    value=""
                    placeholder="Search.."
                />
                <span><i class="fas search-close fa-times-circle"></i></span>
            </div>
            <div class="search-results"></div>
            <div class="accordion" id="menu"></div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Layout Element Panel -->
    <div
        class="noSelect defaultCursor layoutElementPanel draggable-panel draggable-panel-css"
    >
        <div class="panel-header">
            Layout Elements
            <span class="fas fa-minus-square minimize"></span>
            <span class="fas fa-external-link-square-alt maximize"></span>
        </div>
        <div class="panel-body">
            <div class="search-results"></div>
            <div class="accordion" id="subcircuitMenu"></div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Timing Diagram Panel -->
    <div class="timing-diagram-panel draggable-panel">
        <!-- Timing Diagram Panel -->
        <div class="panel-header">
            Timing Diagram
            <span class="fas fa-minus-square minimize panel-button"></span>
            <span
                class="fas fa-external-link-square-alt maximize panel-button-icon"
            ></span>
        </div>
        <div class="panel-body">
            <div class="timing-diagram-toolbar noSelect">
                <button
                    class="custom-btn--primary panel-button"
                    title="Decrease Size"
                >
                    <span
                        class="fas fa-chevron-left timing-diagram-smaller panel-button-icon"
                    ></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Increase Size"
                >
                    <span
                        class="fas fa-chevron-right timing-diagram-larger panel-button-icon"
                    ></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Decrease Height"
                >
                    <span
                        class="fas fa-chevron-up timing-diagram-small-height panel-button-icon"
                    ></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Increase Height"
                >
                    <span
                        class="fas fa-chevron-down timing-diagram-large-height panel-button-icon"
                    ></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Download As Image"
                >
                    <span
                        class="fas fa-download timing-diagram-download"
                    ></span>
                </button>
                <button
                    class="custom-btn--tertiary panel-button"
                    title="Reset Timing Diagram"
                >
                    <span class="fas fa-undo timing-diagram-reset"></span>
                </button>
                <button
                    class="custom-btn--tertiary panel-button"
                    title="Autocalibrate Cycle Units"
                >
                    <span class="fas fa-magic timing-diagram-calibrate"></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Zoom In"
                >
                    <span
                        class="fas fa-search-plus timing-diagram-zoom-in"
                    ></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Zoom Out"
                >
                    <span
                        class="fas fa-search-minus timing-diagram-zoom-out"
                    ></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Resume auto-scroll"
                >
                    <span class="fas fa-play timing-diagram-resume"></span>
                </button>
                <button
                    class="custom-btn--primary panel-button"
                    title="Pause auto-scroll"
                >
                    <span class="fas fa-pause timing-diagram-pause"></span>
                </button>
                1 cycle =
                <input
                    id="timing-diagram-units"
                    type="number"
                    min="1"
                    autocomplete="off"
                    value="1000"
                />
                Units
                <span id="timing-diagram-log"></span>
            </div>
            <div id="plot">
                <canvas id="plotArea"></canvas>
            </div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Testbench Panel -->
    <div class="testbench-manual-panel draggable-panel noSelect defaultCursor">
        <div class="panel-header">
            Testbench
            <span class="fas fa-minus-square minimize panel-button"></span>
            <span
                class="fas fa-external-link-square-alt maximize panel-button-icon"
            ></span>
        </div>
        <div class="panel-body tb-test-not-null tb-panel-hidden">
            <div class="tb-manual-test-data">
                <div style="margin-bottom: 10px; overflow: auto">
                    <span class="tb-data" id="data-title"
                        ><b>Test:</b> <span></span
                    ></span>
                    <span class="tb-data" id="data-type"
                        ><b>Type:</b> <span></span
                    ></span>
                </div>
                <button
                    class="custom-btn--basic panel-button tb-dialog-button"
                    id="edit-test-btn"
                >
                    Edit
                </button>
                <button
                    class="custom-btn--tertiary panel-button tb-dialog-button"
                    id="remove-test-btn"
                >
                    Remove
                </button>
            </div>
            <div style="overflow: auto; margin-bottom: 10px">
                <div class="tb-manual-test-buttons tb-group-buttons">
                    <span style="line-height: 24px; margin-right: 5px"
                        ><b>Group: </b></span
                    >
                    <button
                        class="custom-btn--basic panel-button tb-case-button-left tb-case-button"
                        id="prev-group-btn"
                    >
                        <i class="tb-case-arrow tb-case-arrow-left"></i>
                    </button>
                    <span class="tb-test-label group-label"></span>
                    <button
                        class="custom-btn--basic panel-button tb-case-button-right tb-case-button"
                        id="next-group-btn"
                    >
                        <i class="tb-case-arrow tb-case-arrow-right"></i>
                    </button>
                </div>
                <div class="tb-manual-test-buttons tb-case-buttons">
                    <span style="line-height: 24px; margin-right: 5px"
                        ><b>Case: </b></span
                    >
                    <button
                        class="custom-btn--basic panel-button tb-case-button-left tb-case-button"
                        id="prev-case-btn"
                    >
                        <i class="tb-case-arrow tb-case-arrow-left"></i>
                    </button>
                    <span class="tb-test-label case-label"></span>
                    <button
                        class="custom-btn--basic panel-button tb-case-button-right tb-case-button"
                        id="next-case-btn"
                    >
                        <i class="tb-case-arrow tb-case-arrow-right"></i>
                    </button>
                </div>
            </div>
            <div style="text-align: center">
                <table class="tb-manual-table">
                    <tr id="tb-manual-table-labels">
                        <th>LABELS</th>
                    </tr>
                    <tr id="tb-manual-table-bitwidths">
                        <td>Bitwidth</td>
                    </tr>
                    <tr id="tb-manual-table-current-case">
                        <td>Current Case</td>
                    </tr>
                    <tr id="tb-manual-table-test-result">
                        <td>Result</td>
                    </tr>
                </table>
            </div>
            <div style="display: table; margin-top: 20px; margin-left: 8px">
                <div class="testbench-manual-panel-buttons">
                    <button
                        class="custom-btn--basic panel-button tb-dialog-button"
                        id="validate-btn"
                    >
                        Validate
                    </button>
                    <button
                        class="custom-btn--primary panel-button tb-dialog-button"
                        id="runall-btn"
                    >
                        Run All
                    </button>
                </div>
                <span class="testbench-runall-label">
                    <span id="runall-summary">placeholder</span> Tests Passed
                    <span id="runall-detailed-link" style="color: #18a2cd"
                        >View Detailed</span
                    >
                </span>
            </div>
        </div>
        <div class="panel-body tb-test-null">
            <div class="tb-manual-test-data">
                <div style="margin-bottom: 10px; overflow: auto">
                    <p><i>No Test is attached to the current circuit</i></p>
                </div>
                <button
                    class="custom-btn--primary panel-button tb-dialog-button"
                    id="attach-test-btn"
                >
                    Attach Test
                </button>
            </div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Message Display -->
    <div id="MessageDiv"></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Verilog Editor Panel -->
    <div
        class="noSelect defaultCursor draggable-panel draggable-panel-css"
        id="verilogEditorPanel"
    >
        <div class="panel-header">
            Verilog Module
            <span class="fas fa-minus-square minimize"></span>
            <span class="fas fa-external-link-square-alt maximize"></span>
        </div>

        <div class="panel-body">
            <div class="layout-body">
                <button
                    class="largeButton btn logixButton btn-xs custom-btn--tertiary"
                    id="resetVerilogCode"
                >
                    Reset Code
                </button>
                <button
                    class="largeButton btn logixButton btn-xs custom-btn--primary"
                    id="saveVerilogCode"
                >
                    Save Code
                </button>
                <div id="verilogOutput">
                    This is an experimental module. The code is not saved unless
                    the "Save Code" button is clicked.
                </div>
            </div>
        </div>

        <div class="panel-header text-center">Apply Themes</div>
        <div class="panel-body">
            <div class="layout-body">
                <div>
                    <p class="text-center mb-2">Select a theme:</p>
                    <select
                        id="selectVerilogTheme"
                        class="applyTheme"
                        style="width: 90%"
                    >
                        <optgroup label="Light Themes">
                            <option>default</option>
                            <option>solarized</option>
                            <option>elegant</option>
                            <option>neat</option>
                            <option>idea</option>
                            <option>neo</option>
                        </optgroup>
                        <optgroup label="Dark Themes">
                            <option>blackboard</option>
                            <option>cobalt</option>
                            <option>night</option>
                            <option>the-matrix</option>
                            <option>midnight</option>
                            <option>monokai</option>
                        </optgroup>
                    </select>
                </div>
            </div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Element Properties Panel -->
    <div
        class="moduleProperty noSelect effect1 properties-panel draggable-panel draggable-panel-css guide_2"
        id="moduleProperty"
    >
        <div id="moduleProperty-title" class="noSelect panel-header">
            Properties
            <span class="fas fa-minus-square minimize"></span>
            <span class="fas fa-external-link-square-alt maximize"></span>
        </div>
        <div class="panel-body"><div id="moduleProperty-inner"></div></div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <div id="customShortcutDialog" title="Keybinding Preference"></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Layout Panel -->
    <div id="layoutDialog" class="draggable-panel draggable-panel-css">
        <div class="panel-header">
            Layout
            <span class="fas fa-minus-square minimize"></span>
            <span class="fas fa-external-link-square-alt maximize"></span>
        </div>
        <div class="layout-body panel-body" id="layout-body">
            <div class="">
                <button
                    class="zoomButton btn-lg"
                    id="decreaseLayoutWidth"
                    title="Decrease Width"
                >
                    <span class="fa fa-minus" aria-hidden="true"></span>
                </button>
                <span>Width</span>
                <button
                    class="zoomButton btn-lg"
                    id="increaseLayoutWidth"
                    title="Increase Width"
                >
                    <span class="fa fa-plus" aria-hidden="true"></span>
                </button>
            </div>
            <div class="">
                <button
                    class="zoomButton btn-lg"
                    id="decreaseLayoutHeight"
                    title="Decrease Height"
                >
                    <span class="fa fa-minus" aria-hidden="true"></span>
                </button>
                <span>Height</span>
                <button
                    class="zoomButton btn-lg"
                    id="increaseLayoutHeight"
                    title="Increase Height"
                >
                    <span class="fa fa-plus" aria-hidden="true"></span>
                </button>
            </div>
            <div class="">
                <span>Reset all nodes:</span>
                <button class="zoomButton btn-lg" id="layoutResetNodes">
                    <span
                        class="fa fa-sync"
                        aria-hidden="true"
                        title="Reset"
                    ></span>
                </button>
            </div>
            <div class="layout-title">
                <span>Title</span>
                <div class="layout--btn-group">
                    <button
                        class="zoomButton-up btn-lg no-select"
                        id="layoutTitleUp"
                    >
                        <svg
                            id="Group_304"
                            data-name="Group 304"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(19.4 17.755) rotate(180)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                    <button
                        class="zoomButton-down btn-lg no-select"
                        id="layoutTitleDown"
                    >
                        <svg
                            id="Group_305"
                            data-name="Group 305"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(10 11.655)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                    <button
                        class="zoomButton-left btn-lg no-select"
                        id="layoutTitleLeft"
                    >
                        <svg
                            id="Group_306"
                            data-name="Group 306"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(18.1 9.655) rotate(90)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                    <button
                        class="zoomButton-right btn-lg no-select"
                        id="layoutTitleRight"
                    >
                        <svg
                            id="Group_307"
                            data-name="Group 307"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(12 19.055) rotate(-90)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                </div>
            </div>
            <div class="layout-title--enable">
                <span>Title Enabled:</span>
                <label class="switch">
                    <input type="checkbox" checked id="toggleLayoutTitle" />
                    <span class="slider"></span>
                </label>
            </div>
            <div class="">
                <button class="Layout-btn custom-btn--primary" id="saveLayout">
                    Save
                </button>

                <button
                    class="Layout-btn custom-btn--tertiary"
                    id="cancelLayout"
                >
                    Cancel
                </button>
            </div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Save -->
    <div
        id="saveImageDialog"
        class="noSelect"
        style="display: none"
        title="Render Image"
    >
        <div class="download-dialog-section-1">
            <label class="option custom-radio inline"
                ><input
                    type="radio"
                    name="imgType"
                    value="png"
                    checked="checked" />PNG<span></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="imgType" value="jpeg" />JPEG<span
                ></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="imgType" value="svg" />SVG<span
                ></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="imgType" value="bmp" />BMP<span
                ></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="imgType" value="gif" />GIF<span
                ></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="imgType" value="tiff" />TIFF<span
                ></span
            ></label>
        </div>
        <div class="download-dialog-section-2">
            <div
                class="option inline btn-group btn-group-toggle"
                style="border: none"
                data-toggle="buttons"
            >
                <div class="btn" id="radio-full" role="button">
                    <input type="radio" name="view" value="full" /> Full Circuit
                    View
                </div>
                <div class="btn active" id="radio-current" role="button">
                    <input
                        type="radio"
                        name="view"
                        value="current"
                        checked="checked"
                    />Current View
                </div>
            </div>
            <div class="download-dialog-section-2_2">
                <label class="cb-checkbox"
                    ><input
                        type="checkbox"
                        name="transparent"
                        value="transparent"
                    />Transparent Background</label
                >
            </div>
        </div>
        <div class="download-dialog-section-3">
            <span>Resolution:</span>
            <label class="option custom-radio inline"
                ><input
                    type="radio"
                    name="resolution"
                    value="1"
                    checked="checked" />1x<span></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="resolution" value="2" />2x<span
                ></span
            ></label>
            <label class="option custom-radio inline"
                ><input type="radio" name="resolution" value="4" />4x<span
                ></span
            ></label>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Custom Themes -->
    <div
        id="colorThemesDialog"
        class="customScroll colorThemesDialog"
        tabindex="0"
        style="display: none"
        title="Select Theme"
    ></div>
    <div
        id="CustomColorThemesDialog"
        class="customScroll"
        tabindex="0"
        style="display: none"
        title="Custom Theme"
    ></div>
    <input
        type="file"
        id="importThemeFile"
        name="themeFile"
        style="display: none"
        multiple
    />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Simulation Area - Canvas (3) + Help Section-->
    <div class="simulation" id="simulation">
        <!-- <div id="restrictedDiv" class="alert alert-danger display--none"></div> -->
        <div class="canvasArea" id="canvasArea">
            <canvas
                id="backgroundArea"
                style="
                    position: absolute;
                    left: 0;
                    top: 0;
                    z-index: 0;
                    width: 100%;
                    height: 100%;
                "
            ></canvas>
            <canvas
                id="simulationArea"
                style="
                    position: absolute;
                    left: 0;
                    top: 0;
                    z-index: 1;
                    width: 100%;
                    height: 100%;
                "
            ></canvas>
            <div id="miniMap">
                <canvas
                    id="miniMapArea"
                    style="position: absolute; left: 0; top: 0; z-index: 3"
                ></canvas>
            </div>

            <div id="Help"></div>
            <div
                class="sk-folding-cube loadingIcon"
                style="
                    display: none;
                    position: absolute;
                    right: 50%;
                    bottom: 50%;
                    z-index: 100;
                "
            >
                <div class="sk-cube1 sk-cube"></div>
                <div class="sk-cube2 sk-cube"></div>
                <div class="sk-cube4 sk-cube"></div>
                <div class="sk-cube3 sk-cube"></div>
            </div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Combinational Analysis -->
    <div
        id="combinationalAnalysis"
        style="display: none"
        title="BooleanLogicTable"
    ></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box 1 - Testbench -->
    <div id="setTestbenchData" style="display: none" title="Create Test"></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box 2 - Testbench -->
    <div
        id="testbenchValidate"
        style="display: none"
        title="Testbench Validation"
    ></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Insert Subcircuit -->
    <div
        id="insertSubcircuitDialog"
        class="subcircuitdialog"
        title="Insert SubCircuit"
    ></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Open Project -->
    <div
        id="openProjectDialog"
        style="display: none"
        title="Open Project"
    ></div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <div
        id="bitconverterprompt"
        title="Dec-Bin-Hex-Converter"
        style="display: none"
    >
        <label>Decimal value</label><br /><input
            type="text"
            id="decimalInput"
            value="16"
            label="Decimal"
            name="text1"
        /><br /><br />
        <label>Binary value</label><br /><input
            type="text"
            id="binaryInput"
            value="0b10000"
            label="Binary"
            name="text1"
        /><br /><br />
        <label>Binary-coded decimal value</label><br /><input
            type="text"
            id="bcdInput"
            value="10110"
            label="BCD"
            name="text1"
        /><br /><br />
        <label>Octal value</label><br /><input
            type="text"
            id="octalInput"
            value="020"
            label="Octal"
            name="text1"
        /><br /><br />
        <label>Hexadecimal value</label><br /><input
            type="text"
            id="hexInput"
            value="0x10"
            label="Hex"
            name="text1"
        /><br /><br />
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!---issue reporting-system----->
    <div class="report-sidebar">
        <a
            type="button"
            class="btn btn-primary text-light"
            data-toggle="modal"
            data-target=".issue"
        >
            <span class="fa fa-bug"></span>&nbsp;&nbsp;Report an issue</a
        >
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!---MODAL - issue reporting system---->
    <div
        class="modal fade issue"
        tabindex="-1"
        role="dialog"
        aria-labelledby="mySmallModalLabel"
        aria-hidden="true"
    >
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="container my-2">
                    <button
                        type="button"
                        class="close"
                        data-dismiss="modal"
                        aria-label="Close"
                    >
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <div class="container text-center">
                        <h4>Report an issue</h4>
                    </div>
                    <hr />
                    <div class="container my-2 text-center" id="result"></div>
                    <label id="report-label" style="font-weight: lighter"
                        ><b>Describe your issue:</b></label
                    >
                    <div class="form-group">
                        <textarea
                            class="form-control border-primary"
                            id="issuetext"
                            rows="3"
                        ></textarea>
                    </div>
                    <label
                        for="emailtext"
                        id="email-label"
                        style="font-weight: lighter"
                        ><b>Email</b><span> [Optional]</span>:</label
                    >
                    <div class="form-group">
                        <input
                            class="form-control border-primary"
                            type="email"
                            id="emailtext"
                            rows="3"
                        />
                    </div>
                    <div class="container">
                        <center>
                            <button
                                type="submit"
                                id="report"
                                class="btn btn-primary"
                            >
                                Report
                            </button>
                        </center>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->
</template>

<script>
export default {
    name: 'Extra',
}
</script>
