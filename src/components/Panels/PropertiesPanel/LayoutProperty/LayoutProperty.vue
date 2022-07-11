<template>
    <div id="layoutDialog" class="draggable-panel draggable-panel-css">
        <PanelHeader :header-title="$t('simulator.panel_header.layout')" />
        <div id="layout-body" class="layout-body panel-body">
            <div class="">
                <button
                    id="decreaseLayoutWidth"
                    class="zoomButton btn-lg"
                    title="Decrease Width"
                >
                    <span class="fa fa-minus" aria-hidden="true"></span>
                </button>
                <span>Width</span>
                <button
                    id="increaseLayoutWidth"
                    class="zoomButton btn-lg"
                    title="Increase Width"
                >
                    <span class="fa fa-plus" aria-hidden="true"></span>
                </button>
            </div>
            <div class="">
                <button
                    id="decreaseLayoutHeight"
                    class="zoomButton btn-lg"
                    title="Decrease Height"
                >
                    <span class="fa fa-minus" aria-hidden="true"></span>
                </button>
                <span>Height</span>
                <button
                    id="increaseLayoutHeight"
                    class="zoomButton btn-lg"
                    title="Increase Height"
                >
                    <span class="fa fa-plus" aria-hidden="true"></span>
                </button>
            </div>
            <div class="">
                <span>Reset all nodes:</span>
                <v-btn id="layoutResetNodes" variant="text" icon>
                    <v-icon>mdi-sync</v-icon>
                </v-btn>
            </div>
            <div class="layout-title">
                <span>Title</span>
                <div class="layout--btn-group">
                    <v-btn
                        id="layoutTitleUp"
                        class="layoutBtn"
                        active-class="no-active"
                        variant="outlined"
                        icon
                        ><v-icon>mdi-chevron-up</v-icon></v-btn
                    >
                    <v-btn
                        id="layoutTitleDown"
                        class="layoutBtn"
                        variant="outlined"
                        icon
                        ><v-icon>mdi-chevron-down</v-icon></v-btn
                    >
                    <v-btn
                        id="layoutTitleLeft"
                        class="layoutBtn"
                        variant="outlined"
                        icon
                        ><v-icon>mdi-chevron-left</v-icon></v-btn
                    >
                    <v-btn
                        id="layoutTitleRight"
                        class="layoutBtn"
                        variant="outlined"
                        icon
                        ><v-icon>mdi-chevron-right</v-icon></v-btn
                    >
                </div>
            </div>
            <div class="layout-title--enable">
                <span>Title Enabled:</span>
                <label class="switch">
                    <input id="toggleLayoutTitle" type="checkbox" checked />
                    <span class="slider"></span>
                </label>
            </div>
            <div class="">
                <button id="saveLayout" class="Layout-btn custom-btn--primary">
                    Save
                </button>

                <button
                    id="cancelLayout"
                    class="Layout-btn custom-btn--tertiary"
                >
                    Cancel
                </button>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { setupLayoutModePanelListeners } from '#/simulator/src/layoutMode'
import { onMounted } from '@vue/runtime-core'
import PanelHeader from '../../Shared/PanelHeader.vue'

onMounted(() => {
    setupLayoutModePanelListeners()
})
</script>

<style scoped>
.v-btn.layoutBtn {
    margin: 7px 5px 0px 5px;
    width: 30px;
    height: 30px;
    border: 2px solid white;
    border-radius: 0.6rem;
}
.v-btn.layoutBtn:active {
    border: 2px solid white;
}

.layout--btn-group {
    margin-right: 0;
}
</style>
