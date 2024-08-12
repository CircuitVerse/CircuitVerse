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
        ref="layoutElementPanelRef"
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
    <!-- Testbench -->
    <TestBenchPanel />
    <!-- --------------------------------------------------------------------------------------------- -->
    <TestBenchCreator />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Message Display -->
    <div id="MessageDiv">
        <div v-for="mes in useState().successMessages" class='alert alert-success' role='alert'> {{ mes }}</div>
        <div v-for="error in useState().errorMessages" class='alert alert-danger' role='alert'> {{ error }}</div>
    </div>
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
    <div id="CustomColorThemesDialog" class="customScroll" tabindex="0" style="display: none" title="Custom Theme">
    </div>
    <input id="importThemeFile" type="file" name="themeFile" style="display: none" multiple />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Simulation Area - Canvas (3) + Help Section-->
    <div id="simulation" class="simulation">
        <!-- <div id="restrictedDiv" class="alert alert-danger display--none"></div> -->
        <div id="canvasArea" class="canvasArea">
            <canvas id="backgroundArea" style="
                    position: absolute;
                    left: 0;
                    top: 0;
                    z-index: 0;
                    width: 100%;
                    height: 100%;
                "></canvas>
            <canvas id="simulationArea" style="
                    position: absolute;
                    left: 0;
                    top: 0;
                    z-index: 1;
                    width: 100%;
                    height: 100%;
                "></canvas>
            <div id="miniMap">
                <canvas id="miniMapArea" style="position: absolute; left: 0; top: 0; z-index: 3"></canvas>
            </div>

            <div id="Help"></div>
            <div class="sk-folding-cube loadingIcon" style="
                    display: none;
                    position: absolute;
                    right: 50%;
                    bottom: 50%;
                    z-index: 100;
                ">
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
    <!-- Dialog Box - Testbench -->
     <TestBenchValidator />
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
import TestBenchPanel from './Panels/TestBenchPanel/TestBenchPanel.vue'
import TestBenchCreator from './Panels/TestBenchPanel/TestBenchCreator.vue'
import TestBenchValidator from './Panels/TestBenchPanel/TestBenchValidator.vue'
import { useState } from '#/store/SimulatorStore/state'
</script>