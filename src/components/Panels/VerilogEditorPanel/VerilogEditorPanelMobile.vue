<template>
  <v-dialog
      class="noSelect defaultCursor"
      v-model="simulatorMobileStore.showVerilogPanel"
      :persistent="false"
  >
    <div class="messageBoxContent moduleProperty">
      <div id="moduleProperty-inner">
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

      <div class="text-center">
          {{ $t('simulator.panel_body.verilog_module.apply_themes') }}
      </div>
      <div id="moduleProperty-inner">
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
  </v-dialog>
</template>

<script lang="ts" setup>
import Themes from '../../../assets/constants/Panels/VerilogEditorPanel/THEMES.json'
import {
  saveVerilogCode,
  resetVerilogCode,
  applyVerilogTheme,
} from '#/simulator/src/Verilog2CV'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore';
import { ref, Ref, watch, onMounted } from 'vue'
// import logixFunction from '#/simulator/src/data'

const simulatorMobileStore = useSimulatorMobileStore()

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
    height: auto !important;
    float: none !important;
}
</style>
