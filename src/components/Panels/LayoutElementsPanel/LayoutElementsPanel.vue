<template>
  <div class="noSelect defaultCursor layoutElementPanel draggable-panel draggable-panel-css"
    ref="layoutElementPanelRef">
    <div class="panel-header">
      {{ $t('simulator.layout.layout_elements') }}
      <span class="fas fa-minus-square minimize"></span>
      <span class="fas fa-external-link-square-alt maximize"></span>
    </div>
    <div class="panel-body">
      <v-expansion-panels id="menu" class="accordion" variant="accordion">
        <v-expansion-panel v-for="(group, groupIndex) in SimulatorState.subCircuitElementList" :key="groupIndex">
          <v-expansion-panel-title>
            {{ group.type }}s
          </v-expansion-panel-title>
          <v-expansion-panel-text eager>
            <div class="panel customScroll">
              <div v-for="(element, elementIndex) in group.elements" class="icon subcircuitModule"
              :key="`${groupIndex}-${elementIndex}`" :id="`${group.type}-${elementIndex}`"
              :data-element-id="elementIndex" :data-element-name="group.type"
              @mousedown="dragElement(group.type, element, elementIndex)">
              <div class="icon-image">
                <img :src="getImgUrl(group.type)" />
                <p class="img__description">
                  {{ element.label !== '' ? element.label : $t('simulator.unlabeled') }}
                </p>
              </div>
              </div>
            </div>
          </v-expansion-panel-text>
        </v-expansion-panel>
      </v-expansion-panels>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useState } from '#/store/SimulatorStore/state'
import { simulationArea } from '#/simulator/src/simulationArea'
import { useLayoutStore } from '#/store/layoutStore';
import { ref, onMounted } from 'vue';

const layoutStore = useLayoutStore()

const layoutElementPanelRef = ref<HTMLElement | null>(null);

onMounted(() => {
    layoutStore.layoutElementPanelRef = layoutElementPanelRef.value
})

const SimulatorState = useState();

const dragElement = (groupType: string, element: any, index: number) => {
  element.subcircuitMetadata.showInSubcircuit = true
  element.newElement = true
  simulationArea.lastSelected = element

  // Remove the element from subCircuitElementList
  SimulatorState.subCircuitElementList.forEach((typeGroup) => {
    typeGroup.elements = typeGroup.elements.filter(
      (_, elementIndex) => {
        if(typeGroup.type === groupType && index === elementIndex)
        return false

        return true;
      }
    )
  })

  // Remove the type group if its elements array is empty
  SimulatorState.subCircuitElementList =
    SimulatorState.subCircuitElementList.filter(
      (typeGroup) => typeGroup.elements.length > 0
    )
}

function getImgUrl(elementName: string) {
  const elementImg = new URL(
    `../../../simulator/src/img/${elementName}.svg`,
    import.meta.url
  ).href;
  return elementImg;
}
</script>

<style scoped>

.layoutElementPanel {
  width: 220px;
  font: inherit;
  display: none;
  top: 90px;
  left: 10px;
}
</style>
