<template>
    <div class="timing-diagram-panel draggable-panel" ref="timingDiagramPanelRef" id="time-Diagram">
        <!-- Timing Diagram Panel -->
        <PanelHeader
            :header-title="$t('simulator.panel_header.timing_diagram')"
        />
        <div class="panel-body">
            <div class="timing-diagram-toolbar noSelect">
                <TimingDiagramButtons
                    v-for="button in timingDiagramPanelStore.buttons"
                    :key="button.title"
                    :title="button.title"
                    :icon="button.icon"
                    :btn-class="button.class"
                    class="timing-diagram-panel-button"
                    :type="button.type"
                    @click="
                        () => {
                            handleButtonClick(button.click)
                        }
                    "
                />
                {{ $t('simulator.panel_body.timing_diagram.one_cycle') }}
                <input
                    id="timing-diagram-units"
                    type="number"
                    min="1"
                    autocomplete="off"
                    :value="timingDiagramPanelStore.cycleUnits"
                    @change="handleUnitsChange"
                    @paste="handleUnitsChange"
                    @keyup="handleUnitsChange"
                />
                {{ $t('simulator.panel_body.timing_diagram.units') }}
                <span id="timing-diagram-log"></span>
            </div>
            <div id="plot" ref="plotRef">
                <canvas id="plotArea"></canvas>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { onMounted } from 'vue'
import _plotArea from '#/simulator/src/plotArea'
import TimingDiagramButtons from './TimingDiagramButtons.vue'
import PanelHeader from '../Shared/PanelHeader.vue'
import { handleButtonClick, handleUnitsChange } from './TimingDiagramPanel'
import { useLayoutStore } from '#/store/layoutStore'
import { useTimingDiagramPanelStore } from '#/store/timingDiagramPanelStore'

const layoutStore = useLayoutStore()
const timingDiagramPanelStore = useTimingDiagramPanelStore();

onMounted(() => {
    layoutStore.timingDiagramPanelRef = timingDiagramPanelStore.timingDiagramPanelRef
})
</script>

<style>
.timing-diagram-panel-button {
    margin-right: 5px;
}
</style>

<!-- TODO: input element to vue, remove remaining dom manipulation, header component -->
