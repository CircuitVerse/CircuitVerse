import { checkPropertiesUpdate } from "#/simulator/src/ux"
import { toRaw } from "vue"
import { layoutModeGet } from "#/simulator/src/layoutMode"
import { simulationArea } from "#/simulator/src/simulationArea"
import { prevPropertyObjSet } from "#/simulator/src/ux"
import { usePropertiesPanelStore } from "#/store/propertiesPanelStore"
import { layoutFunctions } from "#/simulator/src/layoutMode"
import { scheduleUpdate } from "#/simulator/src/engine"
import { toRefs } from "vue"

export function showPropertiesPanel() {
  const propertiesPanelStore = toRefs(usePropertiesPanelStore());

  if (propertiesPanelStore.inLayoutMode.value != layoutModeGet())
      propertiesPanelStore.inLayoutMode.value = layoutModeGet()
  checkPropertiesUpdate()
  if (toRaw(propertiesPanelStore.propertiesPanelObj.value) == simulationArea.lastSelected) return
  prevPropertyObjSet(simulationArea.lastSelected)
  propertiesPanelStore.propertiesPanelObj.value = simulationArea.lastSelected
  if(simulationArea.lastSelected && simulationArea.lastSelected.newElement) {
      simulationArea.lastSelected.label = ""
  }
  // there are 3 types of panel body for Properties Panel
  // depending upon which is last selected
  // 1. Properties Panel in Layout mode
  // 2. Properties Panel showing Project Properties
  // 3. Properties Panel showing Circiut Element Properties
  if (propertiesPanelStore.inLayoutMode.value) {
      // will look into it later !!!
      if (
          simulationArea.lastSelected === undefined ||
          ['Wire', 'CircuitElement', 'Node'].indexOf(
              simulationArea.lastSelected.objectType
          ) !== -1
      ) {
          propertiesPanelStore.panelType.value = 1
          // when we cancel layout mode -> show project properties
      } else {
          propertiesPanelStore.panelType.value = 3
          propertiesPanelStore.panelBodyHeader.value = propertiesPanelStore.propertiesPanelObj.value.objectType
      }
  } else {
      if (
          simulationArea.lastSelected === undefined ||
          ['Wire', 'CircuitElement', 'Node'].indexOf(
              simulationArea.lastSelected.objectType
          ) !== -1
      ) {
          propertiesPanelStore.panelType.value = 1
          propertiesPanelStore.panelBodyHeader.value = 'PROJECT PROPERTIES'
          if (simulationArea.lastSelected === undefined)
              propertiesPanelStore.propertiesPanelObj.value = undefined
      } else {
          propertiesPanelStore.panelType.value = 2
          propertiesPanelStore.panelBodyHeader.value = propertiesPanelStore.propertiesPanelObj.value.objectType
      }
  }
}

export function layoutFunction(func: string) {
    if (!layoutFunctions[func]) {
        throw new Error(`Function \`${func}\` not found in layoutFunctions.`);
    }
    layoutFunctions[func]()
    scheduleUpdate()
}
