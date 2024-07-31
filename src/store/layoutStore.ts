import { defineStore } from "pinia";
import { ref, Ref, watch } from "vue";

export const useLayoutStore = defineStore("layoutStore", () => {
  const layoutMode = ref(false);
  const layoutDialogRef: Ref<HTMLElement | null> = ref(null);
  const layoutElementPanelRef: Ref<HTMLElement | null> = ref(null);
  const elementsPanelRef: Ref<HTMLElement | null> = ref(null);
  const timingDiagramPanelRef: Ref<HTMLElement | null> = ref(null);
  const testbenchPanelRef: Ref<HTMLElement | null> = ref(null);

  watch(layoutMode, (val) => {
    if (val) {
      fadeIn(layoutDialogRef.value);
      fadeIn(layoutElementPanelRef.value);
      fadeOut(elementsPanelRef.value);
      fadeOut(timingDiagramPanelRef.value);
      fadeOut(testbenchPanelRef.value);
    } else {
      fadeOut(layoutDialogRef.value);
      fadeOut(layoutElementPanelRef.value);
      fadeIn(elementsPanelRef.value);
      fadeIn(timingDiagramPanelRef.value);
      fadeIn(testbenchPanelRef.value);
    }
  });

  function fadeIn(element: HTMLElement | null, duration = 200) {
    if (!element) return;
    element.style.display = "block";
    element.style.opacity = "0";
    let startTime: number | null = null;

    function animate(currentTime: number | null) {
      if (!startTime) {
        startTime = currentTime;
      }

      const elapsedTime = (currentTime ?? 0) - (startTime ?? 0);
      const newOpacity = elapsedTime / duration;

      element!.style.opacity = newOpacity > 1 ? "1" : newOpacity.toString();

      if (elapsedTime < duration) {
        requestAnimationFrame(animate);
      }
    }

    requestAnimationFrame(animate);
  }

  function fadeOut(element: HTMLElement | null, duration = 200) {
    if (!element) return;
    let startTime: number | null = null;

    function animate(currentTime: number | null) {
      if (!startTime) {
        startTime = currentTime;
      }

      const elapsedTime = (currentTime ?? 0) - (startTime ?? 0);
      const newOpacity = 1 - elapsedTime / duration;

      element!.style.opacity = newOpacity < 0 ? "0" : newOpacity.toString();

      if (elapsedTime < duration) {
        requestAnimationFrame(animate);
      } else {
        element!.style.display = "none";
      }
    }

    requestAnimationFrame(animate);
  }

  return {
    layoutMode,
    layoutDialogRef,
    layoutElementPanelRef,
    elementsPanelRef,
    timingDiagramPanelRef,
    testbenchPanelRef,
  };
});