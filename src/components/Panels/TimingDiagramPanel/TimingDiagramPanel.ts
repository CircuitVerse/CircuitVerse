import { timingDiagramButtonActions } from '#/simulator/src/plotArea'
import _plotArea from '#/simulator/src/plotArea'
import { toRefs } from 'vue'
import { useTimingDiagramPanelStore } from '#/store/timingDiagramPanelStore'

interface PlotArea {
  resize: () => void
  [key: string]: () => void
}

export const plotArea: PlotArea = _plotArea

export function handleButtonClick(button: string) {
  const timingDiagramPanelStore = toRefs(useTimingDiagramPanelStore());
  if (button === 'smaller') {
      if (timingDiagramPanelStore.plotRef.value) {
          timingDiagramPanelStore.plotRef.value.style.width = `${Math.max(
              timingDiagramPanelStore.plotRef.value.offsetWidth - 20,
              560
          )}px`
      }
      plotArea.resize()
  } else if (button === 'larger') {
      if (timingDiagramPanelStore.plotRef.value) {
          timingDiagramPanelStore.plotRef.value.style.width = `${timingDiagramPanelStore.plotRef.value.offsetWidth + 20}px`
      }
      plotArea.resize()
  } else if (button === 'smallHeight') {
      timingDiagramButtonActions.smallHeight()
  } else if (button === 'largeHeight') {
      timingDiagramButtonActions.largeHeight()
  } else {
      plotArea[button]()
  }
}

export function handleUnitsChange(event: Event) {
  const inputElem = event.target as HTMLInputElement
  const timeUnits = parseInt(inputElem.value, 10)
  if (Number.isNaN(timeUnits) || timeUnits < 1) return
  plotArea.cycleUnit = timeUnits
}