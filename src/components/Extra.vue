<template>
    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- TabsBar -->
    <TabsBar />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Verilog Code Editor -->
    <ExportVerilog />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Circuit Elements Panel -->
    <ElementsPanel />
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
            <div id="subcircuitMenu" class="accordion"></div>
        </div>
    </div>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Timing Diagram Panel -->
    <TimingDiagramPanel />
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
                    <span id="data-title" class="tb-data"
                        ><b>Test:</b> <span></span
                    ></span>
                    <span id="data-type" class="tb-data"
                        ><b>Type:</b> <span></span
                    ></span>
                </div>
                <button
                    id="edit-test-btn"
                    class="custom-btn--basic panel-button tb-dialog-button"
                >
                    Edit
                </button>
                <button
                    id="remove-test-btn"
                    class="custom-btn--tertiary panel-button tb-dialog-button"
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
                        id="prev-group-btn"
                        class="custom-btn--basic panel-button tb-case-button-left tb-case-button"
                    >
                        <i class="tb-case-arrow tb-case-arrow-left"></i>
                    </button>
                    <span class="tb-test-label group-label"></span>
                    <button
                        id="next-group-btn"
                        class="custom-btn--basic panel-button tb-case-button-right tb-case-button"
                    >
                        <i class="tb-case-arrow tb-case-arrow-right"></i>
                    </button>
                </div>
                <div class="tb-manual-test-buttons tb-case-buttons">
                    <span style="line-height: 24px; margin-right: 5px"
                        ><b>Case: </b></span
                    >
                    <button
                        id="prev-case-btn"
                        class="custom-btn--basic panel-button tb-case-button-left tb-case-button"
                    >
                        <i class="tb-case-arrow tb-case-arrow-left"></i>
                    </button>
                    <span class="tb-test-label case-label"></span>
                    <button
                        id="next-case-btn"
                        class="custom-btn--basic panel-button tb-case-button-right tb-case-button"
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
                        id="validate-btn"
                        class="custom-btn--basic panel-button tb-dialog-button"
                    >
                        Validate
                    </button>
                    <button
                        id="runall-btn"
                        class="custom-btn--primary panel-button tb-dialog-button"
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
                    id="attach-test-btn"
                    class="custom-btn--primary panel-button tb-dialog-button"
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
    <VerilogEditorPanel />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Element Properties Panel -->
    <PropertiesPanel />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <CustomShortcut />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Save -->
    <SaveImage />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Custom Themes -->
    <!-- <div
        id="colorThemesDialog"
        class="customScroll colorThemesDialog"
        tabindex="0"
        style="display: none"
        title="Select Theme"
    ></div> -->
    <ApplyThemes />
    <div
        id="CustomColorThemesDialog"
        class="customScroll"
        tabindex="0"
        style="display: none"
        title="Custom Theme"
    ></div>
    <input
        id="importThemeFile"
        type="file"
        name="themeFile"
        style="display: none"
        multiple
    />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Simulation Area - Canvas (3) + Help Section-->
    <div id="simulation" class="simulation">
        <!-- <div id="restrictedDiv" class="alert alert-danger display--none"></div> -->
        <div id="canvasArea" class="canvasArea">
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
    <CombinationalAnalysis />
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
    <InsertSubcircuit />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Dialog Box - Open Project -->
    <OpenOffline />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- Dialog Box - Hex Bin Dec --------------------------------------------------------------------------------------------- -->
    <HexBinDec />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!---issue reporting-system----->
    <ReportIssue />
    <!-- --------------------------------------------------------------------------------------------- -->
</template>

<script lang="ts" setup>
import VerilogEditorPanel from './Panels/VerilogEditorPanel/VerilogEditorPanel.vue'
import ElementsPanel from './Panels/ElementsPanel/ElementsPanel.vue'
import PropertiesPanel from './Panels/PropertiesPanel/PropertiesPanel.vue'
import TimingDiagramPanel from './Panels/TimingDiagramPanel/TimingDiagramPanel.vue'
import TabsBar from './TabsBar/TabsBar.vue'
import CombinationalAnalysis from './DialogBox/CombinationalAnalysis.vue'
import HexBinDec from './DialogBox/HexBinDec.vue'
import SaveImage from './DialogBox/SaveImage.vue'
import ApplyThemes from './DialogBox/Themes/ApplyThemes.vue'
import ExportVerilog from './DialogBox/ExportVerilog.vue'
import CustomShortcut from './DialogBox/CustomShortcut.vue'
import InsertSubcircuit from './DialogBox/InsertSubcircuit.vue'
import OpenOffline from './DialogBox/OpenOffline.vue'
import ReportIssue from './ReportIssue/ReportIssue.vue'
</script>