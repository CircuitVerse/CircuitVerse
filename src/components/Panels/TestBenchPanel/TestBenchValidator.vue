<template>
  <v-dialog v-model="showValidator" :persistent="false">
    <v-card class="messageBoxContent">
      <v-card-text>
        <p class="dialogHeader validatorHeader">Testbench Validator</p>
        <v-btn size="x-small" icon class="dialogClose" @mousedown="closeDialog">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-card-text>
      <v-card-text v-if="testBenchStore.validationErrors.ok" class="validBox">
        <div>
          <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" fill="white" class="bi bi-check"
            viewBox="0 0 16 16">
            <path
              d="M10.97 4.97a.75.75 0 0 1 1.07 1.05l-3.99 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.267.267 0 0 1 .02-.022z" />
          </svg>
        </div>
        All good. No validation errors
      </v-card-text>

      <v-card-text v-else class="inValidBox">
        <p>Please fix these errors to run tests</p>
        <table class="validation-ui-table">
          <tr>
            <th><b>Identifier</b></th>
            <th><b>Error</b></th>
          </tr>
          <tr v-for="vError in testBenchStore.validationErrors.invalids" :key="vError.identifier">
            <td>{{ vError.identifier }}</td>
            <td>{{ vError.message }}</td>
          </tr>
        </table>
      </v-card-text>
      <v-card-actions>
        <v-btn class="messageBtn" block @mousedown="closeDialog">Ok</v-btn>
        <v-btn class="messageBtn" block @mousedown="handleAutoFix">Auto Fix</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts" setup>
import { useTestBenchStore, ValidationErrors } from '#/store/testBenchStore';
import { VALIDATION_ERRORS } from '#/simulator/src/testbench';
import { showMessage } from '#/simulator/src/utils';
import { computed } from 'vue';

const testBenchStore = useTestBenchStore();

const showValidator = computed(() => testBenchStore.showTestBenchValidator);

const handleAutoFix = () => {
  const fixedErrors = validationAutoFix(testBenchStore.validationErrors);
  showMessage(`Testbench: Auto fixed ${fixedErrors} errors`)
}

const closeDialog = () => {
  testBenchStore.showTestBenchValidator = false;
}

/**
 * Autofix whatever is possible in validation errors.
 * returns number of autofixed errors
 */
function validationAutoFix(validationErrors: ValidationErrors) {
  // Currently only autofixes bitwidths
  let fixedErrors = 0
  // Return if no errors
  if (validationErrors.ok) return fixedErrors

  const bitwidthErrors = validationErrors?.invalids?.filter(
    (vError) => vError.type === VALIDATION_ERRORS.WRONGBITWIDTH
  )

  bitwidthErrors?.forEach((bwError) => {
    const { element, expectedBitWidth } = bwError.extraInfo
    element.newBitWidth(expectedBitWidth)
    fixedErrors++
  })

  return fixedErrors
}
</script>

<style scoped>
.validBox {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  padding-top: 0 !important;
  padding-bottom: 1.5rem !important;
}

.inValidBox{
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.validatorHeader{
  margin-bottom: 0rem !important;
}
</style>
