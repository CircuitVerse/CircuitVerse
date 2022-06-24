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
                    v-model="elementInput"
                    type="text"
                    class="search-input"
                    placeholder="Search.."
                />
                <span
                    ><i
                        v-if="elementInput"
                        class="fas search-close fa-times-circle"
                        @click="elementInput = ''"
                    ></i
                ></span>
            </div>
            <div
                v-if="elementInput && searchElements().length"
                class="search-results"
            >
                <div
                    v-for="element in searchElements()"
                    :id="element.name"
                    :key="element.name"
                    title="element.label"
                    class="icon logixModules"
                    @click="createElement(element.name)"
                >
                    <img :src="element.imgURL" :alt="element.name" />
                </div>
            </div>
            <div
                v-if="elementInput && !searchElements().length"
                class="search-results"
            >
                No elements found...
            </div>
            <v-expansion-panels
                v-if="!elementInput"
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
    return elementImg
}

var elementInput = ref('')
function searchElements() {
    if (!elementInput) return []
    // logic to be imported from listener.js

    const result = elementPanelList.filter((ele) =>
        ele.toLowerCase().includes(elementInput.value)
    )
    var finalResult = []
    for (const j in result) {
        if (Object.prototype.hasOwnProperty.call(result, j)) {
            for (const category in elementHierarchy) {
                if (
                    Object.prototype.hasOwnProperty.call(
                        elementHierarchy,
                        category
                    )
                ) {
                    const categoryData = elementHierarchy[category]
                    for (let i = 0; i < categoryData.length; i++) {
                        if (result[j] == categoryData[i].label) {
                            finalResult.push(categoryData[i])
                        }
                    }
                }
            }
        }
    }
    return finalResult
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
</script>

<style scoped></style>
