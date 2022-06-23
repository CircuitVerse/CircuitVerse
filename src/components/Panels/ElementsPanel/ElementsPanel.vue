<template>
    <div
        :id="inLayoutMode ? 'guide_1' : ''"
        ref="ElementsPanel"
        class="noSelect defaultCursor draggable-panel draggable-panel-css"
        :class="
            inLayoutMode
                ? 'layoutElementPanel'
                : 'modules ce-panel elementPanel'
        "
    >
        <PanelHeader
            :header-title="
                inLayoutMode ? 'LAYOUT ELEMENTS' : 'CIRCUIT ELEMENTS'
            "
        />
        <div :id="inLayoutMode ? 'testid' : ''" class="panel-body">
            <div v-if="inLayoutMode === false" style="position: relative">
                <input
                    type="text"
                    class="search-input"
                    value=""
                    placeholder="Search.."
                    @keyup="seacrchElements"
                />
                <span><i class="fas search-close fa-times-circle"></i></span>
            </div>
            <div class="search-results"></div>
            <v-expansion-panels
                :id="inLayoutMode ? 'subcircuitMenu' : 'menu'"
                class="accordion"
                variant="accordion"
            >
                <v-expansion-panel
                    v-for="category in panelData"
                    :key="category[0]"
                >
                    <v-expansion-panel-title>
                        {{ category[0] }}
                    </v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <div class="panel customScroll">
                            <div
                                v-for="element in category[1]"
                                :id="element.name"
                                :key="element"
                                title="element.label"
                                class="icon logixModules"
                                @click="createElement(element.name)"
                            >
                                <img
                                    :src="element.imgURL"
                                    :alt="element.name"
                                />
                            </div>
                        </div>
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </div>
    </div>
</template>

<script lang="ts" setup>
import PanelHeader from '@/Panels/PanelHeader.vue'
import metadata from '#/simulator/src/metadata.json'
import simulationArea from '#/simulator/src/simulationArea'
import { uxvar } from '#/simulator/src/ux'
import modules from '#/simulator/src/modules'
import { onBeforeMount, ref } from 'vue'
var inLayoutMode = ref(false)
var panelData = []
window.elementHierarchy = metadata.elementHierarchy
window.elementPanelList = []

onBeforeMount(() => {
    for (const category in elementHierarchy) {
        var categoryData = []
        for (let i = 0; i < elementHierarchy[category].length; i++) {
            const element = elementHierarchy[category][i]
            console.log(element)
            if (!element.name.startsWith('verilog')) {
                window.elementPanelList.push(element.label)
                element['imgURL'] = getImgUrl(element.name)
                categoryData.push(element)
            }
        }
        panelData.push([category, categoryData])
    }
})

function getImgUrl(elementName) {
    const elementImg = new URL(
        `../../../assets/img/${elementName}.svg`,
        import.meta.url
    ).href
    console.log(elementImg)
    return elementImg
}

function createElement(elementName) {
    if (simulationArea.lastSelected && simulationArea.lastSelected.newElement)
        simulationArea.lastSelected.delete()
    var obj = new modules[elementName]()
    simulationArea.lastSelected = obj
    uxvar.smartDropXX += 70
    if (uxvar.smartDropXX / globalScope.scale > width) {
        uxvar.smartDropXX = 50
        uxvar.smartDropYY += 80
    }
}

function seacrchElements() {
    console.log('Searching ...')
    // logic to be imported from listener.js
}
</script>

<style scoped></style>
