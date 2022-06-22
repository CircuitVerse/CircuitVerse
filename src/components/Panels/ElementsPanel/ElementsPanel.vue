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
            <div
                :id="inLayoutMode ? 'subcircuitMenu' : 'menu'"
                class="accordion"
            ></div>
        </div>
    </div>
</template>

<script>
import PanelHeader from '../PanelHeader.vue'
// import { layoutModeGet } from '@/simulator/src/layoutMode';

export default {
    name: 'ElementsPanel',
    components: {
        PanelHeader,
    },
    data() {
        return {
            inLayoutMode: false,
        }
    },
    // computed: {
    //   inLayoutMode: layoutModeGet(),
    // }
}
</script>
