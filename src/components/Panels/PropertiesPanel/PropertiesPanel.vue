<template>
    <div
        id="moduleProperty"
        class="moduleProperty noSelect effect1 properties-panel draggable-panel draggable-panel-css guide_2"
    >
        <PanelHeader :header-title="$t('simulator.panel_header.properties')" />
        <div class="panel-body">
            <div id="moduleProperty-inner">
                <div id="moduleProperty-header">{{ panelBodyHeader }}</div>
                <PanelType1 v-if="panelType == 1" />
                <PanelType2 v-if="panelType == 2" />
                <PanelType3
                    v-if="panelType == 3"
                    :key="toRaw(propertiesPanelObj)"
                    :data="toRaw(propertiesPanelObj)"
                />
                <HelpButton
                    :key="toRaw(propertiesPanelObj)"
                    :data="toRaw(propertiesPanelObj)"
                />
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { ref, toRaw } from '@vue/reactivity'
import simulationArea from '#/simulator/src/simulationArea'
import PanelHeader from '../Shared/PanelHeader.vue'
import HelpButton from '../Shared/HelpButton.vue'
import { onMounted } from 'vue'
import {
    checkPropertiesUpdate,
    hideProperties,
    prevPropertyObjGet,
    prevPropertyObjSet,
} from '#/simulator/src/ux'
import { layoutModeGet } from '#/simulator/src/layoutMode'
import PanelType1 from './PanelTypes/PanelType1.vue'
import PanelType2 from './PanelTypes/PanelType2.vue'
import PanelType3 from './PanelTypes/PanelType3.vue'

const panelBodyHeader = ref('PROJECT PROPERTIES')
const propertiesPanelObj = ref(undefined)
const panelType = ref(2) // default is panel type 2 (project properties)
onMounted(() => {
    // checks for which type of properties panel to show
    setInterval(showPropertiesPanel, 100)
})

function showPropertiesPanel() {
    checkPropertiesUpdate()
    if (toRaw(propertiesPanelObj.value) == simulationArea.lastSelected) return
    prevPropertyObjSet(simulationArea.lastSelected)
    propertiesPanelObj.value = simulationArea.lastSelected
    // there are 3 types of panel body for Properties Panel
    // depending upon which is last selected
    // 1. Properties Panel in Layout mode
    // 2. Properties Panel showing Project Properties
    // 3. Properties Panel showing Circiut Element Properties

    if (layoutModeGet()) {
        panelType.value = 1
        // will look into it later !!!
    } else if (
        simulationArea.lastSelected === undefined ||
        ['Wire', 'CircuitElement', 'Node'].indexOf(
            simulationArea.lastSelected.objectType
        ) !== -1
    ) {
        panelType.value = 2
        panelBodyHeader.value = 'PROJECT PROPERTIES'
        if (simulationArea.lastSelected === undefined)
            propertiesPanelObj.value = undefined
    } else {
        panelType.value = 3
        panelBodyHeader.value = propertiesPanelObj.value.objectType
    }
}
</script>
