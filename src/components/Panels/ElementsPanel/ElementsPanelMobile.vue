<template>
  <div
      class="noSelect defaultCursor draggable-panel-mobile draggable-panel-css modules ce-panel elementPanel elementsPanelMobile"
      :style="{bottom: simulatorMobileStore.showElementsPanel ? '0' : '-12rem'}"
  >
      <div class="panel-body" style="padding: 0;">
          <div style="position: relative" class="search-container">
              <input
                  v-model="elementInput"
                  type="text"
                  class="search-input mobile-search"
                  :placeholder="
                      $t('simulator.panel_body.circuit_elements.search')
                  "
              />
              <span
                  ><i
                      v-if="elementInput"
                      class="fas search-close fa-times-circle"
                      @click="elementInput = ''"
                  ></i
              ></span>
          </div>

          <div v-if="simulatorMobileStore.showCircuits === 'elements'" class="element-category-tabs">
            <div
              v-for="category in panelData" :key="category[0]"
              class="element-category-tab" @mousedown="selectCategory(category[1], category[0])"
              :style="{backgroundColor: selectedCategoryName === category[0] ? 'var(--primary)' : '#eee', color: selectedCategoryName === category[0] ? 'white' : 'black'}"
            >
              {{ category[0] }}
            </div>
          </div>

          <div v-if="simulatorMobileStore.showCircuits === 'elements'" class="mobile-icons">
            <div>
            <div
              v-for="element in filteredElements"
              :id="element.name"
              :key="element.name"
              :title="element.label"
              class="icon logixModules"
              @click="createElement(element.name)"
              @mousedown="createElement(element.name)"
              @mouseover="getTooltipText(element.name)"
              @mouseleave="tooltipText = ''"
            >
              <img
                :src="element.imgURL"
                :alt="element.name"
              />
            </div>
            </div>
          </div>

          <div v-if="simulatorMobileStore.showCircuits === 'layout-elements'" class="element-category-tabs tabs-layout">
            <div
              v-for="(group, groupIndex) in SimulatorState.subCircuitElementList" :key="groupIndex"
              class="element-category-tab" @mousedown="selectCategory(group.elements, group.type, 'layout-elements')"
              :style="{backgroundColor: selectedLayoutCategoryName === group.type ? 'var(--primary)' : '#eee', color: selectedLayoutCategoryName === group.type ? 'white' : 'black'}"
            >
            {{ group.type }}s
            </div>
          </div>

          <div v-if="simulatorMobileStore.showCircuits === 'layout-elements'" class="mobile-icons">
            <div class="panel">
            <div
              v-for="(element, elementIndex) in filteredLayoutElements"
              :key="`${elementIndex}-${elementIndex}`"
              :id="`${element.type}-${elementIndex}`"
              :data-element-id="elementIndex"
              :data-element-name="element.type"
              class="icon subcircuitModule"
              @mousedown="dragElement(selectedLayoutCategoryName, element, elementIndex)"
            >
              <div class="icon-image">
                <img :src="getImgUrl(element.constructor.name)" />
                <p class="img__description">
                  {{ element.label !== '' ? element.label : $t('simulator.unlabeled') }}
                </p>
              </div>
            </div>
            </div>
          </div>

          <!-- <div
              id="Help"
              lines="one"
              :class="tooltipText != 'null' ? 'show' : ''"
          >
              {{ tooltipText }}
          </div> -->

        </div>
      </div>
</template>

<script lang="ts" setup>
import { elementHierarchy } from '#/simulator/src/metadata'
import { simulationArea } from '#/simulator/src/simulationArea'
import { createElement, getImgUrl } from './ElementsPanel'
import modules from '#/simulator/src/modules'
import { onBeforeMount, onMounted, ref, computed, watch } from 'vue'
import { useLayoutStore } from '#/store/layoutStore'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'
import { useState } from '#/store/SimulatorStore/state'
import { ElementsType } from '#/store/simulatorMobileStore'

var panelData = []
window.elementPanelList = []
const layoutStore = useLayoutStore()
const simulatorMobileStore = useSimulatorMobileStore()
const SimulatorState = useState()

const elementsPanelRef = ref<HTMLElement | null>(null);
const selectedCategory = ref<any[] | null>(null)
const selectedLayoutCategory = ref<any[] | null>(null)
const selectedCategoryName = ref('Input')
const selectedLayoutCategoryName = ref<string | null>(null)

onBeforeMount(() => {
  for (const category in elementHierarchy) {
      var categoryData = []
      for (let i = 0; i < elementHierarchy[category].length; i++) {
          const element = elementHierarchy[category][i]
          if (!element.name.startsWith('verilog')) {
              window.elementPanelList.push(element.label)
              element['imgURL'] = getImgUrl(element.name)
              categoryData.push(element)
          }
      }
      panelData.push([category, categoryData])
  }
})

onMounted(() => {
  layoutStore.elementsPanelRef = elementsPanelRef.value

  if (SimulatorState.subCircuitElementList.length > 0) {
    selectedLayoutCategory.value = SimulatorState.subCircuitElementList[0].elements
    selectedLayoutCategoryName.value = SimulatorState.subCircuitElementList[0].type
  }
})

watch(() => simulatorMobileStore.showCircuits, () => {{
  if(simulatorMobileStore.showCircuits === 'layout-elements') {
    selectedLayoutCategory.value = (SimulatorState.subCircuitElementList && SimulatorState.subCircuitElementList.length > 0) ? SimulatorState.subCircuitElementList[0].elements : []
    selectedLayoutCategoryName.value = (SimulatorState.subCircuitElementList && SimulatorState.subCircuitElementList.length > 0) ? SimulatorState.subCircuitElementList[0].type : null
  }
}})

watch(() => SimulatorState.subCircuitElementList, (newVal) => {
  const currSelectedType = selectedLayoutCategoryName.value
  if (currSelectedType) {
    const newSelectedType = newVal.find((typeGroup) => typeGroup.type === currSelectedType)
    selectedLayoutCategory.value = newSelectedType ? newSelectedType.elements : []
    selectedLayoutCategoryName.value = newSelectedType ? newSelectedType.type : null
  }
})

const dragElement = (groupType: string | null, element: any, index: number) => {
  element.subcircuitMetadata.showInSubcircuit = true
  element.newElement = true
  simulationArea.lastSelected = element

  SimulatorState.subCircuitElementList.forEach((typeGroup) => {
    typeGroup.elements = typeGroup.elements.filter(
      (_, elementIndex) => {
        if(typeGroup.type === groupType && index === elementIndex)
        return false

        return true;
      }
    )
  })

  SimulatorState.subCircuitElementList =
    SimulatorState.subCircuitElementList.filter(
      (typeGroup) => typeGroup.elements.length > 0
    )

  const elIndex = SimulatorState.subCircuitElementList.findIndex((typeGroup) => typeGroup.type === groupType)

  if (elIndex === -1) {
    selectedLayoutCategory.value = (SimulatorState.subCircuitElementList && SimulatorState.subCircuitElementList.length > 0)
      ? SimulatorState.subCircuitElementList[0].elements
      : [];

    selectedLayoutCategoryName.value = (SimulatorState.subCircuitElementList && SimulatorState.subCircuitElementList.length > 0) ? SimulatorState.subCircuitElementList[0].type : null;
  }
}

const filteredElements = computed(() => {
  const elements = selectedCategory.value ? selectedCategory.value : panelData[0][1]
  return elements.filter(element => {
    const elementNameLower = element.name.toLowerCase()
    const elementInputLower = elementInput.value.toLowerCase()
    return elementNameLower.includes(elementInputLower)
  })
})

const filteredLayoutElements = computed(() => {
  const elements = selectedLayoutCategory.value ? selectedLayoutCategory.value : (SimulatorState.subCircuitElementList && SimulatorState.subCircuitElementList.length > 0) ? SimulatorState.subCircuitElementList[0].elements : []

  return elements.filter(element => {
    const elementNameLower = element.constructor.name.toLowerCase()
    const elementInputLower = elementInput.value.toLowerCase()
    return elementNameLower.includes(elementInputLower)
  })
})

function selectCategory(categoryData, categoryName, type: ElementsType = 'elements') {
  if (type === 'elements') {
    selectedCategory.value = categoryData
    selectedCategoryName.value = categoryName
  }
  else {
    selectedLayoutCategory.value = categoryData
    selectedLayoutCategoryName.value = categoryName
  }
}

var elementInput = ref('')

const tooltipText = ref('null')
function getTooltipText(elementName: string) {
  tooltipText.value = modules[elementName].prototype.tooltipText
}
</script>

<style scoped>
.elementsPanelMobile{
  top: unset !important;
  left: 0;
  width: 100%;
  transition: all 0.3s;
}

.element-category-tabs {
    display: flex;
    padding: 0 10px;
    overflow-x: scroll;
    white-space: nowrap;
    justify-content: space-between;
    gap: 0.5rem;
}

.element-category-tabs::-webkit-scrollbar, .mobile-icons::-webkit-scrollbar {
    height: 0px;
}

.element-category-tabs::-webkit-scrollbar-thumb, .mobile-icons::-webkit-scrollbar-thumb {
    background-color: transparent;
    border-radius: 4px;
}

.element-category-tabs::-webkit-scrollbar-track, .mobile-icons::-webkit-scrollbar-track {
    background-color: transparent;
}

.element-category-tabs, .mobile-icons {
    scrollbar-width: none;
    scrollbar-color: transparent transparent;
}

.element-category-tab {
    padding: 10px 0;
    cursor: pointer;
    width: 7.5rem;
    font-size: 0.75rem;
    flex-shrink: 0;
    display: flex;
    justify-content: center;
    align-items: center;
}

.tabs-layout {
  justify-content: start;
}

.mobile-icons{
    display: flex;
    justify-content: space-between;
    gap: 0.1rem;
    overflow-x: auto;
    white-space: nowrap;
}

.mobile-icons .icon{
    width: 50px;
    height: 50px;
    margin: 10px;
    cursor: pointer;
    flex-shrink: 0;
}

.mobile-search {
    width: 98vw;
    margin: 0;
    color: black;
}

.search-container {
    padding: 0.5rem;
    color: black;
}

.img__description {
  position: absolute;
  bottom: -16;
  text-align: center;
  left: 0;
  right: 0;
  background-color: grey;
  color: white;
  font-size: 8px;
  visibility: hidden;
  border-bottom-left-radius: 2px;
  border-bottom-right-radius: 2px;
  opacity: 0;
  transition: opacity 0.2s, visibility 0.2s;
}

.icon:hover .img__description {
  visibility: visible;
  opacity: 1;
}
</style>
