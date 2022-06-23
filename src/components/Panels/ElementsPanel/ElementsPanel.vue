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
                    v-for="category in [
                        'Input',
                        'Output',
                        'Gates',
                        'Decoder & Plexer',
                        'Sequentian Elements',
                        'Annotation',
                        'Misc',
                    ]"
                    :key="category"
                >
                    <v-expansion-panel-title>
                        {{ category }}
                    </v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <h2>Hello from {{ category }}</h2>
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </div>
    </div>
</template>

<script lang="ts" setup>
import PanelHeader from '@/Panels/PanelHeader.vue'
import metadata from '#/simulator/src/metadata'
import { ref } from 'vue'
var inLayoutMode = ref(false)
</script>

<style scoped></style>
