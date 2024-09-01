import { defineStore } from "pinia";
import { ref } from "vue";
import { tempBuffer } from "#/simulator/src/layoutMode";

export const usePropertiesPanelStore = defineStore("propertiesPanelStore", () => {
  const inLayoutMode = ref(false)
  const panelBodyHeader = ref('PROJECT PROPERTIES')
  const propertiesPanelObj = ref(undefined)
  const panelType = ref(1) // default is panel type 2 (project properties)

  // Layout

  const titleEnable = ref(tempBuffer?.layout?.titleEnabled)
  const layoutDialogRef = ref<HTMLElement | null>(null);

  return {
    inLayoutMode,
    panelBodyHeader,
    propertiesPanelObj,
    panelType,
    titleEnable,
    layoutDialogRef,
  };
});
