import { simulationArea } from "#/simulator/src/simulationArea"
import modules from "#/simulator/src/modules"
import { uxvar } from "#/simulator/src/ux"

export function createElement(elementName: string) {
  if (simulationArea.lastSelected?.newElement)
      simulationArea.lastSelected.delete()
  var obj = new modules[elementName]()
  simulationArea.lastSelected = obj
  uxvar.smartDropXX += 70
  if (uxvar.smartDropXX / globalScope.scale > width) {
      uxvar.smartDropXX = 50
      uxvar.smartDropYY += 80
  }
}

export function getImgUrl(elementName: string) {
  try {
    const elementImg = new URL(`../../../assets/img/${elementName}.svg`, import.meta.url).href;
    return elementImg;
  } catch (e) {
    console.error("Error loading image:", e);
    return '';
  }
}
