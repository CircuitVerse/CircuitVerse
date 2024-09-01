import { defineStore } from "pinia";
import { ref } from "vue";
import buttonsJSON from '#/assets/constants/Panels/TimingDiagramPanel/buttons.json'

export interface TimingDiagramButton {
  title: string
  icon: string
  class: string
  type: string
  click: string
}

export const useTimingDiagramPanelStore = defineStore("timingDiagramPanelStore", () => {
  const buttons = ref<TimingDiagramButton[]>(buttonsJSON)
  const plotRef = ref<HTMLElement | null>(null)
  const cycleUnits = ref(1000)
  const timingDiagramPanelRef = ref<HTMLElement | null>(null);

  return {
    buttons,
    plotRef,
    cycleUnits,
    timingDiagramPanelRef
  };
});
