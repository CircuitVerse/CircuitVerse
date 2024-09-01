<template>
    <div class="panel-body">
        <div class="timing-diagram-toolbar noSelect">
            <div class="timing-btn-container">
                <TimingDiagramButtons
                  v-for="button in timingDiagramPanelStore.buttons"
                  :key="button.title"
                  :title="button.title"
                  :icon="button.icon"
                  :btn-class="button.class"
                  class="timing-diagram-panel-button"
                  :type="button.type"
                  @click="() => {
                    handleButtonClick(button.click)
                  }
                 " />
            </div>
            {{ $t('simulator.panel_body.timing_diagram.one_cycle') }}
            <div>
                <input id="timing-diagram-units" type="number" min="1" autocomplete="off" :value="timingDiagramPanelStore.cycleUnits"
                    @change="handleUnitsChange" @paste="handleUnitsChange" @keyup="handleUnitsChange" />
                {{ $t('simulator.panel_body.timing_diagram.units') }}
            </div>
            <span v-show="simulatorMobileStore.showCanvas" id="timing-diagram-log"></span>
        </div>
        <div id="plot" ref="plotRef">
            <canvas v-show="simulatorMobileStore.showCanvas" id="plotArea" :style="{ height: '100%'}"></canvas>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { onMounted } from 'vue'
import _plotArea from '#/simulator/src/plotArea'
import TimingDiagramButtons from './TimingDiagramButtons.vue'
import { useLayoutStore } from '#/store/layoutStore'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'
import { useTimingDiagramPanelStore } from '#/store/timingDiagramPanelStore'
import { handleButtonClick, handleUnitsChange } from './TimingDiagramPanel'

const layoutStore = useLayoutStore()
const simulatorMobileStore = useSimulatorMobileStore()
const timingDiagramPanelStore = useTimingDiagramPanelStore();

onMounted(() => {
    layoutStore.timingDiagramPanelRef = timingDiagramPanelStore.timingDiagramPanelRef
})
</script>

<style scoped>
.timing-btn-container {
    white-space: nowrap;
    overflow-x: auto;
    scrollbar-width: none;
    -ms-overflow-style: none;
}

.timing-btn-container::-webkit-scrollbar {
    height: 0px;
}

.timing-btn-container::-webkit-scrollbar-thumb {
    background-color: transparent;
    border-radius: 4px;
}

.timing-btn-container::-webkit-scrollbar-track {
    background-color: transparent;
}

.timing-btn-container > * {
    display: inline-block;
}
</style>
