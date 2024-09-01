<template>
    <QuickButtonMobile v-if="simulatorMobileStore.showQuickButtons && simulatorMobileStore.showMobileView" />
    <TimingDiagramMobile v-if="simulatorMobileStore.showMobileView" v-show="simulatorMobileStore.showTimingDiagram" />
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
    <ElementsPanel v-if="!simulatorMobileStore.showMobileView"/>
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Layout Element Panel -->
    <LayoutElementsPanel />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Timing Diagram Panel -->
    <TimingDiagramPanel v-if="!simulatorMobileStore.showMobileView" />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Testbench -->
    <TestBenchPanel v-if="!simulatorMobileStore.showMobileView" />
    <!-- --------------------------------------------------------------------------------------------- -->
    <TestBenchCreator v-if="!simulatorMobileStore.showMobileView" />
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
    <VerilogEditorPanel v-if="!simulatorMobileStore.showMobileView" />

    <div id="code-window" class="code-window">
        <textarea id="codeTextArea"></textarea>
    </div>
    <VerilogEditorPanelMobile v-if="simulatorMobileStore.showMobileView && simulatorMobileStore.showVerilogPanel" />
    <!-- --------------------------------------------------------------------------------------------- -->

    <!-- --------------------------------------------------------------------------------------------- -->
    <!-- Element Properties Panel -->
    <PropertiesPanel v-if="!simulatorMobileStore.showMobileView" />
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
                    @touchstart="(e) => {
                        simulationArea.touch = true;
                        panStart(e)
                    }"
                    @touchend="(e) => {
                        simulationArea.touch = true;
                        panStop(e)
                    }"
                    @touchmove="(e) => {
                        simulationArea.touch = true;
                        panMove(e)
                    }"
                    @mousedown="(e) => {
                        simulationArea.touch = false;
                        panStart(e)
                    }"
                    @mousemove="(e) => {
                        simulationArea.touch = false;
                        panMove(e)
                    }"
                    @mouseup="(e) => {
                        simulationArea.touch = false;
                        panStop(e)
                    }"
            ></canvas>
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

    <v-btn
      class="cir-ele-btn"
      @mousedown="simulatorMobileStore.showElementsPanel = !simulatorMobileStore.showElementsPanel"
      :style="{bottom: simulatorMobileStore.showElementsPanel ? '10rem' : '2rem'}"
      v-if="simulatorMobileStore.showMobileButtons && simulatorMobileStore.showMobileView && !simulatorMobileStore.isVerilog"
    >
        <i class="fas fa-bezier-curve"></i>
    </v-btn>

    <v-btn
      class="cir-btn"
      @mousedown="(e: React.MouseEvent) => {
        if(simulationArea.shiftDown == false) {
            simulationArea.shiftDown = true;
            selectMultiple = true;
        }
        else {
            simulationArea.shiftDown = false;
            selectMultiple = false;
            e.preventDefault();
        }
      }"
      :style="{bottom: simulatorMobileStore.showElementsPanel ? '10rem' : '2rem', backgroundColor: selectMultiple ? 'var(--primary)' : 'var(--bg-toggle-btn-primary)'}"
      v-if="simulatorMobileStore.showMobileButtons && simulatorMobileStore.showMobileView && !simulatorMobileStore.isVerilog"
    >
        <i class="fa-solid fa-vector-square"></i>
    </v-btn>

    <v-btn
      class="cir-verilog-btn"
      @mousedown="simulatorMobileStore.showVerilogPanel = !simulatorMobileStore.showVerilogPanel"
      v-if="simulatorMobileStore.showMobileButtons && simulatorMobileStore.isVerilog && simulatorMobileStore.showMobileView"
    >
        <i class="fa-solid fa-gears"></i>
    </v-btn>

    <v-btn
      class="cir-btn"
      @mousedown="copyBtnClick()"
      :style="{bottom: simulatorMobileStore.showElementsPanel ? '16rem' : '8rem'}"
      v-if="simulatorMobileStore.showMobileButtons && simulatorMobileStore.showMobileView && !simulatorMobileStore.isCopy && !simulatorMobileStore.isVerilog"
    >
        <i class="fa-solid fa-copy"></i>
    </v-btn>

    <v-btn
      class="cir-btn"
      @mousedown="pasteBtnClick()"
      :style="{bottom: simulatorMobileStore.showElementsPanel ? '16rem' : '8rem'}"
      v-if="simulatorMobileStore.showMobileButtons && simulatorMobileStore.showMobileView && simulatorMobileStore.isCopy && !simulatorMobileStore.isVerilog"
    >
        <i class="fa-solid fa-paste"></i>
    </v-btn>

    <v-btn
      class="cir-btn"
      @mousedown="propertiesBtnClick()"
      :style="{bottom: simulatorMobileStore.showElementsPanel ? `${propertiesPanelPos.up}rem` : `${propertiesPanelPos.down}rem`}"
      v-if="simulatorMobileStore.showMobileButtons && simulatorMobileStore.showMobileView"
    >
        <i class="fa-solid fa-sliders"></i>
    </v-btn>

    <ElementsPanelMobile v-if="simulatorMobileStore.showMobileView" />
    <PropertiesPanelMobile v-if="simulatorMobileStore.showMobileView" />
</template>

<script lang="ts" setup>
import VerilogEditorPanel from './Panels/VerilogEditorPanel/VerilogEditorPanel.vue'
import VerilogEditorPanelMobile from './Panels/VerilogEditorPanel/VerilogEditorPanelMobile.vue'
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
import LayoutElementsPanel from './Panels/LayoutElementsPanel/LayoutElementsPanel.vue'
import TestBenchPanel from './Panels/TestBenchPanel/TestBenchPanel.vue'
import TestBenchCreator from './Panels/TestBenchPanel/TestBenchCreator.vue'
import TestBenchValidator from './Panels/TestBenchPanel/TestBenchValidator.vue'
import QuickButtonMobile from './Navbar/QuickButton/QuickButtonMobile.vue'
import TimingDiagramMobile from './Panels/TimingDiagramPanel/TimingDiagramMobile.vue'
import ElementsPanelMobile from './Panels/ElementsPanel/ElementsPanelMobile.vue'
import PropertiesPanelMobile from './Panels/PropertiesPanel/PropertiesPanelMobile.vue'
import { simulationArea } from '#/simulator/src/simulationArea'
import { paste } from '#/simulator/src/events'
import  { panStart, panMove, panStop } from '#/simulator/src/listeners'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'
import { useState } from '#/store/SimulatorStore/state'
import { reactive, ref, watch } from 'vue'

const simulatorMobileStore = useSimulatorMobileStore()
const selectMultiple = ref(false)
const propertiesPanelPos = reactive({
    up: 22,
    down: 14
});

watch(() => simulatorMobileStore.isVerilog, (val) => {
    if (val) {
        propertiesPanelPos.up = 10
        propertiesPanelPos.down = 2
    } else {
        propertiesPanelPos.up = 22
        propertiesPanelPos.down = 14
    }
})

const copyBtnClick = () => {
    window.document.execCommand('copy')
    simulationArea.shiftDown = false
    simulatorMobileStore.isCopy = true
}

const pasteBtnClick = () => {
    paste(localStorage.getItem('clipboardData'));
    simulatorMobileStore.isCopy = false
}

const propertiesBtnClick = () => {
    simulatorMobileStore.showPropertiesPanel = !simulatorMobileStore.showPropertiesPanel
}
</script>

<style scoped>
.cir-ele-btn, .cir-verilog-btn {
    position: absolute;
    right: 1.5rem;
    bottom: 15rem;
    z-index: 90;
    background-color: var(--bg-toggle-btn-primary);
    color: white;
    border-radius: 100%;
    font-size: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    transition: 0.3s;
    padding: 1rem;
    height: 4rem;
    width: 4rem;
}

.cir-verilog-btn {
    bottom: 2rem;
}

.cir-btn{
    position: absolute;
    left: 1.5rem;
    bottom: 2rem;
    z-index: 90;
    background-color: var(--bg-toggle-btn-primary);
    color: white;
    border-radius: 100%;
    font-size: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    transition: 0.3s;
    padding: 1rem;
    height: 4rem;
    width: 4rem;
}
</style>
