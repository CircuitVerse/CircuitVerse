<template>
  <v-dialog
      v-if="!propertiesPanelStore.inLayoutMode"
      v-model="simulatorMobileStore.showPropertiesPanel"
      :persistent="false"
  >
    <div id="moduleProperty-inner" class="messageBoxContent moduleProperty">
        <div id="moduleProperty-header">{{ propertiesPanelStore.panelBodyHeader }}</div>
        <ProjectProperty v-if="propertiesPanelStore.panelType == 1" />
        <ElementProperty
            v-else-if="propertiesPanelStore.panelType == 2"
            :key="objProperties"
            :obj="objProperties"
        />
        <SubcircuitProperty
            v-else-if="propertiesPanelStore.panelType == 3"
            :key="objProperties"
            :obj="objProperties"
        />
        <HelpButton :key="objProperties" :obj="objProperties" />
    </div>
  </v-dialog>

  <v-dialog
      v-else
      v-model="simulatorMobileStore.showPropertiesPanel"
      :persistent="false"
  >
    <div id="layout-body" class="layout-body panel-body messageBoxContent moduleProperty">
        <div class="">
            <v-btn
                id="decreaseLayoutWidth"
                title="Decrease Width"
                variant="text"
                icon="mdi-minus"
                @click.prevent="layoutFunction('decreaseLayoutWidth')"
            />
            <span>Width</span>
            <v-btn
                id="increaseLayoutWidth"
                title="Increase Width"
                variant="text"
                icon="mdi-plus"
                @click.prevent="layoutFunction('increaseLayoutWidth')"
            />
        </div>
        <div class="">
            <v-btn
                id="decreaseLayoutHeight"
                title="Decrease Height"
                variant="text"
                icon="mdi-minus"
                @click.prevent="layoutFunction('decreaseLayoutHeight')"
            />
            <span>Height</span>
            <v-btn
                id="increaseLayoutHeight"
                title="Increase Height"
                variant="text"
                icon="mdi-plus"
                @click.prevent="layoutFunction('increaseLayoutHeight')"
            />
        </div>
        <div class="">
            <span>Reset all nodes:</span>
            <v-btn
                id="layoutResetNodes"
                variant="text"
                icon="mdi-sync"
                @click.prevent="layoutFunction('layoutResetNodes')"
            />
        </div>
        <div class="layout-title">
            <span>Title</span>
            <div class="layout--btn-group">
                <v-btn
                    id="layoutTitleUp"
                    class="layoutBtn"
                    active-class="no-active"
                    variant="outlined"
                    icon="mdi-chevron-up"
                    @click.prevent="layoutFunction('layoutTitleUp')"
                />
                <v-btn
                    id="layoutTitleDown"
                    class="layoutBtn"
                    variant="outlined"
                    icon="mdi-chevron-down"
                    @click.prevent="layoutFunction('layoutTitleDown')"
                />
                <v-btn
                    id="layoutTitleLeft"
                    class="layoutBtn"
                    variant="outlined"
                    icon="mdi-chevron-left"
                    @click.prevent="layoutFunction('layoutTitleLeft')"
                />
                <v-btn
                    id="layoutTitleRight"
                    class="layoutBtn"
                    variant="outlined"
                    icon="mdi-chevron-right"
                    @click.prevent="layoutFunction('layoutTitleRight')"
                />
            </div>
        </div>
        <div class="layout-title--enable">
            <span>Title Enabled:</span>
            <label class="switch">
                <input
                    id="toggleLayoutTitle"
                    v-model="propertiesPanelStore.titleEnable"
                    type="checkbox"
                />
                <span class="slider"></span>
            </label>
        </div>
        <div class="">
            <button
                id="saveLayout"
                class="Layout-btn custom-btn--primary"
                @click.prevent="layoutFunction('saveLayout')"
            >
                Save
            </button>

            <button
                id="cancelLayout"
                class="Layout-btn custom-btn--tertiary"
                @click.prevent="() => {
                    layoutFunction('cancelLayout')
                    simulatorMobileStore.showPropertiesPanel = false
                    simulatorMobileStore.showCircuits = 'elements'
                }"
            >
                Cancel
            </button>
        </div>
    </div>
  </v-dialog>
</template>

<script lang="ts" setup>
import { toRaw, onMounted, computed } from 'vue'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'
import ProjectProperty from './ModuleProperty/ProjectProperty/ProjectProperty.vue'
import ElementProperty from './ModuleProperty/ElementProperty/ElementProperty.vue'
import SubcircuitProperty from './ModuleProperty/SubcircuitProperty/SubcircuitProperty.vue'
import HelpButton from '../Shared/HelpButton.vue'
import { showPropertiesPanel } from './PropertiesPanel'
import { layoutFunction } from './PropertiesPanel'
import { watch } from 'vue'
import { useLayoutStore } from '#/store/layoutStore'
import { usePropertiesPanelStore } from '#/store/propertiesPanelStore'

const layoutStore = useLayoutStore()
const simulatorMobileStore = useSimulatorMobileStore()
const propertiesPanelStore = usePropertiesPanelStore()

const objProperties = computed(() => toRaw(propertiesPanelStore.propertiesPanelObj))

onMounted(() => {
    layoutStore.layoutDialogRef = propertiesPanelStore.layoutDialogRef;
})

watch(
    () => propertiesPanelStore.titleEnable,
    () => {
        layoutFunction('toggleLayoutTitle')
    }
)

onMounted(() => {
  // checks for which type of properties panel to show
  setInterval(showPropertiesPanel, 100)
})
</script>
