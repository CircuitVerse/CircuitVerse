<template>
    <div id="code-window" class="code-window">
        <textarea id="codeTextArea"></textarea>
    </div>
    <div
        id="verilogEditorPanel"
        class="noSelect defaultCursor draggable-panel draggable-panel-css"
    >
        <PanelHeader
            :header-title="$t('simulator.panel_header.verilog_module')"
        />

        <div class="panel-body">
            <div class="layout-body">
                <button
                    class="largeButton btn btn-xs custom-btn--tertiary"
                    @click="resetVerilogCode"
                >
                    {{ $t('simulator.panel_body.verilog_module.reset_code') }}
                </button>
                <button
                    class="largeButton btn btn-xs custom-btn--primary"
                    @click="saveVerilogCode"
                >
                    {{ $t('simulator.panel_body.verilog_module.save_code') }}
                </button>
                <div id="verilogOutput">
                    {{
                        $t(
                            'simulator.panel_body.verilog_module.module_in_experiment_notice'
                        )
                    }}
                </div>
            </div>
        </div>

        <div class="panel-header text-center">
            {{ $t('simulator.panel_body.verilog_module.apply_themes') }}
        </div>
        <div class="panel-body">
            <div class="layout-body">
                <div>
                    <p class="text-center mb-2">
                        {{
                            $t(
                                'simulator.panel_body.verilog_module.select_theme'
                            )
                        }}
                    </p>
                    <select v-model="selectedTheme" class="applyTheme">
                        <optgroup
                            v-for="optgroup in Themes"
                            :key="optgroup.label"
                            :label="optgroup.label"
                        >
                            <option
                                v-for="option in optgroup.options"
                                :key="option.value"
                            >
                                {{ option.value }}
                            </option>
                        </optgroup>
                    </select>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import Themes from '../../../assets/constants/Panels/VerilogEditorPanel/THEMES.json'
import {
    saveVerilogCode,
    resetVerilogCode,
    applyVerilogTheme,
} from '#/simulator/src/Verilog2CV'
import PanelHeader from '../Shared/PanelHeader.vue'
import { ref, Ref, watch, onMounted } from 'vue'
// import logixFunction from '#/simulator/src/data'

const selectedTheme: Ref<string> = ref(
    localStorage.getItem('verilog-theme') || 'default'
)

onMounted(() => {
    const savedTheme = localStorage.getItem('verilog-theme')
    if (savedTheme) {
        selectedTheme.value = savedTheme
    }
})

watch(selectedTheme, (newTheme: string) => {
    applyVerilogTheme(newTheme)
})
</script>

<style scoped>
.applyTheme {
    width: 90%;
    border: 1px solid #fff;
    padding: 8px;
}
</style>
